#!/bin/bash
set -e

curl --proto "=https" --tlsv1.2 -sSf -L "https://api.bitbucket.org/2.0/repositories/$BITBUCKET_WORKSPACE/$BITBUCKET_REPO_SLUG/pipelines_config/variables" --header "Authorization: Bearer $BITBUCKET_TOKEN" --header "Accept: application/json" > variables.json

while read -r key
do
  if [ $key != "DEVOPS_DOCKER_REGISTRY_URL" ] && [ $key != "DEVOPS_DOCKER_REGISTRY_IMAGE_NAME" ] && [ $key != "DEVOPS_DOCKER_REGISTRY_IMAGE_TAG" ] && [ $key != "DEVOPS_DOCKER_REGISTRY_USER_NAME" ] && [ $key != "DEVOPS_DOCKER_REGISTRY_PASSWORD" ]
  then
    env | grep $(echo "$key=") >> env.list | exit 0
  fi
done < <(jq -r '.values[].key' variables.json)

cat env.list