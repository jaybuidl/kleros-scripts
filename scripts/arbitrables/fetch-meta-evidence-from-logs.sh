#!/bin/bash

# Path to the disputes JSON file
DISPUTES_FILE="./disputes.json"

# Debug mode (set to 1 to enable debug output)
DEBUG=${DEBUG:-0}

# Check if jq is installed
if ! command -v jq &> /dev/null; then
    echo "Error: jq is required but not installed. Please install jq first."
    exit 1
fi

# Check if RPC is set
if [ -z "$RPC" ]; then
    echo "Error: RPC environment variable is not set"
    exit 1
fi

# Check if the disputes file exists
if [ ! -f "$DISPUTES_FILE" ]; then
    echo "Error: $DISPUTES_FILE not found"
    exit 1
fi

# Debug print function
debug_print() {
    if [ "$DEBUG" == "1" ]; then
        echo "DEBUG: $*" >&2
    fi
}

# Function to fetch from IPFS
fetch_ipfs() {
    local ipfs_path=$1
    local output_file=$2
    
    # Remove leading slash if present
    ipfs_path=${ipfs_path#/}
    
    local url="https://cdn.kleros.link/${ipfs_path}"
    echo "Fetching: $url"
    
    curl -s -f "$url" -o "$output_file"
    
    if [ $? -eq 0 ]; then
        echo "Successfully saved to: $output_file"
        return 0
    else
        echo "Failed to fetch: $url"
        return 1
    fi
}

# Function to decode ABI-encoded string
decode_string() {
    local hex_data=$1
    
    # Remove 0x prefix
    hex_data=${hex_data#0x}
    
    # ABI-encoded string format:
    # Position 0-63: offset pointer (32 bytes) - always 0x20 (32) for single string
    # Position 64-127: length (32 bytes) - length of the string in bytes
    # Position 128+: actual string data
    local offset_hex=${hex_data:0:64}
    local length_hex=${hex_data:64:64}
    local length=$((16#$length_hex))
    
    debug_print "ABI decode - offset: 0x$offset_hex, length: $length bytes"
    
    # Extract the hex string data starting at position 128
    local string_hex=${hex_data:128:$((length * 2))}
    
    # Convert hex to ASCII
    echo "$string_hex" | xxd -r -p
}

# Function to fetch metaEvidence from event logs
fetch_metaevidence_from_logs() {
    local arbitrated=$1
    local metaEvidenceId=$2
    
    echo "Querying event logs for arbitrated=$arbitrated, metaEvidenceId=$metaEvidenceId" >&2
    
    # MetaEvidence event topic0
    local topic0="0x61606860eb6c87306811e2695215385101daab53bd6ab4e9f9049aead9363c7d"
    
    # Convert metaEvidenceId to hex (32 bytes padded)
    local metaEvidenceIdHex=$(printf "0x%064x" "$metaEvidenceId")
    
    if [ "$DEBUG" == "1" ]; then
        echo "DEBUG: Searching for topic0=$topic0, topic1=$metaEvidenceIdHex" >&2
    fi
    
    # Prepare the JSON payload using jq to ensure proper formatting
    local json_payload=$(jq -nc \
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
    
    if [ "$DEBUG" == "1" ]; then
        echo "JSON Payload:" >&2
        echo "$json_payload" | jq '.' >&2
    fi
    
    # Query logs using eth_getLogs
    local result=$(curl -s -X POST "$RPC" \
        -H "Content-Type: application/json" \
        -d "$json_payload")
    
    # Check for RPC errors
    local error=$(echo "$result" | jq -r '.error // empty')
    if [ ! -z "$error" ]; then
        echo "RPC ERROR: $error" >&2
        if [ "$DEBUG" == "1" ]; then
            echo "Full response: $result" >&2
        fi
        return 1
    fi
    
    # Check if we got any results
    local log_count=$(echo "$result" | jq '.result | length')
    
    if [ "$log_count" == "0" ] || [ "$log_count" == "null" ]; then
        echo "No MetaEvidence event found for this dispute" >&2
        if [ "$DEBUG" == "1" ]; then
            echo "Full RPC response:" >&2
            echo "$result" | jq '.' >&2
        fi
        return 1
    fi
    
    echo "Found $log_count event(s)" >&2
    
    # Get the first log's data field
    local log_data=$(echo "$result" | jq -r '.result[0].data')
    
    if [ "$log_data" == "null" ] || [ -z "$log_data" ]; then
        echo "Failed to extract log data" >&2
        if [ "$DEBUG" == "1" ]; then
            echo "First log entry:" >&2
            echo "$result" | jq '.result[0]' >&2
        fi
        return 1
    fi
    
    if [ "$DEBUG" == "1" ]; then
        echo "Raw log data: $log_data" >&2
    fi
    
    # Decode the string from the log data
    local evidence=$(decode_string "$log_data")
    
    echo "Decoded metaEvidence path: $evidence" >&2
    
    # Return only the evidence path to stdout
    echo "$evidence"
}

# Function to process additional files from metaEvidence
process_meta_evidence() {
    local folder_name=$1
    local meta_file="$folder_name/metaEvidence.json"
    
    if [ ! -f "$meta_file" ]; then
        return
    fi
    
    # Check for dynamicScriptURI
    dynamicScriptURI=$(jq -r '.dynamicScriptURI // empty' "$meta_file" 2>/dev/null)
    if [ ! -z "$dynamicScriptURI" ] && [ "$dynamicScriptURI" != "null" ]; then
        echo "Found dynamicScriptURI: $dynamicScriptURI"
        dynamic_file="$folder_name/dynamicScript.js"
        
        # Check if dynamic script already exists
        if [ -f "$dynamic_file" ]; then
            echo "DynamicScript already exists, skipping download"
        else
            fetch_ipfs "$dynamicScriptURI" "$dynamic_file"
        fi
    fi
    
    # Check for evidenceDisplayInterfaceURI
    evidenceDisplayURI=$(jq -r '.evidenceDisplayInterfaceURI // empty' "$meta_file" 2>/dev/null)
    if [ ! -z "$evidenceDisplayURI" ] && [ "$evidenceDisplayURI" != "null" ]; then
        echo "Found evidenceDisplayInterfaceURI: $evidenceDisplayURI"
        evidence_file="$folder_name/evidenceDisplayInterface.json"
        
        # Check if evidence display interface already exists
        if [ -f "$evidence_file" ]; then
            echo "EvidenceDisplayInterface already exists, skipping download"
        else
            fetch_ipfs "$evidenceDisplayURI" "$evidence_file"
        fi
    fi
}

# Counter for progress
total=$(jq '.data.disputes | length' "$DISPUTES_FILE")
current=0

# String to track processed combinations (works with bash 3.x)
processed_combinations=""

echo "Processing $total disputes..."

# Iterate through each dispute
while read -r dispute; do
    current=$((current + 1))
    
    # Extract fields
    arbitrated=$(echo "$dispute" | jq -r '.arbitrated')
    metaEvidenceId=$(echo "$dispute" | jq -r '.metaEvidenceId')
    arbitrableHistory=$(echo "$dispute" | jq -r '.arbitrableHistory')
    
    # Create folder name
    folder_name="${arbitrated}-${metaEvidenceId}"
    
    # Check if we've already processed this combination
    if [[ "$processed_combinations" == *"|$folder_name|"* ]]; then
        echo "[$current/$total] Skipping $folder_name (already processed in this run)"
        continue
    fi
    
    echo ""
    echo "[$current/$total] Processing: $folder_name"
    
    # Mark this combination as processed
    processed_combinations="${processed_combinations}|${folder_name}|"
    
    # Create the folder if it doesn't exist
    mkdir -p "$folder_name"
    
    # Fetch the metaEvidence file
    meta_file="$folder_name/metaEvidence.json"
    
    # Check if arbitrableHistory exists
    if [ "$arbitrableHistory" != "null" ]; then
        # Extract metaEvidence path from arbitrableHistory
        metaEvidence=$(echo "$dispute" | jq -r '.arbitrableHistory.metaEvidence')
        
        # Skip if metaEvidence is null or empty
        if [ "$metaEvidence" == "null" ] || [ -z "$metaEvidence" ]; then
            echo "Skipping: no metaEvidence in arbitrableHistory"
            continue
        fi
        
        # Check if metaEvidence already exists
        if [ -f "$meta_file" ]; then
            echo "MetaEvidence already exists, skipping download"
        else
            fetch_ipfs "$metaEvidence" "$meta_file"
        fi
    else
        # No arbitrableHistory, fetch from event logs
        echo "No arbitrableHistory, querying event logs..."
        
        # Check if metaEvidence already exists
        if [ -f "$meta_file" ]; then
            echo "MetaEvidence already exists, skipping event log query"
        else
            metaEvidence=$(fetch_metaevidence_from_logs "$arbitrated" "$metaEvidenceId")
            
            if [ ! -z "$metaEvidence" ] && [ "$metaEvidence" != "null" ]; then
                fetch_ipfs "$metaEvidence" "$meta_file"
            else
                echo "Could not retrieve metaEvidence from event logs"
                continue
            fi
        fi
    fi
    
    # Process additional files from metaEvidence
    process_meta_evidence "$folder_name"
done < <(jq -c '.data.disputes[]' "$DISPUTES_FILE")

echo ""
echo "Done processing all disputes!"