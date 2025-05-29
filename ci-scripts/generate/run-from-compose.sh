#!/usr/bin/env bash
set -euo pipefail

shopt -s nullglob globstar

REPO_ROOT="${1}"
COMPOSE_GLOB="${2}"
OUTPUT_DIR="${3}"

rm -rf "$OUTPUT_DIR"
mkdir -p "$OUTPUT_DIR"

for src in "$REPO_ROOT"/$COMPOSE_GLOB; do
  rel="${src#"$REPO_ROOT"/}"
  out="$OUTPUT_DIR/${rel%.*}.run"
  mkdir -p "$(dirname "$out")"
  decompose --compose-file "$src" >"$out"
  echo "Generated -> $out"
done
