#!/usr/bin/env bats

load ./general-helper.sh

file_name=$(basename "$BATS_TEST_FILENAME" .bats)

setup_file() {
  setup_test "${file_name}"
}

teardown_file() {
  teardown_test "${file_name}"
}

# bats test_tags=platform:imx8, platform:sl1680, platform:imx93, platform:imx95, platform:am62, platform:am62p, platform:am69, platform:upstream, platform:am67a
@test "Chromium runs" {
  run -124 docker compose -f "$COMPOSE_FILE" exec --user torizon "${file_name}" timeout 20s start-browser
}

# bats test_tags=platform:imx8, platform:sl1680, platform:imx95, platform:am62, platform:am62p, platform:am69, platform:am67a
@test "Chromium can display WebGL content" {
  docker compose -f "$COMPOSE_FILE" exec "${file_name}" npm test
}
