#!/bin/bash

if [[ "$PLATFORM_FILTER" == *am62* ]]; then
  DOCKER_RUN=$(read-docker-run.sh "/runs/chromium-tests/chromium-tests-am62-compose.run" "chromium-tests-am62" "chromium-tests" "bash")
elif [[ "$PLATFORM_FILTER" == *imx8* ]]; then
  DOCKER_RUN=$(read-docker-run.sh "/runs/chromium-tests/chromium-tests-imx8-compose.run" "chromium-tests-imx8" "chromium-tests" "bash")
elif [[ "$PLATFORM_FILTER" == *imx95* ]]; then
  DOCKER_RUN=$(read-docker-run.sh "/runs/chromium-tests/chromium-tests-imx95-compose.run" "chromium-tests-imx95" "chromium-tests" "bash")
else
  DOCKER_RUN=$(read-docker-run.sh "/runs/chromium-tests/chromium-tests-upstream-compose.run" "chromium-tests" "chromium-tests")
fi 