#!/bin/sh

# Copyright (c) 2019-2026 Toradex AG
# SPDX-License-Identifier: MIT

_PF_ROOT="${CI_PROJECT_DIR:-.}"

platform_list() {
  for _f in "$_PF_ROOT"/ci-scripts/build/*.yml; do
    [ -e "$_f" ] || continue
    basename "$_f" .yml
  done
}

platform_of_image() {
  _img="$1"
  for _p in $(platform_list); do
    case "$_img" in
      *-"$_p" | *_"$_p")
        printf '%s\n' "$_p"
        return 0
        ;;
    esac
  done
  printf 'upstream\n'
}

platform_selected() {
  _p="$1"
  for _entry in $(printf '%s' "${PLATFORMS:-}" | tr ',' ' '); do
    if [ "$_entry" = "$_p" ]; then
      return 0
    fi
  done
  return 1
}
