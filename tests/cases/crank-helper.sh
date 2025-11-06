#!/usr/bin/env bash

setup_crank() {
  docker container kill crank || true
  docker container rm crank || true

  local DOCKER_RUN
  if [[ "$PLATFORM_FILTER" == *am62* ]]; then
    DOCKER_RUN=$(read-docker-run.sh "/runs/crank/crank-am62-compose.run" "crank-am62" "crank")
  elif [[ "$PLATFORM_FILTER" == *imx8* ]]; then
    DOCKER_RUN=$(read-docker-run.sh "/runs/crank/crank-imx8-compose.run" "crank-imx8" "crank")
  elif [[ "$PLATFORM_FILTER" == *imx7* ]]; then
    DOCKER_RUN=$(read-docker-run.sh "/runs/crank/crank-imx7-compose.run" "crank-imx7" "crank")
  elif [[ "$PLATFORM_FILTER" == *imx6* ]]; then
    DOCKER_RUN=$(read-docker-run.sh "/runs/crank/crank-imx6-compose.run" "crank-imx6" "crank")
  fi

  # Add -it flag to match the original behavior
  DOCKER_RUN=${DOCKER_RUN//-d --name=/-d -it --name=}

  eval "$DOCKER_RUN"

  sleep 10

  check_if_base_container_runs crank

}

teardown_crank() {
  cleanup_container crank
}
