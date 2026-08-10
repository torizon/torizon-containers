#!/usr/bin/env bats

bats_load_library bats-support
bats_load_library bats-assert

load ./kernel-helper.sh
load ./general-helper.sh

file_name=$(basename "$BATS_TEST_FILENAME" .bats)

setup_file() {
  setup_test weston
  setup_test "${file_name}"
  export_arch_triplet
  export_has_gpu
}

teardown_file() {
  teardown_test "${file_name}"
  teardown_test weston
}

# bats test_tags=platform:imx8, platform:sl1680, platform:imx93, platform:imx95, platform:am62, platform:am62p, platform:upstream, platform:am69, platform:am67a
@test "Qt6 cube runs" {
  bats_require_minimum_version 1.5.0

  run -0 clean_kernel_logs

  run -124 docker compose -f "$COMPOSE_FILE" exec "${file_name}" timeout 10s \
    "/usr/lib/$ARCH_TRIPLET/qt6/examples/opengl/cube/bin/cube"

  run -0 gpu_kernel_logs
}

# bats test_tags=platform:imx8, platform:sl1680, platform:imx93, platform:imx95, platform:am62, platform:am62p, platform:upstream, platform:am69, platform:am67a
@test "Qt6 shapedclock runs" {
  bats_require_minimum_version 1.5.0

  run -0 clean_kernel_logs

  run -124 docker compose -f "$COMPOSE_FILE" exec "${file_name}" \
    timeout 10s "/usr/lib/$ARCH_TRIPLET/qt6/examples/widgets/widgets/shapedclock/bin/shapedclock"

  run -0 gpu_kernel_logs
}

# bats test_tags=platform:imx8, platform:sl1680, platform:imx93, platform:imx95, platform:am62, platform:am62p, platform:upstream, platform:am69, platform:am67a
@test "Qt6 can create OpenGL ES context" {
  bats_require_minimum_version 1.5.0

  run -0 clean_kernel_logs

  run docker compose -f "$COMPOSE_FILE" exec "${file_name}" contextinfo

  assert_output --regexp "OpenGL Version: OpenGL ES [23]\.[012].*"

  if $HAS_GPU; then
    refute_output --regexp "[Ll][Ll][Vv][Mm][Pp][Ii][Pp][Ee]"
  fi

  run -0 gpu_kernel_logs
}

# bats test_tags=platform:imx8, platform:sl1680, platform:imx93, platform:imx95, platform:am62, platform:am62p, platform:upstream, platform:am69, platform:am67a
@test "Qt6 EGL kmscube runs" {
  bats_require_minimum_version 1.5.0

  run -0 clean_kernel_logs

  run -124 docker compose -f "$COMPOSE_FILE" exec -e QT_QPA_PLATFORM=eglfs "${file_name}" timeout 10s \
    kms-setup.sh "/usr/lib/$ARCH_TRIPLET/qt6/examples/opengl/cube/bin/cube"

  if $HAS_GPU; then
    refute_output --regexp "[Ll][Ll][Vv][Mm][Pp][Ii][Pp][Ee]"
  fi

  run -0 gpu_kernel_logs
}

# bats test_tags=platform:imx8, platform:sl1680, platform:imx93, platform:imx95, platform:am62, platform:am62p, platform:upstream, platform:am69, platform:am67a
@test "Qt6 can create OpenGLES context" {
  bats_require_minimum_version 1.5.0

  run -0 clean_kernel_logs

  run docker compose -f "$COMPOSE_FILE" exec -e QT_QPA_PLATFORM=eglfs "${file_name}" \
    kms-setup.sh contextinfo

  assert_output --regexp "OpenGL Version: OpenGL ES [23]\.[012].*"

  if $HAS_GPU; then
    refute_output --regexp "[Ll][Ll][Vv][Mm][Pp][Ii][Pp][Ee]"
  fi
  
  run -0 gpu_kernel_logs
}
