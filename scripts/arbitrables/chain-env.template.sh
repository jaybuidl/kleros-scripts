#!/bin/bash

# Template configuration file for chain-specific environment variables
# 
# Setup:
#   1. Copy this file: cp chain-env.template.sh chain-env.sh
#   2. Fill in your actual URLs in chain-env.sh
#   3. Add chain-env.sh to .gitignore (it should already be there)
#   4. Source before running scripts: source chain-env.sh ethereum
#
# This script should be SOURCED, not executed
# Usage: source chain-env.sh <chain>

if [ "$0" = "$BASH_SOURCE" ]; then
    echo "Error: This script should be sourced, not executed"
    echo "Usage: source $0 <chain>"
    exit 1
fi

CHAIN="${1:-}"

if [ -z "$CHAIN" ]; then
    # Try to detect current chain from symlink
    if [ -L "./disputes.json" ]; then
        target=$(readlink "./disputes.json")
        case "$target" in
            *ethereum*)
                CHAIN="ethereum"
                ;;
            *gnosis*)
                CHAIN="gnosis"
                ;;
        esac
    fi
    
    if [ -z "$CHAIN" ]; then
        echo "Error: Please specify a chain"
        echo "Usage: source $0 <ethereum|gnosis>"
        return 1
    fi
fi

case "$CHAIN" in
    ethereum)
        echo "Setting up environment for Ethereum Mainnet..."
        # Replace with your actual Ethereum subgraph URL
        export DISPUTE_SUBGRAPH="https://api.studio.thegraph.com/query/YOUR_ID/YOUR_SUBGRAPH/version/latest"
        # Replace with your actual Ethereum RPC URL (e.g., Infura, Alchemy)
        export RPC="https://mainnet.infura.io/v3/YOUR_API_KEY"
        export CHAIN_NAME="ethereum"
        ;;
    gnosis)
        echo "Setting up environment for Gnosis Chain..."
        # Replace with your actual Gnosis subgraph URL
        export DISPUTE_SUBGRAPH="https://api.studio.thegraph.com/query/YOUR_ID/YOUR_SUBGRAPH/version/latest"
        # Replace with your actual Gnosis RPC URL
        export RPC="https://rpc.gnosischain.com"
        export CHAIN_NAME="gnosis"
        ;;
    *)
        echo "Error: Unknown chain '$CHAIN'"
        echo "Available chains: ethereum, gnosis"
        return 1
        ;;
esac

echo "✓ Environment configured for $CHAIN_NAME"
echo "  DISPUTE_SUBGRAPH: ${DISPUTE_SUBGRAPH:0:50}..."
echo "  RPC: ${RPC:0:50}..."

