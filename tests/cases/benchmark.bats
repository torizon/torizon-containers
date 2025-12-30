#!/usr/bin/env bats

load ./weston-helper.sh
load ./general-helper.sh
load ./benchmark-helper.sh

setup_file() {
  setup_weston
  setup_benchmark
}

teardown_file() {
  teardown_benchmark
  teardown_weston
}

# bats test_tags=platform:imx8, platform:sl1680, platform:imx95, platform:am62, platform:am62p, platform:am69, platform:upstream
@test "Benchmark runs" {
  run -124 docker container exec --user torizon benchmark timeout 20s "mangohud --dlsym glmark2-es2-wayland --run-forever"
}