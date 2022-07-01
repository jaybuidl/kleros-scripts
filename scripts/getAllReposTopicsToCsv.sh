#!/bin/bash

function getPage() #pageNumber
{
  local page=$1
  curl --silent -H "Accept: application/vnd.github.v3+json" -H "Authorization: token $GHTOKEN" "https://api.github.com/orgs/kleros/repos?per_page=50&page=$page"
}

function getPoHPage() #pageNumber
{
  local page=$1
  curl --silent -H "Accept: application/vnd.github.v3+json" -H "Authorization: token $GHTOKEN" "https://api.github.com/orgs/Proof-Of-Humanity/repos?per_page=50&page=$page"
}

function getPages()
{
getPage 1
sleep 1
getPage 2
sleep 1
getPage 3
sleep 1
getPage 4
sleep 1
getPoHPage 1
}

getPages | jq -r ' .[] | select(.private == false) | .html_url + "," + (.topics | @csv) ' | sort
