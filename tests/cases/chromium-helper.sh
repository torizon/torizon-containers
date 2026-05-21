#!/usr/bin/env bash

setup_chromium() {
  docker container kill chromium || true
  docker container rm chromium || true

  local DOCKER_RUN
  if [[ "$PLATFORM_FILTER" == *am62* ]]; then
    DOCKER_RUN=$(read-docker-run.sh "/runs/chromium/chromium-am62-compose.run" "chromium-am62" "chromium")
  elif [[ "$PLATFORM_FILTER" == *am67a* ]]; then
    DOCKER_RUN=$(read-docker-run.sh "/runs/chromium/chromium-am67a-compose.run" "chromium-am67a" "chromium")
  elif [[ "$PLATFORM_FILTER" == *am69* ]]; then
    DOCKER_RUN=$(read-docker-run.sh "/runs/chromium/chromium-am69-compose.run" "chromium-am69" "chromium")
  elif [[ "$PLATFORM_FILTER" == *imx8* ]]; then
    DOCKER_RUN=$(read-docker-run.sh "/runs/chromium/chromium-imx8-compose.run" "chromium-imx8" "chromium")
  elif [[ "$PLATFORM_FILTER" == *imx93* ]]; then
    DOCKER_RUN=$(read-docker-run.sh "/runs/chromium/chromium-imx93-compose.run" "chromium-imx93" "chromium")
  elif [[ "$PLATFORM_FILTER" == *imx95* ]]; then
    DOCKER_RUN=$(read-docker-run.sh "/runs/chromium/chromium-imx95-compose.run" "chromium-imx95" "chromium")
  elif [[ "$PLATFORM_FILTER" == *sl1680* ]]; then
    DOCKER_RUN=$(read-docker-run.sh "/runs/chromium/chromium-sl1680-compose.run" "chromium-sl1680" "chromium")
  else
    DOCKER_RUN=$(read-docker-run.sh "/runs/chromium/chromium-upstream-compose.run" "chromium" "chromium")
  fi

  eval "$DOCKER_RUN"

  sleep 40
}

teardown_chromium() {
  docker container kill chromium || true

  IMAGE_ID=$(docker container inspect -f '{{.Image}}' "chromium" 2>/dev/null)
  if [[ -n "$IMAGE_ID" ]]; then
    docker image rm -f "$IMAGE_ID" || true
  fi
  docker container rm "chromium" || true
}
