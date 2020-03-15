#!/usr/bin/env bash

CACHE_REGISTER_PATH="$HOME/.mc_cache"
CACHE_INDEX_PATH="$CACHE_REGISTER_PATH/.mc_index.json"

function get_cache_id() {
  local cmd cache_id
  cmd="$1"
  cache_id="$(jq ".[\"$cmd\"]" "$CACHE_INDEX_PATH")"
  echo $cache_id | grep -Eo [^\"]+
}

function execute_command() {
  local cmd
  cmd="$1"

  output="$(eval "$cmd")"
  echo $output

  cache_uuid="$([ -z "$2" ] && echo "$(uuidgen)" || echo "$2")"
  new_index="$(jq ".[\"$cmd\"] = \"$cache_uuid\"" "$CACHE_INDEX_PATH")"
  echo "$new_index" > "$CACHE_INDEX_PATH"

  echo "$output" > "$CACHE_REGISTER_PATH/$cache_uuid.txt"
}

if [[ $* == *--flush* ]] || [[ $* == *-f* ]]; then
  rm -rf "$CACHE_REGISTER_PATH"
  exit $?
fi

command=""

for argument in "${@:1}"; do
  if [[ "$argument" =~ ^- ]]; then
    continue
  fi
  command+=" $argument"
done

if [ -z "$command" ]; then
  cat "$(dirname "$0")/README.md"
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

if [[ $* == *--update* ]] || [[ $* == *-u* ]]; then
  execute_command "$command" "$cache_id"
  exit 0
fi

cat "$CACHE_REGISTER_PATH/$cache_id.txt"
