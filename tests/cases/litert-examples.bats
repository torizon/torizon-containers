#!/usr/bin/env bats

load ./general-helper.sh

LITERT_MEAN_MAX="${LITERT_MEAN_MAX:-0.1}"

file_name=$(basename "$BATS_TEST_FILENAME" .bats)

setup_file() {
  setup_test "${file_name}"
}

teardown_file() {
  teardown_test "${file_name}"
}

# bats test_tags=platform:imx95
@test "LiteRT container runs benchmark with Neutron delegate" {
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

  awk -v m="$mean_time" -v max="$LITERT_MEAN_MAX" 'BEGIN{exit !(m<=max)}' \
    || { echo "Mean inference time too high: $mean_time > $LITERT_MEAN_MAX"; false; }
}
