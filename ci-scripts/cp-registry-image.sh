#!/bin/sh

REGISTRY=$1
NAMESPACE=$2
IMAGE_NAME=$3
OLD_IMAGE_TAG=$4
NEW_IMAGE_TAG=$5

# check if the tag we want to push already exists
OLD_IMAGE_PATH="$REGISTRY"/"$NAMESPACE"/"$IMAGE_NAME":"$OLD_IMAGE_TAG"
NEW_IMAGE_PATH="$REGISTRY"/"$NAMESPACE"/"$IMAGE_NAME":"$NEW_IMAGE_TAG"

if regctl image digest "$NEW_IMAGE_PATH" >/dev/null 2>&1; then
  echo "Found an existing $NEW_IMAGE_PATH"
  echo "Exiting successfully"
  exit 0
else
  echo "Tag $NEW_IMAGE_PATH does not exist"
  echo "Re-tagging from $OLD_IMAGE_PATH"
  # has a next image been pushed yet?
  if regctl image digest "$OLD_IMAGE_PATH" >/dev/null 2>&1; then
    # it has been pushed, re-tag from $OLD_IMAGE_TAG to $NEW_IMAGE_TAG
    regctl image copy "$OLD_IMAGE_PATH" "$NEW_IMAGE_PATH"
  else
    echo "Can't find a $OLD_IMAGE_PATH to re-tag from"
    exit 1
  fi
fi
