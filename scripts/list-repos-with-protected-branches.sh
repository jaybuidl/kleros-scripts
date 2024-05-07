gh repo list kleros --limit 200 --no-archived --json "nameWithOwner,defaultBranchRef" | jq -c '.[]' | while read j; do
    nameWithOwner=$(jq -r '.nameWithOwner' <<<"$j")
    defaultBranch=$(jq -r '.defaultBranchRef.name' <<<"$j")
    echo -n "\"$nameWithOwner\": "
    gh api repos/$nameWithOwner/branches -f 'protected=true' -X GET | jq '[.[].name ]'
    echo ","
done
