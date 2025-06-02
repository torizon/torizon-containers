#!/usr/bin/env bats

load ./weston-helper.sh
load ./chromium-helper.sh
load ./general-helper.sh

setup_file() {
  setup_weston
  setup_chromium
}

teardown_file() {
  teardown_chromium
  teardown_weston
}

# bats test_tags=platform:imx8, platform:am62, platform:upstream
@test "Chromium runs" {
  run -124 docker container exec --user torizon chromium-tests timeout 20s start-browser
}

# bats test_tags=platform:imx8, platform:imx95
@test "Chromium can display WebGL content" {
  docker exec chromium-tests npm test
}
