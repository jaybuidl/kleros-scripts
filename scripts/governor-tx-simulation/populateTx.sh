#!/usr/bin/env bash

oldTx="$(cast tx --rpc-url https://eth-rpc.gateway.pokt.network 0xc07ed485c7e4e8dce7e1ee373f6179287cc5d66adc1405a028e990ee9f762924 --json)"
#oldTx="$(cat tx.json)"

chainId=$(( $(echo "$oldTx" | jq -r .chainId) ))
gas=$(( $(echo "$oldTx" | jq -r .gas) ))
gasPrice=$(( $(echo "$oldTx" | jq -r .gasPrice) ))
blockNumber=$(( $(echo "$oldTx" | jq -r .blockNumber) ))
value=$(( $(echo "$oldTx" | jq -r .value) ))
echo "$oldTx" | jq \
    --arg chainId $chainId \
    --arg gas $gas \
    --arg gasPrice $gasPrice \
    --arg blockNumber $blockNumber \
    --arg value $value \
    '.gas = ($gas | tonumber) | .block_number = ($blockNumber | tonumber) | .value = $value | .transaction_index = 0 | .network_id = $chainId | .save = true | .gas_price = $gasPrice | with_entries(select(.key == ("block_number", "transaction_index", "from", "to", "input", "value", "gas", "gas_price", "network_id", "save")))'

# No hex for gas or block_number or value, watchout for string vs number fields
# EXPECTED:
#  "network_id": string,
#  "block_number": number,
#  "transaction_index": number,
#  "from": string,
#  "input": string,
#  "gas": number,
#  "gas_price": string,
#  "to": string,
#  "value": string,
#  "save": true

