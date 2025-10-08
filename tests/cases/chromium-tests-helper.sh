#!/usr/bin/env bash

setup_chromium_tests() {
  docker container kill chromium-tests || true
  docker container rm chromium-tests || true

  local DOCKER_RUN
  if [[ "$PLATFORM_FILTER" == *am62p* ]]; then
    DOCKER_RUN=$(read-docker-run.sh "/runs/chromium-tests/chromium-tests-am62p-compose.run" "chromium-tests-am62p" "chromium-tests")
  elif [[ "$PLATFORM_FILTER" == *am62* ]]; then
    DOCKER_RUN=$(read-docker-run.sh "/runs/chromium-tests/chromium-tests-am62-compose.run" "chromium-tests-am62" "chromium-tests")
  elif [[ "$PLATFORM_FILTER" == *am69* ]]; then
    DOCKER_RUN=$(read-docker-run.sh "/runs/chromium-tests/chromium-tests-am69-compose.run" "chromium-tests-am69" "chromium-tests")
  elif [[ "$PLATFORM_FILTER" == *imx8* ]]; then
    DOCKER_RUN=$(read-docker-run.sh "/runs/chromium-tests/chromium-tests-imx8-compose.run" "chromium-tests-imx8" "chromium-tests")
  elif [[ "$PLATFORM_FILTER" == *sl1680* ]]; then
    DOCKER_RUN=$(read-docker-run.sh "/runs/chromium-tests/chromium-tests-sl1680-compose.run" "chromium-tests-sl1680" "chromium-tests")
  elif [[ "$PLATFORM_FILTER" == *imx95* ]]; then
    DOCKER_RUN=$(read-docker-run.sh "/runs/chromium-tests/chromium-tests-imx95-compose.run" "chromium-tests-imx95" "chromium-tests")
  else
    DOCKER_RUN=$(read-docker-run.sh "/runs/chromium-tests/chromium-tests-upstream-compose.run" "chromium-tests" "chromium-tests")
  fi

  eval "$DOCKER_RUN"

  sleep 240
}

teardown_chromium_tests() {
  docker container kill chromium-tests || true

  IMAGE_ID=$(docker container inspect -f '{{.Image}}' "chromium-tests" 2>/dev/null)
  if [[ -n "$IMAGE_ID" ]]; then
    docker image rm -f "$IMAGE_ID" || true
  fi
  docker container rm "chromium-tests" || true
}
