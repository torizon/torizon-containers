#!/bin/bash

source /tests/cases/general-helper.sh

printf "\e[0Ksection_end:%s:prepare\r\e[0KDevice preparation finished\n" "$(date +%s)"

echo "$PAID_DOCKERHUB_TOKEN" | docker login --username "$PAID_DOCKERHUB_USER" --password-stdin

if [ "${REGISTRY:-}" = "${CI_REGISTRY:-}" ] && [ -n "${CI_REGISTRY_USER:-}" ]; then
  echo "$CI_REGISTRY_PASSWORD" | docker login --username "$CI_REGISTRY_USER" --password-stdin "$CI_REGISTRY"
  regctl registry login "$CI_REGISTRY" -u "$CI_REGISTRY_USER" -p "$CI_REGISTRY_PASSWORD"
fi

PLATFORM_FILTER=$(get_platform_filter "$SOC_UDT")
export PLATFORM_FILTER

PLATFORM="${PLATFORM_FILTER#platform:}"
export PLATFORM

printf "\e[0Ksection_start:%s:testing\r\e[0KStart Bats Testing\n" "$(date +%s)"

# It's ok if bats fails, we just care about the report, hence the || true
bats --report-formatter junit --output /home/torizon --verbose-run --show-output-of-passing-tests --trace --recursive --timing --filter-tags "$PLATFORM_FILTER" . || true

printf "\e[0Ksection_end:%s:testing\r\e[0KTests finished\n" "$(date +%s)"
