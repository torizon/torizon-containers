#!/usr/bin/env bats

load ./kernel-helper.sh

# the name of this file is what it is because it will make the tests
# defined here execute before any other. Yes, it is perhaps a bit odd
# but the alternative is a much more complicated orchestration of
# tests and merge of test results inside the run-tests.sh script.

# tests here are meant to be generally about system information that
# will be flushed in subsequent test runs (dmesg is the first example).

# bats test_tags=platform:imx8, platform:sl1680, platform:imx95, platform:am62, platform:am62p, platform:upstream
@test "pre-test: unflushed GPU kernel logs" {
  # subsequent tests will clean the kernel logs, so don't bother here
  run -0 gpu_kernel_logs
}

# bats test_tags=platform:imx8, platform:sl1680, platform:imx95, platform:am62, platform:am62p, platform:upstream, platform:am69
@test "DRM interface is available" {
  for interface in /sys/class/drm/*/status; do
    if [ -f "$interface" ]; then
      status=$(cat "$interface")
      if [ "$status" = "connected" ]; then
        echo "Display interface connected: $interface"
        return 0
      fi
    fi
  done

  echo "No display interface is connected."
  return 1
}

# bats test_tags=platform:imx8, platform:sl1680, platform:imx95, platform:am62, platform:am62p, platform:upstream, platform:am69
@test "renderD node exists in /dev/dri" {
  run compgen -G "/dev/dri/renderD*"
  [ "$status" -eq 0 ]
}
