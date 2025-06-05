#!/usr/bin/env bash

setup_qt6_enterprise() {
  docker container kill qt6-enterprise || true
  docker container rm qt6-enterprise || true

  local DOCKER_RUN
  if [[ "$PLATFORM_FILTER" == *imx8* ]]; then
    DOCKER_RUN=$(read-docker-run.sh "/runs/qt6-enterprise/qt6-enterprise-imx8-compose.run" "qt6-enterprise-imx8" "qt6-enterprise" "bash")
  fi

  eval "$DOCKER_RUN"

  sleep 30
}

teardown_qt6_enterprise() {
  docker container kill qt6-enterprise || true

  IMAGE_ID=$(docker container inspect -f '{{.Image}}' "qt6-enterprise" 2>/dev/null)
  if [[ -n "$IMAGE_ID" ]]; then
    docker image rm -f "$IMAGE_ID" || true
  fi
  docker container rm "qt6-enterprise" || true
}
