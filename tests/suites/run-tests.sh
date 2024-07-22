#!/bin/bash

BASE_DIR=/suites

if [ "$SOC_UDT" == "am62" ]; then
    TARGET_DIR="am62"
elif [[ "$SOC_UDT" == imx8* ]]; then
    TARGET_DIR="imx8"
else
    TARGET_DIR="upstream"
fi

FULL_PATH="$BASE_DIR/$TARGET_DIR"

RESULT_DIR="/home/torizon"
mkdir -p "$RESULT_DIR"

find "$FULL_PATH" -type f -name setup_suite.bash -exec dirname {} \; | while read -r DIR; do
    echo "Running tests in $DIR"

    cd "$DIR" || { echo "Failed to change directory to $DIR"; exit 1; }

    bats --report-formatter junit --output "$RESULT_DIR" .
    mv $RESULT_DIR/report.xml $RESULT_DIR/"$(basename "$DIR")".xml

    echo "Executed bats command in $DIR"
done

echo "Merging test results..."

MERGED_REPORT="$RESULT_DIR/report.xml"
echo '<?xml version="1.0" encoding="UTF-8"?>' > "$MERGED_REPORT"
echo '<testsuites>' >> "$MERGED_REPORT"

find "$RESULT_DIR" -name '*.xml' | while read -r FILE; do
    xmlstarlet sel -t -c "//testsuite" "$FILE" >> "$MERGED_REPORT"
done

echo '</testsuites>' >> "$MERGED_REPORT"

echo "Merged JUnit report written to $MERGED_REPORT"
