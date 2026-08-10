#!/bin/sh

RELEASE_TAG="stable"
IS_RELEASE_BRANCH="false"

if [ -n "${CI_COMMIT_BRANCH:-}" ]; then
  case " ${RELEASE_BRANCHES:-} " in
    *" ${CI_COMMIT_BRANCH} "*)
      RELEASE_TAG="${CI_COMMIT_BRANCH}"
      if [ "${CI_COMMIT_REF_PROTECTED:-}" = "true" ] &&
        [ "${CI_PIPELINE_SOURCE:-}" != "merge_request_event" ]; then
        IS_RELEASE_BRANCH="true"
      fi
      ;;
  esac
fi

export RELEASE_TAG
export IS_RELEASE_BRANCH
