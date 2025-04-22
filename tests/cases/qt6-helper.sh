#!/usr/bin/env bash

setup_qt6() {
  DOCKER_RUN_AM62="docker container run -d -it --privileged --name=qt6-wayland-tests \
              -v /dev:/dev -v /run/udev/:/run/udev/ -v /tmp:/tmp \
              $REGISTRY/torizon/qt6-wayland-tests-am62:stable-rc"

  DOCKER_RUN_AM69="docker container run -d -it --privileged --name=qt6-wayland-tests \
              -v /dev:/dev -v /run/udev/:/run/udev/ -v /tmp:/tmp \
              $REGISTRY/torizon/qt6-wayland-tests-am69:stable-rc"

  DOCKER_RUN_IMX8="docker container run -d -it --privileged --name=qt6-wayland-tests \
              -v /dev:/dev -v /run/udev/:/run/udev/ -v /tmp:/tmp \
              $REGISTRY/torizon/qt6-wayland-tests-imx8:stable-rc"

  DOCKER_RUN_IMX95="docker container run -d -it --privileged --name=qt6-wayland-tests \
              -v /dev:/dev -v /run/udev/:/run/udev/ -v /tmp:/tmp \
              $REGISTRY/torizon/qt6-wayland-tests-imx95:stable-rc"

  DOCKER_RUN_UPSTREAM="docker container run -d -it --privileged --name=qt6-wayland-tests \
              -v /dev:/dev -v /run/udev/:/run/udev/ -v /tmp:/tmp \
              $REGISTRY/torizon/qt6-wayland-tests:stable-rc"

  docker container kill qt6-wayland-tests || true
  docker container rm qt6-wayland-tests || true

  if [[ "$PLATFORM_FILTER" == *am62* ]]; then
    DOCKER_RUN=$DOCKER_RUN_AM62
  elif [[ "$PLATFORM_FILTER" == *imx8* ]]; then
    DOCKER_RUN=$DOCKER_RUN_IMX8
  elif [[ "$PLATFORM_FILTER" == *imx95* ]]; then
    DOCKER_RUN=$DOCKER_RUN_IMX95
  elif [[ "$PLATFORM_FILTER" == *am69* ]]; then
    DOCKER_RUN=$DOCKER_RUN_AM69
  else
    DOCKER_RUN=$DOCKER_RUN_UPSTREAM
  fi

  eval "$DOCKER_RUN"

  sleep 10

  check_if_base_container_runs qt6-wayland-tests
}

teardown_qt6() {
  cleanup_container qt6-wayland-tests
}
