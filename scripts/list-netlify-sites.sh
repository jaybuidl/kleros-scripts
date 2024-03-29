#!/usr/bin/env bash

netlify sites:list --json | jq '[
  .[] 
  | select(.account_slug == "kleros")
  | with_entries(select(.key | in({"name":1, "url":1, "deploy_url":1, "published_deploy":1, "build_settings":1}))) 
  | .repo_branch = .build_settings.repo_branch 
  | .repo_url = .build_settings.repo_url 
  | .allowed_branches = .build_settings.allowed_branches 
  | .available_functions = [.published_deploy.available_functions[]?.n]
  | del(.published_deploy) 
  | del(.build_settings)
]'