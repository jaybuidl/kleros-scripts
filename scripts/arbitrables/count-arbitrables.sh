#!/bin/bash

jq '[.data.disputes[].arbitrated] | unique | {count: length, addresses: .}' disputes.json
