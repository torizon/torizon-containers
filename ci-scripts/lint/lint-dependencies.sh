#!/bin/bash

# small script that checks if the dependencies inside the `build/*yml` jobs
# are correct. It parses the yaml files and errors out if IMAGE_BASE doesn't
# end with the specified suffix, like '-am62' or '-imx8'.

if ! command -v yq &>/dev/null; then
  echo "Error: 'yq' is not installed. Please install yq to proceed."
  exit 1
fi

if [ "$#" -ne 2 ]; then
  echo "Usage: $0 <yaml_file> <suffix>"
  exit 1
fi

YAML_FILE="$1"
SUFFIX="$2"
ERROR_FOUND=0

IMAGE_NAMES=$(yq eval '.. | select(has("IMAGE_NAME")) | .IMAGE_NAME' "$YAML_FILE")

for IMAGE_NAME in $IMAGE_NAMES; do
  if [[ "$IMAGE_NAME" != *"$SUFFIX" ]]; then
    echo "Error: IMAGE_NAME '$IMAGE_NAME' does not end with '$SUFFIX'."
    ERROR_FOUND=1
  fi
done

if [ "$ERROR_FOUND" -eq 1 ]; then
  exit 1
fi
