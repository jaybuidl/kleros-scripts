#!/usr/bin/env bash

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

[[ ! $TENDERLY_USER ]] && echo "env var TENDERLY_USER not set" && exit 1
[[ ! $TENDERLY_ACCESS_KEY ]] && echo "env var TENDERLY_ACCESS_KEY not set" && exit 1

curl -s https://api.tenderly.co/api/v1/account/$TENDERLY_USER/project/project/simulate \
    -X POST \
    -H "X-Access-Key: $TENDERLY_ACCESS_KEY" \
    -H "Content-Type: application/json" \
    --data "$($SCRIPT_DIR/populateTx.sh)"
