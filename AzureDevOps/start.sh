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

while read -r key
do
  if [ $key != "DEVOPS_DOCKER_REGISTRY_URL" ] && [ $key != "DEVOPS_DOCKER_REGISTRY_IMAGE_NAME" ] && [ $key != "DEVOPS_DOCKER_REGISTRY_IMAGE_TAG" ] && [ $key != "DEVOPS_DOCKER_REGISTRY_USER_NAME" ] && [ $key != "DEVOPS_DOCKER_REGISTRY_PASSWORD" ]
  then
    env | grep $(echo "$key=") >> env.list | exit 0
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
env | grep 'SYSTEM_PULLREQUEST_SOURCECOMMITID=' >> env.list | exit 0

docker login $DEVOPS_DOCKER_REGISTRY_URL --username "$DEVOPS_DOCKER_REGISTRY_USER_NAME" --password-stdin <<< $DEVOPS_DOCKER_REGISTRY_PASSWORD
echo "SETDEVELOPERS - DevOps.CiCd.Manager"
echo "Downloading..."
docker pull --quiet $DEVOPS_DOCKER_REGISTRY_URL/$DEVOPS_DOCKER_REGISTRY_IMAGE_NAME:$DEVOPS_DOCKER_REGISTRY_IMAGE_TAG
echo "SETDEVELOPERS - DevOps.CiCd.Manager"
echo "Starting..."
docker run --quiet --privileged --env-file env.list $DEVOPS_DOCKER_REGISTRY_URL/$DEVOPS_DOCKER_REGISTRY_IMAGE_NAME:$DEVOPS_DOCKER_REGISTRY_IMAGE_TAG