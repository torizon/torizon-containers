#!/usr/bin/env bash

setup_benchmark() {
  docker container kill benchmark || true
  docker container rm benchmark || true

  local PLATFORM
  PLATFORM="${PLATFORM_FILTER:+-${PLATFORM_FILTER}}"

  local DOCKER_RUN
  DOCKER_RUN="docker run -d \
    --name benchmark \
    -e MANGOHUD=1 \
    -e MANGOHUD_CONFIG=cpu_temp,gpu_temp,position=top-left,height=500,font_size=32 \
    -v /tmp:/tmp \
    -v /dev:/dev \
    --device-cgroup-rule='c 4:* rmw' \
    --device-cgroup-rule='c 13:* rmw' \
    --device-cgroup-rule='c 199:* rmw' \
    --device-cgroup-rule='c 226:* rmw' \
    $REGISTRY/torizon/benchmark${PLATFORM}:stable-rc \
    bash"

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
