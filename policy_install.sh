#!/bin/bash

# -----------------------------------
outfile="myfile.txt"

#management port - should be 443 for npm, 4434 for epm
mgmtport="4434"

#reporting (set to 1 for compressed results)
outputformat="0"

#policy name to install
policyname="standard"

#install fwappurl policy
accesspolicy="true"

#install threat policy
threatpolicy="false"
# -----------------------------------

# Delete output file if exists
if [ -f "$outfile" ]
then
     rm $outfile
fi

# Run script
scriptjson=$(mgmt_cli -r true install-policy policy-package $policyname access $accesspolicy threat-prevention $threatpolicy --port $mgmtport --format json)
if [ "$outputformat" = 1 ]
then
     echo $scriptjson >> $outfile
else
     echo $scriptjson | jq -r '' >> $outfile
fi
