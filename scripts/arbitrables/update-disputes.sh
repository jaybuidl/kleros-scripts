#!/bin/bash

# Script to fetch new disputes from The Graph and update disputes.json
DISPUTES_FILE="./disputes.json"
TEMP_FILE="./disputes_temp.json"

# Check if jq is installed
if ! command -v jq &> /dev/null; then
    echo "Error: jq is required but not installed. Please install jq first."
    exit 1
fi

# Check if DISPUTE_SUBGRAPH is set
if [ -z "$DISPUTE_SUBGRAPH" ]; then
    echo "Error: DISPUTE_SUBGRAPH environment variable is not set"
    echo "Usage: export DISPUTE_SUBGRAPH='your-graph-endpoint-url'"
    exit 1
fi

# Check if disputes file exists
if [ ! -f "$DISPUTES_FILE" ]; then
    echo "Error: $DISPUTES_FILE not found"
    exit 1
fi

echo "Reading current disputes file..."

# Find the highest dispute ID in the current file
max_id=$(jq '[.data.disputes[].id | tonumber] | max' "$DISPUTES_FILE")

if [ "$max_id" == "null" ] || [ -z "$max_id" ]; then
    echo "No existing disputes found, starting from 0"
    max_id=0
else
    echo "Current highest dispute ID: $max_id"
fi

# Calculate the starting ID for the query (max_id + 1)
start_id=$((max_id + 1))

echo "Querying for disputes from The Graph..."
echo "Note: Filtering for disputes with ID > $max_id (due to string comparison in GraphQL)"

# Query ALL disputes (up to 1000) and filter client-side
# We can't use id_gte with numeric comparison, so we fetch and filter
graphql_query='{"query":"{ disputes(first: 1000, orderBy: id, orderDirection: desc) { id arbitrated metaEvidenceId arbitrableHistory { metaEvidence } }}"}'

# Query The Graph
echo "Fetching from The Graph..."
response=$(curl -s -X POST "$DISPUTE_SUBGRAPH" \
    -H "Content-Type: application/json" \
    -d "$graphql_query")

# Check for errors in the response
error=$(echo "$response" | jq -r '.errors // empty')
if [ ! -z "$error" ]; then
    echo "Error from The Graph:"
    echo "$error" | jq '.'
    exit 1
fi

# Extract the disputes and filter for IDs greater than max_id (numerically)
new_disputes=$(echo "$response" | jq --argjson maxId "$max_id" '[.data.disputes[] | select((.id | tonumber) > $maxId)]')
new_count=$(echo "$new_disputes" | jq 'length')

echo "Found $new_count new disputes"

if [ "$new_count" == "0" ]; then
    echo "No new disputes to add. disputes.json is already up to date."
    exit 0
fi

# Check if we might have hit The Graph's 1000 item limit
total_fetched=$(echo "$response" | jq '.data.disputes | length')
if [ "$total_fetched" == "1000" ]; then
    echo ""
    echo "⚠️  Warning: Fetched exactly 1000 disputes from The Graph (the maximum)."
    echo "   There might be more disputes beyond what we can see in a single query."
    echo "   After this update completes, run the update again to fetch additional disputes."
    echo ""
fi

# Show the range of new dispute IDs
min_new_id=$(echo "$new_disputes" | jq '[.[].id | tonumber] | min')
max_new_id=$(echo "$new_disputes" | jq '[.[].id | tonumber] | max')
echo "New dispute ID range: $min_new_id to $max_new_id"

# Merge the disputes and sort by ID
echo "Merging disputes and sorting by ID..."

jq --argjson newDisputes "$new_disputes" \
    '{
        data: {
            disputes: (
                (.data.disputes + $newDisputes) 
                | sort_by(.id | tonumber)
            )
        }
    }' "$DISPUTES_FILE" > "$TEMP_FILE"

# Verify the merge was successful
if [ $? -ne 0 ]; then
    echo "Error: Failed to merge disputes"
    rm -f "$TEMP_FILE"
    exit 1
fi

# Check the new total count
total_count=$(jq '.data.disputes | length' "$TEMP_FILE")
echo "Total disputes after merge: $total_count"

# Backup the original file
backup_file="${DISPUTES_FILE}.backup.$(date +%Y%m%d_%H%M%S)"
echo "Creating backup: $backup_file"
cp "$DISPUTES_FILE" "$backup_file"

# Replace the original file with the merged version
mv "$TEMP_FILE" "$DISPUTES_FILE"

echo ""
echo "✓ Successfully updated $DISPUTES_FILE"
echo "  - Added $new_count new disputes"
echo "  - Total disputes: $total_count"
echo "  - Backup saved to: $backup_file"
echo ""
echo "New disputes range from ID $min_new_id to $max_new_id"

