#!/bin/bash

set -e

DOCKER_ID=${DOCKER_USERNAME}
GIT_TAG=$(git rev-parse --short HEAD)

for i in cpu gpu
do
docker build -t ${DOCKER_ID}/tensorflow-${i}:${GIT_TAG} --target tensorflow-${i} .
docker tag ${DOCKER_ID}/tensorflow-${i}:${GIT_TAG} ${DOCKER_ID}/tensorflow-${i}:latest
done
