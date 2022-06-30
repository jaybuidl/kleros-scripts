#!/bin/bash

if [[ ! "$1" ]]
then
  echo "Usage: $(basename $0) [address]"
  exit 1
fi

address=$1

data=$(curl -X POST -s -d '{ "query": "{ litems( where: {registry: \"0x76944a2678a0954a610096ee78e8ceb8d46d5922\", status: Registered, keywords_contains: \"'$address'\"} ) { keywords data } }"}' https://api.thegraph.com/subgraphs/name/eccentricexit/curate-xdai-ii | jq -r .data.litems[].data)

if [[ "$data" != "" ]]
then
  curl -s https://ipfs.kleros.io/$data | jq .values
fi

