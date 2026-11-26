#!/usr/bin/env bash

# Decodes an H.264 elementary stream using the hardware decoder selected for
# the target i.MX8 platform. Hantro platforms use vpudec, while Amphion
# platforms use v4l2h264dec. Decoded frames are sent to fakesink so the entire
# stream can be validated without requiring a display or producing a raw file.
# Fails if the decoded frame count differs from the input.

set -euo pipefail

readonly SOC_ID_FILE="/sys/devices/soc0/soc_id"

usage() {
  cat <<EOF
Usage:
  $(basename "$0") [--backend <hantro|amphion>] --input <file.h264>

Options:
  --backend BACKEND  Decoder backend: hantro or amphion
                     Default: detected from the SoC
  --input FILE       H.264 elementary stream to decode
  -h, --help         Show this help message
EOF
}

fail() {
  echo "ERROR: $*" >&2
  exit 1
}

require_element() {
  local element="$1"

  if ! gst-inspect-1.0 "$element" >/dev/null 2>&1; then
    fail "Required GStreamer element is unavailable: $element"
  fi
}

# Sets backend from the running SoC when --backend is not given.
detect_backend() {
  local soc_id

  [[ -r "$SOC_ID_FILE" ]] ||
    fail "Cannot detect the SoC: $SOC_ID_FILE is unavailable; pass --backend"

  soc_id="$(<"$SOC_ID_FILE")"
  echo "Detected SoC: $soc_id"

  case "$soc_id" in
    i.MX8MM | i.MX8MP | i.MX8MQ) backend="hantro" ;;
    i.MX8QM | i.MX8QXP) backend="amphion" ;;
    *) fail "No hardware H.264 decoder known for $soc_id; pass --backend" ;;
  esac
}

# Prints the number of buffers the given pipeline pushes into a fakesink.
count_frames() {
  local output

  output="$(gst-launch-1.0 -v "$@" ! fakesink silent=false sync=false)" ||
    fail "GStreamer pipeline failed: $*"

  grep -c "last-message = chain" <<<"$output" || true
}

backend=""
input_file=""

while (($# > 0)); do
  case "$1" in
    --backend)
      (($# >= 2)) || fail "Missing value for --backend"
      backend="$2"
      shift 2
      ;;

    --input)
      (($# >= 2)) || fail "Missing value for --input"
      input_file="$2"
      shift 2
      ;;

    -h | --help)
      usage
      exit 0
      ;;

    *)
      fail "Unknown argument: $1"
      ;;
  esac
done

[[ -n "$input_file" ]] || fail "--input is required"
[[ -f "$input_file" ]] || fail "Input file does not exist: $input_file"
[[ -r "$input_file" ]] || fail "Input file is not readable: $input_file"
[[ -s "$input_file" ]] || fail "Input file is empty: $input_file"

command -v gst-launch-1.0 >/dev/null 2>&1 ||
  fail "gst-launch-1.0 is unavailable"

command -v gst-inspect-1.0 >/dev/null 2>&1 ||
  fail "gst-inspect-1.0 is unavailable"

require_element "filesrc"
require_element "h264parse"
require_element "fakesink"

echo "Input file: $input_file"

[[ -n "$backend" ]] || detect_backend

case "$backend" in
  hantro)
    backend_name="Hantro"
    decoder="vpudec"
    ;;

  amphion)
    backend_name="Amphion"
    decoder="v4l2h264dec"
    ;;

  *)
    fail "Unsupported backend: $backend"
    ;;
esac

require_element "$decoder"

echo "Decoder backend: $backend_name"
echo "Decoder element: $decoder"

input_frames="$(count_frames \
  filesrc location="$input_file" \
  ! h264parse \
  ! "video/x-h264,alignment=au")"

echo "Input frames: $input_frames"

((input_frames > 0)) || fail "No H.264 frames found in $input_file"

decoded_frames="$(count_frames \
  filesrc location="$input_file" \
  ! h264parse \
  ! "$decoder")"

echo "Decoded frames: $decoded_frames"

((decoded_frames == input_frames)) ||
  fail "Decoded $decoded_frames frames, expected $input_frames"

echo "H.264 decoding completed successfully"
echo "Result: PASS"
