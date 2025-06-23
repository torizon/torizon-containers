#!/usr/bin/env bash

setup_weston() {
  docker container kill weston || true
  docker container rm weston || true

  local DOCKER_RUN
  if [[ "$PLATFORM_FILTER" == *am62p* ]]; then
    DOCKER_RUN=$(read-docker-run.sh "/runs/weston/weston-am62p-compose.run" "weston-am62p" "weston")
  elif [[ "$PLATFORM_FILTER" == *am62* ]]; then
    DOCKER_RUN=$(read-docker-run.sh "/runs/weston/weston-am62-compose.run" "weston-am62" "weston")
  elif [[ "$PLATFORM_FILTER" == *imx8* ]]; then
    DOCKER_RUN=$(read-docker-run.sh "/runs/weston/weston-imx8-compose.run" "weston-imx8" "weston")
  else
    DOCKER_RUN=$(read-docker-run.sh "/runs/weston/weston-upstream-compose.run" "weston" "weston")
  fi

  eval "$DOCKER_RUN"

  sleep 30
}

weston_container_logs() {
  docker logs weston
}

is_weston_running() {
  docker container ls | grep -q weston
  status=$?

  if [[ "$status" -ne 0 ]]; then
    echo "Weston container is not running"
    exit 1
  else
    echo "Weston container is running"
  fi
}

teardown_weston() {
  docker container kill weston || true

  IMAGE_ID=$(docker container inspect -f '{{.Image}}' weston 2>/dev/null)
  if [[ -n "$IMAGE_ID" ]]; then
    docker image rm -f "$IMAGE_ID" || true
  fi

  docker container rm weston || true
}
