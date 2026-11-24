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

# bats test_tags=platform:imx8
@test "UXDivers The Climate Box" {
  bats_require_minimum_version 1.5.0

  if [[ "$SOC_UDT" =~ imx8qxp || "$SOC_UDT" =~ imx8qm ]]; then
    skip "This demo is unsupported on imx8qxp and imx8qm"
  fi
  
  run -0 clean_kernel_logs

  run -0 docker compose -f "$COMPOSE_FILE" top "${file_name}" | grep "TheClimateBox"

  run -0 gpu_kernel_logs
}
