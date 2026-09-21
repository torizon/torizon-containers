#!/usr/bin/env bats

bats_load_library bats-assert

load ./general-helper.sh

file_name=$(basename "$BATS_TEST_FILENAME" .bats)

setup_file() {
  setup_test "${file_name}" 40
}

teardown_file() {
  teardown_test "${file_name}"
}

# bats test_tags=platform:orin
@test "Photo booth serves the panel" {
  run -0 docker compose -f "$COMPOSE_FILE" logs photo-booth
  assert_output --partial "panel on http://0.0.0.0:8080"
}
