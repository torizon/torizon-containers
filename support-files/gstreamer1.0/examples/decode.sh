#!/usr/bin/env bash

# Decodes an H.264 elementary stream using the hardware decoder selected for
# the target i.MX8 platform. Hantro platforms use vpudec, while Amphion
# platforms use v4l2h264dec. Decoded frames are sent to fakesink so the entire
# stream can be validated without requiring a display or producing a raw file.

set -euo pipefail

usage() {
  cat <<EOF
Usage:
  $(basename "$0") --backend <hantro|amphion> --input <file.h264>

Options:
  --backend BACKEND  Decoder backend: hantro or amphion
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

decode_hantro() {
  require_element "vpudec"

  echo "Decoder backend: Hantro"
  echo "Decoder element: vpudec"

  gst-launch-1.0 -q \
    filesrc location="$input_file" \
    ! h264parse \
    ! vpudec \
    ! fakesink sync=false
}

decode_amphion() {
  require_element "v4l2h264dec"

  echo "Decoder backend: Amphion"
  echo "Decoder element: v4l2h264dec"

  gst-launch-1.0 -q \
    filesrc location="$input_file" \
    ! h264parse \
    ! v4l2h264dec \
    ! fakesink sync=false
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

[[ -n "$backend" ]] || fail "--backend is required"
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

case "$backend" in
  hantro)
    decode_hantro
    ;;

  amphion)
    decode_amphion
    ;;

  *)
    fail "Unsupported backend: $backend"
    ;;
esac

echo "H.264 decoding completed successfully"
echo "Result: PASS"
