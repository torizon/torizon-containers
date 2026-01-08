#!/usr/bin/env bash

# Exit on error
set -e

parse_docker_run() {
  local file="$1"
  local match_keyword="$2"
  local container_name="$3"
  local override_command="$4"

  # Debug output
  echo "DEBUG: Looking for file: $file" >&2
  echo "DEBUG: Match keyword: $match_keyword" >&2
  echo "DEBUG: Container name: $container_name" >&2
  echo "DEBUG: Override command: $override_command" >&2

  if [[ ! -f "$file" ]]; then
    echo "ERROR: File not found: $file" >&2
    echo ""
    return 1
  fi

  local commands=()
  local current_cmd=""
  while IFS= read -r line; do
    if [[ "$line" =~ ^docker[[:space:]]+run ]]; then
      if [[ -n "$current_cmd" ]]; then
        commands+=("$current_cmd")
      fi
      current_cmd="$line"
    elif [[ -n "$current_cmd" ]]; then
      current_cmd+=" $line"
    fi
  done <"$file"
  if [[ -n "$current_cmd" ]]; then
    commands+=("$current_cmd")
  fi

  local matched_command=""
  for cmd in "${commands[@]}"; do
    if [[ "$cmd" == *"$match_keyword"* ]]; then
      matched_command="$cmd"
      break
    fi
  done

  if [[ -z "$matched_command" ]]; then
    echo "ERROR: No matching command found for keyword: $match_keyword" >&2
    echo ""
    return 1
  fi

  matched_command=$(echo "$matched_command" | tr -d '\\\n' | tr -s ' ')

  if [[ -n "$container_name" ]]; then
    matched_command=${matched_command/docker run -d/docker run -d --name=$container_name}
  fi

  if [[ -n "$override_command" ]]; then
    # Remove everything after the last image name
    matched_command=$(echo "$matched_command" | sed -E 's/(.*[^ ]) .*$/\1/')
    matched_command="$matched_command $override_command"
  fi

  # Expand shell variables in the command while preserving quotes
  local expanded_command
  if ! expanded_command=$(echo "$matched_command" | envsubst '$REGISTRY'); then
    echo "ERROR: Failed to expand variables in command" >&2
    echo ""
    return 1
  fi

  echo "DEBUG: Found command: $matched_command" >&2
  echo "DEBUG: Expanded command: $expanded_command" >&2
  echo "$expanded_command"
}

parse_docker_run "$@"
