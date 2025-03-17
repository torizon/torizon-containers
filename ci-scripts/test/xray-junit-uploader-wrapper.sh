#!/bin/bash

for prefix in VERDIN_IMX8MPQ VERDIN_AM62DUAL VERDIN_IMX8MMQ APALIS_IMX6Q APALIS_IMX8QM COLIBRI_IMX8QXP COLIBRI_IMX7D_EMMC COLIBRI_IMX6DL COLIBIR_IMX6ULL SK_AM62 SK_AM62P; do
  board_name=$(echo "$prefix" | tr '[:upper:]' '[:lower:]' | tr '_' '-')

  var_name="${prefix}_TEST_EXEC_KEY"
  report_path="reports/report-e2e-test-${board_name}-nightly.xml"

  if [ -f "$report_path" ]; then
    xray-junit-uploader \
      --report "$report_path" \
      --test-plan-key "$TORIZON_OS_TEST_PLAN_KEY" \
      --test-exec-key "${!var_name}"
  fi
done
