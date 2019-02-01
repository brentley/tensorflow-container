#!/bin/bash

set -e

DOCKER_ID=${DOCKER_USERNAME}
GIT_TAG=$(git rev-parse --short HEAD)

echo "${DOCKER_PASSWORD}" | docker login -u "${DOCKER_USERNAME}" --password-stdin

for i in cpu gpu
do
docker push ${DOCKER_ID}/tensorflow-${i}:${GIT_TAG}
docker push ${DOCKER_ID}/tensorflow-${i}:latest
done
