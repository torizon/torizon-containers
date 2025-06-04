#!/usr/bin/env bats

load ./weston-helper.sh
load ./qt6-enterprise-helper.sh
load ./kernel-helper.sh
load ./general-helper.sh

setup_file() {
  setup_weston
  setup_qt6_enterprise
}

teardown_file() {
  teardown_qt6_enterprise
  teardown_weston
}

# bats test_tags=platform:imx8
@test "Qt6 Enterprise Demo Launcher" {
  bats_require_minimum_version 1.5.0

  run -0 clean_kernel_logs

  run -124 docker container exec -e QT_QPA_PLATFORM=wayland qt6-enterprise timeout 10s /opt/b2qt-demolauncher/qtlauncher

  run -0 gpu_kernel_logs
}

# bats test_tags=platform:imx8
@test "Qt6 Enterprise Coffee Machine" {
  bats_require_minimum_version 1.5.0

  run -0 clean_kernel_logs

  run -124 docker container exec -e QT_QPA_PLATFORM=wayland qt6-enterprise timeout 10s /usr/local/bin/coffeemachine

  run -0 gpu_kernel_logs
}

# bats test_tags=platform:imx8
@test "Qt6 Enterprise Robot Arm" {
  bats_require_minimum_version 1.5.0

  run -0 clean_kernel_logs

  run -124 docker container exec -e QT_QPA_PLATFORM=wayland qt6-enterprise timeout 10s /usr/local/bin/RobotArmApp

  run -0 gpu_kernel_logs
}

# bats test_tags=platform:imx8
@test "Qt6 Enterprise Thermostat" {
  bats_require_minimum_version 1.5.0

  run -0 clean_kernel_logs

  run -124 docker container exec -e QT_QPA_PLATFORM=wayland qt6-enterprise timeout 10s /usr/local/bin/ThermostatApp

  run -0 gpu_kernel_logs
}
