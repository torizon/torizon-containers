#!/usr/bin/env bash

# Generates a synthetic video stream and encodes it as an H.264 elementary
# stream using the hardware encoder selected for the target i.MX8 platform.
# Hantro platforms use vpuenc_h264, while Amphion platforms use v4l2h264enc.
# The resulting H.264 stream is written to the output file provided by the user.
# Fails if the output frame count differs from --frames.

set -euo pipefail

readonly DEFAULT_FRAMES=120
readonly DEFAULT_WIDTH=640
readonly DEFAULT_HEIGHT=480
readonly DEFAULT_FRAMERATE="30/1"

usage() {
  cat <<EOF
Usage:
  $(basename "$0") --backend <hantro|amphion> --output <file.h264> [options]

Required options:
  --backend BACKEND  Encoder backend: hantro or amphion
  --output FILE      Output H.264 elementary stream

Optional:
  --frames NUMBER    Number of frames to encode
                     Default: ${DEFAULT_FRAMES}
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
    fail "Required GStreamer element is not available: $element"
  fi
}

validate_positive_integer() {
  local value="$1"
  local argument="$2"

  if [[ ! "$value" =~ ^[1-9][0-9]*$ ]]; then
    fail "$argument must be a positive integer: $value"
  fi
}

# Prints the number of buffers the given pipeline pushes into a fakesink.
count_frames() {
  local output

  output="$(gst-launch-1.0 -v "$@" ! fakesink silent=false sync=false)" ||
    fail "GStreamer pipeline failed: $*"

  grep -c "last-message = chain" <<<"$output" || true
}

encode_hantro() {
  require_element "vpuenc_h264"

  echo "Encoder backend: Hantro"
  echo "Encoder element: vpuenc_h264"
  echo "Input format: I420"

  gst-launch-1.0 -q -e \
    videotestsrc num-buffers="$frames" \
    ! "video/x-raw,format=I420,width=${DEFAULT_WIDTH},height=${DEFAULT_HEIGHT},framerate=${DEFAULT_FRAMERATE}" \
    ! vpuenc_h264 \
    ! h264parse \
    ! "video/x-h264,stream-format=byte-stream,alignment=au" \
    ! filesink location="$output_file"
}

encode_amphion() {
  require_element "v4l2h264enc"

  echo "Encoder backend: Amphion"
  echo "Encoder element: v4l2h264enc"
  echo "Input format: NV12"

  gst-launch-1.0 -q -e \
    videotestsrc num-buffers="$frames" \
    ! "video/x-raw,format=NV12,width=${DEFAULT_WIDTH},height=${DEFAULT_HEIGHT},framerate=${DEFAULT_FRAMERATE}" \
    ! v4l2h264enc \
    ! h264parse \
    ! "video/x-h264,stream-format=byte-stream,alignment=au" \
    ! filesink location="$output_file"
}

backend=""
output_file=""
frames="$DEFAULT_FRAMES"

while (($# > 0)); do
  case "$1" in
    --backend)
      (($# >= 2)) || fail "Missing value for --backend"
      backend="$2"
      shift 2
      ;;

    --output)
      (($# >= 2)) || fail "Missing value for --output"
      output_file="$2"
      shift 2
      ;;

    --frames)
      (($# >= 2)) || fail "Missing value for --frames"
      frames="$2"
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
[[ -n "$output_file" ]] || fail "--output is required"

validate_positive_integer "$frames" "--frames"

command -v gst-launch-1.0 >/dev/null 2>&1 ||
  fail "gst-launch-1.0 is not installed"

command -v gst-inspect-1.0 >/dev/null 2>&1 ||
  fail "gst-inspect-1.0 is not installed"

require_element "videotestsrc"
require_element "h264parse"
require_element "filesink"
require_element "filesrc"
require_element "fakesink"

output_directory="$(dirname "$output_file")"

[[ -d "$output_directory" ]] ||
  fail "Output directory does not exist: $output_directory"

[[ -w "$output_directory" ]] ||
  fail "Output directory is not writable: $output_directory"

rm -f "$output_file"

echo "Output file: $output_file"
echo "Frames: $frames"
echo "Resolution: ${DEFAULT_WIDTH}x${DEFAULT_HEIGHT}"
echo "Framerate: $DEFAULT_FRAMERATE"

case "$backend" in
  hantro)
    encode_hantro
    ;;

  amphion)
    encode_amphion
    ;;

  *)
    fail "Unsupported backend: $backend"
    ;;
esac

if [[ ! -s "$output_file" ]]; then
  rm -f "$output_file"
  fail "Encoding completed without producing a nonempty output file"
fi

echo "Encoded bytes: $(stat -c '%s' "$output_file")"

encoded_frames="$(count_frames \
  filesrc location="$output_file" \
  ! h264parse \
  ! "video/x-h264,alignment=au")"

echo "Encoded frames: $encoded_frames"

((encoded_frames == frames)) ||
  fail "Encoded $encoded_frames frames, expected $frames"

echo "H.264 encoding completed successfully"
echo "Result: PASS"
