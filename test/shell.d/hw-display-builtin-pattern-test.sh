#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

test_tmp=$(mktemp -d)
trap 'rm -rf "$test_tmp"' EXIT

# A copy of the command reads its platform file from a fixture root (none
# unless a case writes one, whatever the machine running the suite has).
platform_root="$test_tmp/platform"
mkdir -p "$platform_root"
pattern_command="$test_tmp/omarchy-hw-display-builtin-pattern"
platform_root_copy "$ROOT/bin/omarchy-hw-display-builtin-pattern" "$pattern_command" "$platform_root"

# Both consumers: Bash's =~ and jq's test().
builtin() {
  local pattern
  pattern=$("$pattern_command")
  [[ $1 =~ $pattern ]] || return 1
  jq -en --arg name "$1" --arg builtin "$pattern" '$name | test($builtin)' >/dev/null ||
    fail "jq agrees with Bash on $1" "pattern: $pattern"
}

external() {
  local pattern
  pattern=$("$pattern_command")
  ! [[ $1 =~ $pattern ]] || return 1
  ! jq -en --arg name "$1" --arg builtin "$pattern" '$name | test($builtin)' >/dev/null ||
    fail "jq agrees with Bash on $1" "pattern: $pattern"
}

for name in eDP-1 eDP-2 LVDS-1 DSI-1; do
  builtin "$name" || fail "$name is a built-in panel"
done
for name in DP-1 HDMI-A-1 Unknown-1 xeDP-1 eDP; do
  external "$name" || fail "$name is not a built-in panel"
done
pass "eDP, LVDS and DSI connectors are built in without a platform file"

printf '%s\n%s\n' '# a firmware framebuffer panel' 'builtin-connector Unknown-1' >"$platform_root/displays.conf"
builtin Unknown-1 || fail "a platform-named connector is built in"
builtin eDP-1 || fail "eDP stays built in beside a platform-named connector"
for name in Unknown-10 Unknown-2 xUnknown-1 DP-1; do
  external "$name" || fail "$name is not the platform-named connector"
done
pass "a platform-named connector is built in, matched whole"

printf 'builtin-connector Unknown-1\r\n' >"$platform_root/displays.conf"
builtin Unknown-1 || fail "a displays.conf saved with CRLF line ends reads the same"
# The last line needs no newline.
printf 'builtin-connector Unknown-1' >"$platform_root/displays.conf"
builtin Unknown-1 || fail "a last line without a newline is read"
printf 'builtin-connector Virtual.1\nbuiltin-connector Unknown-1\n' >"$platform_root/displays.conf"
builtin Virtual.1 || fail "several connectors can be named"
builtin Unknown-1 || fail "several connectors can be named"
external VirtualX1 || fail "a dot in a name is literal"
pass "displays.conf line ends, a missing last newline and several names read the same"

for conf in 'builtin-connector Unknown-1 extra' 'builtin-connector' 'builtin-connectors Unknown-1' \
  'builtin-connector ../Unknown-1' 'builtin-connector .' 'builtin-connector ..' 'builtin-connector .hidden' \
  'builtin-connector Unknown-.*' 'builtin-connector DP-1|HDMI-A-1' 'builtin-connector (Unknown-1)' \
  '# builtin-connector Unknown-1'; do
  printf '%s\n' "$conf" >"$platform_root/displays.conf"
  for name in Unknown-1 DP-1 HDMI-A-1; do
    external "$name" || fail "an ignored line names no built-in connector" "conf: $conf, name: $name"
  done
  builtin eDP-1 || fail "an ignored line keeps the default" "conf: $conf"
done
rm -f "$platform_root/displays.conf"
pass "lines with a wrong word count, an unsafe name or a pattern are ignored"
