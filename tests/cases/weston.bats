#!/usr/bin/env bats

load ./kernel-helper.sh
load ./general-helper.sh

file_name=$(basename "$BATS_TEST_FILENAME" .bats)

setup_file() {
  setup_test weston
  setup_test "${file_name}"
}

teardown_file() {
  teardown_test "${file_name}"
  teardown_test weston
}

# bats test_tags=platform:imx8, platform:sl1680, platform:imx93, platform:imx95, platform:am62, platform:am62p, platform:upstream, platform:am69, platform:am67a
@test "Weston Simple EGL runs" {
  bats_require_minimum_version 1.5.0

  run -0 clean_kernel_logs
  run -124 docker compose -f "$COMPOSE_FILE" exec "${file_name}" timeout 10s weston-simple-egl

  echo "Ran for 10 seconds without crashing, terminated by timeout."
  run -0 gpu_kernel_logs
}

# bats test_tags=platform:imx8, platform:sl1680, platform:imx93, platform:imx95, platform:am62, platform:am62p, platform:upstream, platform:am69, platform:am67a
@test "Weston Terminal runs" {
  bats_require_minimum_version 1.5.0

  run -124 docker compose -f "$COMPOSE_FILE" exec "${file_name}" timeout 5s weston-terminal

  echo "Ran for 5 seconds without crashing, terminated by timeout."
}
