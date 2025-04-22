#!/usr/bin/env bats

load ./weston-helper.sh
load ./general-helper.sh

DOCKER_RUN_AM62="docker container run -d --name=chromium \
    -v /tmp:/tmp -v /var/run/dbus:/var/run/dbus \
    -v /dev/dri:/dev/dri --device-cgroup-rule='c 226:* rmw' \
    --security-opt seccomp=unconfined --shm-size 256mb \
    $REGISTRY/torizon/chromium-am62:stable-rc \
    --virtual-keyboard http://info.cern.ch/hypertext/WWW/TheProject.html"

DOCKER_RUN_AM69="docker container run -d --name=chromium \
    -v /tmp:/tmp -v /var/run/dbus:/var/run/dbus \
    -v /dev/dri:/dev/dri --device-cgroup-rule='c 226:* rmw' \
    --security-opt seccomp=unconfined --shm-size 256mb \
    $REGISTRY/torizon/chromium-am69:stable-rc \
    --virtual-keyboard http://info.cern.ch/hypertext/WWW/TheProject.html"

# note the `-td`: it allocates a pty so it keeps the container running
DOCKER_RUN_IMX8="docker container run -td --name=chromium-tests --entrypoint /usr/bin/bash \
    -v /tmp:/tmp -v /var/run/dbus:/var/run/dbus \
    -v /dev:/dev --device-cgroup-rule='c 199:* rmw' \
    --device-cgroup-rule='c 81:* rmw' --device-cgroup-rule='c 234:* rmw' \
    --device-cgroup-rule='c 253:* rmw'  --device-cgroup-rule='c 226:* rmw' \
    --device-cgroup-rule='c 235:* rmw' \
    --security-opt seccomp=unconfined --shm-size 256mb \
    $REGISTRY/torizon/chromium-tests-imx8:stable-rc"

# note the `-td`: it allocates a pty so it keeps the container running
DOCKER_RUN_IMX95="docker container run -td --name=chromium-tests --entrypoint /usr/bin/bash \
    -v /tmp:/tmp -v /var/run/dbus:/var/run/dbus \
    -v /dev:/dev --device-cgroup-rule='c 199:* rmw' \
    --device-cgroup-rule='c 81:* rmw' --device-cgroup-rule='c 234:* rmw' \
    --device-cgroup-rule='c 253:* rmw'  --device-cgroup-rule='c 226:* rmw' \
    --device-cgroup-rule='c 235:* rmw' \
    --security-opt seccomp=unconfined --shm-size 256mb \
    $REGISTRY/torizon/chromium-tests-imx95:stable-rc"

DOCKER_RUN_UPSTREAM="docker container run -d --name=chromium \
    -v /tmp:/tmp -v /var/run/dbus:/var/run/dbus \
    -v /dev/dri:/dev/dri --device-cgroup-rule='c 226:* rmw' \
    --security-opt seccomp=unconfined --shm-size 256mb \
    $REGISTRY/torizon/chromium:stable-rc \
    --virtual-keyboard http://info.cern.ch/hypertext/WWW/TheProject.html"


setup_file() {

  setup_weston

  docker container kill chromium || true
  docker container rm chromium || true

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

  sleep 40
}

teardown_file() {
  cleanup_container chromium-tests

  teardown_weston
}

# bats test_tags=platform:imx8, platform:imx95, platform:am62, platform:upstream, platform:am69
@test "Chromium runs" {
  run -124 docker container exec --user torizon chromium-tests timeout 20s start-browser
}

# bats test_tags=platform:imx8, platform:imx95
@test "Chromium can display WebGL content" {
  docker exec chromium-tests npm test
}
