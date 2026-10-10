#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

require_command jq

browser_watch="$ROOT/bin/omarchy-hyprland-browser-watch"
autostart="$ROOT/default/hypr/autostart.lua"
browser_rules="$ROOT/default/hypr/apps/browser.lua"

test_tmp=$(mktemp -d)
watch_pid=""
events_fd=""

stop_watcher() {
  if [[ -n $watch_pid ]]; then
    kill -KILL "$watch_pid" 2>/dev/null || true
    wait "$watch_pid" 2>/dev/null || true
    watch_pid=""
  fi

  if [[ -n $events_fd ]]; then
    exec {events_fd}>&-
    events_fd=""
  fi

  return 0
}

cleanup() {
  stop_watcher
  rm -rf "$test_tmp"
}
trap cleanup EXIT

fake_bin="$test_tmp/bin"
mkdir -p "$fake_bin"

clients_file="$test_tmp/clients.json"
dispatch_log="$test_tmp/dispatch.log"
events="$test_tmp/events"

cat >"$fake_bin/hyprctl" <<'SH'
#!/bin/bash

if [[ ${1:-} == "clients" && ${2:-} == "-j" ]]; then
  cat "$OMARCHY_TEST_CLIENTS_FILE"
elif [[ ${1:-} == "dispatch" ]]; then
  shift
  printf '%s\n' "$*" >>"$OMARCHY_TEST_DISPATCH_LOG"
fi
SH

cat >"$fake_bin/socat" <<'SH'
#!/bin/bash

exec cat "$OMARCHY_TEST_EVENTS"
SH

chmod +x "$fake_bin"/*

# One workspace 1 holding the presentation float, one workspace 3 holding
# another, and a workspace 2 with none.
cat >"$clients_file" <<'JSON'
[
  {"address":"0x1a01","class":"org.omarchy.terminal","floating":true,"workspace":{"id":1}},
  {"address":"0x1a03","class":"org.omarchy.terminal","floating":true,"workspace":{"id":3}},
  {"address":"0x2b01","class":"chromium","floating":false,"workspace":{"id":1}},
  {"address":"0x2b02","class":"chromium","floating":false,"workspace":{"id":2}},
  {"address":"0x2b03","class":"chromium","floating":true,"workspace":{"id":1}},
  {"address":"0x2c03","class":"firefox","floating":false,"workspace":{"id":3}},
  {"address":"0x2d01","class":"org.codeberg.dnkl.foot","floating":false,"workspace":{"id":1}}
]
JSON

: >"$dispatch_log"
mkfifo "$events"

PATH="$fake_bin:$PATH" \
XDG_RUNTIME_DIR="$test_tmp" \
HYPRLAND_INSTANCE_SIGNATURE=test \
OMARCHY_TEST_EVENTS="$events" \
OMARCHY_TEST_CLIENTS_FILE="$clients_file" \
OMARCHY_TEST_DISPATCH_LOG="$dispatch_log" \
  "$browser_watch" &
watch_pid=$!

exec {events_fd}>"$events"

dispatches() {
  wc -l <"$dispatch_log" | tr -d ' '
}

await_dispatches() {
  local waited

  for (( waited = 0; waited < 100; waited++ )); do
    (( $(dispatches) >= $1 )) && return 0
    sleep 0.05
  done

  return 1
}

# Events are handled in order, so the cases that must do nothing can be sent
# first and judged by what the log holds once the later ones have landed. No
# sleeping on the absence of an action.
# Hyprland writes the address without the 0x that hyprctl reports and expects,
# so the events here carry the bare form the compositor sends.
printf 'openwindow>>2b02,2,chromium,Sign in\n' >&"$events_fd"
printf 'openwindow>>2b03,1,chromium,Sign in\n' >&"$events_fd"
printf 'openwindow>>2d01,1,org.codeberg.dnkl.foot,Omarchy\n' >&"$events_fd"

# A page title can hold commas; the class must still be read from field three.
printf 'openwindow>>2b01,1,chromium,Sign in to Claude, then return here\n' >&"$events_fd"
printf 'openwindow>>2c03,3,firefox,Mozilla Firefox\n' >&"$events_fd"

await_dispatches 6 || fail "a browser opening under the presentation float is raised" "$(<"$dispatch_log")"

for address in 0x2b01 0x2c03; do
  grep -qF "hl.dsp.window.float({ window = \"address:$address\", action = \"toggle\" })" "$dispatch_log" ||
    fail "the browser is floated out of the tiled layer" "$address: $(<"$dispatch_log")"
  grep -qF "hl.dsp.window.alter_zorder({ window = \"address:$address\", mode = \"top\" })" "$dispatch_log" ||
    fail "the browser is raised above the float that covered it" "$address: $(<"$dispatch_log")"
  grep -qF "hl.dsp.focus({ window = \"address:$address\" })" "$dispatch_log" ||
    fail "the browser takes focus once it is visible" "$address: $(<"$dispatch_log")"
done
pass "a browser opening under the presentation float is floated, raised and focused"

(( $(dispatches) == 6 )) || fail "only covered browsers are touched" "$(<"$dispatch_log")"
for address in 0x2b02 0x2b03 0x2d01; do
  ! grep -qF "address:$address" "$dispatch_log" ||
    fail "an uncovered window is left alone" "$address: $(<"$dispatch_log")"
done
pass "browsers on a workspace with no presentation float, already-floating browsers and non-browsers are left alone"

stop_watcher

grep -F 'o.launch("omarchy-hyprland-browser-watch")' "$autostart" >/dev/null ||
  fail "the browser watcher starts with the session"
pass "the browser watcher starts with the session"

# The fix exists because browsers are pinned to the tiled layer, where nothing
# can lift them over a float. If that ever changes, this is the thread to pull.
grep -F 'o.window({ tag = "chromium-based-browser" }, { tag = "-default-opacity", tile = true' "$browser_rules" >/dev/null ||
  fail "browsers are still forced to tile, which is what strands them under the float"
pass "browsers are still forced to tile, which is what strands them under the float"
