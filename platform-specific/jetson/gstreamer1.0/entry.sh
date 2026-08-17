#!/bin/sh
set -eu

if [ "$(id -u)" = "0" ]; then
  case "$(tr -d '\0' </proc/device-tree/compatible 2>/dev/null || true)" in
    *tegra264*) CUDA_DRV_VARIANT="openrm" ;;
    *) CUDA_DRV_VARIANT="nvgpu" ;;
  esac

  if [ ! -e "/opt/nvidia/l4t-gpu-libs/${CUDA_DRV_VARIANT}/libcuda.so.1" ]; then
    echo "entry.sh: no libcuda for variant '${CUDA_DRV_VARIANT}'" >&2
    exit 1
  fi

  echo "/opt/nvidia/l4t-gpu-libs/${CUDA_DRV_VARIANT}" >/etc/ld.so.conf.d/nvidia-l4t-cuda.conf
  ldconfig
fi

if [ "$#" -eq 0 ]; then
  exec /bin/bash
fi

exec "$@"
