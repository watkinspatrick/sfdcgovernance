#!/bin/bash

org='ps'
#Look for changes to login ip
echo "AuditKey__c,Subject,Description,Ownerid" > audit.csv
sfdx force:data:soql:query -q "Select id,action,display from setupaudittrail where action in ('loginiprange') and createddate=TODAY" -u $org -r csv | tail -n +2 | sed "s/$/\,005F0000003NfcL/g" >> audit.csv

#Notify the "monitor"
sfdx force:data:bulk:upsert -f ./audit.csv -i id -s Task -u $org

