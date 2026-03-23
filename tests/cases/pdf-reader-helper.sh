#!/usr/bin/env bash

setup_pdf_reader() {
  docker container kill pdf-reader || true
  docker container rm pdf-reader || true

  local DOCKER_RUN
  if [[ "$PLATFORM_FILTER" == *imx8* ]]; then
    DOCKER_RUN=$(read-docker-run.sh "/runs/pdf-reader/pdf-reader-imx8-compose.run" "pdf-reader-imx8" "pdf-reader")
  elif [[ "$PLATFORM_FILTER" == *imx95* ]]; then
    DOCKER_RUN=$(read-docker-run.sh "/runs/pdf-reader/pdf-reader-imx95-compose.run" "pdf-reader-imx95" "pdf-reader")
  elif [[ "$PLATFORM_FILTER" == *am62* ]]; then
    DOCKER_RUN=$(read-docker-run.sh "/runs/pdf-reader/pdf-reader-am62-compose.run" "pdf-reader-am62" "pdf-reader")
  elif [[ "$PLATFORM_FILTER" == *am62p* ]]; then
    DOCKER_RUN=$(read-docker-run.sh "/runs/pdf-reader/pdf-reader-am62p-compose.run" "pdf-reader-am62p" "pdf-reader")
  elif [[ "$PLATFORM_FILTER" == *am69* ]]; then
    DOCKER_RUN=$(read-docker-run.sh "/runs/pdf-reader/pdf-reader-am69-compose.run" "pdf-reader-am69" "pdf-reader")
  else
    # return 1, since there is no PDF reader image for upstream, and we want to skip the test instead of failing it
    return 1
  fi

  # Add -it flag to match the original behavior
  DOCKER_RUN=${DOCKER_RUN//-d --name=/-d -it --name=}

  eval "$DOCKER_RUN"

  sleep 10

  check_if_base_container_runs pdf-reader

}

teardown_pdf_reader() {
  cleanup_container pdf-reader
}
