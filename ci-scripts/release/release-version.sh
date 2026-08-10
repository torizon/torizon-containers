#!/bin/sh

RELEASE_MAJOR=$(grep -h '^[[:space:]]*major:' ci-scripts/container-versions/*.yml |
  awk '{print $2}' | sort -u)

if [ -z "$RELEASE_MAJOR" ]; then
  echo "No major found in ci-scripts/container-versions/*.yml" >&2
  exit 1
fi

if [ "$(printf '%s\n' "$RELEASE_MAJOR" | wc -l)" -ne 1 ]; then
  echo "Majors disagree across ci-scripts/container-versions/*.yml:" >&2
  printf '%s\n' "$RELEASE_MAJOR" >&2
  exit 1
fi

RELEASE_VERSION="${RELEASE_MAJOR}-$(date -u +%Y.%m.%d)"

export RELEASE_MAJOR
export RELEASE_VERSION
