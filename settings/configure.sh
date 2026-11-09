#!/usr/bin/env bash
# Applies the organization's standard settings to repositories of nestor-home:
#   squash merge only, the pull request title as the whole commit message (release-please reads only that),
#   branches deleted on merge,
#   auto-merge allowed, and the rulesets in this folder (main and release tags).
#
#   settings/configure.sh nestor nestor-web ...     (needs gh with the repo and admin:org scopes)
#
# Every repository's CI must end with a job named `ci` and run the `PR title` workflow, the two
# checks the main ruleset requires.
set -euo pipefail
cd -- "$(dirname -- "${BASH_SOURCE[0]}")"
org=nestor-home

for repo in "$@"; do
  gh api --method PATCH "repos/$org/$repo" --silent \
    -F allow_squash_merge=true -F allow_merge_commit=false -F allow_rebase_merge=false \
    -f squash_merge_commit_title=PR_TITLE -f squash_merge_commit_message=BLANK \
    -F delete_branch_on_merge=true -F allow_auto_merge=true -F allow_update_branch=true
  for file in ruleset-*.json; do
    name=$(jq -r .name "$file")
    id=$(gh api "repos/$org/$repo/rulesets" --jq ".[] | select(.name == \"$name\") | .id")
    if [[ -n "$id" ]]; then
      gh api --method PUT "repos/$org/$repo/rulesets/$id" --input "$file" --silent
    else
      gh api --method POST "repos/$org/$repo/rulesets" --input "$file" --silent
    fi
  done
  echo "$org/$repo configured"
done
