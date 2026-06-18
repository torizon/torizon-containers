#!/usr/bin/env bats

load ./general-helper.sh

file_name=$(basename "$BATS_TEST_FILENAME" .bats)

setup_file() {
  setup_test weston
  setup_test "${file_name}"
}

teardown_file() {
  teardown_test "${file_name}"
  teardown_test weston
}

# bats test_tags=platform:imx8, platform:sl1680, platform:imx93, platform:imx95, platform:am62, platform:am62p, platform:upstream, platform:am69, platform:am67a
@test "Simple GTK3 application runs" {
  bats_require_minimum_version 1.5.0

  RUN_SIMPLE_GTK_3_TEST='simple-gtk3-test'

  run -124 docker compose -f "$COMPOSE_FILE" exec "${file_name}" timeout 10s $RUN_SIMPLE_GTK_3_TEST

  echo $status

  echo "Ran for 10 seconds without crashing, terminated by timeout."
}

# bats test_tags=platform:imx8, platform:sl1680, platform:imx93, platform:imx95, platform:am62, platform:am62p, platform:upstream, platform:am69, platform:am67a
@test "gtk3-icon-browser runs" {
  bats_require_minimum_version 1.5.0

  RUN_GTK_3_EXAMPLE='gtk3-icon-browser'

  run -124 docker compose -f "$COMPOSE_FILE" exec "${file_name}" timeout 10s $RUN_GTK_3_EXAMPLE

  echo $status

  echo "Ran for 10 seconds without crashing, terminated by timeout."
}
