#!/bin/bash

# Script to check for new disputes from The Graph without modifying disputes.json
DISPUTES_FILE="./disputes.json"

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

echo "Checking for new disputes..."
echo ""

# Find the highest dispute ID in the current file
max_id=$(jq '[.data.disputes[].id | tonumber] | max' "$DISPUTES_FILE")
current_count=$(jq '.data.disputes | length' "$DISPUTES_FILE")

echo "Current status:"
echo "  - Total disputes in file: $current_count"
echo "  - Highest dispute ID: $max_id"
echo ""

# Calculate the starting ID for the query (max_id + 1)
start_id=$((max_id + 1))

echo "Querying The Graph for disputes..."
echo "Note: Filtering for disputes with ID > $max_id (due to string comparison in GraphQL)"

# Query ALL disputes (up to 1000) and filter client-side
# We can't use id_gte with numeric comparison, so we fetch and filter
graphql_query='{"query":"{ disputes(first: 1000, orderBy: id, orderDirection: desc) { id arbitrated metaEvidenceId arbitrableHistory { metaEvidence } }}"}'

# Query The Graph
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

echo ""
echo "Query results:"
echo "  - New disputes found: $new_count"

if [ "$new_count" == "0" ]; then
    echo ""
    echo "✓ Your disputes.json is up to date!"
    exit 0
fi

# Check if we might have hit The Graph's 1000 item limit
total_fetched=$(echo "$response" | jq '.data.disputes | length')
if [ "$total_fetched" == "1000" ]; then
    echo ""
    echo "⚠️  Warning: Fetched exactly 1000 disputes from The Graph (the maximum)."
    echo "   There might be more disputes beyond what we can see in a single query."
    echo "   After updating, run this script again to check for additional disputes."
fi

# Show the range of new dispute IDs
min_new_id=$(echo "$new_disputes" | jq '[.[].id | tonumber] | min')
max_new_id=$(echo "$new_disputes" | jq '[.[].id | tonumber] | max')
echo "  - New dispute ID range: $min_new_id to $max_new_id"
echo ""

# Show summary of arbitrated addresses in new disputes
unique_addresses=$(echo "$new_disputes" | jq '[.[].arbitrated] | unique | length')
echo "Summary of new disputes:"
echo "  - Unique arbitrated contracts: $unique_addresses"

# Count how many have arbitrableHistory
with_history=$(echo "$new_disputes" | jq '[.[] | select(.arbitrableHistory != null)] | length')
without_history=$(echo "$new_disputes" | jq '[.[] | select(.arbitrableHistory == null)] | length')
echo "  - With arbitrableHistory: $with_history"
echo "  - Without arbitrableHistory: $without_history"

echo ""
echo "After update, you would have:"
echo "  - Total disputes: $((current_count + new_count))"
echo ""
echo "Run ./update-disputes.sh to apply the update"

