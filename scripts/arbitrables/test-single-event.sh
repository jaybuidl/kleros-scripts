#!/bin/bash

# Test script to debug a single MetaEvidence event query
# Usage: ./test-single-event.sh <arbitrated_address> <metaEvidenceId>

if [ -z "$1" ] || [ -z "$2" ]; then
    echo "Usage: $0 <arbitrated_address> <metaEvidenceId>"
    echo "Example: $0 0x776e5853e3d61b2dfb22bcf872a43bf9a1231e52 0"
    exit 1
fi

if [ -z "$RPC" ]; then
    echo "Error: RPC environment variable is not set"
    exit 1
fi

arbitrated=$1
metaEvidenceId=$2

# MetaEvidence event topic0
topic0="0x61606860eb6c87306811e2695215385101daab53bd6ab4e9f9049aead9363c7d"

# Convert metaEvidenceId to hex (32 bytes padded)
metaEvidenceIdHex=$(printf "0x%064x" "$metaEvidenceId")

echo "Testing MetaEvidence event query:"
echo "  Arbitrated: $arbitrated"
echo "  MetaEvidenceId: $metaEvidenceId (hex: $metaEvidenceIdHex)"
echo "  Topic0: $topic0"
echo "  RPC: $RPC"
echo ""

# Prepare the JSON payload using jq to ensure proper formatting
json_payload=$(jq -nc \
    --arg address "$arbitrated" \
    --arg topic0 "$topic0" \
    --arg topic1 "$metaEvidenceIdHex" \
    '{
        jsonrpc: "2.0",
        method: "eth_getLogs",
        params: [{
            address: $address,
            topics: [$topic0, $topic1],
            fromBlock: "0x0",
            toBlock: "latest"
        }],
        id: 1
    }')

echo "JSON Payload (compact):"
echo "$json_payload"
echo ""
echo "JSON Payload (formatted):"
echo "$json_payload" | jq '.'
echo ""

# Query logs using eth_getLogs
echo "Sending RPC request..."
result=$(curl -s -X POST "$RPC" \
    -H "Content-Type: application/json" \
    -d "$json_payload")

echo "Raw RPC Response:"
echo "$result" | jq '.'
echo ""

# Check for errors
error=$(echo "$result" | jq -r '.error // empty')
if [ ! -z "$error" ]; then
    echo "ERROR: RPC returned an error"
    echo "$error"
    exit 1
fi

# Check result
log_count=$(echo "$result" | jq '.result | length')
echo "Number of events found: $log_count"
echo ""

if [ "$log_count" == "0" ] || [ "$log_count" == "null" ]; then
    echo "No events found. This could mean:"
    echo "  1. The metaEvidenceId doesn't match any events"
    echo "  2. The contract address is incorrect"
    echo "  3. The RPC node doesn't have full history"
    echo "  4. The events are on a different chain"
    exit 1
fi

# Show all events
for i in $(seq 0 $((log_count - 1))); do
    echo "Event #$i:"
    echo "$result" | jq ".result[$i]"
    
    log_data=$(echo "$result" | jq -r ".result[$i].data")
    echo "Raw data: $log_data"
    
    # Decode the string (ABI-encoded string format)
    # Position 0-63: offset pointer (32 bytes)
    # Position 64-127: length (32 bytes)
    # Position 128+: actual string data
    hex_data=${log_data#0x}
    
    offset_hex=${hex_data:0:64}
    length_hex=${hex_data:64:64}
    length=$((16#$length_hex))
    
    echo "Offset: 0x$offset_hex (decimal: $((16#$offset_hex)))"
    echo "Length: 0x$length_hex (decimal: $length bytes)"
    
    # Extract string data starting at position 128
    string_hex=${hex_data:128:$((length * 2))}
    
    decoded=$(echo "$string_hex" | xxd -r -p)
    echo "Decoded string: $decoded"
    echo ""
done

