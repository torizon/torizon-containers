#!/bin/bash

if ! command -v yq &>/dev/null; then
  echo "Error: 'yq' is not installed. Please install yq to proceed."
  exit 1
fi

FILE="$1"

jobs=$(yq e 'keys | .[]' "$FILE")

EXIT_CODE=0

for job in $jobs; do
  extends=$(yq e '.["'"$job"'"].extends' "$FILE")

  if [[ "$job" =~ build-.*-(am62|imx8|upstream) ]]; then
    PATTERN="${BASH_REMATCH[1]}"
    expected_template=".build-${PATTERN}-template"

    if [[ "$extends" != "$expected_template" ]]; then
      echo "Job '$job' extends '$extends' but expected '$expected_template'"
      EXIT_CODE=1
    fi
  fi
done

exit $EXIT_CODE
