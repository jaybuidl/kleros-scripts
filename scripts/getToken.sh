#!/bin/bash

if [[ ! "$1" ]]
then
  echo "Usage: $(basename $0) [token address]"
  exit 1
fi

address=$1

data=$(curl -X POST -s -d '{ "query": "{ litems( where: {registry: \"0x6e31d83b0c696f7d57241d3dffd0f2b628d14c67\", status: Registered, keywords_contains: \"'$address'\"} ) { keywords data } }"}' https://api.thegraph.com/subgraphs/name/kleros/curate | jq -r .data.litems[].data)

if [[ "$data" != "" ]]
then
  curl -s https://ipfs.kleros.io/$data | jq .values
fi
