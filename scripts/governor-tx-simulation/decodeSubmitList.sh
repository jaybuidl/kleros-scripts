#!/usr/bin/env bash

txId=${1:-0xc07ed485c7e4e8dce7e1ee373f6179287cc5d66adc1405a028e990ee9f762924}

input=$(cast tx --rpc-url https://eth-rpc.gateway.pokt.network $txId --json | jq -r .input)
functionSig=$(cast 4byte ${input:2:8})

cast --calldata-decode "$functionSig" "$input" 
