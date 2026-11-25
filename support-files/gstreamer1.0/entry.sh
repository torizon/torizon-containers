#!/bin/bash

# Initializes the container for the detected i.MX8 SoC.
# It reads the device-tree compatibility information, selects the appropriate
# HiFi4 DSP firmware for supported platforms, updates the firmware symlink,
# selects the Hantro VPU wrapper library and daemon variants matching the
# running SoC, and then executes the command passed to the container.

set -e

DSP_FIRMWARE_DIR="/usr/lib/firmware/imx/dsp"
COMPATIBLE_FILE="/proc/device-tree/compatible"
DSP_FIRMWARE_LINK="${DSP_FIRMWARE_DIR}/hifi4.bin"
SOC_ID_FILE="/sys/devices/soc0/soc_id"
VPUWRAP_LIB_DIR="/usr/lib/aarch64-linux-gnu"
VPUWRAP_LD_CONF="/etc/ld.so.conf.d/00-imx-vpuwrap.conf"
VSIDAEMON_BIN="/usr/bin/vsidaemon"

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

# libfslvpuwrap3 (imx-vpuwrap) installs one libfslvpuwrap.so.3 per i.MX8M
# variant under /usr/lib/aarch64-linux-gnu/<variant>/, and
# imx-vpu-hantro-daemon installs one /usr/bin/vsidaemon-<variant> binary per
# variant. Point the dynamic loader to the variant matching the running SoC
# and link the matching Hantro daemon.
select_imx_vpu_hantro_variant() {
  local soc_id
  local variant
  local libdir

  if [ ! -r "${SOC_ID_FILE}" ]; then
    echo "Warning: ${SOC_ID_FILE} is not available; skipping Hantro VPU variant selection" >&2
    return 0
  fi

  soc_id="$(cat "${SOC_ID_FILE}")"

  case "${soc_id}" in
    i.MX8MM) variant="mx8mm" ;;
    i.MX8MP) variant="mx8mp" ;;
    i.MX8MQ) variant="mx8mq" ;;
    *)
      echo "No Hantro VPU variant selection required for ${soc_id}"
      return 0
      ;;
  esac

  libdir="${VPUWRAP_LIB_DIR}/${variant}"

  if [ ! -d "${libdir}" ]; then
    echo "Error: Hantro VPU wrapper library directory not found: ${libdir}" >&2
    return 1
  fi

  echo "Selecting Hantro VPU wrapper library from ${variant}"

  if ! echo "${libdir}" >"${VPUWRAP_LD_CONF}" || ! ldconfig; then
    echo "Warning: could not update the dynamic loader cache; run the container as root" >&2
    return 0
  fi

  ln -sfn "${VSIDAEMON_BIN}-${variant}" "${VSIDAEMON_BIN}"
}

select_imx_dsp_firmware
select_imx_vpu_hantro_variant

exec "$@"
