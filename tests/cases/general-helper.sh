#!/usr/bin/env bash

SCRIPT_DIR="$(realpath "${BASH_SOURCE[0]}")"
export SCRIPT_DIR

COMPOSE_DIR="${SCRIPT_DIR}/../compose"
export COMPOSE_DIR

check_if_base_container_runs() {
  local container_name="$1"

  docker container ls | grep -q "$container_name"
  local status=$?

  if [[ "$status" -ne 0 ]]; then
    echo "Base container '$container_name' is not running"
    exit 1
  fi
}

cleanup_container() {
  local container_name="$1"

  docker container kill "$container_name"
  docker image rm -f "$(docker container inspect -f '{{.Image}}' "$container_name")"
  docker container rm "$container_name"
}

export_arch_triplet() {
  local arch
  arch=$(uname -m)

  case "$arch" in
    aarch64)
      ARCH_TRIPLET="aarch64-linux-gnu"
      ;;
    armv7l | armv7)
      ARCH_TRIPLET="arm-linux-gnueabihf"
      ;;
    x86_64)
      ARCH_TRIPLET="x86_64-linux-gnu"
      ;;
    *)
      echo "Unsupported architecture: $arch"
      exit 1
      ;;
  esac

  export ARCH_TRIPLET
}

get_platform_filter() {
  case "$1" in
    *am62p*) echo "platform:am62p" ;;
    *am62*) echo "platform:am62" ;;
    *imx8*) echo "platform:imx8" ;;
    *imx93*) echo "platform:imx93" ;;
    *imx95*) echo "platform:imx95" ;;
    *am69*) echo "platform:am69" ;;
    *sl1680*) echo "platform:sl1680" ;;
    *beagley-ai*) echo "platform:am67a" ;;
    *) echo "platform:upstream" ;;
  esac
}

get_compose_file() {
  local base_name="$1"
  local folder="demo-gallery-composes"

  if [[ -n "$PLATFORM" ]]; then
    if [[ "$base_name" == *tests* ]]; then
      folder="test-composes"
    fi

    echo "/tests/${folder}/${base_name}/${base_name}-${PLATFORM}-compose.yml"
  fi
}

setup_test() {
  local compose_service_name="$1"
  local timeout="${2:-10}"

  docker container kill "$compose_service_name" || true
  docker container rm "$compose_service_name" || true

  compose_file=$(get_compose_file "$compose_service_name")
  COMPOSE_FILE="$compose_file"
  export COMPOSE_FILE

  docker compose -f "$compose_file" up -d

  sleep "${timeout}"

}

teardown_test() {
  local compose_service_name="$1"

  compose_file=$(get_compose_file "$compose_service_name")

  docker compose -f "$compose_file" down --volumes --rmi all --remove-orphans

  rm -rf /tmp/1000-runtime-dir
}
