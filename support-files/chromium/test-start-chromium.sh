#!/bin/bash

FAILED_TESTS=0

run_test() {
  local test_name="$1"
  local args="$2"
  local expected_output="$3"

  echo "Running test: $test_name"
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

run_test "Default URL" "--dry-run" "chromium --allow-insecure-localhost --disable-notifications --use-gl=egl --in-process-gpu --check-for-update-interval=315360000 --disable-seccomp-filter-sandbox --no-sandbox --enable-features=UseOzonePlatform --ozone-platform=wayland --kiosk www.toradex.com"

run_test "Custom URL" "--dry-run https://example.com" "chromium --allow-insecure-localhost --disable-notifications --use-gl=egl --in-process-gpu --check-for-update-interval=315360000 --disable-seccomp-filter-sandbox --no-sandbox --enable-features=UseOzonePlatform --ozone-platform=wayland --kiosk https://example.com"

run_test "Window Mode" "--dry-run --window-mode https://example.com" "chromium --allow-insecure-localhost --disable-notifications --use-gl=egl --in-process-gpu --check-for-update-interval=315360000 --disable-seccomp-filter-sandbox --no-sandbox --enable-features=UseOzonePlatform --ozone-platform=wayland --start-maximized --app=https://example.com"

run_test "Browser Mode" "--dry-run --browser-mode https://example.com" "chromium --allow-insecure-localhost --disable-notifications --use-gl=egl --in-process-gpu --check-for-update-interval=315360000 --disable-seccomp-filter-sandbox --no-sandbox --enable-features=UseOzonePlatform --ozone-platform=wayland --start-maximized https://example.com"

run_test "Custom Param" "--dry-run --custom-param https://example.com" "chromium --allow-insecure-localhost --disable-notifications --use-gl=egl --in-process-gpu --check-for-update-interval=315360000 --disable-seccomp-filter-sandbox --no-sandbox --enable-features=UseOzonePlatform --ozone-platform=wayland --custom-param --kiosk https://example.com"

run_test "Multiple Options" "--dry-run --window-mode --custom-param https://example.com" "chromium --allow-insecure-localhost --disable-notifications --use-gl=egl --in-process-gpu --check-for-update-interval=315360000 --disable-seccomp-filter-sandbox --no-sandbox --enable-features=UseOzonePlatform --ozone-platform=wayland --custom-param --start-maximized --app=https://example.com"

if [ $FAILED_TESTS -gt 0 ]; then
  echo "Test suite failed: $FAILED_TESTS test(s) failed."
  exit 1
else
  echo "All tests passed successfully."
  exit 0
fi
