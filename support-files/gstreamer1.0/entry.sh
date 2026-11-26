#!/bin/bash

# Initializes the container for the detected i.MX8 SoC.
# It reads the SoC identifier, selects the appropriate HiFi4 DSP firmware for
# supported platforms, updates the firmware symlink, selects the Hantro VPU
# wrapper library and daemon variants matching the running SoC, and then
# executes the command passed to the container.

set -e

# /sys/devices/soc0/soc_id is readable in unprivileged containers, unlike
# /proc/device-tree, which points to /sys/firmware and is masked by Docker.
SOC_ID_FILE="/sys/devices/soc0/soc_id"
DSP_FIRMWARE_DIR="/usr/lib/firmware/imx/dsp"
DSP_FIRMWARE_LINK="${DSP_FIRMWARE_DIR}/hifi4.bin"
VPUWRAP_LIB_DIR="/usr/lib/aarch64-linux-gnu"
VPUWRAP_LD_CONF="/etc/ld.so.conf.d/00-imx-vpuwrap.conf"
VSIDAEMON_BIN="/usr/bin/vsidaemon"

read_soc_id() {
  if [ ! -r "${SOC_ID_FILE}" ]; then
    echo "Warning: ${SOC_ID_FILE} is not available; skipping SoC-specific setup" >&2
    return 1
  fi

  soc_id="$(cat "${SOC_ID_FILE}")"
  echo "Detected SoC: ${soc_id}"
}

select_imx_dsp_firmware() {
  local platform
  local firmware

  # The i.MX8DX shares the i.MX8QXP die and reports i.MX8QXP.
  case "${soc_id}" in
    i.MX8MP) platform="imx8m" ;;
    i.MX8QM | i.MX8QXP | i.MX8DXL) platform="imx8qmqxp" ;;
    i.MX8ULP) platform="imx8ulp" ;;
    *)
      echo "No HiFi4 firmware selection required for ${soc_id}"
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
  local variant
  local libdir

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

if read_soc_id; then
  select_imx_dsp_firmware
  select_imx_vpu_hantro_variant
fi

exec "$@"
