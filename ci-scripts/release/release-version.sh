#!/bin/sh

RELEASE_MAJOR=$(grep -h '^[[:space:]]*major:' ci-scripts/container-versions/*.yml |
  awk '{print $2}' | sort -u)

if [ "$(printf '%s\n' "$RELEASE_MAJOR" | grep -c .)" -gt 1 ]; then
  echo "Majors disagree across ci-scripts/container-versions/*.yml:" >&2
  printf '%s\n' "$RELEASE_MAJOR" >&2
  exit 1
fi

RELEASE_SERIES="${RELEASE_MAJOR:-$RELEASE_TAG}"

if [ -z "$RELEASE_SERIES" ]; then
  echo "No major in ci-scripts/container-versions/*.yml and no RELEASE_TAG set" >&2
  exit 1
fi

RELEASE_VERSION="${RELEASE_SERIES}-$(date -u +%Y.%m.%d)"

export RELEASE_MAJOR
export RELEASE_SERIES
export RELEASE_VERSION
