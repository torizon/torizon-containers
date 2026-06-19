#!/usr/bin/env bats

bats_load_library bats-assert

load ./kernel-helper.sh
load ./general-helper.sh

file_name=$(basename "$BATS_TEST_FILENAME" .bats)

setup_file() {
  local compose_service_name="${file_name}"
  local timeout=10

  docker container kill "$compose_service_name" || true
  docker container rm "$compose_service_name" || true

  compose_file=$(get_compose_file "$compose_service_name")
  COMPOSE_FILE="$compose_file"
  export COMPOSE_FILE

  docker compose -f "$compose_file" -f - up -d << EOF
services:
 luna-cameras-ai-demo:
   healthcheck:
     test: ["CMD-SHELL", "exit 0"]
EOF

  sleep "${timeout}"
}

teardown_file() {
  teardown_test "${file_name}"
}

# bats test_tags=platform:sl1680
@test "Luna Cameras AI Demo" {
  bats_require_minimum_version 1.5.0

  run -0 clean_kernel_logs

  run -0 docker compose -f "$COMPOSE_FILE" -f - top << EOF
services:
 luna-cameras-ai-demo:
   healthcheck:
     test: ["CMD-SHELL", "exit 0"]
EOF
  assert_output --partial "vision.dual_models"

  run -0 gpu_kernel_logs
}
