#!/bin/bash

# -----------------------------------
outfile="myfile.txt"
mgmtport="4434"
outputformat="1"
# -----------------------------------

# Delete output file if exists
if [ -f "$outfile" ]
then
     rm $outfile
fi

# Pull objects
echo "pulling objects"
objjson=$(mgmt_cli -r true show gateways-and-servers --port $mgmtport --format json)

# Create target list
echo "creating target list"
mapfile -t objarray < <(echo $objjson | jq '.objects[] | select(.type=="simple-gateway") | .name' )

# Run script
echo "running script"
for name in ${objarray[@]}; do
     scriptjson=$(mgmt_cli -r true run-script script-name "run cpinfo" script "cpinfo -y all /" targets.1 "$name" --port $mgmtport  --format json 2> /dev/null)
     status=$(echo $scriptjson | jq -r '.tasks[0]["task-details"][0].statusCode')
     statusdesc=$(echo $scriptjson | jq -r '.tasks[0]["task-details"][0].statusDescription')
     response=$(echo $scriptjson | $CPDIR/jq/jq -r '(.tasks[0]["task-details"][0].responseMessage)' | base64 -di)
     if [ "$status" = "failed" ]
     then
          echo $name, $status, $statusdesc
          # add to output file
          echo $name, $status, $statusdesc >> $outfile
     else
          echo $name, $status
          # add to output file
          echo $name, $status >> $outfile
          if [ "$outputformat" = 1 ]
          then
               echo $response >> $outfile
          else
               echo $scriptjson | $CPDIR/jq/jq -r '(.tasks[0]["task-details"][0].responseMessage)' | base64 -di >> $outfile     
          fi
     fi
done
