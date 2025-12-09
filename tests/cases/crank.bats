#!/usr/bin/env bats

load ./weston-helper.sh
load ./crank-helper.sh
load ./kernel-helper.sh
load ./general-helper.sh

setup_file() {
  setup_weston
  setup_crank
}

teardown_file() {
  teardown_crank
  teardown_weston
}

# bats test_tags=platform:am62, platform:imx8, platform:upstream
@test "Crank Demo Launcher" {
  bats_require_minimum_version 1.5.0

  run -0 clean_kernel_logs

  run -124 timeout 10s docker container exec crank /usr/crank/docker_sbengine.sh

  run -0 gpu_kernel_logs
}
