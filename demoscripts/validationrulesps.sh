#!/bin/bash

#DX Alias for the org you want to run this on.
org="ps"
filterfile=""
filter=""

#Setup CSV File header.
echo "id,fullname,active,description,orgname" > validationrules.csv

#Get list of validation rule ids and put them in a file
sfdx force:data:soql:query -q "Select id from ValidationRule" -t -u $org -r csv | tail -n +2 > validationrulefilterlist
filterfile=$(<validationrulefilterlist)

for filter in $filterfile
	do sfdx force:data:soql:query -q "Select id,fullname,active,description from ValidationRule where id='$filter'" -t -u $org -r csv | tail -n +2 >> validationrules.csv
done

rm validationrulefilterlist

exit 0
