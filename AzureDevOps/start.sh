#!/bin/bash
set -e

export AZURE_DEVOPS_EXT_PAT=$1
az pipelines variable list --organization $2 --project $3 --pipeline-id $4 > variables.json

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

cat env.list

docker login $DEVOPS_DOCKER_REGISTRY_URL --username "$DEVOPS_DOCKER_REGISTRY_USER_NAME" --password-stdin <<< $DEVOPS_DOCKER_REGISTRY_PASSWORD
docker run --env-file env.list $DEVOPS_DOCKER_REGISTRY_URL/$DEVOPS_DOCKER_REGISTRY_IMAGE_NAME:$5