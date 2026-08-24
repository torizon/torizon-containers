#!/bin/sh

RELEASE_ALIASES=$(sed -n 's/^[[:space:]]*alias:[[:space:]]*//p' ci-scripts/container-versions/*.yml |
  tr -d "\"'[]" |
  sed 's/[[:space:]]*,[[:space:]]*/,/g; s/^[[:space:]]*//; s/[[:space:]]*$//' |
  sort -u)

if [ -z "$RELEASE_ALIASES" ]; then
  echo "No alias found in ci-scripts/container-versions/*.yml" >&2
  exit 1
fi

if [ "$(printf '%s\n' "$RELEASE_ALIASES" | wc -l)" -ne 1 ]; then
  echo "Aliases disagree across ci-scripts/container-versions/*.yml:" >&2
  printf '%s\n' "$RELEASE_ALIASES" >&2
  exit 1
fi

# alias is a list, e.g. [scarthgap, bookworm-scarthgap]; the first entry is
# the canonical one used for the staging/rc image tag.
RELEASE_TAG=$(printf '%s\n' "$RELEASE_ALIASES" | cut -d',' -f1)

IS_RELEASE_BRANCH="false"

if [ "${CI_COMMIT_REF_PROTECTED:-}" = "true" ] && [ -n "${CI_COMMIT_BRANCH:-}" ] &&
  [ "${CI_PIPELINE_SOURCE:-}" != "merge_request_event" ]; then
  IS_RELEASE_BRANCH="true"
fi

export RELEASE_TAG
export IS_RELEASE_BRANCH
