#!/usr/bin/env bats

load ./weston-helper.sh
load ./general-helper.sh
load ./chromium-tests-helper.sh

setup_file() {
  setup_weston

  cleanup_container chromium-tests

  eval "$DOCKER_RUN"

  sleep 40
}

teardown_file() {
  cleanup_container chromium-tests

  teardown_weston
}

# bats test_tags=platform:imx8, platform:imx95, platform:am62, platform:upstream
@test "Chromium runs" {
  run -124 docker container exec --user torizon chromium-tests timeout 20s start-browser
}

# bats test_tags=platform:imx8, platform:imx95, platform:am62
@test "Chromium can display WebGL content" {
  docker exec chromium-tests npm test
}