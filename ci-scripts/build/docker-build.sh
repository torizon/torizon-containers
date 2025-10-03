#!/bin/bash

set -x
set -euo pipefail

# Copyright (c) 2019-2025 Toradex AG
# SPDX-License-Identifier: MIT

if [[ "${IMAGE_NAME:-}" == *am6* ]]; then
  TORADEX_SNAPSHOT=$(curl https://feeds.toradex.com/stable/am6x/snapshots/latest-snapshot)
  export TORADEX_SNAPSHOT
elif [[ "${IMAGE_NAME:-}" == *imx8 ]]; then
  TORADEX_SNAPSHOT=$(curl https://feeds.toradex.com/stable/imx8/snapshots/latest-snapshot)
  export TORADEX_SNAPSHOT
elif [[ "${IMAGE_NAME:-}" == *imx95 ]]; then
  TORADEX_SNAPSHOT=$(curl https://feeds.toradex.com/stable/imx95/snapshots/latest-snapshot)
  export TORADEX_SNAPSHOT
elif [[ "${IMAGE_NAME:-}" == *sl1680 ]]; then
  TORADEX_SNAPSHOT=$(curl https://feeds.toradex.com/stable/sl1680/snapshots/latest-snapshot)
  export TORADEX_SNAPSHOT
else
  TORADEX_SNAPSHOT=$(curl https://feeds.toradex.com/stable/upstream/snapshots/latest-snapshot)
  export TORADEX_SNAPSHOT
fi

declare -A BUILD_TARGETS=(
  ["BUILD_FOR_ARM_V7"]="linux/arm/v7"
  ["BUILD_FOR_ARM_V8"]="linux/arm64"
  ["BUILD_FOR_AMD64"]="linux/amd64"
)

SELECTED_PLATFORMS=()

UNEXPECTED_PLATFORM=()
for VAR in $(env | grep '^BUILD_FOR_' | cut -d= -f1); do
  if [[ ! ${BUILD_TARGETS[$VAR]+_} ]]; then
    UNEXPECTED_PLATFORM+=("$VAR")
  fi
done

if [ "${#UNEXPECTED_PLATFORM[@]}" -gt 0 ]; then
  echo "Error: Unexpected variables are set: ${UNEXPECTED_PLATFORM[*]}" >&2
  exit 1
fi

# Collect selected platforms
for VAR in "${!BUILD_TARGETS[@]}"; do
  if [ -n "${!VAR-}" ]; then
    SELECTED_PLATFORMS+=("${BUILD_TARGETS[$VAR]}")
  fi
done

if [ "${#SELECTED_PLATFORMS[@]}" -eq 0 ]; then
  echo "Error: No build targets specified." >&2
  exit 1
fi

BUILD_PLATFORMS=""
for PLATFORM in "${SELECTED_PLATFORMS[@]}"; do
  BUILD_PLATFORMS="$BUILD_PLATFORMS --platform $PLATFORM"
done

export REGISTRY=${CI_REGISTRY-}
export PUSH_REGISTRY=${CI_REGISTRY-}
export REGISTRY_NAMESPACE=${CI_PROJECT_PATH-}
export IMAGE_TAG=${CI_COMMIT_REF_SLUG-}-${CI_PIPELINE_ID-}

# Protected refs outside an MR: pull & push on Docker Hub with -rc tag
if [[ "${CI_COMMIT_REF_PROTECTED:-}" == "true" && "${CI_PIPELINE_SOURCE:-}" != "merge_request_event" ]]; then
  export REGISTRY=${DOCKERHUB_REGISTRY_URL-}
  export PUSH_REGISTRY=${DOCKERHUB_REGISTRY_URL-}
  export REGISTRY_NAMESPACE=${PROJECT_SETTING_REGISTRY_NAMESPACE-}
  export IMAGE_TAG=${CI_COMMIT_BRANCH-${CI_COMMIT_REF_NAME-}}-rc
fi

# Override for Aval test images, push to GitLab even inside protected branches
if [[ "${CI_WORLD_TEST:-false}" == "true" || $(env | grep -c '^CI_TEST') -gt 0 ]]; then
  export REGISTRY=${CI_REGISTRY-}
  export PUSH_REGISTRY=${CI_REGISTRY-}
  export REGISTRY_NAMESPACE=${CI_PROJECT_PATH-}
  export IMAGE_TAG=${CI_COMMIT_REF_SLUG-}-${CI_PIPELINE_ID-}
fi

# Base images on MR: pull from Docker Hub, push to GitLab, because we start from the Debian image hosted at DockerHub
if [[ ${CI_JOB_NAME:-} == build-base-* && "${CI_PIPELINE_SOURCE:-}" == "merge_request_event" ]]; then
  export REGISTRY=${DOCKERHUB_REGISTRY_URL-}
  export PUSH_REGISTRY=${CI_REGISTRY-}
  export REGISTRY_NAMESPACE=${CI_PROJECT_PATH-}
  export IMAGE_TAG=${CI_COMMIT_REF_SLUG-}-${CI_PIPELINE_ID-}
fi

# echo the Dockerfile in CI, making it easier to spot bugs.
cat "${DOCKERFILE_FOLDER-}Dockerfile"

# shellcheck disable=SC2086
docker buildx build --progress=plain --sbom=true --push ${BUILD_PLATFORMS} \
  --build-arg ACCEPT_FSL_EULA="${ACCEPT_FSL_EULA-}" \
  --build-arg TORADEX_FEED_URL="${TORADEX_FEED_URL-}" \
  --build-arg BASE_IMAGE_NAME="${BASE_IMAGE_NAME-}" \
  --build-arg BASE_IMAGE_NAME_DEBUG="${BASE_IMAGE_NAME_DEBUG-}" \
  --build-arg BUILD_BASE_IMAGE_NAME="${BUILD_BASE_IMAGE_NAME-}" \
  --build-arg CROSS_COMPILER="${CROSS_COMPILER-}" \
  --build-arg CROSS_TARGET_ARCH="${CROSS_TARGET_ARCH-}" \
  --build-arg DEBIAN_POINT_RELEASE="${DEBIAN_POINT_RELEASE-}" \
  --build-arg DOTNET_DEBUGGER_VER="${DOTNET_DEBUGGER_VER-}" \
  --build-arg DOTNET_RUNTIME="${DOTNET_RUNTIME-}" \
  --build-arg DOTNET_SEMVER="${DOTNET_SEMVER-}" \
  --build-arg IMAGE_TAG="${IMAGE_TAG-}" \
  --build-arg REGISTRY="${REGISTRY-}" \
  --build-arg REGISTRY_NAMESPACE="${REGISTRY_NAMESPACE-}" \
  --build-arg TORADEX_SNAPSHOT="${TORADEX_SNAPSHOT-}" \
  --label torizon.image.name="${IMAGE_NAME-}" \
  --label torizon.git.branch="${CI_COMMIT_BRANCH-}" \
  --label torizon.git.hash="${CI_COMMIT_SHA-}" \
  --label torizon.git.pipeline="${CI_PIPELINE_ID-}" \
  --label torizon.debian.snapshot="${TORADEX_SNAPSHOT-}" \
  -f "${DOCKERFILE_FOLDER-}Dockerfile" \
  ${ADDITIONAL_DOCKER_BUILD_OPTIONS-} \
  -t "${PUSH_REGISTRY-}/${REGISTRY_NAMESPACE-}/${IMAGE_NAME-}:${IMAGE_TAG-}" \
  "${DOCKERFILE_BUILD_CONTEXT_FOLDER-}"

for PLATFORM in "${SELECTED_PLATFORMS[@]}"; do
  trivy image --platform="$PLATFORM" --scanners secret "${PUSH_REGISTRY}/${REGISTRY_NAMESPACE}/${IMAGE_NAME}:${IMAGE_TAG}"
done
