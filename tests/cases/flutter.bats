#!/usr/bin/env bats

load ./weston-helper.sh
load ./flutter-helper.sh
load ./kernel-helper.sh
load ./general-helper.sh


setup_file() {
  setup_weston
  setup_flutter
}

teardown_file() {
  teardown_flutter
  teardown_weston
}

## add below the platform that should test the demo
# bats test_tags=platform:imx95
@test "Flutter Internet Radio" {
  bats_require_minimum_version 1.5.0

  run -0 clean_kernel_logs

  run -0 docker top flutter | grep flutter-client

  run -0 gpu_kernel_logs
}
