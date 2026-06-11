#!/usr/bin/env bash

CONTAINER_NAME=tensorflow-lite-examples
TIME_TO_SLEEP=10

setup_tensorflow() {
  docker container kill ${CONTAINER_NAME} || true
  docker container rm ${CONTAINER_NAME} || true

  local DOCKER_RUN
  if [[ "$PLATFORM_FILTER" == *imx95* ]]; then
    DOCKER_RUN=$(read-docker-run.sh "/runs/${CONTAINER_NAME}/${CONTAINER_NAME}-imx95-compose.run" "${CONTAINER_NAME}-imx95" "${CONTAINER_NAME}")
  elif [[ "$PLATFORM_FILTER" == *imx8* ]]; then
    DOCKER_RUN=$(read-docker-run.sh "/runs/${CONTAINER_NAME}/${CONTAINER_NAME}-imx8-compose.run" "${CONTAINER_NAME}-imx8" "${CONTAINER_NAME}")
  elif [[ "$PLATFORM_FILTER" == *sl1680* ]]; then
    DOCKER_RUN=$(read-docker-run.sh "/runs/${CONTAINER_NAME}/${CONTAINER_NAME}-sl1680-compose.run" "${CONTAINER_NAME}-sl1680" "${CONTAINER_NAME}")
  else
    DOCKER_RUN="false"
  fi

  eval "$DOCKER_RUN"

  sleep ${TIME_TO_SLEEP}
}

teardown_tensorflow() {
  docker container kill ${CONTAINER_NAME} || true

  IMAGE_ID=$(docker container inspect -f '{{.Image}}' "${CONTAINER_NAME}" 2>/dev/null)
  if [[ -n "$IMAGE_ID" ]]; then
    docker image rm -f "$IMAGE_ID" || true
  fi
  docker container rm "${CONTAINER_NAME}" || true
}
