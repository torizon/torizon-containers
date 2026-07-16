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

# bats test_tags=platform:imx8
@test "GStreamer hardware H.264 decode runs" {
  bats_require_minimum_version 1.5.0
  run -0 clean_kernel_logs

  if [[ "$SOC_UDT" =~ imx8mm || "$SOC_UDT" =~ imx8mp ]]; then
    backend="hantro"
  elif [[ "$SOC_UDT" =~ imx8q || "$SOC_UDT" =~ imx8dx ]]; then
    backend="amphion"
  else
    echo "Unexpected SOC_UDT=$SOC_UDT" >&2
    return 1
  fi

  run -0 docker compose -f "$COMPOSE_FILE" exec "${file_name}" \
    gstreamer-decode \
    --backend "$backend" \
    --input /usr/share/gstreamer1.0-examples/test-h264.h264

  [[ "$output" == *"H.264 decoding completed successfully"* ]]
  [[ "$output" == *"Result: PASS"* ]]
}

# bats test_tags=platform:imx8
@test "GStreamer hardware H.264 encode runs" {
  bats_require_minimum_version 1.5.0
  run -0 clean_kernel_logs

  if [[ "$SOC_UDT" =~ imx8mm || "$SOC_UDT" =~ imx8mp ]]; then
    backend="hantro"
  elif [[ "$SOC_UDT" =~ imx8q || "$SOC_UDT" =~ imx8dx ]]; then
    backend="amphion"
  else
    echo "Unexpected SOC_UDT=$SOC_UDT" >&2
    return 1
  fi

  run -0 docker compose -f "$COMPOSE_FILE" exec "${file_name}" \
    gstreamer-encode \
    --backend "$backend" \
    --output /tmp/encoded.h264 \
    --frames 120
  [[ "$output" == *"H.264 encoding completed successfully"* ]]
  [[ "$output" == *"Encoded bytes:"* ]]
  [[ "$output" == *"Result: PASS"* ]]
}

# bats test_tags=platform:imx8
@test "GStreamer H.264 RTP UDP loopback runs" {
  bats_require_minimum_version 1.5.0
  run -0 clean_kernel_logs

  run -0 docker compose -f "$COMPOSE_FILE" exec "${file_name}" \
    gstreamer-stream loopback \
    --input /usr/share/gstreamer1.0-examples/test-h264.mp4 \
    --output /tmp/received.h264 \
    --port 5000 \
    --duration 30

  [[ "$output" == *"All RTP packets were received in the correct order"* ]]
  [[ "$output" == *"RTP packet contents match successfully"* ]]
  [[ "$output" == *"H.264 RTP UDP loopback completed successfully"* ]]
  [[ "$output" == *"Result: PASS"* ]]
}