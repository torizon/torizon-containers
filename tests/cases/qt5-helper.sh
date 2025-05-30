#!/usr/bin/env bash

setup_qt5() {
  QT5_WAYLAND_EXAMPLES_RUN_AM62=$(read-docker-run.sh "runs/qt5-wayland-examples/qt5-wayland-examples-am62-compose.run" "qt5-wayland-examples-am62" "qt5-wayland-examples")
  QT5_WAYLAND_EXAMPLES_RUN_IMX8=$(read-docker-run.sh "runs/qt5-wayland-examples/qt5-wayland-examples-imx8-compose.run" "qt5-wayland-examples-imx8" "qt5-wayland-examples")
  QT5_WAYLAND_EXAMPLES_RUN_UPSTREAM=$(read-docker-run.sh "runs/qt5-wayland-examples/qt5-wayland-examples-upstream-compose.run" "qt5-wayland-examples" "qt5-wayland-examples")

  docker container kill qt5-wayland-examples || true
  docker container rm qt5-wayland-examples || true

  local DOCKER_RUN
  if [[ "$PLATFORM_FILTER" == *am62* ]]; then
    DOCKER_RUN="$QT5_WAYLAND_EXAMPLES_RUN_AM62"
  elif [[ "$PLATFORM_FILTER" == *imx8* ]]; then
    DOCKER_RUN="$QT5_WAYLAND_EXAMPLES_RUN_IMX8"
  elif [[ "$PLATFORM_FILTER" == *imx95* ]]; then
    # IMX95 uses IMX8 qt5 for now
    DOCKER_RUN="$QT5_WAYLAND_EXAMPLES_RUN_IMX8"
    DOCKER_RUN=${DOCKER_RUN//qt5-wayland-examples-imx8/qt5-wayland-examples-imx95}
  elif [[ "$PLATFORM_FILTER" == *am69* ]]; then
    # AM69 uses AM62 qt5 for now
    DOCKER_RUN="$QT5_WAYLAND_EXAMPLES_RUN_AM62"
    DOCKER_RUN=${DOCKER_RUN//qt5-wayland-examples-am62/qt5-wayland-examples-am69}
  else
    DOCKER_RUN="$QT5_WAYLAND_EXAMPLES_RUN_UPSTREAM"
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
