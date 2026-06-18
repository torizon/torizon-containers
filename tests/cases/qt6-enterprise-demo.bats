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

# bats test_tags=platform:imx8
@test "Qt6 Enterprise Demo Launcher" {
  bats_require_minimum_version 1.5.0

  run -0 clean_kernel_logs

  run -124 docker compose -f "$COMPOSE_FILE" top "${file_name}" | grep qtlauncher

  run -0 gpu_kernel_logs
}

# bats test_tags=platform:imx8
@test "Qt6 Enterprise Coffee Machine" {
  bats_require_minimum_version 1.5.0

  run -0 clean_kernel_logs

  run -124 docker compose -f "$COMPOSE_FILE" exec -e QT_QPA_PLATFORM=wayland "${file_name}" timeout 10s /usr/local/bin/coffeemachine

  run -0 gpu_kernel_logs
}

# bats test_tags=platform:imx8
@test "Qt6 Enterprise Robot Arm" {
  bats_require_minimum_version 1.5.0

  run -0 clean_kernel_logs

  run -124 docker compose -f "$COMPOSE_FILE" exec -e QT_QPA_PLATFORM=wayland "${file_name}" timeout 10s /usr/local/bin/RobotArmApp

  run -0 gpu_kernel_logs
}

# bats test_tags=platform:imx8
@test "Qt6 Enterprise Thermostat" {
  bats_require_minimum_version 1.5.0

  run -0 clean_kernel_logs

  run -124 docker compose -f "$COMPOSE_FILE" exec -e QT_QPA_PLATFORM=wayland "${file_name}" timeout 10s /usr/local/bin/ThermostatApp

  run -0 gpu_kernel_logs
}
