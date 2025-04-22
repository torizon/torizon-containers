#!/usr/bin/env bash

setup_qt5() {
  DOCKER_RUN_AM62="docker container run -d -it --name=qt5-wayland-examples \
              -v /dev:/dev -v /run/udev/:/run/udev/ -v /tmp:/tmp \
              --device-cgroup-rule='c 4:* rmw'  --device-cgroup-rule='c 13:* rmw' \
              --device-cgroup-rule='c 29:* rmw' --device-cgroup-rule='c 226:* rmw' \
              $REGISTRY/torizon/qt5-wayland-examples-am62:stable-rc"

  DOCKER_RUN_AM69="docker container run -d -it --name=qt5-wayland-examples \
              -v /dev:/dev -v /run/udev/:/run/udev/ -v /tmp:/tmp \
              --device-cgroup-rule='c 4:* rmw'  --device-cgroup-rule='c 13:* rmw' \
              --device-cgroup-rule='c 29:* rmw' --device-cgroup-rule='c 226:* rmw' \
              $REGISTRY/torizon/qt5-wayland-examples-am69:stable-rc"

  DOCKER_RUN_IMX8="docker container run -d -it --name=qt5-wayland-examples \
              -v /dev:/dev -v /run/udev/:/run/udev/ -v /tmp:/tmp \
              --device-cgroup-rule='c 4:* rmw' --device-cgroup-rule='c 13:* rmw' \
              --device-cgroup-rule='c 29:* rmw' --device-cgroup-rule='c 199:* rmw' \
	      --device-cgroup-rule='c 226:* rmw' \
              $REGISTRY/torizon/qt5-wayland-examples-imx8:stable-rc"

  DOCKER_RUN_IMX95="docker container run -d -it --name=qt5-wayland-examples \
              -v /dev:/dev -v /run/udev/:/run/udev/ -v /tmp:/tmp \
              --device-cgroup-rule='c 4:* rmw' --device-cgroup-rule='c 13:* rmw' \
              --device-cgroup-rule='c 29:* rmw' --device-cgroup-rule='c 199:* rmw' \
	      --device-cgroup-rule='c 226:* rmw' \
              $REGISTRY/torizon/qt5-wayland-examples-imx95:stable-rc"

  DOCKER_RUN_UPSTREAM="docker container run -d -it --name=qt5-wayland-examples \
              -v /dev:/dev -v /run/udev/:/run/udev/ -v /tmp:/tmp \
              --device-cgroup-rule='c 4:* rmw'  --device-cgroup-rule='c 13:* rmw' \
              --device-cgroup-rule='c 29:* rmw' --device-cgroup-rule='c 226:* rmw' \
              $REGISTRY/torizon/qt5-wayland-examples:stable-rc"

  docker container kill qt5-wayland-examples || true
  docker container rm qt5-wayland-examples || true

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

  check_if_base_container_runs qt5-wayland-examples
}

teardown_qt5() {
  cleanup_container qt5-wayland-examples
}
