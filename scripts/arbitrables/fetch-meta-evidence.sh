#!/bin/bash

# Path to the disputes JSON file
DISPUTES_FILE="./disputes.json"

# Check if jq is installed
if ! command -v jq &> /dev/null; then
    echo "Error: jq is required but not installed. Please install jq first."
    exit 1
fi

# Check if the disputes file exists
if [ ! -f "$DISPUTES_FILE" ]; then
    echo "Error: $DISPUTES_FILE not found"
    exit 1
fi

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
    
    # Skip if arbitrableHistory is null
    if [ "$arbitrableHistory" == "null" ]; then
        echo "[$current/$total] Skipping dispute with arbitrated=$arbitrated (no arbitrableHistory)"
        continue
    fi
    
    # Extract metaEvidence path
    metaEvidence=$(echo "$dispute" | jq -r '.arbitrableHistory.metaEvidence')
    
    # Skip if metaEvidence is null or empty
    if [ "$metaEvidence" == "null" ] || [ -z "$metaEvidence" ]; then
        echo "[$current/$total] Skipping dispute with arbitrated=$arbitrated (no metaEvidence)"
        continue
    fi
    
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
    
    # Check if metaEvidence already exists
    if [ -f "$meta_file" ]; then
        echo "MetaEvidence already exists, skipping download"
    else
        fetch_ipfs "$metaEvidence" "$meta_file"
    fi
    
    # Check if the metaEvidence file contains dynamicScriptURI or evidenceDisplayInterfaceURI
    if [ -f "$meta_file" ]; then
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
    fi
done < <(jq -c '.data.disputes[]' "$DISPUTES_FILE")

echo ""
echo "Done processing all disputes!"