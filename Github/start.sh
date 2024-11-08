#!/bin/bash
set -e

if [ -z "$1" ]
then
  export DEVOPS_DOCKER_REGISTRY_IMAGE_TAG=main
else
  export DEVOPS_DOCKER_REGISTRY_IMAGE_TAG=$1
fi

env
if [ "$SECRETS_JSON" != "null" ]
then
echo "$SECRETS_JSON" > secrets.json
while read -r variable
do
    if [ $variable != "DEVOPS_DOCKER_REGISTRY_URL" ] && [ $variable != "DEVOPS_DOCKER_REGISTRY_IMAGE_NAME" ] && [ $variable != "DEVOPS_DOCKER_REGISTRY_IMAGE_TAG" ] && [ $variable != "DEVOPS_DOCKER_REGISTRY_USER_NAME" ] && [ $variable != "DEVOPS_DOCKER_REGISTRY_PASSWORD" ]
    then
    env | grep $(echo $variable) >> env.list | exit 0
    fi
done < <(jq -r 'keys[]' secrets.json)
fi

if [ "$VARS_JSON" != "null" ]
then
echo "has values"
else
echo "no values in VARS_JSON"
fi

cat env.list