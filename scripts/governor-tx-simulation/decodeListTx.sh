#!/usr/bin/env bash

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

function toJsonArray {
    cat - | sed -e 's|\[|["|g' -e 's|, |", "|g' -e 's|]|"]|g'
}

txId=${1:-0xc07ed485c7e4e8dce7e1ee373f6179287cc5d66adc1405a028e990ee9f762924}
input=$($SCRIPT_DIR/decodeSubmitList.sh $txId)
tos=$(echo "$input" | sed -n '1p' | toJsonArray)
values=$(echo "$input" | sed -n '2p' | toJsonArray)
data=$(echo "$input" | sed -n '3p')
sizes=$(echo "$input" | sed -n '4p' | toJsonArray)
descriptions=$(echo "$input" | sed -n '5p' | sed -e 's|,$||' -e 's|^|["|g' -e 's|,|", "|g' -e 's|$|"]|g')

# split data by size
cursor=2
dataArray="[]"
for i in $(seq 0 $(( $(echo "$sizes" | jq '. |  length') - 1 )))
do 
    description=$(echo "$descriptions" | jq -r --arg i $i '.[$i|tonumber]')
    #echo "#$i @$cursor: $description $calldata" 
    size=$(echo "$sizes" | jq -r --arg i $i '.[$i|tonumber]')
    calldata=${data:$cursor:$(($size * 2))}
    #cast pretty-calldata "0x$calldata"
    dataArray=$(echo "$dataArray" | jq --arg calldata "$calldata" '. += ["0x"+$calldata]')
    cursor=$(( $cursor + $(($size * 2)) )) 
done

echo "{}" \
    | jq \
        --argjson values "$values" \
        --argjson tos "$tos" \
        --argjson descriptions "$descriptions" \
        --argjson input "$dataArray" \
       '[$tos, $values, $descriptions, $input] 
            | transpose[] 
            | { 
                to: .[0], 
                value: .[1], 
                description: .[2], 
                input: .[3] 
            } ' \
    | jq -s .


