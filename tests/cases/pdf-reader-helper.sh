#!/usr/bin/env bash

setup_pdf-reader() {
  docker container kill pdf-reader || true
  docker container rm pdf-reader || true

  local DOCKER_RUN
  if [[ "$PLATFORM_FILTER" == *imx8* ]]; then
    DOCKER_RUN=$(read-docker-run.sh "/runs/pdf-reader/pdf-reader-imx8-compose.run" "pdf-reader-imx8" "pdf-reader")
  else
    return 1
  fi

  # Add -it flag to match the original behavior
  DOCKER_RUN=${DOCKER_RUN//-d --name=/-d -it --name=}

  eval "$DOCKER_RUN"

  sleep 10

  check_if_base_container_runs pdf-reader

}

teardown_pdf-reader() {
  cleanup_container pdf-reader
}
