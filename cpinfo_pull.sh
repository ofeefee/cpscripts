#!/bin/bash

FILE="myfile.txt"

mapfile -t my_array < <( mgmt_cli -r true show gateways-and-servers --port 4434 --format json | jq '.objects[] | select(.type=="simple-gateway") | .name' )

if [ -f "$FILE" ]
then
     rm myfile.txt
fi

for name in ${my_array[@]}; do
     echo $name >> myfile.txt
     mgmt_cli -r true run-script script-name "run cpinfo" script "cpinfo -y all /" targets.1 "$name" --port 4434  --format json 2> /dev/null | $CPDIR/jq/jq -r '(.tasks[0]["task-details"][0].responseMessage)' | base64 -di >> myfile.txt

done

