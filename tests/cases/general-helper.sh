#!/usr/bin/env bash

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
