#!/bin/bash

repos="$(./getAllReposTopicsToCsv.sh)"

function byProduct() #product
{
  local product=$1
  echo "*** $product ***"
  echo "$repos" | grep $product | cut -f1 -d,
}

byProduct court
echo
byProduct v2
echo
byProduct token
echo
byProduct curate
echo
byProduct linguo
echo
byProduct escrow
echo
byProduct governor
echo
byProduct realitio
echo
byProduct resolver
echo
byProduct platform
echo
byProduct opsec
echo
byProduct Proof-Of-Humanity
echo
byProduct research