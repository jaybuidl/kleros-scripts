gh repo list kleros --limit 20 --no-archived --json "nameWithOwner,defaultBranchRef" | jq -c '.[]' | while read j; do
    nameWithOwner=$(jq -r '.nameWithOwner' <<<"$j")
    defaultBranch=$(jq -r '.defaultBranchRef.name' <<<"$j")
    echo -n "{\"$nameWithOwner\": "
    users=$(gh api repos/$nameWithOwner/collaborators --jq 'map(select((.role_name == "maintain" or .role_name == "admin") and .login != "clesaege" and .login != "federicoast" and .login != "jaybuidl") |  {user: .login, role: .role_name})')
    if [[ -z "$users" ]]; then
        users="[]"
    fi
    teams=$(gh api repos/$nameWithOwner/teams --jq 'map({team: .name, role: .permission})')
    echo "$users $teams" | jq -s add
    echo "},"
done
