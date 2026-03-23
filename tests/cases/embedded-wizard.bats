#!/usr/bin/env bats

load ./weston-helper.sh
load ./embedded-wizard-helper.sh
load ./kernel-helper.sh
load ./general-helper.sh


setup_file() {
  setup_weston
  setup_embedded_wizard
}

teardown_file() {
  teardown_embedded_wizard
  teardown_weston
}

# bats test_tags=platform:am62p, platform:imx8, platform:imx95
@test "Embedded Wizard Demo Launcher" {
  bats_require_minimum_version 1.5.0

  run -0 clean_kernel_logs

  run -0 docker top embedded-wizard | grep "EmbeddedWizard-Linux-OpenGL-Wayland"

  run -0 gpu_kernel_logs
}
