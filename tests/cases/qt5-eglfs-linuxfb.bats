#!/usr/bin/env bats

load ./kernel-helper.sh
load ./general-helper.sh
load ./qt5-helper.sh

setup_file() {
  setup_qt5

  export_arch_triplet
}

teardown_file() {
  teardown_qt5
}

# bats test_tags=platform:imx8, platform:imx95, platform:am62, platform:upstream, platform:am69
@test "Qt5 EGL kmscube runs" {
  bats_require_minimum_version 1.5.0

  run -0 clean_kernel_logs

  run timeout 10s docker container exec -e QT_QPA_PLATFORM=eglfs qt5-wayland-examples \
    kms-setup.sh "/usr/lib/$ARCH_TRIPLET/qt5/examples/opengl/cube/cube"

  run -0 gpu_kernel_logs
}

# bats test_tags=platform:imx8, platform:imx95, platform:am62, platform:upstream, platform:am69
@test "Qt5 LinuxFB shapedclock runs" {
  bats_require_minimum_version 1.5.0

  run -0 clean_kernel_logs

  run -124 docker container exec -e QT_QPA_PLATFORM=linuxfb qt5-wayland-examples \
    timeout 10s "/usr/lib/$ARCH_TRIPLET/qt5/examples/widgets/widgets/shapedclock/shapedclock"

  run -0 gpu_kernel_logs
}
