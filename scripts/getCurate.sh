#!/bin/bash

if [[ ! "$1" ]]
then
  echo "Usage: $(basename $0) [address]"
  exit 1
fi

address=$1

function getTokenMainnet() {
    local address=$1
    curl -X POST -s -d '{ "query": "{ litems( where: {registry: \"0x6e31d83b0c696f7d57241d3dffd0f2b628d14c67\", status: Registered, keywords_contains: \"'$address'\"} ) { keywords data } }"}' https://api.thegraph.com/subgraphs/name/kleros/curate | jq -r .data.litems[].data
}

function getTagXdai() {
    local address=$1
    curl -X POST -s -d '{ "query": "{ litems( where: {registry: \"0x76944a2678a0954a610096ee78e8ceb8d46d5922\", status: Registered, keywords_contains: \"'$address'\"} ) { keywords data } }"}' https://api.thegraph.com/subgraphs/name/eccentricexit/curate-xdai-ii | jq -r .data.litems[].data
}

output='{}'

ipfs=$(getTokenMainnet $address)
if [[ "$ipfs" != "" ]]
then
    output="$output { \"tokenMainnet\": $(curl -s https://ipfs.kleros.io/$ipfs | jq .values) }"
fi

ipfs=$(getTagXdai $address)
if [[ "$ipfs" != "" ]]
then
    output="$output { \"tagXdai\": $(curl -s https://ipfs.kleros.io/$ipfs | jq .values) }"
fi

echo "$output" | jq -s add