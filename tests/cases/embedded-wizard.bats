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

# bats test_tags=platform:am62p, platform:imx8, platform:imx95
@test "Embedded Wizard Demo Launcher" {
  bats_require_minimum_version 1.5.0

  run -0 clean_kernel_logs

  run -0 docker compose -f "$COMPOSE_FILE" top "${file_name}" | grep "EmbeddedWizard-Linux-OpenGL-Wayland"

  run -0 gpu_kernel_logs
}
