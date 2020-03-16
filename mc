#!/usr/bin/env bash

CACHE_REGISTER_PATH="$HOME/.mc_cache"
CACHE_INDEX_PATH="$CACHE_REGISTER_PATH/.mc_index.json"

function get_cache_id() {
  local cmd
  cmd="$1"
  current_path="$(pwd)"
  jq ".[\"$cmd:$current_path\"]" "$CACHE_INDEX_PATH" | grep -Eo [^\"]+
}

function execute_command() {
  local cmd
  cmd="$1"

  output="$(eval "$cmd")"
  echo $output

  cache_uuid="$([ -z "$2" ] && echo "$(uuidgen)" || echo "$2")"
  new_index="$(jq ".[\"$cmd:$(pwd)\"] = \"$cache_uuid\"" "$CACHE_INDEX_PATH")"
  echo "$new_index" > "$CACHE_INDEX_PATH"

  echo "$output" > "$CACHE_REGISTER_PATH/$cache_uuid.txt"
}

flag_help=0
flag_flush=0
flag_update=0
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

if [ ! -d "$CACHE_REGISTER_PATH" ]; then
  mkdir "$CACHE_REGISTER_PATH"
  echo "{}" > "$CACHE_INDEX_PATH"
  execute_command "$command"
  exit 0
fi

cache_id="$(get_cache_id "$command")"

if [[ "$cache_id" == 'null' ]]; then
  execute_command "$command"
  exit 0
fi

if [ "$flag_update" -eq 1 ]; then
  execute_command "$command" "$cache_id"
  exit 0
fi

cat "$CACHE_REGISTER_PATH/$cache_id.txt"
