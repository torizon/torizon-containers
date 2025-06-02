#!/usr/bin/env bash

setup_qt5() {
  docker container kill qt5-wayland-examples || true
  docker container rm qt5-wayland-examples || true

  local DOCKER_RUN
  if [[ "$PLATFORM_FILTER" == *am62* ]]; then
    DOCKER_RUN=$(read-docker-run.sh "/runs/qt5-wayland-examples/qt5-wayland-examples-am62-compose.run" "qt5-wayland-examples-am62" "qt5-wayland-examples")
  elif [[ "$PLATFORM_FILTER" == *imx8* ]]; then
    DOCKER_RUN=$(read-docker-run.sh "/runs/qt5-wayland-examples/qt5-wayland-examples-imx8-compose.run" "qt5-wayland-examples-imx8" "qt5-wayland-examples")
  else
    DOCKER_RUN=$(read-docker-run.sh "/runs/qt5-wayland-examples/qt5-wayland-examples-upstream-compose.run" "qt5-wayland-examples" "qt5-wayland-examples")
  fi

  # Add -it flag to match the original behavior
  DOCKER_RUN=${DOCKER_RUN//-d --name=/-d -it --name=}

  eval "$DOCKER_RUN"

  sleep 10

  check_if_base_container_runs qt5-wayland-examples
}

teardown_qt5() {
  cleanup_container qt5-wayland-examples
}
