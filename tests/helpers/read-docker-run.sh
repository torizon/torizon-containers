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

  local commands
  if ! commands=$(awk '/^docker run/ {if(cmd) print cmd; cmd=$0; next} {cmd=cmd" "$0} END {print cmd}' "$file"); then
    echo "ERROR: Failed to parse docker run commands from file" >&2
    echo ""
    return 1
  fi

  if [[ -z "$commands" ]]; then
    echo "ERROR: No docker run commands found in file" >&2
    echo ""
    return 1
  fi

  local matched_command
  if ! matched_command=$(echo "$commands" | grep "$match_keyword" | head -n 1); then
    echo "ERROR: Failed to grep for match keyword" >&2
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

  matched_command=$(echo "$matched_command" | tr '\n' ' ' | sed 's/  */ /g' | sed 's/ *$//')

  echo "DEBUG: Found command: $matched_command" >&2
  echo "$matched_command"
}

parse_docker_run "$@"
