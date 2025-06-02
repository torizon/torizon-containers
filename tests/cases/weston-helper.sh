#!/usr/bin/env bash

setup_weston() {
  WESTON_RUN_AM62=$(read-docker-run.sh "/runs/weston/weston-am62-compose.run" "weston-am62" "weston")
  WESTON_RUN_IMX8=$(read-docker-run.sh "/runs/weston/weston-imx8-compose.run" "weston-imx8" "weston")
  WESTON_RUN_UPSTREAM=$(read-docker-run.sh "/runs/weston/weston-upstream-compose.run" "weston" "weston")

  docker container kill weston || true
  docker container rm weston || true

  local DOCKER_RUN
  if [[ "$PLATFORM_FILTER" == *am62* ]]; then
    DOCKER_RUN="$WESTON_RUN_AM62"
  elif [[ "$PLATFORM_FILTER" == *imx8* ]]; then
    DOCKER_RUN="$WESTON_RUN_IMX8"
  else
    DOCKER_RUN="$WESTON_RUN_UPSTREAM"
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
