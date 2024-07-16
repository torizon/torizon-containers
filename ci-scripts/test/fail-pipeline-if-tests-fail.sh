#!/bin/bash

# This script exists because GitLab doesn't anylize the contents of a junit.xml
# report before passing or failing a job. Meaning you get a green checkmark
# even though a test failed. And that's not very nice :-(

# Adapted from Erik Zivkovic. Thanks, Erik ;-)

if [ -z "$1" ]; then
  echo "Usage: $0 [path/to/file.xml]"
  exit 1
fi

if ! test -f "$1"; then
  echo "FILE NOT FOUND: $1"
  exit 1
fi

if grep "<failure" "$1"; then
  echo "Found a failure in report $1"
  exit 1
fi
