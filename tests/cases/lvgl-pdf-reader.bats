#!/usr/bin/env bats

load ./lvgl-pdf-reader-helper.sh
load ./kernel-helper.sh
load ./general-helper.sh

setup_file() {
  setup_pdf-reader
}

teardown_file() {
  teardown_pdf-reader
}

# bats test_tags=platform:imx8
@test "LVGL PDF Reader Demo Launcher" {
  bats_require_minimum_version 1.5.0

  run -0 clean_kernel_logs

  run -124 timeout 10s docker container exec pdf-reader /bin/sh /usr/pdf-reader/pdf-reader

  run -0 gpu_kernel_logs
}
