#!/usr/bin/env bats

load ./weston-helper.sh
load ./general-helper.sh

DOCKER_RUN_AM62="docker container run -d -it \
    --name=gtk3-tests -v /dev:/dev -v /tmp:/tmp \
    --device-cgroup-rule='c 4:* rmw'  \
    --device-cgroup-rule='c 13:* rmw' \
    --device-cgroup-rule='c 226:* rmw' \
    $REGISTRY/torizon/gtk3-tests-am62:stable-rc bash"

DOCKER_RUN_AM69="docker container run -d -it \
    --name=gtk3-tests -v /dev:/dev -v /tmp:/tmp \
    --device-cgroup-rule='c 4:* rmw'  \
    --device-cgroup-rule='c 13:* rmw' \
    --device-cgroup-rule='c 226:* rmw' \
    $REGISTRY/torizon/gtk3-tests-am69:stable-rc bash"

DOCKER_RUN_IMX8="docker container run -d -it \
    --name=gtk3-tests -v /dev:/dev -v /tmp:/tmp \
    --device-cgroup-rule='c 4:* rmw'  \
    --device-cgroup-rule='c 13:* rmw' \
    --device-cgroup-rule='c 199:* rmw' \
    --device-cgroup-rule='c 226:* rmw' \
    $REGISTRY/torizon/gtk3-tests-imx8:stable-rc bash"

DOCKER_RUN_IMX95="docker container run -d -it \
    --name=gtk3-tests -v /dev:/dev -v /tmp:/tmp \
    --device-cgroup-rule='c 4:* rmw'  \
    --device-cgroup-rule='c 13:* rmw' \
    --device-cgroup-rule='c 199:* rmw' \
    --device-cgroup-rule='c 226:* rmw' \
    $REGISTRY/torizon/gtk3-tests-imx95:stable-rc bash"

DOCKER_RUN_UPSTREAM="docker container run -d -it \
    --name=gtk3-tests -v /dev:/dev -v /tmp:/tmp \
    --device-cgroup-rule='c 4:* rmw'  \
    --device-cgroup-rule='c 13:* rmw' \
    --device-cgroup-rule='c 226:* rmw' \
    $REGISTRY/torizon/gtk3-tests:stable-rc bash"

setup_file() {

  setup_weston

  docker container kill gtk3-tests || true
  docker container rm gtk3-tests || true

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

  check_if_base_container_runs gtk3-tests
}

teardown_file() {
  cleanup_container graphics-tests

  teardown_weston
}

# bats test_tags=platform:imx8, platform:imx95, platform:am62, platform:upstream, platform:am69
@test "Simple GTK3 application runs" {
  bats_require_minimum_version 1.5.0

  RUN_SIMPLE_GTK_3_TEST='simple-gtk3-test'

  run -124 docker container exec gtk3-tests timeout 10s $RUN_SIMPLE_GTK_3_TEST

  echo $status

  echo "Ran for 10 seconds without crashing, terminated by timeout."
}

# bats test_tags=platform:imx8, platform:imx95, platform:am62, platform:upstream, platform:am69
@test "gtk3-icon-browser runs" {
  bats_require_minimum_version 1.5.0

  RUN_GTK_3_EXAMPLE='gtk3-icon-browser'

  run -124 docker container exec gtk3-tests timeout 10s $RUN_GTK_3_EXAMPLE

  echo $status

  echo "Ran for 10 seconds without crashing, terminated by timeout."
}
