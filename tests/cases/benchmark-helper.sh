#!/usr/bin/env bash

setup_benchmark() {
  docker container kill benchmark || true
  docker container rm benchmark || true

  local DOCKER_RUN
  if [[ "$PLATFORM_FILTER" == *am62p* ]]; then
    DOCKER_RUN=$(read-docker-run.sh "/runs/benchmark/benchmark-am62p-compose.run" "benchmark-am62p" "benchmark")
  elif [[ "$PLATFORM_FILTER" == *am62* ]]; then
    DOCKER_RUN=$(read-docker-run.sh "/runs/benchmark/benchmark-am62-compose.run" "benchmark-am62" "benchmark")
  elif [[ "$PLATFORM_FILTER" == *am69* ]]; then
    DOCKER_RUN=$(read-docker-run.sh "/runs/benchmark/benchmark-am69-compose.run" "benchmark-am69" "benchmark")
  elif [[ "$PLATFORM_FILTER" == *imx8* ]]; then
    DOCKER_RUN=$(read-docker-run.sh "/runs/benchmark/benchmark-imx8-compose.run" "benchmark-imx8" "benchmark")
  elif [[ "$PLATFORM_FILTER" == *imx95* ]]; then
    DOCKER_RUN=$(read-docker-run.sh "/runs/benchmark/benchmark-imx95-compose.run" "benchmark-imx95" "benchmark")
  elif [[ "$PLATFORM_FILTER" == *sl1680* ]]; then
    DOCKER_RUN=$(read-docker-run.sh "/runs/benchmark/benchmark-sl1680-compose.run" "benchmark-sl1680" "benchmark")
  else
    DOCKER_RUN=$(read-docker-run.sh "/runs/benchmark/benchmark-upstream-compose.run" "benchmark" "benchmark")
  fi

  eval "$DOCKER_RUN"

  sleep 240
}

teardown_benchmark() {
  docker container kill benchmark || true

  IMAGE_ID=$(docker container inspect -f '{{.Image}}' "benchmark" 2>/dev/null)
  if [[ -n "$IMAGE_ID" ]]; then
    docker image rm -f "$IMAGE_ID" || true
  fi
  docker container rm "benchmark" || true
}
