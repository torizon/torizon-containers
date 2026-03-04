#!/bin/bash

if [[ "$SOC_UDT" == *am62p* ]]; then
  PLATFORM_FILTER="platform:am62p"
elif [[ "$SOC_UDT" == *am62* ]]; then
  PLATFORM_FILTER="platform:am62"
elif [[ "$SOC_UDT" == *imx8* ]]; then
  PLATFORM_FILTER="platform:imx8"
elif [[ "$SOC_UDT" == *imx95* ]]; then
  PLATFORM_FILTER="platform:imx95"
elif [[ "$SOC_UDT" == *am69* ]]; then
  PLATFORM_FILTER="platform:am69"
elif [[ "$SOC_UDT" == *sl1680* ]]; then
  PLATFORM_FILTER="platform:sl1680"
elif [[ "$SOC_UDT" == *beagley-ai* ]]; then
  PLATFORM_FILTER="platform:am67a"
else
  PLATFORM_FILTER="platform:upstream"
fi

export PLATFORM_FILTER

# It's ok if bats fails, we just care about the report, hence the || true
bats --report-formatter junit --output /home/torizon --verbose-run --show-output-of-passing-tests --trace --recursive --timing --filter-tags "$PLATFORM_FILTER" . || true
