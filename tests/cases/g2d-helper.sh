#!/usr/bin/env bash

# Read dmesg logs related to PXP/G2D
g2d_kernel_logs() {
  logs=$(dmesg --read-clear | grep -i -E '(pxp|g2d|pixel.process)')
  echo "$logs"
}

clean_g2d_kernel_logs() {
  dmesg --clear
}

g2d_assert_faster_than_cpu() {
  local output="$1"

  local g2d_copy
  local cpu_copy
  g2d_copy=$(echo "$output" | grep "g2d copy non-cacheable" | grep -oE '[0-9]+' | head -1)
  cpu_copy=$(echo "$output" | grep "cpu copy non-cacheable" | grep -oE '[0-9]+' | head -1)

  echo "G2D copy: ${g2d_copy}us vs CPU copy: ${cpu_copy}us"

  if [ "$g2d_copy" -lt "$cpu_copy" ]; then
    echo "PASSED: G2D is faster than CPU"
    return 0
  else
    echo "FAILED: G2D is not faster than CPU"
    return 1
  fi
}
