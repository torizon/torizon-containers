#!/usr/bin/env bats

bats_load_library bats-support
bats_load_library bats-assert

load ./kernel-helper.sh
load ./general-helper.sh
load ./qt6-helper.sh

setup_file() {
  setup_qt6

  export_arch_triplet
}

teardown_file() {
  teardown_qt6
}

# bats test_tags=platform:imx8, platform:imx95, platform:am62, platform:upstream
@test "Qt6 EGL kmscube runs" {
  bats_require_minimum_version 1.5.0

  run -0 clean_kernel_logs

  run timeout 10s docker container exec -e QT_QPA_PLATFORM=eglfs qt6-wayland-tests \
    kms-setup.sh "/usr/lib/$ARCH_TRIPLET/qt6/examples/opengl/cube/cube"

  run -0 gpu_kernel_logs
}

# bats test_tags=platform:imx8, platform:imx95, platform:am62, platform:upstream
@test "Qt6 LinuxFB shapedclock runs" {
  bats_require_minimum_version 1.5.0

  run -0 clean_kernel_logs

  run -124 docker container exec -e QT_QPA_PLATFORM=linuxfb qt6-wayland-tests \
    timeout 10s "/usr/lib/$ARCH_TRIPLET/qt6/examples/widgets/widgets/shapedclock/shapedclock"

  run -0 gpu_kernel_logs
}

# bats test_tags=platform:imx8, platform:imx95, platform:am62, platform:upstream
@test "Qt6 can create OpenGLES context" {
  bats_require_minimum_version 1.5.0

  run -0 clean_kernel_logs

  run docker container exec -e QT_QPA_PLATFORM=eglfs qt6-wayland-tests \
    kms-setup.sh contextinfo

  assert_output --regexp "OpenGL Version: OpenGL ES [23]\.[02].*"

  run -0 gpu_kernel_logs
}
