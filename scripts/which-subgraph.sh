#!/usr/bin/env bash

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
ROOT_DIR="$(git rev-parse --show-toplevel)"

_title() {
  echo "$(tput bold)$(tput setaf 202)${@}$(tput sgr0)"
}

_title "✨ Code"
find "$ROOT_DIR" \
    -not \( \( \
        -name ".git" -or \
        -name "node_modules" -or \
        -name build  -or \
        -name dist -or \
        -name cache -or \
        -name "postgres" \
    \) -prune \) \
    -type f \
    -exec grep -HI api.thegraph.com {} \;
echo 

cd - 2>&1 >/dev/null

for context in production dev deploy-preview branch-preview
do 
  _title "✨ Netlify $context"
  netlify env:list --context $context --plain | grep -i graph 
  echo
done
