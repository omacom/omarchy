#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

require_command jq

tmp_dir=$(mktemp -d)
trap 'rm -rf "$tmp_dir"' EXIT

timing_file="$tmp_dir/omarchy-install-timing.json"
duration_command="$ROOT/bin/omarchy-install-duration"

install_duration() {
  OMARCHY_INSTALL_TIMING_FILE="$timing_file" "$duration_command"
}

assert_duration() {
  local expected="$1" description="$2" actual
  actual=$(install_duration)
  [[ $actual == $expected ]] || fail "$description" "expected: $expected; actual: ${actual:-<empty>}"
  pass "$description"
}

assert_omitted() {
  local description="$1" output status

  if output=$(install_duration 2>&1); then
    status=0
  else
    status=$?
  fi

  (( status == 0 )) || fail "$description" "exited with status $status"
  [[ -z $output ]] || fail "$description" "unexpected output: $output"
  pass "$description"
}

printf '{"started_at":1000,"finished_at":1042}\n' >"$timing_file"
assert_duration "42s" "installation durations under one minute show seconds"

printf '{"started_at":1000.1,"finished_at":1068.4}\n' >"$timing_file"
assert_duration "1m 8s" "installation durations over one minute show minutes and seconds"

printf '{"started_at":1000,"finished_at":4723}\n' >"$timing_file"
assert_duration "1h 2m 3s" "installation durations over one hour show hours, minutes, and seconds"

rm "$timing_file"
assert_omitted "a missing timing file omits the installation duration"

printf 'not json\n' >"$timing_file"
assert_omitted "malformed timing JSON omits the installation duration"

chmod 000 "$timing_file"
assert_omitted "an unreadable timing file omits the installation duration"
chmod 600 "$timing_file"

printf '{"started_at":1000}\n' >"$timing_file"
assert_omitted "a missing finish timestamp omits the installation duration"

printf '{"started_at":"yesterday","finished_at":1042}\n' >"$timing_file"
assert_omitted "nonnumeric timestamps omit the installation duration"

printf '{"started_at":1042,"finished_at":1000}\n' >"$timing_file"
assert_omitted "a finish before the start omits the installation duration"

jq -e '
  .modules[]
  | select(type == "object" and .type == "command" and .key == "󰔟 Installed In")
  | .text == "omarchy-install-duration 2>/dev/null"
' "$ROOT/etc/fastfetch/config.jsonc" >/dev/null || fail "Fastfetch includes the installation duration helper"
pass "Fastfetch includes the installation duration helper"
