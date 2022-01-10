#!/bin/bash

npm list -g npm-dependants || npm install -g npm-dependants

for p in $(npm search @kleros --parseable | cut -f1 | sort)
do
  echo $p
  npm-dependants $p  | sed 's/^/├─ /g'
  echo
done
