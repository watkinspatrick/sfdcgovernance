# Treating Permissions as Data for Analysis
In the course, we discuss using other skillset other than your traditional Salesforce Developer or Administrator to streamline, untangle and analyze permissions in Salesforce.com.  This is a guide on how to do that and model the different permissions types along with all of the gotchas of getting this information out of the various APIs it hides in throughtout the system.  

The real power comes from getting all of these permissions in their raw form out into a relational database and being able to use traditional SQL to analyze them.  SOQL has too many limitations to do this and as you will see, the information needed really comes from a variety of APIs, meaning using SOQL alone would basically be impossible.  Note that this guide may not be comprehensive as permisisons that are even available change from org to org based on features that have been purchased or turned on by support.

## General Knowledge and Approach
### Permissions Data Model
Familiarize yourself with the permissions data model first.  Everything really revolves around the PermissionSet object.  Every proflie has an underlying permission set driving it.  It is just not accessible through the permission set interface in the system.

[Crow's Foot Data Model](https://developer.salesforce.com/docs/atlas.en-us.api.meta/api/sforce_api_erd_profile_permissions.htm)


### BIGGEST GOTCHA: The Dreaded SobjectType and TableEnumorId fields
Salesforce apparently never planned their schema for the idea of namespaces or the fact that people might actually use all of the characters given to them in naming an object.  The **sobjecttype** field on this object is only set to 40 characters.  However, an object name can be much longer if it has a namespaceprefix. Even without a namespaceprefix, you can create an object that is 40 characters and then the __c is added to the end, making it 43. The max length of a namespaceprefix is 15, then the double underscore, then the object name, so 15 + 2 + 43. The length of this field on all of these objects should be 60, not 40.  Here are the objects I've found affected by this bug so far:
* MatchingRule
* SlaProcess
* AssignmentRule
* RecordType
* FieldPermissions
* ObjectPermissions
* DuplicateRule
* QueueSobject

This is due to the fact that SF is a metadata-driven system.  Under the covers, the database if capable of holding larger amounts of data than what is defined at the metadata level.  Admins who have ever made a field SHORTER in length know this as your existing values that are longer than the new length don't get truncated--instead they just cause headaches if you ever try to edit those records.  You will really start to notice this issue when doing analysis if you have a bunch of managed packages in your org. How did Salesforce respond when I reported this obvious bug to them years ago?

[Unhelpful help article explaining that when we say "Length" we didn't actually mean for you to take that SERIOUSLY!](https://help.salesforce.com/articleView?id=000270252&language=en_US&type=1)

So, when you are replicating this data to a relational database, of course every standard ETL tool actually trusts what the schema says and sets up the target fields in your target database to be the incorrect length.  Tools like [DBAmp](http://www.forceamp.com/) do have mechanisms for this that will allow you to override the field length, so look for those options.  Worst case, some apex to put this information into a custom object where you control the lengths may be required.  Note that salesforce for most api calls WILL give you the entire underlying value, despite what the metadata says the length is.  The exception to this is the **getUpdated()** call in the SOAP API, which truncates it as well. 

## System and App Permissions
These are the permissions that really define "powers" within the system that are for the most part not object-specific (App permissions can be, but are only for standard app and objects associated with things like service cloud, sales cloud, etc.)

## Object Permissions
The object for this is simple enough: **ObjectPermissions**
Available in: SOAP, REST, Apex, ToolingAPI

### What it's got
#### Base Permissions
The four basic permissions are **PermissionsRead, PermissionsCreate, PermissionsEdit, PermissionsDelete**.  These define the baseline capability to do those things at the object level.  They do NOT mean that you actually CAN do those things.  When modelling en masse to determine what effective access certain users have, or for auditing, be aware of these gotchas:
1. *PermissionsRead* is a bit irrelevant.  If the profile or permission set does not have read access, there's just no record at all in the table (more efficient from a data storage standpoint).  Effectively though, this means that you will never see a false value in this field and from a data modeling and insert standpoint, you cannot ever update this field. 
2. You can grant *PermissionsCreate* without *PermissionsEdit* and vice versa.  This can be really useful for places where you want users to be able to submit some kind of request for instance but then not edit it once submitted, or the reverse.  The same goes for If you grant *ModifyAllRecords*, you can still also NOT grant *PermissionCreate* if you so desire.
3. You cannot grant *PermissionsDelete* without also giving *PermissionsEdit*.
4. *PermissionsEdit* is contingent on the sharing model if the object is Public Read Only or Private.  Giving Edit only means that the user has the ability to Edit IF the record-level access permits it.  If they are not the owner, or have access through role hierarchy, apex sharing, manual sharing, sharing rule, etc. then they won't be able to edit the record.
5. *PermissionsDelete* is SUPER weird.  People get tripped up over this all the time.  Even if you have the permission, you cannot delete unless you are either the **OWNER** of the record or **ABOVE THE OWNER** in the role hierarchy.  Because of this, it is often a helpful solution to develop a visualforce page (that can be access controlled in SetupEntityAccess--see below) allowing the person who wants to delete to make themselves the owner and then process the delete (as a future call or as a two step method--whichever your users prefer).  

#### Admin Permissions
The two dangerous permissions here are **PermissionsViewAllRecords and PermissionsModifyAllRecords**.  Here's where it gets interesting.  These essentially provide an object-level override to any sharing.  Normally, record level access is NOT determined by the profile or permission set.  In theory, I could give you read, edit, and delete on an object, but if that object were private, and there were no sharing rules, etc. to grant you record level access, you would see nothing in the object.  These two permissions override all of that and just grant the complete set of rows.  Here are the biggest gotchas:
1. *PermissionsModifyAllRecords* will actually give you the ability to delete ANY record in the object--not just the ones that you own or where you are above the owner in the role hierarchy.
2. *PermissionsModifyAllRecords* comes with a VERY scary power that most people don't know about.  If a user has this permission, they can **APPROVE** any record that is going through approval on that object on behalf of any approver.  Yeah, crazy.  That is why this permission should ONLY be reserved for actual Administrators or Delegated Administrators: 
[An unhelpful help article that fails to explain these nuances, but does at least caution this should be for admins only](https://help.salesforce.com/articleView?id=users_profiles_view_all_mod_all.htm&type=5)

#### Other useful fields
Very helpfully, this object also includes your standard audit fields like createdbyid, lastmodifieddate, etc.  This is super helpful for seeing who screwed up what and when.  

### How to use it
This object obviously can be used for analysis of who has what permissions and where from.  ALSO as of API v40 our prayers were answered and you can insert and update (excluding updating the PermissionsRead field as noted above) on this object EVEN IF the permission set it is linked to is owned by a profile.  This means that mass permissions cleanups are NOT hard to do on this object.  Here are some excellent use cases for making use of this object:
1. Identify all the places where a user has Modify All on an object but where that object also has an approval processs (possible audit issue) so you can target removing Modify All from those permission sets or Profiles.
2. Identify all the places where the org-wide default is set to Public Read/Write, but people have Modify All on the object.  This can probably safely be removed as it won't affect their row-level access except in terms of what they can delete and having the ability to approve any approval process (which again, is really something you can solve in a much better way).
3. Finding where Modify All Data or View All Data were granted at some point in the past and then removed.

## Field Permissions
Field level security is captured in this object.  

Very UNhelpfully, this object DOES NOT include your standard audit fields like createdbyid, lastmodifieddate, etc.  This would be super helpful for seeing who screwed up what and when.  Please vote on this idea I posted if you feel this would be helpful:
[Add audit fields to FieldPermissions Object](https://success.salesforce.com/ideaView?id=0873A000000lGXhQAM)


## Setup Entity Access


#Coming Soon
PageLayoutAssignment
DefaultRecordtype
Recordtype
TabPermission-Hidden
TabPermission-DefaultOn
TabPermission-DefaultOff
ApexPage
ApexClass
CustomPermission
ServicePresenceStatus
ConnectedApplication
TabSet
