#!/bin/bash

# Copyright (c) 2019-2024 Toradex AG
# SPDX-License-Identifier: MIT

re_tag_image() {
  registry=$1
  namespace=$2
  image_name=$3
  old_image_tag=$4
  new_image_tag=$5
  force_flag=$6

  # check if the tag we want to push already exists
  old_image_path="$registry/$namespace/$image_name:$old_image_tag"
  new_image_path="$registry/$namespace/$image_name:$new_image_tag"

  if [ "$force_flag" = "--force" ]; then
    echo "Force flag is set, proceeding regardless of existing image"
  elif regctl image digest "$new_image_path" >/dev/null 2>&1; then
    echo "Found an existing $new_image_path"
    echo "---------------------------------------------------------------------"
    return 1
  fi

  echo "Re-tagging from $old_image_path"
  # has a "$staging_tag" image been pushed yet?
  if regctl image digest "$old_image_path" >/dev/null 2>&1; then
    # it has been pushed, re-tag from $old_image_tag to $new_image_tag
    regctl image copy "$old_image_path" "$new_image_path"
    echo "---------------------------------------------------------------------"
    return 0
  else
    echo "Can't find a $old_image_path to re-tag from"
    echo "---------------------------------------------------------------------"
    exit 1
  fi
}

if [ $# -ne 3 ]; then
  echo "Usage: $0 <path_to_container_versions_yml> <registry_namespace> <staging_tag>"
  exit 1
fi

yaml_file="$1"
registry_namespace="$2"
staging_tag="$3"

while IFS=: read -r image_name rest; do
  image_name=$(echo "$image_name" | xargs)

  major=$(yq e ".$image_name.major" "$yaml_file")
  minor=$(yq e ".$image_name.minor" "$yaml_file")
  patch=$(yq e ".$image_name.patch" "$yaml_file")

  re_tag_image docker.io "$registry_namespace" "$image_name" "$staging_tag" "$major"."$minor"."$patch"
  re_tag_status=$?
  if [ $re_tag_status -eq 0 ]; then
    re_tag_image docker.io "$registry_namespace" "$image_name" "$staging_tag" "$major"."$minor" "--force"
    re_tag_image docker.io "$registry_namespace" "$image_name" "$staging_tag" "$major" "--force"
  fi
  echo "$image_name: $major.$minor.$patch" >>release_notes.md
  echo "" >>release_notes.md

done < <(yq e 'keys | .[]' "$yaml_file")
