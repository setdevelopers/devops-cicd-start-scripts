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

env | grep 'BITBUCKET_REPO_SLUG=' >> env.list | exit 0
env | grep 'BITBUCKET_GIT_HTTP_ORIGIN=' >> env.list | exit 0
env | grep 'BITBUCKET_BRANCH=' >> env.list | exit 0
env | grep 'BITBUCKET_PR_ID=' >> env.list | exit 0
env | grep 'BITBUCKET_PR_DESTINATION_BRANCH=' >> env.list | exit 0
env | grep 'BITBUCKET_COMMIT=' >> env.list | exit 0

docker login $DEVOPS_DOCKER_REGISTRY_URL --username "$DEVOPS_DOCKER_REGISTRY_USER_NAME" --password-stdin <<< $DEVOPS_DOCKER_REGISTRY_PASSWORD
echo "SETDEVELOPERS - DevOps.CiCd.Manager"
echo "Downloading..."
docker pull --quiet $DEVOPS_DOCKER_REGISTRY_URL/$DEVOPS_DOCKER_REGISTRY_IMAGE_NAME:$DEVOPS_DOCKER_REGISTRY_IMAGE_TAG
echo "SETDEVELOPERS - DevOps.CiCd.Manager"
echo "Starting..."
docker run --quiet --privileged --env-file env.list $DEVOPS_DOCKER_REGISTRY_URL/$DEVOPS_DOCKER_REGISTRY_IMAGE_NAME:$DEVOPS_DOCKER_REGISTRY_IMAGE_TAG