#!/bin/bash

# Bar panel first open and reopen: panels build their content lazily on
# first open (#15044), so the first open is the one to watch, and a
# reopen must stay instant because the content survives the close. Each
# panel is timed from its IPC open until the compositor maps its panel
# surface; budgets scale with how fast this machine starts processes.

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

TMPDIR=""
QS_PID=""

# Same leftover discipline as the runtime smoke test: Quickshell leaves
# children behind when it stops, so stop whatever still runs with this
# test's scratch OMARCHY_PATH once the shell is down.
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

stop_shell() {
  local alive

  if [[ -n $QS_PID ]] && kill -0 "$QS_PID" 2>/dev/null; then
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
  QS_PID=""
  if signal_leftovers -TERM; then
    for _ in {1..30}; do
      [[ -n $(leftover_pids) ]] || break
      sleep 0.1
    done
    signal_leftovers -KILL || true
  fi
  [[ -n ${test_root:-} ]] && rm -f "$(shell_ipc_socket "$test_root")"
  return 0
}

cleanup() {
  stop_shell
  [[ -n $TMPDIR && -d $TMPDIR ]] && rm -rf "$TMPDIR"
  return 0
}
trap cleanup EXIT

require_compositor "panel open budgets"
require_command jq
command -v quickshell >/dev/null 2>&1 || { skip "quickshell not installed; skipping panel open budgets"; exit 0; }
require_comparable_speed "panel open budgets"

FIRST_BUDGET_MS=$(( ${OMARCHY_PANEL_FIRST_OPEN_BUDGET_MS:-400} * SPEED_PERCENT / 100 ))
REOPEN_BUDGET_MS=$(( ${OMARCHY_PANEL_REOPEN_BUDGET_MS:-150} * SPEED_PERCENT / 100 ))

TMPDIR=$(mktemp -d)
test_root="$TMPDIR/omarchy"
test_home="$TMPDIR/home"
stub_bin="$TMPDIR/bin"
log="$TMPDIR/quickshell.log"
mkdir -p "$test_root" "$test_home" "$stub_bin"
# Nobody touches the seat during a run, so without this the scratch
# shell's idle service would eventually screensave/lock the real desktop.
mkdir -p "$test_home/.local/state/omarchy/indicators"
touch "$test_home/.local/state/omarchy/indicators/stay-awake"
cp -a "$ROOT/shell" "$test_root/shell"
ln -s "$ROOT/config" "$test_root/config"
ln -s "$ROOT/bin" "$test_root/bin"
ln -s "$ROOT/default" "$test_root/default"

# The scratch shell must not reach the real session: the clipboard plugin
# cleans up stale watchers at startup with a pkill whose pattern also
# matches the session shell's watchers (the idle-spawn test stubs the
# same commands for the same reason).
for name in pkill killall; do
  printf '#!/bin/bash\nexit 1\n' >"$stub_bin/$name"
  chmod +x "$stub_bin/$name"
done
# Nor may it change system state over D-Bus: the battery service applies a
# power profile when UPower reports one.
for name in omarchy-powerprofiles-set powerprofilesctl; do
  printf '#!/bin/bash\nexit 0\n' >"$stub_bin/$name"
  chmod +x "$stub_bin/$name"
done
# The shell runs some commands under `bash -lc`, and a login shell resets
# PATH and OMARCHY_PATH from /etc/omarchy.conf, which would put the
# session's checkout and its real commands back ahead of these stubs.
printf '#!/bin/bash\n[[ ${1:-} == "-lc" ]] && shift && set -- -c "$@"\nexec /bin/bash "$@"\n' >"$stub_bin/bash"
chmod +x "$stub_bin/bash"


shell_ipc() {
  OMARCHY_PATH="$test_root" "$ROOT/bin/omarchy-shell" "$@"
}

shell_ipc_quiet() {
  OMARCHY_PATH="$test_root" "$ROOT/bin/omarchy-shell" -q "$@"
}

# mapped|absent|unknown: a failed compositor query proves nothing, so
# an absent verdict only counts from a query that actually answered.
panel_state() {
  local layers
  layers=$(hyprctl -j layers 2>/dev/null) || { echo unknown; return; }
  [[ -n $layers ]] || { echo unknown; return; }
  if jq -e --argjson pid "$QS_PID" '
    [.. | objects | select(.namespace? == "omarchy-keyboard-panel" and .pid == $pid and .w > 0 and .h > 0)] | length > 0
  ' <<<"$layers" >/dev/null 2>&1; then
    echo mapped
  else
    echo absent
  fi
}

wait_panel() { # mapped|absent
  local want="$1"
  for _ in {1..300}; do
    [[ $(panel_state) == "$want" ]] && return 0
    kill -0 "$QS_PID" 2>/dev/null || return 1
    sleep 0.01
  done
  return 1
}

OMARCHY_PATH="$test_root" \
HOME="$test_home" \
XDG_CONFIG_HOME="$test_home/.config" \
XDG_CACHE_HOME="$test_home/.cache" \
XDG_STATE_HOME="$test_home/.local/state" \
PATH="$stub_bin:$ROOT/bin:$PATH" \
  quickshell -p "$test_root/shell" --no-color >"$log" 2>&1 &
QS_PID=$!

for _ in {1..80}; do
  # Not the quiet form: -q succeeds even when no shell answers.
  [[ $(shell_ipc shell ping 2>/dev/null || true) == "ok" ]] && break
  kill -0 "$QS_PID" 2>/dev/null || { sed -n '1,120p' "$log" >&2; fail "panel test shell becomes available"; }
  sleep 0.1
done

# Registration is asynchronous; wait until the panels answer.
for _ in {1..80}; do
  plugins=$(shell_ipc shell listPlugins 2>/dev/null || true)
  if jq -e 'map(.id) | contains(["omarchy.audio","omarchy.bluetooth","omarchy.monitor","omarchy.network"])' <<<"$plugins" >/dev/null 2>&1; then
    break
  fi
  kill -0 "$QS_PID" 2>/dev/null || { sed -n '1,120p' "$log" >&2; fail "panel test shell registers its panels"; }
  sleep 0.1
done

panels=(omarchy.audio omarchy.bluetooth omarchy.monitor omarchy.network)
# The power panel hides itself without a battery, so it can only be
# timed where one exists.
if "$ROOT/bin/omarchy-battery-present" >/dev/null 2>&1; then
  panels+=(omarchy.power)
else
  skip "panel omarchy.power first open and reopen (no battery)"
fi

# listPlugins reports discovered manifests, not registered IPC handlers:
# widget components load asynchronously, so wait until each panel's own
# handler answers a (harmless, already-closed) close before timing it.
for panel in "${panels[@]}"; do
  ready=""
  for _ in {1..80}; do
    if shell_ipc "$panel" close >/dev/null 2>&1; then ready=1; break; fi
    kill -0 "$QS_PID" 2>/dev/null || break
    sleep 0.1
  done
  [[ -n $ready ]] || { sed -n '1,120p' "$log" >&2; fail "panel $panel IPC handler becomes available"; }
done

open_ms() { # panel-id -> ms on stdout, fails when it never maps
  local id="$1" start end
  start=$EPOCHREALTIME
  shell_ipc_quiet "$id" open >/dev/null 2>&1 || true
  wait_panel mapped || return 1
  end=$EPOCHREALTIME
  echo $(( (${end/[.,]/} - ${start/[.,]/}) / 1000 ))
}

close_panel() {
  shell_ipc_quiet "$1" close >/dev/null 2>&1 || true
  wait_panel absent || return 1
}

for panel in "${panels[@]}"; do
  first=$(open_ms "$panel") || { sed -n '1,120p' "$log" >&2; fail "panel $panel first open maps its surface"; }
  close_panel "$panel" || fail "panel $panel closes after first open"
  reopen=""
  for _ in 1 2; do
    elapsed=$(open_ms "$panel") || { sed -n '1,120p' "$log" >&2; fail "panel $panel reopen maps its surface"; }
    close_panel "$panel" || fail "panel $panel closes after reopen"
    if [[ -z $reopen ]] || (( elapsed < reopen )); then reopen=$elapsed; fi
  done
  (( first <= FIRST_BUDGET_MS )) || fail "panel $panel first open within ${FIRST_BUDGET_MS}ms" "First open took ${first}ms."
  (( reopen <= REOPEN_BUDGET_MS )) || fail "panel $panel reopen within ${REOPEN_BUDGET_MS}ms" "Fastest reopen took ${reopen}ms."
  pass "panel $panel first open ${first}ms, reopen ${reopen}ms"
done
