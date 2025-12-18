#!/bin/bash

# Verify the MetaEvidence event topic0 hash

echo "Verifying MetaEvidence event signature..."
echo ""
echo "Event signature: MetaEvidence(uint256,string)"
echo "Correct topic0: 0x61606860eb6c87306811e2695215385101daab53bd6ab4e9f9049aead9363c7d"
echo ""

# Calculate the keccak256 hash using cast (from foundry) if available
if command -v cast &> /dev/null; then
    calculated=$(cast sig "MetaEvidence(uint256,string)")
    echo "Calculated topic0: $calculated"
    
    if [ "$calculated" == "0x61606860eb6c87306811e2695215385101daab53bd6ab4e9f9049aead9363c7d" ]; then
        echo "✓ Topic0 hash is CORRECT"
    else
        echo "✗ Topic0 hash is INCORRECT!"
        echo "  Use this instead: $calculated"
    fi
else
    echo "Note: Install foundry/cast to verify the hash"
    echo "  brew install foundry"
fi
echo ""

# Also set the address variable if not set
if [ -z "$arbitrated" ]; then
    arbitrated="0x776e5853e3d61b2dfb22bcf872a43bf9a1231e52"
fi

# Also test a simple eth_blockNumber query to verify RPC is working
echo "=== Testing basic RPC connectivity ==="
result=$(curl -s -X POST "$RPC" \
    -H "Content-Type: application/json" \
    -d '{"jsonrpc":"2.0","method":"eth_blockNumber","params":[],"id":1}')

echo "eth_blockNumber response:"
echo "$result" | jq '.'
echo ""

# Test eth_getCode to verify the address exists
echo "=== Testing if contract exists at address ==="
result=$(curl -s -X POST "$RPC" \
    -H "Content-Type: application/json" \
    -d "{\"jsonrpc\":\"2.0\",\"method\":\"eth_getCode\",\"params\":[\"$arbitrated\",\"latest\"],\"id\":1}")

code=$(echo "$result" | jq -r '.result')
if [ "$code" == "0x" ] || [ "$code" == "null" ]; then
    echo "WARNING: No code at this address! It might not be a contract."
else
    echo "✓ Contract code exists (length: ${#code} chars)"
fi
echo ""

