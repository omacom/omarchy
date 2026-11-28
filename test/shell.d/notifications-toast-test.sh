#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

# The card's own countdown, on a card the test creates: the real Toast.qml in a
# shell of its own, so the timer, its start/stop handlers and the expiry signal
# all run. The pure arithmetic is covered by notifications-test.sh; this file is
# the half a test of a JS module cannot reach.
#
# SIGSTOP stands in for a suspend: it freezes the process, so no timer fires,
# exactly as a suspend does, and unlike a suspend it needs no privilege.

TMPDIR=""
QS_PID=""

# Quickshell leaves children running when it is stopped, among them the
# inotifywait watching the plugin directory. Once the shell is gone, stop
# whatever still carries this test's scratch OMARCHY_PATH: every child inherits
# it, and the environment is read afresh before every signal, so a pid that has
# since been reused is never sent one.
leftover_pids() {
  local environ pid

  [[ -n ${test_root:-} ]] || return 0
  while IFS= read -r environ; do
    pid=${environ#/proc/}
    echo "${pid%/environ}"
  done < <(grep -lzxF -- "OMARCHY_PATH=$test_root" /proc/[0-9]*/environ 2>/dev/null || true)
}

signal_leftovers() {
  local leftovers=()

  mapfile -t leftovers < <(leftover_pids)
  (( ${#leftovers[@]} > 0 )) || return 1
  kill "$1" "${leftovers[@]}" 2>/dev/null || true
}

# A stopped shell cannot be relied on to exit, so it is continued before TERM.
cleanup() {
  local alive

  if [[ -n $QS_PID ]] && kill -0 "$QS_PID" 2>/dev/null; then
    kill -CONT "$QS_PID" 2>/dev/null || true
    kill "$QS_PID" 2>/dev/null || true
    alive=1
    for _ in {1..30}; do
      if ! kill -0 "$QS_PID" 2>/dev/null; then
        alive=0
        break
      fi
      sleep 0.1
    done
    (( alive == 0 )) || kill -KILL "$QS_PID" 2>/dev/null || true
    wait "$QS_PID" 2>/dev/null || true
  fi
  if signal_leftovers -TERM; then
    for _ in {1..30}; do
      [[ -n $(leftover_pids) ]] || break
      sleep 0.1
    done
    signal_leftovers -KILL || true
  fi
  [[ -n ${test_root:-} ]] && rm -f "$(shell_ipc_socket "$test_root")"
  [[ -n $TMPDIR && -d $TMPDIR ]] && rm -rf "$TMPDIR"
  return 0
}
trap cleanup EXIT

require_compositor "notification toast countdown"

if ! command -v quickshell >/dev/null 2>&1; then
  skip "quickshell not installed; skipping notification toast countdown"
  exit 0
fi

TMPDIR=$(mktemp -d)
test_root="$TMPDIR/omarchy"
test_home="$TMPDIR/home"
log="$TMPDIR/quickshell.log"
mkdir -p "$test_root" "$test_home"
cp -a "$ROOT/shell" "$test_root/shell"
ln -s "$ROOT/config" "$test_root/config"
ln -s "$ROOT/bin" "$test_root/bin"

shell_ipc() {
  OMARCHY_PATH="$test_root" "$ROOT/bin/omarchy-shell" "$@"
}

shell_ipc_quiet() {
  OMARCHY_PATH="$test_root" "$ROOT/bin/omarchy-shell" -q "$@"
}

probe() {
  shell_ipc toast-probe "$@"
}

fail_with_log() {
  sed -n '1,200p' "$log" >&2
  fail "$@"
}

# A countdown is read as a whole number of milliseconds: the card's is a real,
# and truncating under a millisecond cannot hide a tick.
number() {
  [[ $1 =~ ^([0-9]+)(\.[0-9]+)?$ ]] || fail "$2" "$1"
  echo "${BASH_REMATCH[1]}"
}

# A card of the checkout's own Toast.qml, with the scene a real one has left
# out: the card then stands still and only its countdown moves.
probe_dir="$test_home/.config/omarchy/plugins/acme.toast-probe"
mkdir -p "$probe_dir"
cat >"$probe_dir/manifest.json" <<JSON
{
  "schemaVersion": 1,
  "id": "acme.toast-probe",
  "name": "Toast Probe",
  "version": "1.0.0",
  "kinds": ["service"],
  "entryPoints": {"service": "Service.qml"}
}
JSON
cat >"$probe_dir/Service.qml" <<'QML'
import QtQuick
import Quickshell
import Quickshell.Io

Item {
  id: root

  property int expiries: 0
  property int shows: 0
  readonly property var card: loader.item

  Loader {
    id: loader
    source: "file://" + Quickshell.env("OMARCHY_PATH") + "/shell/plugins/notifications/Toast.qml"
    onLoaded: item.expired.connect(function() { root.expiries = root.expiries + 1 })
  }

  IpcHandler {
    target: "toast-probe"

    // Each show is a fresh arrival: the timestamp moves, so the card restarts
    // its period through the same property a sender's update does.
    function show(duration: string): string {
      if (!loader.item) return "no-card"
      root.shows = root.shows + 1
      loader.item.row = {
        key: "probe",
        app: "probe",
        appName: "Probe",
        summary: "Probe",
        body: "Probe body",
        urgency: 1,
        ts: root.shows,
        duration: Number(duration)
      }
      return "ok"
    }

    function hold(value: string): string {
      if (!loader.item) return "no-card"
      loader.item.paused = value === "true"
      return "ok"
    }

    function remaining(): string {
      return loader.item ? String(loader.item.remaining) : "no-card"
    }

    function expiriesCount(): string {
      return String(root.expiries)
    }
  }
}
QML

OMARCHY_PATH="$test_root" \
HOME="$test_home" \
XDG_CONFIG_HOME="$test_home/.config" \
XDG_CACHE_HOME="$test_home/.cache" \
XDG_STATE_HOME="$test_home/.local/state" \
PATH="$ROOT/bin:$PATH" \
  quickshell -p "$test_root/shell" --no-color >"$log" 2>&1 &
QS_PID=$!

for _ in {1..80}; do
  shell_ipc_quiet shell ping >/dev/null 2>&1 && break
  kill -0 "$QS_PID" 2>/dev/null || fail_with_log "test shell exited before IPC became available"
  sleep 0.1
done

# A plugin in the user's config directory starts disabled, so the probe has to
# be discovered and then enabled the way any third-party plugin is.
listed=""
for _ in {1..80}; do
  listed=$(shell_ipc shell listPlugins 2>/dev/null || true)
  [[ $listed == *acme.toast-probe* ]] && break
  kill -0 "$QS_PID" 2>/dev/null || fail_with_log "test shell exited before the probe was listed"
  sleep 0.1
done
[[ $listed == *acme.toast-probe* ]] || fail_with_log "the shell lists the probe plugin"

enabled=""
for _ in {1..80}; do
  enabled=$(shell_ipc shell setPluginEnabled acme.toast-probe true 2>/dev/null || true)
  [[ $enabled == "ok" ]] && break
  kill -0 "$QS_PID" 2>/dev/null || fail_with_log "test shell exited before the probe could be enabled"
  sleep 0.1
done
[[ $enabled == "ok" ]] || fail_with_log "the probe service could be enabled"

# A loaded card with no row yet answers 0. "no-card" means the Loader has not
# produced one, and "Target not found." means the plugin's IPC is not up.
loaded=""
for _ in {1..80}; do
  loaded=$(probe remaining 2>/dev/null || true)
  [[ $loaded == "0" ]] && break
  kill -0 "$QS_PID" 2>/dev/null || fail_with_log "test shell exited before the probe card loaded"
  sleep 0.1
done
[[ $loaded == "0" ]] || fail_with_log "the probe loads the checkout's Toast.qml" "probe answered: $loaded"
pass "the probe loads the checkout's Toast.qml"

# Control: an untouched card charges its countdown and expires on its own. A
# card that never ticks would pass the suspend case below for the wrong reason.
[[ $(probe show 3000) == "ok" ]] || fail_with_log "the probe shows a card"
sleep 1
left=$(number "$(probe remaining)" "a running card holds a numeric countdown")
(( left > 300 && left < 2900 )) || fail "a running card charges its countdown" "$left"

for _ in {1..40}; do
  [[ $(probe expiriesCount) == "1" ]] && break
  sleep 0.1
done
[[ $(probe expiriesCount) == "1" ]] ||
  fail "a card that is left alone expires on its lifetime" "expiries: $(probe expiriesCount)"
pass "a card that is left alone expires on its lifetime"

# The suspend case. The card is frozen for longer than the lifetime it has
# left; on resume it must expire at once rather than carry that time.
[[ $(probe show 6000) == "ok" ]] || fail_with_log "the probe shows a second card"
sleep 1
left=$(number "$(probe remaining)" "the frozen card holds a numeric countdown")
(( left > 3500 )) || fail "the card has most of its lifetime left before the freeze" "$left"

kill -STOP "$QS_PID"
stopped=0
for _ in {1..20}; do
  if grep -q '^State:.*T' "/proc/$QS_PID/status" 2>/dev/null; then
    stopped=1
    break
  fi
  sleep 0.05
done
(( stopped == 1 )) || fail "the test shell is frozen, so the freeze can stand in for a suspend"

sleep 6
kill -CONT "$QS_PID"

for _ in {1..20}; do
  [[ $(probe expiriesCount 2>/dev/null || true) == "2" ]] && break
  sleep 0.1
done
[[ $(probe expiriesCount) == "2" ]] ||
  fail "a card frozen for longer than its lifetime expires on resume" \
    "expiries: $(probe expiriesCount), remaining: $(probe remaining)"
pass "a card frozen for longer than its lifetime expires on resume"

# A deliberate stop is not a suspend: an open deck pauses the card, and the
# paused span must not be charged when it starts again.
[[ $(probe show 6000) == "ok" ]] || fail_with_log "the probe shows a third card"
sleep 1
[[ $(probe hold true) == "ok" ]] || fail_with_log "the probe holds the card"
held=$(number "$(probe remaining)" "a held card holds a numeric countdown")
sleep 1.5
after=$(number "$(probe remaining)" "a held card holds a numeric countdown")
(( after >= held - 1 )) || fail "a held card charges nothing while it is held" "held: $held, after: $after"

[[ $(probe hold false) == "ok" ]] || fail_with_log "the probe releases the card"
sleep 1.6
resumed=$(number "$(probe remaining)" "a released card holds a numeric countdown")
# Both bounds matter. A release that charged the held 1.5 s as well would drop
# this by about 3 s, and a release that never restarted the timer would drop it
# by nothing; either passes a one-sided check.
(( resumed <= after - 800 )) || fail "a released card charges the time it runs" "after: $after, resumed: $resumed"
(( resumed >= after - 2000 )) || fail "a released card charges only the time it ran" "after: $after, resumed: $resumed"
pass "a held card charges nothing, and a released one charges again"
