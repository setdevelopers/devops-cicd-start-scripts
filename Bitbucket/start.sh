#!/bin/bash
set -e

curl --proto "=https" --tlsv1.2 -sSf -L "https://api.bitbucket.org/2.0/repositories/$BITBUCKET_WORKSPACE/$BITBUCKET_REPO_SLUG/pipelines_config/variables" --header "Authorization: Bearer $BITBUCKET_TOKEN" --header "Accept: application/json" > variables.json

cat variables.json