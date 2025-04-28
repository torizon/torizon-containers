#!/usr/bin/env bats

load ./weston-helper.sh
load ./kernel-helper.sh
load ./general-helper.sh

DOCKER_RUN_IMX8="docker container run -d -it --net=host --name=qt6-enterprise-demo \
             --cap-add CAP_SYS_TTY_CONFIG -v /dev:/dev -v /tmp:/tmp -v /run/udev/:/run/udev/ \
             --device-cgroup-rule='c 4:* rmw'  --device-cgroup-rule='c 13:* rmw' \
             --device-cgroup-rule='c 226:* rmw' --device-cgroup-rule='c 29:* rmw' --device-cgroup-rule='c 199:* rmw' \
             $REGISTRY/torizon/qt6-enterprise-demo-imx8:stable-rc bash"

setup_file() {
  setup_weston

  docker container kill qt6-enterprise-demo || true
  docker container rm qt6-enterprise-demo || true

  DOCKER_RUN=$DOCKER_RUN_IMX8

  eval "$DOCKER_RUN"
  sleep 30
}

teardown_file() {
  teardown_weston

  cleanup_container qt6-enterprise-demo
}

# bats test_tags=platform:imx8
@test "Qt6 Enterprise Demo Launcher" {
  bats_require_minimum_version 1.5.0

  run -0 clean_kernel_logs

  run -124 docker container exec -e QT_QPA_PLATFORM=wayland qt6-enterprise-demo timeout 10s /opt/b2qt-demolauncher/qtlauncher

  run -0 gpu_kernel_logs
}

# bats test_tags=platform:imx8
@test "Qt6 Enterprise Coffee Machine" {
  bats_require_minimum_version 1.5.0

  run -0 clean_kernel_logs

  run -124 docker container exec -e QT_QPA_PLATFORM=wayland qt6-enterprise-demo timeout 10s /usr/local/bin/coffeemachine

  run -0 gpu_kernel_logs
}

# bats test_tags=platform:imx8
@test "Qt6 Enterprise Robot Arm" {
  bats_require_minimum_version 1.5.0

  run -0 clean_kernel_logs

  run -124 docker container exec -e QT_QPA_PLATFORM=wayland qt6-enterprise-demo timeout 10s /usr/local/bin/RobotArmApp

  run -0 gpu_kernel_logs
}

# bats test_tags=platform:imx8
@test "Qt6 Enterprise Thermostat" {
  bats_require_minimum_version 1.5.0

  run -0 clean_kernel_logs

  run -124 docker container exec -e QT_QPA_PLATFORM=wayland qt6-enterprise-demo timeout 10s /usr/local/bin/ThermostatApp

  run -0 gpu_kernel_logs
}
