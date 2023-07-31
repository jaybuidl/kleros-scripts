#!/bin/bash

if [[ ! "$1" ]]
then
    echo "Usage: $(basename $0) [tag]"
    exit 1
fi

tag=$1

function getTagMainnet() {
        local tag=$1
        curl -X POST -s -d '{ "query": "{ litems( where: {registry: \"0x6e31d83b0c696f7d57241d3dffd0f2b628d14c67\", status: Registered, keywords_contains_nocase: \"'$tag'\"} ) { keywords data } }"}' https://api.thegraph.com/subgraphs/name/kleros/curate | jq -r .data.litems[].data
}

function getTagGnosis() {
        local tag=$1
        curl -X POST -s -d '{ "query": "{ litems( where: {registry: \"0x66260c69d03837016d88c9877e61e08ef74c59f2\", status: Registered, keywords_contains_nocase: \"'$tag'\"} ) { keywords data } }"}' https://api.thegraph.com/subgraphs/name/kleros/legacy-curate-xdai | jq -r .data.litems[].data
}

output='{}'

ipfsUris="$(getTagMainnet $tag)"
ipfsUris="$ipfsUris\n"
ipfsUris="$ipfsUris$(getTagGnosis $tag)"
ipfsUris=$(echo -e "$ipfsUris" | sed '/^$/d') # remove empty lines

if [[ "$ipfsUris" != "" ]]
then
    for item in $ipfsUris; do 
        itemData=$(curl -s https://ipfs.kleros.io/$item | jq .values)
        output=$(echo "$output" | jq --argjson itemData "$itemData" '.tags += [$itemData]')
    done
fi
echo "$output" | jq -s add
