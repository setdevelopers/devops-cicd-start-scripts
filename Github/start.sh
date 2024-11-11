#!/bin/bash
set -e

if [ -z "$1" ]
then
  export DEVOPS_DOCKER_REGISTRY_IMAGE_TAG=main
else
  export DEVOPS_DOCKER_REGISTRY_IMAGE_TAG=$1
fi

if [ "$SECRETS_JSON" != "null" ]
then
  echo "$SECRETS_JSON" > secrets.json
  while read -r key
  do
    value=$(jq -r ".$key" secrets.json)

    if [ "$key" == "DEVOPS_DOCKER_REGISTRY_URL" ] 
    then
      export DEVOPS_DOCKER_REGISTRY_URL=$value
    elif [ "$key" == "DEVOPS_DOCKER_REGISTRY_IMAGE_NAME" ]
    then
      export DEVOPS_DOCKER_REGISTRY_IMAGE_NAME=$value
    elif [ "$key" == "DEVOPS_DOCKER_REGISTRY_IMAGE_TAG" ]
    then
      export DEVOPS_DOCKER_REGISTRY_IMAGE_TAG=$value
    elif [ "$key" == "DEVOPS_DOCKER_REGISTRY_USER_NAME" ]
    then
      export DEVOPS_DOCKER_REGISTRY_USER_NAME=$value
    elif [ "$key" == "DEVOPS_DOCKER_REGISTRY_PASSWORD" ]
    then
      export DEVOPS_DOCKER_REGISTRY_PASSWORD=$value
    elif [ "$key" == "github_token" ]
    then
      echo "GITHUB_TOKEN=$value" >> env.list | exit 0
    else
      echo "$key=$value" >> env.list | exit 0
    fi
  done < <(jq -r 'keys[]' secrets.json)
  rm secrets.json
fi

if [ "$VARS_JSON" != "null" ]
then
  echo "$VARS_JSON" > vars.json
  while read -r key
  do
    value=$(jq -r ".$key" vars.json)
    echo "$key=$value" >> env.list | exit 0
  done < <(jq -r 'keys[]' vars.json)
  rm vars.json
fi

env | grep 'GITHUB_SERVER_URL=' >> env.list | exit 0
env | grep 'GITHUB_REPOSITORY=' >> env.list | exit 0
env | grep 'GITHUB_EVENT_NAME=' >> env.list | exit 0
env | grep 'GITHUB_BASE_REF=' >> env.list | exit 0
env | grep 'GITHUB_HEAD_REF=' >> env.list | exit 0
env | grep 'GITHUB_REF=' >> env.list | exit 0
env | grep 'GITHUB_SHA=' >> env.list | exit 0
env | grep 'PULLREQUEST_SOURCE_BRANCH_COMMIT=' >> env.list | exit 0

docker login $DEVOPS_DOCKER_REGISTRY_URL --username "$DEVOPS_DOCKER_REGISTRY_USER_NAME" --password-stdin <<< $DEVOPS_DOCKER_REGISTRY_PASSWORD
echo "SETDEVELOPERS - DevOps.CiCd.Manager"
echo "Downloading..."
docker pull --quiet $DEVOPS_DOCKER_REGISTRY_URL/$DEVOPS_DOCKER_REGISTRY_IMAGE_NAME:$DEVOPS_DOCKER_REGISTRY_IMAGE_TAG
echo "SETDEVELOPERS - DevOps.CiCd.Manager"
echo "Starting..."
docker run --quiet --env-file env.list $DEVOPS_DOCKER_REGISTRY_URL/$DEVOPS_DOCKER_REGISTRY_IMAGE_NAME:$DEVOPS_DOCKER_REGISTRY_IMAGE_TAG