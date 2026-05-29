#!/usr/bin/env bash

setup_flutter() {
  docker container kill flutter || true
  docker container rm flutter || true

  local DOCKER_RUN
  if [[ "$PLATFORM_FILTER" == *am62* ]]; then
    DOCKER_RUN=$(read-docker-run.sh "/runs/flutter/flutter-am62-compose.run" "flutter-am62" "flutter")
  elif [[ "$PLATFORM_FILTER" == *imx8* ]]; then
    DOCKER_RUN=$(read-docker-run.sh "/runs/flutter/flutter-imx8-compose.run" "flutter-imx8" "flutter")
  elif [[ "$PLATFORM_FILTER" == *imx95* ]]; then
    DOCKER_RUN=$(read-docker-run.sh "/runs/flutter/flutter-imx95-compose.run" "flutter-imx95" "flutter")
  else
    echo "Error: Unsupported platform filter: $PLATFORM_FILTER"
    return 1
  fi

  # Add -it flag to match the original behavior
  DOCKER_RUN=${DOCKER_RUN//-d --name=/-d -it --name=}

  eval "$DOCKER_RUN"

  sleep 10

  check_if_base_container_runs flutter

}

teardown_flutter() {
  cleanup_container flutter
}
