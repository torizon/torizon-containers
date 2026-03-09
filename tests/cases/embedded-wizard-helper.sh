#!/usr/bin/env bash

setup_embedded_wizard() {
  docker container kill embedded-wizard || true
  docker container rm embedded-wizard || true

  local DOCKER_RUN
  if [[ "$PLATFORM_FILTER" == *am62p* ]]; then
    DOCKER_RUN=$(read-docker-run.sh "/runs/embedded-wizard/embedded-wizard-am62p-compose.run" "embedded-wizard-am62p" "embedded-wizard")
  elif [[ "$PLATFORM_FILTER" == *imx8* ]]; then
    DOCKER_RUN=$(read-docker-run.sh "/runs/embedded-wizard/embedded-wizard-imx8-compose.run" "embedded-wizard-imx8" "embedded-wizard")
  elif [[ "$PLATFORM_FILTER" == *imx95* ]]; then
    DOCKER_RUN=$(read-docker-run.sh "/runs/embedded-wizard/embedded-wizard-imx95-compose.run" "embedded-wizard-imx95" "embedded-wizard")
  else
    echo "Error: Unsupported platform filter: $PLATFORM_FILTER"
    return 1
  fi

  # Add -it flag to match the original behavior
  DOCKER_RUN=${DOCKER_RUN//-d --name=/-d -it --name=}

  eval "$DOCKER_RUN"

  sleep 10

  check_if_base_container_runs embedded-wizard

}

teardown_embedded_wizard() {
  cleanup_container embedded-wizard
}
