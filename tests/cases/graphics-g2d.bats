#!/usr/bin/env bats
# Copyright (c) 2019-2025 Toradex AG
# SPDX-License-Identifier: MIT

load ./g2d-helper.sh
load ./kernel-helper.sh
load ./general-helper.sh

DOCKER_RUN_IMX93="docker container run -e ACCEPT_FSL_EULA=1 -d -it --privileged \
            --name=graphics-tests -v /dev:/dev -v /tmp:/tmp \
            --device-cgroup-rule='c 509:* rmw' \
            $REGISTRY/torizon/graphics-tests-imx93:stable-rc"
            
setup_file() {
  docker container kill graphics-tests || true
  docker container rm graphics-tests || true

  eval "$DOCKER_RUN_IMX93"

  sleep 10

  check_if_base_container_runs graphics-tests
}

teardown_file() {
  cleanup_container graphics-tests
}

# bats test_tags=platform:imx93
@test "PXP and DMA heap devices nodes exists" {
  bats_require_minimum_version 1.5.0
  run -0 clean_g2d_kernel_logs

  run docker container exec graphics-tests test -e /dev/pxp_device
  [ "$status" -eq 0 ]

  run docker container exec graphics-tests test -e /dev/dma_heap/linux,cma
  [ "$status" -eq 0 ]

  run docker container exec graphics-tests test -e /dev/dma_heap/linux,cma-uncached
  [ "$status" -eq 0 ]

  run -0 g2d_kernel_logs
}

# bats test_tags=platform:imx93
@test "libg2d-pxp library is installed" {
  bats_require_minimum_version 1.5.0
  export_arch_triplet

  run docker container exec graphics-tests \
    test -e /usr/lib/${ARCH_TRIPLET}/libg2d-pxp.so.2.2.0
  [ "$status" -eq 0 ]
}

# bats test_tags=platform:imx93
@test "G2D basic test runs successfully" {
  run docker container exec graphics-tests \
    /opt/g2d_samples/g2d_basic_test
  [ "$status" -eq 0 ]

  g2d_assert_faster_than_cpu "$output"
}

