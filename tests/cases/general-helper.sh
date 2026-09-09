#!/usr/bin/env bash

GENERAL_HELPER_DIR="$(dirname "$(realpath "${BASH_SOURCE[0]}")")"
export GENERAL_HELPER_DIR

COMPOSE_DIR="${GENERAL_HELPER_DIR}/../compose"
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

# Echoes the most recent <slug>-<pipeline-id> tag pushed for an image repo, or nothing if none exists.
find_latest_pipeline_tag() {
  local repo="$1"
  local candidates
  candidates=$(regctl tag ls "$repo" 2>/dev/null |
    grep -E "^${CI_COMMIT_REF_SLUG}-[0-9]+\$" |
    sed "s/^${CI_COMMIT_REF_SLUG}-//" |
    sort -n)

  if [[ -z "$candidates" ]]; then
    echo "  no ${CI_COMMIT_REF_SLUG}-<pipeline-id> tags exist for ${repo}" >&2
    return 0
  fi

  echo "  candidate pipeline-ids for ${repo}: $(echo "$candidates" | tr '\n' ' ')" >&2
  local latest_suffix
  latest_suffix=$(echo "$candidates" | tail -1)
  echo "  picked highest: ${latest_suffix} (pipeline URL: .../-/pipelines/${latest_suffix})" >&2

  echo "${CI_COMMIT_REF_SLUG}-${latest_suffix}"
}

# Resolves the local IMAGE_TAG alias to the actual latest pipeline tag and re-tags it locally so callers can keep using :${IMAGE_TAG}.
resolve_image_tag() {
  local image_name="$1"
  local repo="${REGISTRY}/${REGISTRY_NAMESPACE}/${image_name}"

  if [[ "${REGISTRY:-}" != "${CI_REGISTRY:-}" ]]; then
    return 0
  fi

  local latest_tag
  latest_tag=$(find_latest_pipeline_tag "$repo")
  if [[ -z "$latest_tag" ]]; then
    echo "WARNING: no ${CI_COMMIT_REF_SLUG}-<pipeline-id> tag found for ${repo}; leaving :${IMAGE_TAG} unresolved"
    return 0
  fi

  echo "Resolved ${repo}:${IMAGE_TAG} -> ${latest_tag}"
  docker pull "${repo}:${latest_tag}"
  docker tag "${repo}:${latest_tag}" "${repo}:${IMAGE_TAG}"
}

# Resolves the latest pipeline tag and aliases it locally under the hardcoded "torizon/<image>:stable-rc" name the compose files expect.
resolve_pinned_image_tag() {
  local image_name="$1"
  local repo="${REGISTRY}/${REGISTRY_NAMESPACE}/${image_name}"
  local pinned_ref="${REGISTRY}/torizon/${image_name}:stable-rc"

  if [[ "${REGISTRY:-}" != "${CI_REGISTRY:-}" ]]; then
    return 0
  fi

  local latest_tag
  latest_tag=$(find_latest_pipeline_tag "$repo")
  if [[ -z "$latest_tag" ]]; then
    echo "WARNING: no ${CI_COMMIT_REF_SLUG}-<pipeline-id> tag found for ${repo}; leaving ${pinned_ref} unresolved"
    return 0
  fi

  echo "Resolved ${pinned_ref} -> ${repo}:${latest_tag}"
  docker pull "${repo}:${latest_tag}"
  docker tag "${repo}:${latest_tag}" "${pinned_ref}"
}

# Scans a compose file for dynamic and pinned image references and resolves each one's tag.
resolve_dynamic_image_tags() {
  local compose_file="$1"

  local image_name
  for image_name in $(grep -oE '\$\{REGISTRY_NAMESPACE\}/[A-Za-z0-9._-]+:\$\{IMAGE_TAG\}' "$compose_file" |
    sed -E 's#^\$\{REGISTRY_NAMESPACE\}/##; s#:\$\{IMAGE_TAG\}$##' | sort -u); do
    resolve_image_tag "$image_name"
  done

  for image_name in $(grep -oE 'torizon/[A-Za-z0-9._-]+:stable-rc' "$compose_file" |
    sed -E 's#^torizon/##; s#:stable-rc$##' | sort -u); do
    resolve_pinned_image_tag "$image_name"
  done
}

setup_test() {
  local compose_service_name="$1"
  local timeout="${2:-10}"

  docker container kill "$compose_service_name" || true
  docker container rm "$compose_service_name" || true

  compose_file=$(get_compose_file "$compose_service_name")
  COMPOSE_FILE="$compose_file"
  export COMPOSE_FILE

  resolve_dynamic_image_tags "$compose_file"

  docker compose -f "$compose_file" up -d

  sleep "${timeout}"

}

teardown_test() {
  local compose_service_name="$1"

  compose_file=$(get_compose_file "$compose_service_name")

  docker compose -f "$compose_file" down --volumes --rmi all --remove-orphans

  rm -rf /tmp/1000-runtime-dir
}

export_has_gpu() {
  local no_gpu_socs=(
    am62l
    imx6ull
    imx7
    imx93
  )

  local has_gpu=true

  for soc in "${no_gpu_socs[@]}"; do
    if [[ "$SOC_UDT" =~ $soc ]]; then
      has_gpu=false
      break
    fi
  done

  export HAS_GPU="$has_gpu"
}
