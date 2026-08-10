#!/bin/sh

RELEASE_TAG="stable"
IS_RELEASE_BRANCH="false"

if [ -n "${CI_COMMIT_BRANCH:-}" ] && [ "${CI_PIPELINE_SOURCE:-}" != "merge_request_event" ]; then
  RELEASE_TAG="$CI_COMMIT_BRANCH"
  IS_RELEASE_BRANCH="true"
fi

export RELEASE_TAG
export IS_RELEASE_BRANCH
