#!/bin/bash
set -e

if [ -z "$1" ]
then
  export DEVOPS_DOCKER_REGISTRY_IMAGE_TAG=main
else
  export DEVOPS_DOCKER_REGISTRY_IMAGE_TAG=$1
fi

curl --proto "=https" --tlsv1.2 -sSf -L "https://gitlab.com/api/v4/projects/$CI_PROJECT_ID/variables" --header "PRIVATE-TOKEN: $GITLAB_TOKEN" > variables.json

while read -r key
do
  if [ $key != "DEVOPS_DOCKER_REGISTRY_URL" ] && [ $key != "DEVOPS_DOCKER_REGISTRY_IMAGE_NAME" ] && [ $key != "DEVOPS_DOCKER_REGISTRY_IMAGE_TAG" ] && [ $key != "DEVOPS_DOCKER_REGISTRY_USER_NAME" ] && [ $key != "DEVOPS_DOCKER_REGISTRY_PASSWORD" ]
  then
    env | grep $(echo "$key=") >> env.list | exit 0
  fi
done < <(jq -r '.[].key' variables.json)

env | grep 'CI_PROJECT_URL=' >> env.list | exit 0
env | grep 'CI_PROJECT_NAME=' >> env.list | exit 0
env | grep 'CI_COMMIT_REF_NAME=' >> env.list | exit 0
env | grep 'CI_COMMIT_SHA=' >> env.list | exit 0
env | grep 'CI_PIPELINE_SOURCE=' >> env.list | exit 0
env | grep 'CI_MERGE_REQUEST_IID=' >> env.list | exit 0
env | grep 'CI_MERGE_REQUEST_SOURCE_BRANCH_NAME=' >> env.list | exit 0
env | grep 'CI_MERGE_REQUEST_TARGET_BRANCH_NAME=' >> env.list | exit 0

docker login $DEVOPS_DOCKER_REGISTRY_URL --username "$DEVOPS_DOCKER_REGISTRY_USER_NAME" --password-stdin <<< $DEVOPS_DOCKER_REGISTRY_PASSWORD
echo "SETDEVELOPERS - DevOps.CiCd.Manager"
echo "Downloading..."
docker pull --quiet $DEVOPS_DOCKER_REGISTRY_URL/$DEVOPS_DOCKER_REGISTRY_IMAGE_NAME:$DEVOPS_DOCKER_REGISTRY_IMAGE_TAG
echo "SETDEVELOPERS - DevOps.CiCd.Manager"
echo "Starting..."
docker run --privileged --env-file env.list $DEVOPS_DOCKER_REGISTRY_URL/$DEVOPS_DOCKER_REGISTRY_IMAGE_NAME:$DEVOPS_DOCKER_REGISTRY_IMAGE_TAG