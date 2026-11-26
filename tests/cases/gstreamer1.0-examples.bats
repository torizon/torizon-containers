#!/usr/bin/env bats

load ./general-helper.sh

file_name=$(basename "$BATS_TEST_FILENAME" .bats)

setup_file() {
  setup_test "${file_name}"
}

teardown_file() {
  teardown_test "${file_name}"
}

# bats test_tags=platform:imx8
@test "GStreamer container selects the Hantro VPU variant for the SoC" {
  bats_require_minimum_version 1.5.0

  if [[ "$SOC_UDT" =~ imx8mm ]]; then
    variant="mx8mm"
  elif [[ "$SOC_UDT" =~ imx8mp ]]; then
    variant="mx8mp"
  else
    skip "No Hantro VPU variant selection on $SOC_UDT"
  fi

  run -0 docker compose -f "$COMPOSE_FILE" exec -T "${file_name}" \
    cat /etc/ld.so.conf.d/00-imx-vpuwrap.conf
  [[ "$output" == "/usr/lib/aarch64-linux-gnu/${variant}" ]]

  run -0 docker compose -f "$COMPOSE_FILE" exec -T "${file_name}" \
    readlink /usr/bin/vsidaemon
  [[ "$output" == "/usr/bin/vsidaemon-${variant}" ]]
}

# bats test_tags=platform:imx8
@test "GStreamer container selects the HiFi4 DSP firmware for the SoC" {
  bats_require_minimum_version 1.5.0

  if [[ "$SOC_UDT" =~ imx8mp ]]; then
    platform="imx8m"
  elif [[ "$SOC_UDT" =~ imx8q || "$SOC_UDT" =~ imx8dx ]]; then
    platform="imx8qmqxp"
  else
    skip "No HiFi4 DSP firmware selection on $SOC_UDT"
  fi

  run -0 docker compose -f "$COMPOSE_FILE" exec -T "${file_name}" \
    readlink /usr/lib/firmware/imx/dsp/hifi4.bin
  [[ "$output" == "${platform}/hifi4.bin" ]]
}

# bats test_tags=platform:imx8
@test "GStreamer hardware H.264 decode runs" {
  bats_require_minimum_version 1.5.0

  run -0 docker compose -f "$COMPOSE_FILE" exec "${file_name}" \
    gstreamer-decode \
    --input /usr/share/gstreamer1.0-examples/test-h264.h264

  [[ "$output" == *"Decoded frames: 300"* ]]
  [[ "$output" == *"H.264 decoding completed successfully"* ]]
  [[ "$output" == *"Result: PASS"* ]]
}

# bats test_tags=platform:imx8
@test "GStreamer hardware H.264 encode runs" {
  bats_require_minimum_version 1.5.0

  run -0 docker compose -f "$COMPOSE_FILE" exec "${file_name}" \
    gstreamer-encode \
    --output /tmp/encoded.h264 \
    --frames 120
  [[ "$output" == *"H.264 encoding completed successfully"* ]]
  [[ "$output" == *"Encoded bytes:"* ]]
  [[ "$output" == *"Encoded frames: 120"* ]]
  [[ "$output" == *"Result: PASS"* ]]
}

# bats test_tags=platform:imx8
@test "GStreamer H.264 RTP UDP loopback runs" {
  bats_require_minimum_version 1.5.0

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