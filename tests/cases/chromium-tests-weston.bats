#!/usr/bin/env bats

load ./weston-helper.sh
load ./general-helper.sh
load ./chromium-tests-helper.sh

setup_file() {
  setup_weston
  setup_chromium_tests
}

teardown_file() {
  teardown_chromium_tests
  teardown_weston
}

# bats test_tags=platform:imx8, platform:sl1680, platform:imx95, platform:am62, platform:am62p, platform:am69, platform:upstream
@test "Chromium runs" {
  run -124 docker container exec --user torizon chromium-tests timeout 20s start-browser
}

# bats test_tags=platform:imx8, platform:sl1680, platform:imx95, platform:am62, platform:am62p, platform:am69
@test "Chromium can display WebGL content" {
  docker exec chromium-tests npm test
}