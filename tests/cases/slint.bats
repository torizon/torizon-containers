#!/usr/bin/env bats

load ./slint-helper.sh
load ./kernel-helper.sh
load ./general-helper.sh

setup_file() {
  setup_slint
}

teardown_file() {
  teardown_slint
}

# bats test_tags=platform:am62, platform:imx8, platform:imx95
@test "Slint Demo Launcher" {
  bats_require_minimum_version 1.5.0

  run -0 clean_kernel_logs

  run -0 docker top slint | grep home-automation

  run -0 gpu_kernel_logs
}

# bats test_tags=platform:upstream
@test "Slint Demo Launcher - Upstream" {
  bats_require_minimum_version 1.5.0

  run -0 clean_kernel_logs

  run -0 docker top slint | grep energy-monitor

  run -0 gpu_kernel_logs
}
