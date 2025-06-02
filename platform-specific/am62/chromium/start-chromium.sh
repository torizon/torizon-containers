#!/bin/bash

DEFAULT_URL="www.toradex.com"
DRY_RUN=false

chromium_base_params="
  --allow-insecure-localhost
  --disable-notifications
  --in-process-gpu
  --check-for-update-interval=315360000
  --disable-seccomp-filter-sandbox
  --no-sandbox
  --enable-features=UseOzonePlatform
  --ozone-platform=wayland
"

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
    --virtual-keyboard)
      chromium_extended_params="${chromium_extended_params} --load-extension=/chrome-extensions/chrome-virtual-keyboard-master"
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

COMMAND=$(echo "chromium $chromium_base_params$chromium_extended_params $chromium_mode_params$DEFAULT_URL" | xargs)

if [ "$DRY_RUN" = true ]; then
  echo "$COMMAND"
else
  eval "$COMMAND"
fi
