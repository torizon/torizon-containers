#!/usr/bin/env bats

load ./general-helper.sh

TFLITE_CONTAINER_NAME="${TFLITE_CONTAINER_NAME:-tflite-tests}"
TFLITE_IMAGE="${TFLITE_IMAGE:-torizon/tensorflow-lite-imx8:stable-rc}"
TFLITE_MEAN_MAX="${TFLITE_MEAN_MAX:-0.01}"

setup_file() {
  bats_require_minimum_version 1.5.0

  cleanup_container "$TFLITE_CONTAINER_NAME"
}

teardown_file() {
  cleanup_container "$TFLITE_CONTAINER_NAME"
}

# bats test_tags=platform:imx8
@test "TensorFlow Lite container runs benchmark with Delegate" {
  run -0 timeout 10m docker run --rm \
    --name "$TFLITE_CONTAINER_NAME" \
    --privileged \
    -v /dev:/dev \
    -v /tmp:/tmp \
    "$TFLITE_IMAGE"

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
