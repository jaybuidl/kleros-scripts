#!/bin/bash

[ -z $INFURA_PROJECT_ID ] && echo "env var INFURA_PROJECT_ID not set" && exit 1

function get() #network #rpc #explorer
{
    local network="$1"
    local rpc="$2"
    local explorer="$3"

    echo -n "$network: "
    result="$(curl -s \
      -X POST \
      -H 'Content-Type: application/json' \
      --data '{
        "jsonrpc":"2.0",
        "method":"eth_getBlockByNumber",
        "params":
          [ "latest", true ],
          "id":1
      }' \
      $rpc | jq '
        .result 
          | with_entries(
            select(
              [ .key ] 
                | inside([
                    "number", 
                    "difficulty", 
                    "mixHash"
                ]
              )
            )
          )
      '
    )"
    blockNb=$(echo $(($(echo "$result" | jq -r .number))))
    echo "$result" | jq --arg url "${explorer}/${blockNb}" '. | .url=$url'
}

get "Kiln (merged Mar 15)" https://rpc.kiln.themerge.dev https://explorer.kiln.themerge.dev/block
get "Ropsten (merged Jun 9)" https://rpc.ankr.com/eth_ropsten/ https://ropsten.etherscan.io/block
get "Goerli (merged Aug 11)" https://rpc.ankr.com/eth_goerli/ https://goerli.etherscan.io/block
get "Sepolia (merged Jul 7)" https://rpc.sepolia.online https://sepolia.etherscan.io/block
get "Mainnet (not merged)" https://rpc.ankr.com/eth/ https://etherscan.io/block


# ❌ BeaconState.randao_mixes are not exposed in the JSON RPC API
# https://github.com/ethereum/consensus-specs/blob/v1.0.1/specs/phase0/beacon-chain.md#beaconstate
#
# ✅ BeaconBlockBody.randao_reveal is available in the JSON RPC API
# https://github.com/ethereum/consensus-specs/blob/v1.0.1/specs/phase0/beacon-chain.md#beaconblockbody
# https://ethereum.github.io/beacon-APIs/#/Beacon/getBlockV2
function getBeacon() # network #rpc
{
    local network="$1"
    local rpc="$2"
    local explorer="$3"

    echo -n "$network: "
    curl -s \
        -H 'Content-Type: application/json' \
        ${rpc}/eth/v2/beacon/blocks/finalized | jq --arg url $explorer '
          .data.message 
            | { 
                slot: .slot, 
                randao_reveal: .body.randao_reveal,
                url: ( $url + "/" + .slot )
            }'
}

getBeacon "Prater Beacon" https://$INFURA_PROJECT_ID@eth2-beacon-prater.infura.io https://beaconcha.in/block
getBeacon "Mainnet Beacon" https://$INFURA_PROJECT_ID@eth2-beacon-mainnet.infura.io https://prater.beaconcha.in/block