#!/usr/bin/env bash

setup_lvgl() {
  docker container kill lvgl || true
  docker container rm lvgl || true

  local DOCKER_RUN
  if [[ "$PLATFORM_FILTER" == *am62p* ]]; then
    DOCKER_RUN=$(read-docker-run.sh "/runs/lvgl/lvgl-am62p-compose.run" "lvgl-am62p" "lvgl")
  else
    echo "Error: Unsupported platform filter: $PLATFORM_FILTER"
    return 1
  fi

  # Add -it flag to match the original behavior
  DOCKER_RUN=${DOCKER_RUN//-d --name=/-d -it --name=}

  eval "$DOCKER_RUN"

  sleep 10

  check_if_base_container_runs lvgl

}

teardown_lvgl() {
  cleanup_container lvgl
}
