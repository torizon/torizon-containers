#!/usr/bin/env bats

load ./pdf-reader-helper.sh
load ./kernel-helper.sh
load ./general-helper.sh

setup_file() {
  setup_pdf_reader
}

teardown_file() {
  teardown_pdf_reader
}

# bats test_tags=platform:am62, platform:am62p, platform:am69, platform:imx8, platform:imx95
@test "LVGL PDF Reader Demo Launcher" {
  bats_require_minimum_version 1.5.0

  run -0 clean_kernel_logs

  run -0 docker top pdf-reader | grep "pdf-reader"

  run -0 gpu_kernel_logs
}
