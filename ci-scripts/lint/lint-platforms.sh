#!/bin/bash

# Copyright (c) 2019-2026 Toradex AG
# SPDX-License-Identifier: MIT

set -uo pipefail

CI_FILE=".gitlab-ci.yml"
BUILD_DIR="ci-scripts/build"

declared=$(yq e '.variables.PLATFORMS.value' "$CI_FILE" |
  tr ',' '\n' | tr ' ' '\n' | sed '/^$/d' | sort -u)

on_disk=$(for f in "$BUILD_DIR"/*.yml; do
  basename "$f" .yml
done | sort -u)

missing=$(comm -13 <(printf '%s\n' "$declared") <(printf '%s\n' "$on_disk"))
unknown=$(comm -23 <(printf '%s\n' "$declared") <(printf '%s\n' "$on_disk"))

EXIT_CODE=0

if [ -n "$missing" ]; then
  echo "Platforms with a $BUILD_DIR/<platform>.yml but absent from PLATFORMS in $CI_FILE."
  echo "They would never be built or published:"
  printf '  %s\n' $missing
  EXIT_CODE=1
fi

if [ -n "$unknown" ]; then
  echo "Platforms listed in PLATFORMS in $CI_FILE with no $BUILD_DIR/<platform>.yml:"
  printf '  %s\n' $unknown
  EXIT_CODE=1
fi

if [ "$EXIT_CODE" -eq 0 ]; then
  echo "PLATFORMS matches $BUILD_DIR: $(printf '%s ' $on_disk)"
fi

exit $EXIT_CODE
