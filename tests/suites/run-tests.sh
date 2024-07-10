#!/bin/bash

start=$(date +%s)

BASE_DIR=/suites

if [ "$SOC_UDT" == "am62" ]; then
    TARGET_DIR="am62"
elif [[ "$SOC_UDT" == imx8* ]]; then
    TARGET_DIR="imx8"
else
    TARGET_DIR="upstream"
fi

FULL_PATH="$BASE_DIR/$TARGET_DIR"

cd "$FULL_PATH" || { echo "Failed to change directory to $FULL_PATH"; exit 1; }
bats --report-formatter junit --output /home/torizon --recursive .

echo "Executed bats command in $FULL_PATH"

end=$(date +%s)
runtime=$((end-start))
echo "Total execution time: $runtime seconds"
