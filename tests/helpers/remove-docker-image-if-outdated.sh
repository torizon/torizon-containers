#!/bin/bash

image=$1

remote_sha=$(regctl image digest "$image")
local_sha=$(docker inspect --format='{{index .RepoDigests 0}}' "$image" 2>/dev/null | awk -F '@' '{print $2}')

if [[ -z "$remote_sha" ]]; then
  echo "Error: Unable to retrieve remote SHA for image '$image'."
  exit 1
elif [[ -z "$local_sha" ]]; then
  echo "Image cannot be outdated because it hasn't been pulled."
elif [ "$remote_sha" != "$local_sha" ]; then
  docker rmi -f "$image"
  echo "The local image '$image' was outdated and has been removed."
else
  echo "The local image '$image' is up-to-date."
fi
