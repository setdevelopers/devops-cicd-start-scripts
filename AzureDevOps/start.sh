#!/bin/bash
set -e

if [ -z "$1" ]
then
  export DEVOPS_DOCKER_REGISTRY_IMAGE_TAG=main
else
  export DEVOPS_DOCKER_REGISTRY_IMAGE_TAG=$1
fi

export AZURE_DEVOPS_EXT_PAT=$SYSTEM_ACCESSTOKEN
az pipelines variable list --organization $SYSTEM_COLLECTIONURI --project $SYSTEM_TEAMPROJECTID --pipeline-id $SYSTEM_DEFINITIONID > variables.json

while read -r variable
do
  if [ $variable != "DEVOPS_DOCKER_REGISTRY_URL" ] && [ $variable != "DEVOPS_DOCKER_REGISTRY_IMAGE_NAME" ] && [ $variable != "DEVOPS_DOCKER_REGISTRY_IMAGE_TAG" ] && [ $variable != "DEVOPS_DOCKER_REGISTRY_USER_NAME" ] && [ $variable != "DEVOPS_DOCKER_REGISTRY_PASSWORD" ]
  then
    env | grep $(echo $variable) >> env.list
  fi
done < <(jq -r 'keys[]' variables.json)

env | grep 'SYSTEM_ACCESSTOKEN=' >> env.list | exit 0
env | grep 'BUILD_REPOSITORY_URI=' >> env.list | exit 0
env | grep 'BUILD_REPOSITORY_NAME=' >> env.list | exit 0
env | grep 'BUILD_SOURCEBRANCH=' >> env.list | exit 0
env | grep 'BUILD_SOURCEVERSION=' >> env.list | exit 0
env | grep 'SYSTEM_PULLREQUEST_PULLREQUESTID=' >> env.list | exit 0
env | grep 'SYSTEM_PULLREQUEST_SOURCEBRANCH=' >> env.list | exit 0
env | grep 'SYSTEM_PULLREQUEST_TARGETBRANCH=' >> env.list | exit 0

docker login $DEVOPS_DOCKER_REGISTRY_URL --username "$DEVOPS_DOCKER_REGISTRY_USER_NAME" --password-stdin <<< $DEVOPS_DOCKER_REGISTRY_PASSWORD
docker run --quiet --env-file env.list $DEVOPS_DOCKER_REGISTRY_URL/$DEVOPS_DOCKER_REGISTRY_IMAGE_NAME:$DEVOPS_DOCKER_REGISTRY_IMAGE_TAG