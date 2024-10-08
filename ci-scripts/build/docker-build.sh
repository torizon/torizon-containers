#!/bin/bash

set -x

# Copyright (c) 2019-2023 Toradex AG
# SPDX-License-Identifier: MIT

docker login -u "$DOCKERHUB_USER" -p "$DOCKERHUB_TOKEN"
docker login -u "$CI_REGISTRY_USER" -p "$CI_REGISTRY_PASSWORD" "$CI_REGISTRY"

docker info

if [[ "${IMAGE_NAME}" == *am62 ]]; then
  TORADEX_SNAPSHOT=$(curl https://feeds.toradex.com/stable/am62/snapshots/latest-snapshot)
  export TORADEX_SNAPSHOT
elif [[ "${IMAGE_NAME}" == *imx8 ]]; then
  TORADEX_SNAPSHOT=$(curl https://feeds.toradex.com/stable/imx8/snapshots/latest-snapshot)
  export TORADEX_SNAPSHOT
else
  TORADEX_SNAPSHOT=$(curl https://feeds.toradex.com/stable/upstream/snapshots/latest-snapshot)
  export TORADEX_SNAPSHOT
fi

docker buildx create --name multiarch-builder --driver docker-container --platform linux/arm/v7,linux/arm64/v8,linux/amd64 --use
docker buildx inspect --bootstrap

docker run --privileged --rm "${TORADEX_INTERNAL_DOCKERHUB_CACHE}/tonistiigi/binfmt" --install arm64,arm

declare -A BUILD_TARGETS=(
  ["BUILD_FOR_ARM_V7"]="linux/arm/v7"
  ["BUILD_FOR_ARM_V8"]="linux/arm64/v8"
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
  if [ -n "${!VAR}" ]; then
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

if [[ "${CI_PIPELINE_SOURCE}" == "merge_request_event" || "${CI_COMMIT_REF_PROTECTED}" == "false" ]]; then
  export PULL_REGISTRY=${CI_REGISTRY}
  export PUSH_REGISTRY=${CI_REGISTRY}
  export REGISTRY_NAMESPACE=${CI_PROJECT_PATH}
  export IMAGE_TAG=${CI_COMMIT_REF_SLUG}-${CI_PIPELINE_ID}
fi

if [[ "${CI_COMMIT_REF_PROTECTED}" == "true" ]]; then
  export PULL_REGISTRY=${TORADEX_INTERNAL_DOCKERHUB_CACHE}
  export PUSH_REGISTRY="docker.io"
  export REGISTRY_NAMESPACE=${PROJECT_SETTING_REGISTRY_NAMESPACE}
  export IMAGE_TAG=${CI_COMMIT_BRANCH}
fi

# shellcheck disable=SC2086
docker buildx build --progress=plain --sbom=true --push ${BUILD_PLATFORMS} \
  --build-arg ACCEPT_FSL_EULA="${ACCEPT_FSL_EULA}" \
  --build-arg TORADEX_FEED_URL="${TORADEX_FEED_URL}" \
  --build-arg BASE_IMAGE_NAME="${BASE_IMAGE_NAME}" \
  --build-arg BASE_IMAGE_NAME_DEBUG="${BASE_IMAGE_NAME_DEBUG}" \
  --build-arg BASE_IMAGE_NAME_WAYLAND="${BASE_IMAGE_NAME_WAYLAND}" \
  --build-arg CROSS_COMPILER="${CROSS_COMPILER}" \
  --build-arg CROSS_TARGET_ARCH="${CROSS_TARGET_ARCH}" \
  --build-arg DEBIAN_POINT_RELEASE="${DEBIAN_POINT_RELEASE}" \
  --build-arg DOTNET_DEBUGGER_VER="${DOTNET_DEBUGGER_VER}" \
  --build-arg DOTNET_RUNTIME="${DOTNET_RUNTIME}" \
  --build-arg DOTNET_SEMVER="${DOTNET_SEMVER}" \
  --build-arg IMAGE_TAG="${IMAGE_TAG}" \
  --build-arg REGISTRY_PROXY="${TORADEX_INTERNAL_DOCKERHUB_CACHE}" \
  --build-arg REGISTRY="${PULL_REGISTRY}" \
  --build-arg REGISTRY_NAMESPACE="${REGISTRY_NAMESPACE}" \
  --build-arg TORADEX_SNAPSHOT="${TORADEX_SNAPSHOT}" \
  --label container.name="${IMAGE_NAME}" \
  --label container.version="${MAJOR}"."${MINOR}"."${PATCH}" \
  --label git.branch="${CI_COMMIT_BRANCH}" \
  --label git.hash="${CI_COMMIT_SHA}" \
  --label pipeline.id="${CI_PIPELINE_ID}" \
  -f "${DOCKERFILE_FOLDER}Dockerfile" \
  -t "${PUSH_REGISTRY}/${REGISTRY_NAMESPACE}/${IMAGE_NAME}:${IMAGE_TAG}" \
  "${DOCKERFILE_BUILD_CONTEXT_FOLDER}"
