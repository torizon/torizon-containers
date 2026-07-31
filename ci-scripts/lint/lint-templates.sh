#!/bin/bash
set -euo pipefail

if ! command -v yq &>/dev/null; then
  echo "Error: 'yq' is not installed. Please install yq to proceed."
  exit 1
fi

FILE="$1"

jobs=$(yq e 'keys | .[]' "$FILE")

EXIT_CODE=0

uses_base_template() {
  local job="$1"
  local platform="$2"
  local base=".build-${platform}-template"
  local current

  current=$(yq e '.["'"$job"'"].extends // ""' "$FILE")

  for _ in {1..10}; do
    if [[ -z "$current" || "$current" == "null" ]]; then
      break
    fi

    if [[ "$current" == "$base" ]]; then
      return 0
    fi

    current=$(yq e '.["'"$current"'"].extends // ""' "$FILE")
  done

  return 1
}

for job in $jobs; do
  [[ "$job" != build-* ]] && continue

  if [[ "$job" =~ ^build-.*-(sl1680|imx95|imx93|imx8|am62p|am62|am67a|am69|jetson|upstream)$ ]]; then
    PATTERN="${BASH_REMATCH[1]}"

    if ! uses_base_template "$job" "$PATTERN"; then
      extends=$(yq e '.["'"$job"'"].extends // ""' "$FILE")
      echo "Job '$job' extends '$extends' but does not use '.build-${PATTERN}-template' in its extends chain"
      EXIT_CODE=1
    fi
  fi
done

exit $EXIT_CODE
