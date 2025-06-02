#!/usr/bin/env bash

# Exit on error
set -e

parse_docker_run() {
  local file="$1"
  local match_keyword="$2"
  local container_name="$3"

  # Debug output
  echo "DEBUG: Looking for file: $file" >&2
  echo "DEBUG: Match keyword: $match_keyword" >&2
  echo "DEBUG: Container name: $container_name" >&2

  if [[ ! -f "$file" ]]; then
    echo "ERROR: File not found: $file" >&2
    echo ""
    return 1
  fi

  local matched_command
  if ! matched_command=$(grep -A 50 "^docker run" "$file" | grep -B 50 "$match_keyword" | head -n 50 | tr -d '\\\n' | tr -s ' '); then
    echo "ERROR: Failed to find matching docker run command" >&2
    echo ""
    return 1
  fi

  if [[ -z "$matched_command" ]]; then
    echo "ERROR: No matching command found for keyword: $match_keyword" >&2
    echo ""
    return 1
  fi

  if [[ -n "$container_name" ]]; then
    matched_command=${matched_command/docker run/docker container run -d --name=$container_name --net=host}
  else
    matched_command=${matched_command/docker run/docker container run -d --net=host}
  fi

  # Expand shell variables in the command while preserving quotes
  local expanded_command
  if ! expanded_command=$(echo "$matched_command" | envsubst); then
    echo "ERROR: Failed to expand variables in command" >&2
    echo ""
    return 1
  fi

  echo "DEBUG: Found command: $matched_command" >&2
  echo "DEBUG: Expanded command: $expanded_command" >&2
  echo "$expanded_command"
}

parse_docker_run "$@"
