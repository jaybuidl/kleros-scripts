#!/usr/bin/env bash

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)"
ROOT_DIR="$(git rev-parse --show-toplevel)"

nameWithOwner=$(gh repo view --json nameWithOwner | jq -r .nameWithOwner)
branch=$(git rev-parse --abbrev-ref HEAD)

_title() {
  echo "$(tput bold)$(tput setaf 202)${@}$(tput sgr0)"
}

_title "✨ Repo maintainers"
gh api repos/$nameWithOwner/collaborators --jq '.[] | select ( .permissions.maintain == true ) | .login, .permissions'

echo

_title "✨ Repo environments reviewers"
ghEnvs="$(gh api repos/$nameWithOwner/environments | jq .environments)"
for row in $(echo "${ghEnvs}" | jq -r '.[] | @base64'); do
  _jq() {
    echo ${row} | base64 --decode | jq -r ${@}
  }
  echo "🔒 $(_jq '.name')"
  echo $(_jq '.protection_rules[]') | jq '. 
    | select(.type == "required_reviewers") 
    | { 
      "prevent_self_review" : .prevent_self_review, 
      "reviewers" : [ .reviewers[].reviewer.login ] 
    }'
  echo
done

_title "✨ Repo branch protection"
protectedBranches=$(gh api repos/$nameWithOwner/branches --paginate --jq '.[] 
  | select([.name] | inside(["master", "main", "dev", "development"]))
  | select(.protection.enabled == true) 
  | .name')
for protectedBranch in $protectedBranches
do
  echo "🔒 $protectedBranch"
  gh api repos/$nameWithOwner/branches/$protectedBranch/protection | 
    jq 'walk(if type == "object" then with_entries(select(.key | (endswith("url") or endswith("checks")) | not)) else . end) 
      | {
        "required_pull_request_reviews": .required_pull_request_reviews,
        "required_signatures": .required_signatures.enabled,
        "enforce_admins": .enforce_admins.enabled,
        "required_linear_history": .required_linear_history.enabled,
        "allow_force_pushes": .allow_force_pushes.enabled,
        "allow_deletions": .allow_deletions.enabled,
        "block_creations": .block_creations.enabled,
        "required_conversation_resolution": .required_conversation_resolution.enabled,
        "lock_branch": .lock_branch.enabled,
        "allow_fork_syncing": .allow_fork_syncing.enabled,
      }
    '
  echo
done

_title "✨ Repo ruleset"
gh ruleset list

echo

_title "✨ Code owners (in the current branch $branch)"
for f in "$ROOT_DIR/CODEOWNERS" "$ROOT_DIR/.github/CODEOWNERS" "$ROOT_DIR/docs/CODEOWNERS"; do
  [ -f $f ] && echo "$f" && cat $f
done
