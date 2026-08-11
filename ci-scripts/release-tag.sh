#!/bin/sh

RELEASE_TAG=$(sed -n 's/^[[:space:]]*alias:[[:space:]]*//p' ci-scripts/container-versions/*.yml |
  tr -d "\"'" | sort -u)

if [ -z "$RELEASE_TAG" ]; then
  echo "No alias found in ci-scripts/container-versions/*.yml" >&2
  exit 1
fi

if [ "$(printf '%s\n' "$RELEASE_TAG" | wc -l)" -ne 1 ]; then
  echo "Aliases disagree across ci-scripts/container-versions/*.yml:" >&2
  printf '%s\n' "$RELEASE_TAG" >&2
  exit 1
fi

IS_RELEASE_BRANCH="false"

if [ "${CI_COMMIT_REF_PROTECTED:-}" = "true" ] && [ -n "${CI_COMMIT_BRANCH:-}" ] &&
  [ "${CI_PIPELINE_SOURCE:-}" != "merge_request_event" ]; then
  IS_RELEASE_BRANCH="true"
fi

export RELEASE_TAG
export IS_RELEASE_BRANCH
