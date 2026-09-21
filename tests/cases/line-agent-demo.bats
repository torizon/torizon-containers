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
@test "Line simulator is running the line" {
  run -0 docker compose -f "$COMPOSE_FILE" logs sim
  assert_output --partial "line simulator on :8080"
}

# bats test_tags=platform:orin
@test "Maintenance agent is attached to the line" {
  run -0 docker compose -f "$COMPOSE_FILE" logs agent
  assert_output --partial "maintenance agent starting"
}
