#!/usr/bin/env bash

cat - | jq '. 
    | { 
        "simulation": {
            id: .simulation.id, 
            status: .simulation.status, 
            created_at: .simulation.created_at
        }, 
        "call_trace": .transaction.transaction_info.call_trace 
    }'

