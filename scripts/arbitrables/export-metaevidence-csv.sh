#!/bin/bash

# export-metaevidence-csv.sh
#
# Walk every arbitrable folder for a chain (named "0x<address>-<metaEvidenceId>")
# and flatten each folder's metaEvidence.json into one CSV row, for a comparable
# overview of all indexed arbitrables. Broken/empty folders are NOT skipped: they
# are emitted as rows with a "notes" column flagging the problem, so no situation
# is hidden.
#
# Usage:
#   cd scripts/arbitrables
#   ./export-metaevidence-csv.sh ethereum   # writes ethereum.csv
#   ./export-metaevidence-csv.sh gnosis     # writes gnosis.csv
#   ./export-metaevidence-csv.sh ethereum out.csv   # custom output path
#
# Idempotent: re-running overwrites the output CSV. A summary is printed to stderr.
#
# Import into the Google Sheet (one tab per chain):
#   open the matching tab (Ethereum / Gnosis)
#   -> File > Import > Upload the CSV
#   -> "Replace current sheet", Separator = Comma
#   -> leave "Convert text to numbers, dates, and formulas" UNCHECKED
#      (keeps IPFS paths and any "="-leading descriptions as plain text)

# Columns: address,metaevidenceId,category,subCategory,policy,title,description,metadata,notes
GATEWAY="https://cdn.kleros.link"

# Check if jq is installed
if ! command -v jq &> /dev/null; then
    echo "Error: jq is required but not installed. Please install jq first." >&2
    exit 1
fi

# Chain / input directory (positional arg)
CHAIN="$1"
if [ -z "$CHAIN" ]; then
    echo "Usage: $0 <chain> [output.csv]   (e.g. $0 ethereum)" >&2
    exit 1
fi
CHAIN_DIR="$CHAIN"
if [ ! -d "$CHAIN_DIR" ]; then
    echo "Error: directory '$CHAIN_DIR' not found (run from scripts/arbitrables)" >&2
    exit 1
fi

OUT="${2:-${CHAIN}.csv}"

# Emit an "anomaly" row (address + metaevidenceId + notes, other fields blank),
# routed through jq @csv so escaping stays consistent with the valid rows.
emit_anomaly() {
    jq -rn --arg addr "$1" --arg id "$2" --arg notes "$3" \
        '[$addr, $id, "", "", "", "", "", "", $notes] | @csv'
}

# Counters (for the stderr summary)
rows=0
n_missing=0
n_zerobyte=0
n_notjson=0

{
    # Header row
    printf 'address,metaevidenceId,category,subCategory,policy,title,description,metadata,notes\n'

    # Iterate folders, sorted by address then NUMERIC metaEvidenceId (so -2 precedes -10)
    while IFS= read -r dir; do
        name=$(basename "$dir")
        addr="${name%-*}"   # everything before the last '-' (addresses contain no '-')
        id="${name##*-}"    # everything after the last '-'
        meta="$dir/metaEvidence.json"

        if [ ! -f "$meta" ]; then
            emit_anomaly "$addr" "$id" "missing metaEvidence.json"
            n_missing=$((n_missing + 1))
        elif [ ! -s "$meta" ]; then
            emit_anomaly "$addr" "$id" "zero-byte file"
            n_zerobyte=$((n_zerobyte + 1))
        elif ! jq empty "$meta" >/dev/null 2>&1; then
            ftype=$(file -b "$meta" 2>/dev/null | cut -d, -f1)
            emit_anomaly "$addr" "$id" "not valid JSON${ftype:+ ($ftype)}"
            n_notjson=$((n_notjson + 1))
        else
            jq -r --arg addr "$addr" --arg id "$id" --arg gw "$GATEWAY" '
                # Collapse CR/LF runs to a single space so each row is one physical
                # line in the CSV (fields are still quoted by @csv for commas/quotes).
                def clean: gsub("[\\r\\n]+"; " ");
                [ $addr,
                  $id,
                  ((.category // "") | clean),
                  ((.subCategory // "") | clean),
                  (if (.fileURI // "") == "" then "" else $gw + (.fileURI | gsub(" "; "%20")) end),
                  ((.title // "") | clean),
                  ((.description // "") | clean),
                  (if (.metadata | type) == "object" then (.metadata | tojson) else "" end),
                  ([ (if (.category // "") == "" then "empty category" else empty end),
                     (if (.fileURI  // "") == "" then "no policy"      else empty end),
                     (if (.description // "") == "" then "empty description" else empty end)
                   ] | join("; "))
                ] | @csv' "$meta"
        fi

        rows=$((rows + 1))
    done < <(find "$CHAIN_DIR" -maxdepth 1 -type d -name '0x*-*' | sort -t- -k1,1 -k2,2n)
} > "$OUT"

# Summary to stderr
echo "Wrote $rows rows to $OUT" >&2
echo "  anomalies: missing=$n_missing zero-byte=$n_zerobyte not-json=$n_notjson" >&2
