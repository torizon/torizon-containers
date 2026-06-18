#!/usr/bin/env bats

load ./general-helper.sh

TFLITE_MEAN_MAX="${TFLITE_MEAN_MAX:-0.1}"

file_name=$(basename "$BATS_TEST_FILENAME" .bats)

setup_file() {
  setup_test "${file_name}"
}

teardown_file() {
  teardown_test "${file_name}"
}

# bats test_tags=platform:imx8, platform:sl1680
@test "TensorFlow Lite container runs benchmark with Delegate" {

  run -0 docker compose -f "$COMPOSE_FILE" logs "${file_name}"

  echo "$output" | grep -qE 'vx_delegate Delegate::Init|INFO: Vx delegate:' \
    || { echo "VX delegate not detected in output"; false; }

  images_processed="$(
    echo "$output" | awk -F: '/Images processed/ {gsub(/[[:space:]]/,"",$2); print $2; exit}'
  )"
  [[ -n "$images_processed" ]] || { echo "Could not parse Images processed"; false; }
  [[ "$images_processed" -ge 1 ]] || { echo "Images processed too low: $images_processed"; false; }

  mean_time="$(
    echo "$output" | awk -F: '/Mean inference time/ {print $2; exit}' | xargs
  )"
  [[ -n "$mean_time" ]] || { echo "Could not parse Mean inference time"; false; }

  awk -v m="$mean_time" -v max="$TFLITE_MEAN_MAX" 'BEGIN{exit !(m<=max)}' \
    || { echo "Mean inference time too high: $mean_time > $TFLITE_MEAN_MAX"; false; }
}

# bats test_tags=platform:imx95
@test "Tensorflow Lite Examples container runs with NPU Delegate" {
  bats_require_minimum_version 1.5.0

  run -0 docker compose -f "$COMPOSE_FILE" logs "${file_name}"

  echo "$output" | grep -qE "Neutron delegate version" \
    || { echo "Neutron delegate not detected in output"; false; }

  images_processed="$(
    echo "$output" | awk -F: '/Images processed/ {gsub(/[[:space:]]/,"",$2); print $2; exit}'
  )"
  [[ -n "$images_processed" ]] || { echo "Could not parse Images processed"; false; }
  [[ "$images_processed" -ge 1 ]] || { echo "Images processed too low: $images_processed"; false; }

  mean_time="$(
    echo "$output" | awk -F: '/Mean inference time/ {print $2; exit}' | xargs
  )"
  [[ -n "$mean_time" ]] || { echo "Could not parse Mean inference time"; false; }

  awk -v m="$mean_time" -v max="$TFLITE_MEAN_MAX" 'BEGIN{exit !(m<=max)}' \
    || { echo "Mean inference time too high: $mean_time > $TFLITE_MEAN_MAX"; false; }

}
