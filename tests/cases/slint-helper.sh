#!/usr/bin/env bash

setup_slint() {
  docker container kill slint || true
  docker container rm slint || true

  local DOCKER_RUN
  if [[ "$PLATFORM_FILTER" == *am62* ]]; then
    DOCKER_RUN=$(read-docker-run.sh "/runs/slint/slint-am62-compose.run" "slint-am62" "slint")
  elif [[ "$PLATFORM_FILTER" == *imx8* ]]; then
    DOCKER_RUN=$(read-docker-run.sh "/runs/slint/slint-imx8-compose.run" "slint-imx8" "slint")
  elif [[ "$PLATFORM_FILTER" == *imx95* ]]; then
    DOCKER_RUN=$(read-docker-run.sh "/runs/slint/slint-imx95-compose.run" "slint-imx95" "slint")
  else
    DOCKER_RUN=$(read-docker-run.sh "/runs/slint/slint-upstream-compose.run" "slint" "slint")
  fi

  # Add -it flag to match the original behavior
  DOCKER_RUN=${DOCKER_RUN//-d --name=/-d -it --name=}

  eval "$DOCKER_RUN"

  sleep 10

  check_if_base_container_runs slint

}

teardown_slint() {
  cleanup_container slint
}
