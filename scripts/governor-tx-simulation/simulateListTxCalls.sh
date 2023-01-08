#!/usr/bin/env bash

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

txId=${1:-0xc07ed485c7e4e8dce7e1ee373f6179287cc5d66adc1405a028e990ee9f762924}
calls=$(./decodeListTx.sh $txId)

for i in $(seq 0 $(( $(echo "$calls" | jq '. |  length') - 1 )))
do
    call=$(echo "$calls" | jq -r --arg i $i '.[$i|tonumber]')
    #echo "$i: $call"
    
    # Use the fields of the governor.submitList() tx as defaults for the calls
    # De simulate the execution as if the governor was making the calls, so we replace .from with the governor address, which is in the .to field of the submitList() tx.
    # Disable saving the simulation to the Tenderly dashboard, the UI doesn't support bulk deletes.
    ./populateTx.sh \
        | jq \
            --argjson call "$call" \
            '.value = $call.value 
                | .input = $call.input 
                | .from = .to
                | .to = $call.to
                | .save = false' \
        | ./simulateTx.sh
        #| cat -
done

