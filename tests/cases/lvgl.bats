#!/usr/bin/env bats

load ./weston-helper.sh
load ./lvgl-helper.sh
load ./kernel-helper.sh
load ./general-helper.sh


setup_file() {
  setup_weston
  setup_lvgl
}

teardown_file() {
  teardown_lvgl
  teardown_weston
}

# bats test_tags=platform:am62p
@test "LVGL Demo Launcher" {
  bats_require_minimum_version 1.5.0

  run -0 clean_kernel_logs

  run -0 docker top lvgl | grep lv_demo_truck

  run -0 gpu_kernel_logs
}
