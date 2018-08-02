# SFDC Governance Resources
A collection of tools and scripts demonstrated in the Pluralsight Play by Play course [Implementing Sustainable and Scalable Salesforce Governance](http://www.pluralsight.com/courses/play-by-play-implementing-sustainable-scalable-salesforce-governance)  

[Scripts](https://github.com/watkinspatrick/sfdcgovernance/tree/master/demoscripts) in the repo were written on Ubuntu using BASH.  

## Scanning and Reporting Tools
[Source scanner](https://security.secure.force.com/security/tools/forcecom/scanner)  
Free tool from Salesforce for security and code quality reporting (pay version with api, etc. available from the link)

[Health Check](https://login.salesforce.com/_ui/security/dashboard/aura/SecurityDashboardAuraContainer?retURL=%2Fui%2F)  
A scorecard for your org of the recommended security settings vs. where your settings are currently configured.

[Optimizer](https://login.salesforce.com/ui/setup/optimizer/OptimizerSetupPage?setupid=SalesforceOptimizer&retURL=%2Fui%2Fsetup%2FSetup%3Fsetupid%3DMonitoring)  
Provides business-friendly charts on best practices within the org and gives good overviews of what is being used.

[Lightning Readiness](https://login.salesforce.com/ui/setup/lightning/Enable)  
Gives things you need to fix before moving to lightning but bleeds over into some best practices as well such as hard-coded org references which are an issue when you do an org split/instance refresh.

[Field Footprint](https://appexchange.salesforce.com/listingDetail?listingId=a0N3A00000EShrRUAT)  
When doing field cleanup, this is a great tool for seeing which fields are populated:

[Field Trip](https://appexchange.salesforce.com/appxListingDetail?listingId=a0N30000003HSXEEA4)  
Another tool for identifying where fields are populated. 

[PMD](https://github.com/pmd/pmd)  
Source code analyzer that works with Apex and Visualforce. Can find many flaws as well as identify duplicate code blocks

## Other Helpful Tools
[DBAmp](http://www.forceamp.com/)  
***PAID*** Tool for replicating SF objects into SQL server where you can do more creative or labor-intensive analysis, especially if you have a large number of permissions.

[Demandtools](https://www.validity.com/product-demand/)  
***PAID*** Data management and de-duplication of data.

[Illuminated Cloud](http://www.illuminatedcloud.com/home/completion/livetemplates)  
***PAID*** SF IDE for Intellij.  Specifically linking to the live templates here, which could be shared by developers to drive consistency in documentation or coding patterns.

[SFDX CLI](https://developer.salesforce.com/tools/sfdxcli)  
Command line interface for doing scripting that can pull from setup, metadata and data to create automated monitoring of governance policies.
