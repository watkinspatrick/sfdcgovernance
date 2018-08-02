#!/bin/bash
org="ps"

#Technical debt

#When was this sandbox created?
startedate=`sfdx force:data:soql:query -q "Select createddate from SetupAuditTrail order by createddate asc limit 1" -u $org -r csv | tail -n +2`

#What's the max api version?
ourapi=`sfdx force:data:soql:query -q "select apiversion from apexclass order by apiversion desc limit 1" -u $org -r csv | tail -n +2`

#Find everything that's been edited since the sandbox was created that hasn't been updated to our current API version standard.
sfdx force:data:soql:query -q "select id,name,lastmodifieddate,apiversion,lastmodifiedby.name from apexclass where lastmodifieddate>$startedate and apiversion<$ourapi" -u $org -r csv > reminders.csv
