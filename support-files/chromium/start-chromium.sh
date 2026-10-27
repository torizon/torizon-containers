#!/bin/bash

DEFAULT_URL="https://www.toradex.com"
DRY_RUN=false

# Returns success if a GPU is available:
# - DRM render node (etnaviv, panfrost, PowerVR, etc.)
# - Vivante proprietary driver (galcore)
has_gpu() {
  # Allow forcing the result (HAS_GPU=true|false), useful for tests
  if [ -n "$HAS_GPU" ]; then
    [ "$HAS_GPU" = true ]
    return
  fi
  ls /dev/dri/renderD* >/dev/null 2>&1 || [ -e /dev/galcore ]
}

chromium_base_params="
  --allow-insecure-localhost
  --disable-notifications
  --check-for-update-interval=315360000
  --disable-seccomp-filter-sandbox
  --no-sandbox
  --enable-features=UseOzonePlatform
  --ozone-platform=wayland
"

# Pick GPU-related params based on hardware
if has_gpu; then
  chromium_gpu_params="--use-gl=egl --in-process-gpu"
else
  # No GPU (e.g. i.MX93): use software rendering
  chromium_gpu_params="--disable-gpu"
fi

chromium_mode_params="--kiosk "

chromium_extended_params=""

for arg in "$@"; do
  case $arg in
    --window-mode)
      chromium_mode_params="--start-maximized --app="
      ;;
    --browser-mode)
      chromium_mode_params="--start-maximized "
      ;;
    --dry-run)
      DRY_RUN=true
      ;;
    --*)
      chromium_extended_params="${chromium_extended_params} $arg"
      ;;
    *)
      DEFAULT_URL=$arg
      ;;
  esac
done

COMMAND=$(echo "chromium $chromium_base_params $chromium_gpu_params$chromium_extended_params $chromium_mode_params$DEFAULT_URL" | xargs)

if [ "$DRY_RUN" = true ]; then
  echo "$COMMAND"
else
  eval "$COMMAND"
fi
