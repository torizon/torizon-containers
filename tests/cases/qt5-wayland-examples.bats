#!/usr/bin/env bats

load ./kernel-helper.sh
load ./general-helper.sh

file_name=$(basename "$BATS_TEST_FILENAME" .bats)

setup_file() {
  setup_test "${file_name}"
  export_arch_triplet
  export_has_gpu
}

teardown_file() {
  teardown_test "${file_name}"
}


# bats test_tags=platform:imx8, platform:sl1680, platform:imx93, platform:imx95, platform:am62, platform:am62p, platform:upstream, platform:am69, platform:am67a
@test "Qt5 cube runs" {
  bats_require_minimum_version 1.5.0

  run -0 clean_kernel_logs

  run -124 docker compose -f "$COMPOSE_FILE" exec "${file_name}" timeout 10s \
    "/usr/lib/$ARCH_TRIPLET/qt5/examples/opengl/cube/cube"

  run -0 gpu_kernel_logs
}

# bats test_tags=platform:imx8, platform:sl1680, platform:imx93, platform:imx95, platform:am62, platform:am62p, platform:upstream, platform:am69, platform:am67a
@test "Qt5 shapedclock runs" {
  bats_require_minimum_version 1.5.0

  run -0 clean_kernel_logs

  run -124 docker compose -f "$COMPOSE_FILE" exec "${file_name}" \
    timeout 10s "/usr/lib/$ARCH_TRIPLET/qt5/examples/widgets/widgets/shapedclock/shapedclock"

  run -0 gpu_kernel_logs
}

# bats test_tags=platform:imx8, platform:sl1680, platform:imx93, platform:imx95, platform:am62, platform:am62p, platform:upstream, platform:am67a
@test "Qt5 EGLFS kmscube runs" {
  bats_require_minimum_version 1.5.0

  run -0 clean_kernel_logs

  run -124 docker compose -f "$COMPOSE_FILE" exec -e QT_QPA_PLATFORM=eglfs "${file_name}" timeout 10s \
    kms-setup.sh "/usr/lib/$ARCH_TRIPLET/qt5/examples/opengl/cube/cube"

  if $HAS_GPU; then
    refute_output --regexp "[Ll][Ll][Vv][Mm][Pp][Ii][Pp][Ee]"
  fi

  run -0 gpu_kernel_logs
}
