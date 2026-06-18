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

# bats test_tags=platform:imx8, platform:sl1680, platform:imx93, platform:imx95, platform:am62, platform:am62p, platform:upstream, platform:am69, platform:am67a
@test "kmscube has sufficient score" {
  run -0 clean_kernel_logs

  docker compose -f "$COMPOSE_FILE" exec -it "${file_name}" kmscube -c 2048 -D /dev/dri/card0 | tee /tmp/kmscube.txt

  FPSs=$(grep 'fps)' /tmp/kmscube.txt | cut -d '(' -f 2 | cut -d ' ' -f 1)
  for FPS in $FPSs; do [ 1 -eq "$(echo "$FPS >= 55" | bc)" ]; done

  run -0 gpu_kernel_logs
}

# bats test_tags=platform:am62, platform:am62p, platform:upstream, platform:am69, platform:am67a
@test "Modetest is able to probe DRM information " {
  docker compose -f "$COMPOSE_FILE" exec "${file_name}" modetest
}

# autodetection is frail for imx-drm
# bats test_tags=platform:imx8, platform:imx93, platform:imx95
@test "Modetest is able to probe DRM information" {
  docker compose -f "$COMPOSE_FILE" exec "${file_name}" modetest -M imx-drm
}

# bats test_tags=platform:imx8
@test "gputop runs" {
  docker compose -f "$COMPOSE_FILE" exec "${file_name}" gputop -b -f
}

# bats test_tags=platform:imx8, platform:sl1680, platform:imx93, platform:imx95, platform:am62, platform:am62p, platform:upstream, platform:am69, platform:am67a
@test "GLMark2 has sufficient score" {
  if [[ "$SOC_UDT" =~ imx7 ]]; then
    skip "imx7 doesn't have a GPU"
  fi

  SCORE_PASS_THRESHOLD=200

  run -0 clean_kernel_logs

  run docker compose -f "$COMPOSE_FILE" exec "${file_name}" glmark2-es2-wayland -b shading:duration=5.0 -b build:use-vbo=false -b texture

  score=$(echo "$output" | grep -i "score" | cut -d: -f2 | xargs)

  echo "GLMark2 Score: Actual - $score vs Expected - $SCORE_PASS_THRESHOLD"

  [[ "$score" -ge "$SCORE_PASS_THRESHOLD" ]]

  run -0 gpu_kernel_logs
}

# bats test_tags=platform:imx8, platform:sl1680, platform:imx93, platform:imx95, platform:am62, platform:am62p, platform:upstream, platform:am69, platform:am67a
@test "XTerm with XWayland runs" {
  bats_require_minimum_version 1.5.0

  run -124 docker compose -f "$COMPOSE_FILE" exec --user torizon "${file_name}" timeout 5s xterm -fa DejaVuSansMono

  echo "Ran for 5 seconds without crashing, terminated by timeout."
}
