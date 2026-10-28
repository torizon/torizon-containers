#!/bin/bash

FAILED_TESTS=0

# Common params shared by all expected outputs
BASE="chromium --allow-insecure-localhost --disable-notifications --check-for-update-interval=315360000 --disable-seccomp-filter-sandbox --no-sandbox --enable-features=UseOzonePlatform --ozone-platform=wayland"

run_test() {
  local test_name="$1"
  local args="$2"
  local expected_output="$3"

  echo "Running test: $test_name (HAS_GPU=$HAS_GPU)"
  # we specifically want to split the args here, so ignore 2086
  # shellcheck disable=SC2086
  actual_output=$(bash ./start-chromium.sh $args)

  if [ "$actual_output" = "$expected_output" ]; then
    echo "PASS"
  else
    echo "FAIL"
    echo "Expected: $expected_output"
    echo "Actual:   $actual_output"
    FAILED_TESTS=$((FAILED_TESTS + 1))
  fi
  echo
}

# --- Platforms with GPU ---
export HAS_GPU=true
GPU="--use-gl=egl --use-angle=gles --in-process-gpu"

run_test "Default URL" "--dry-run" "$BASE $GPU --kiosk https://www.toradex.com"

run_test "Custom URL" "--dry-run https://example.com" "$BASE $GPU --kiosk https://example.com"

run_test "Window Mode" "--dry-run --window-mode https://example.com" "$BASE $GPU --start-maximized --app=https://example.com"

run_test "Browser Mode" "--dry-run --browser-mode https://example.com" "$BASE $GPU --start-maximized https://example.com"

run_test "Custom Param" "--dry-run --custom-param https://example.com" "$BASE $GPU --custom-param --kiosk https://example.com"

run_test "Multiple Options" "--dry-run --window-mode --custom-param https://example.com" "$BASE $GPU --custom-param --start-maximized --app=https://example.com"

# --- Platforms without GPU (e.g. i.MX93) ---
export HAS_GPU=false
NO_GPU="--disable-gpu"

run_test "Default URL" "--dry-run" "$BASE $NO_GPU --kiosk https://www.toradex.com"

run_test "Window Mode" "--dry-run --window-mode https://example.com" "$BASE $NO_GPU --start-maximized --app=https://example.com"

run_test "Multiple Options" "--dry-run --window-mode --custom-param https://example.com" "$BASE $NO_GPU --custom-param --start-maximized --app=https://example.com"

if [ $FAILED_TESTS -gt 0 ]; then
  echo "Test suite failed: $FAILED_TESTS test(s) failed."
  exit 1
else
  echo "All tests passed successfully."
  exit 0
fi
