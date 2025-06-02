#!/usr/bin/env bash

setup_chromium() {
  CHROMIUM_RUN_AM62=$(read-docker-run.sh "tests/runs/chromium/chromium-am62-compose.run" "chromium-am62" "chromium")
  CHROMIUM_RUN_IMX8
  CHROMIUM_RUN_IMX8=$(read-docker-run.sh "tests/runs/chromium/chromium-imx8-compose.run" "chromium-imx8" "chromium")
  export CHROMIUM_RUN_IMX8
  CHROMIUM_RUN_UPSTREAM=$(read-docker-run.sh "tests/runs/chromium/chromium-upstream-compose.run" "chromium" "chromium")

  # For test containers
  CHROMIUM_TESTS_RUN_IMX8="docker container run -td --name=chromium-tests --entrypoint /usr/bin/bash \
    -v /tmp:/tmp -v /var/run/dbus:/var/run/dbus \
    -v /dev:/dev --device-cgroup-rule='c 199:* rmw' \
    --device-cgroup-rule='c 81:* rmw' --device-cgroup-rule='c 234:* rmw' \
    --device-cgroup-rule='c 253:* rmw'  --device-cgroup-rule='c 226:* rmw' \
    --device-cgroup-rule='c 235:* rmw' \
    --security-opt seccomp=unconfined --shm-size 256mb \
    $REGISTRY/torizon/chromium-tests-imx8:stable-rc"

  CHROMIUM_TESTS_RUN_IMX95="docker container run -td --name=chromium-tests --entrypoint /usr/bin/bash \
    -v /tmp:/tmp -v /var/run/dbus:/var/run/dbus \
    -v /dev:/dev --device-cgroup-rule='c 199:* rmw' \
    --device-cgroup-rule='c 81:* rmw' --device-cgroup-rule='c 234:* rmw' \
    --device-cgroup-rule='c 253:* rmw'  --device-cgroup-rule='c 226:* rmw' \
    --device-cgroup-rule='c 235:* rmw' \
    --security-opt seccomp=unconfined --shm-size 256mb \
    $REGISTRY/torizon/chromium-tests-imx95:stable-rc"

  docker container kill chromium || true
  docker container rm chromium || true
  docker container kill chromium-tests || true
  docker container rm chromium-tests || true

  local DOCKER_RUN
  if [[ "$PLATFORM_FILTER" == *am62* ]]; then
    DOCKER_RUN="$CHROMIUM_RUN_AM62"
  elif [[ "$PLATFORM_FILTER" == *imx8* ]]; then
    DOCKER_RUN="$CHROMIUM_TESTS_RUN_IMX8"
  elif [[ "$PLATFORM_FILTER" == *imx95* ]]; then
    DOCKER_RUN="$CHROMIUM_TESTS_RUN_IMX95"
  elif [[ "$PLATFORM_FILTER" == *am69* ]]; then
    # AM69 uses am62 chromium for now
    DOCKER_RUN="$CHROMIUM_RUN_AM62"
    DOCKER_RUN=${DOCKER_RUN//chromium-am62/chromium-am69}
  else
    DOCKER_RUN="$CHROMIUM_RUN_UPSTREAM"
  fi

  eval "$DOCKER_RUN"

  sleep 40
}

teardown_chromium() {
  docker container kill chromium || true
  docker container kill chromium-tests || true

  for container in chromium chromium-tests; do
    IMAGE_ID=$(docker container inspect -f '{{.Image}}' "$container" 2>/dev/null)
    if [[ -n "$IMAGE_ID" ]]; then
      docker image rm -f "$IMAGE_ID" || true
    fi
    docker container rm "$container" || true
  done
}
