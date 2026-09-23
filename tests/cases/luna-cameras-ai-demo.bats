#!/usr/bin/env bats

bats_load_library bats-assert

load ./kernel-helper.sh
load ./general-helper.sh

file_name=$(basename "$BATS_TEST_FILENAME" .bats)

setup_file() {
  setup_test "${file_name}"
}

teardown_file() {
  teardown_test "${file_name}"
}

# bats test_tags=platform:sl1680
@test "Luna Cameras AI Demo" {
  bats_require_minimum_version 1.5.0

  run -0 clean_kernel_logs

  run -0 docker compose -f "$COMPOSE_FILE" top "${file_name}"
  assert_output --partial "vision.dual_models"

  run -0 gpu_kernel_logs
}
