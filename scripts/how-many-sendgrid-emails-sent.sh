#!/usr/bin/env bash

if [[ -z "$SENDGRID_API_KEY" ]]; then
    echo "SENDGRID_API_KEY is not set. Exiting..."
    exit 1
fi

function count_emails() {
    local day=$1

    # We could have used the stats API but it doesn't let us filter out the marketing emails
    curl -sG -X GET "https://api.sendgrid.com/v3/messages" \
        --header "Authorization: Bearer $SENDGRID_API_KEY" \
        --data-urlencode "query=(Not(Contains(categories,\"newsletter\")) AND (last_event_time BETWEEN TIMESTAMP \"${day}T00:00:00Z\" AND TIMESTAMP \"${day}T23:59:59Z\") AND (status=\"delivered\"))" \
        --data-urlencode "limit=1000" \
        | jq '.messages | length'
}

for i in {0..6}; do
    day=$(date -I -v-${i}d)
    echo "$day: $(count_emails $day) emails delivered"
done
