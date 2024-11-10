#!/bin/bash
set -e

curl --request GET --url 'https://api.bitbucket.org/2.0/repositories/${BITBUCKET_WORKSPACE}/${BITBUCKET_REPO_SLUG}/deployments_config/environments/${BITBUCKET_DEPLOYMENT_ENVIRONMENT_UUID}/variables' --header "Authorization: Bearer ${BITBUCKET_TOKEN}" --header "Accept: application/json"