#!/bin/bash

# Initializes the container for the detected i.MX8 SoC.
# It reads the device-tree compatibility information, selects the appropriate
# HiFi4 DSP firmware for supported platforms, updates the firmware symlink,
# and then executes the command passed to the container.

set -e

DSP_FIRMWARE_DIR="/usr/lib/firmware/imx/dsp"
COMPATIBLE_FILE="/proc/device-tree/compatible"
DSP_FIRMWARE_LINK="${DSP_FIRMWARE_DIR}/hifi4.bin"

select_imx_dsp_firmware() {
  local compatible
  local platform
  local firmware

  if [ ! -r "${COMPATIBLE_FILE}" ]; then
    echo "Warning: ${COMPATIBLE_FILE} is not available; skipping DSP firmware selection" >&2
    return 0
  fi

  compatible="$(tr '\0' '\n' <"${COMPATIBLE_FILE}")"

  case "${compatible}" in
    *fsl,imx8mp*)
      platform="imx8m"
      ;;

    *fsl,imx8qm* | *fsl,imx8qxp* | *fsl,imx8dx*)
      platform="imx8qmqxp"
      ;;

    *fsl,imx8ulp*)
      platform="imx8ulp"
      ;;

    *)
      echo "No HiFi4 firmware selection required for this platform"
      return 0
      ;;
  esac

  firmware="${DSP_FIRMWARE_DIR}/${platform}/hifi4.bin"

  if [ ! -f "${firmware}" ]; then
    echo "Error: DSP firmware not found: ${firmware}" >&2
    return 1
  fi

  echo "Selecting HiFi4 firmware from ${platform}"

  ln -sfn \
    "${platform}/hifi4.bin" \
    "${DSP_FIRMWARE_LINK}"

  echo "Selected DSP firmware:"
  ls -l "${DSP_FIRMWARE_LINK}"
}

select_imx_dsp_firmware

exec "$@"
