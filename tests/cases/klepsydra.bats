#!/usr/bin/env bats

load ./kernel-helper.sh
load ./general-helper.sh

file_name=$(basename "$BATS_TEST_FILENAME" .bats)

setup_file() {
  setup_test "${file_name}"
}

teardown_file() {
  teardown_test "${file_name}"
}

# bats test_tags=platform:am69, platform:imx8
@test "Klepsydra Demo Launcher" {
  bats_require_minimum_version 1.5.0
  if [[ "$SOC_UDT" =~ imx8qxp ]]; then
    skip "This demo is unsupported on imx8qxp"
  fi
  run -0 clean_kernel_logs

  run -0 docker compose -f "$COMPOSE_FILE" top "${file_name}" | grep "kpe-depth-estimation-demo-app"

  run -0 gpu_kernel_logs
}
