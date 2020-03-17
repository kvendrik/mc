#!/usr/bin/env bash

CACHE_REGISTER_PATH="$HOME/.mc_cache"

function get_cache_id() {
  local cmd project_specific hash_string project_path branch_name
  cmd="$1"
  project_specific="$2"
  hash_string="$cmd"

  if [ "$project_specific" -eq 1 ]; then
    if git rev-parse --show-toplevel > /dev/null; then
      project_path="$(git rev-parse --show-toplevel)"
      branch_name="$(git rev-parse --abbrev-ref HEAD)"
      hash_string="$hash_string:$project_path:$branch_name"
    else
      hash_string="$hash_string:$(pwd)"
    fi
  fi

  md5 -qs "$hash_string"
}

function execute_command() {
  local cmd log_path
  cmd="$1"
  log_path="$2"

  output="$(eval "$cmd")"
  echo $output

  echo "$output" > "$log_path"
}

flag_help=0
flag_flush=0
flag_update=0
flag_project=0
command_string_started=0
command=""

for argument in "${@:1}"; do
  if [[ "$argument" =~ ^[^-] ]]; then
    command_string_started=1
  fi

  if [ "$command_string_started" -eq 1 ]; then
    command+="$argument "
    continue
  fi

  if [[ "$argument" == "--help" ]] || [[ "$argument" == "-h" ]]; then
    flag_help=1
  elif [[ "$argument" == "--update" ]] || [[ "$argument" == "-u" ]]; then
    flag_update=1
  elif [[ "$argument" == "--flush" ]] || [[ "$argument" == "-f" ]]; then
    flag_flush=1
  elif [[ "$argument" == "--project" ]] || [[ "$argument" == "-p" ]]; then
    flag_project=1
  fi
done

if [ "$flag_flush" -eq 1 ]; then
  rm -rf "$CACHE_REGISTER_PATH"
  exit $?
fi

if [ -z "$command" ] || [ "$flag_help" -eq 1 ]; then
  cat "$(dirname "$0")/README.md" | tr -d '`'
  exit 1
fi

cache_id="$(get_cache_id "$command" $flag_project)"
log_path="$CACHE_REGISTER_PATH/$cache_id.log"

if [ ! -d "$CACHE_REGISTER_PATH" ]; then
  mkdir "$CACHE_REGISTER_PATH"
  execute_command "$command" "$log_path"
  exit 0
fi

if [ ! -f "$log_path" ] || [ "$flag_update" -eq 1 ]; then
  execute_command "$command" "$log_path"
  exit 0
fi

cat "$log_path"
