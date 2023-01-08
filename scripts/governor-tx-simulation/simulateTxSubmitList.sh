#!/usr/bin/env bash

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"


$SCRIPT_DIR/populateTx.sh \
    | $SCRIPT_DIR/simulateTx.sh \
    | $SCRIPT_DIR/filterSimulation.sh
