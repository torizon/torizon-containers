#!/usr/bin/env bash

parse_docker_run() {
  local file="$1"
  local match_keyword="$2"
  local container_name="$3"

  if [[ ! -f "$file" ]]; then
    echo ""
    return
  fi

  local commands
  commands=$(awk '/^docker run/ {if(cmd) print cmd; cmd=$0; next} {cmd=cmd" "$0} END {print cmd}' "$file")

  local matched_command
  matched_command=$(echo "$commands" | grep "$match_keyword" | head -n 1)

  if [[ -z "$matched_command" ]]; then
    echo ""
    return
  fi

  if [[ -n "$container_name" ]]; then
    matched_command=${matched_command/docker run/docker container run -d --name=$container_name --net=host}
  else
    matched_command=${matched_command/docker run/docker container run -d --net=host}
  fi

  matched_command=$(echo "$matched_command" | tr '\n' ' ' | sed 's/  */ /g' | sed 's/ *$//')

  echo "$matched_command"
}

parse_docker_run "$@"
