#!/bin/bash

# Login to a usable desktop, the segment a test can own: from the
# session launching bin/omarchy-launch-shell (what uwsm starts at
# login) until the compositor maps the bar at a real size. Greetd and
# uwsm compositor start are not in here -- they need a real boot and
# belong to image/acceptance testing; this guards everything after
# the compositor exists: systemd-cat spawn, launcher supervision, and
# shell start. Fastest of three, scaled to machine process speed.

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

  # The launcher relaunches its shell; stop it first so nothing returns.
  if [[ -n ${LAUNCHER_PID:-} ]] && kill -0 "$LAUNCHER_PID" 2>/dev/null; then
    kill "$LAUNCHER_PID" 2>/dev/null || true
    for _ in {1..20}; do
      kill -0 "$LAUNCHER_PID" 2>/dev/null || break
      sleep 0.1
    done
    kill -KILL "$LAUNCHER_PID" 2>/dev/null || true
  fi
  LAUNCHER_PID=""
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

require_compositor "login to desktop budget"
require_command jq
command -v quickshell >/dev/null 2>&1 || { skip "quickshell not installed; skipping login to desktop budget"; exit 0; }
require_comparable_speed "login to desktop budget"

BUDGET_MS=$(( ${OMARCHY_LOGIN_DESKTOP_BUDGET_MS:-750} * SPEED_PERCENT / 100 ))

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


# The shell the launcher starts: found by its scratch config path.
launcher_shell_pid() {
  local p
  for p in $(pgrep -f "quickshell -n -p $test_root/shell" || true); do
    echo "$p"
    return 0
  done
  return 1
}

bar_mapped_for() {
  local pid="$1" layers
  layers=$(hyprctl -j layers 2>/dev/null || true)
  [[ -n $layers ]] && jq -e --argjson pid "$pid" '
    [.. | objects | select(.namespace? == "omarchy-bar" and .pid == $pid and .w > 0 and .h > 0)] | length > 0
  ' <<<"$layers" >/dev/null 2>&1
}

cold_login_ms() {
  local start end elapsed pid

  : >"$log"
  # Every sample is a fresh login: the first launch writes a session
  # marker that later launches read as "already consumed" and skip the
  # login intro work for.
  rm -f "$test_home/.local/state/omarchy/background-intro.session-id"
  start=$EPOCHREALTIME
  OMARCHY_PATH="$test_root" \
  HOME="$test_home" \
  XDG_CONFIG_HOME="$test_home/.config" \
  XDG_CACHE_HOME="$test_home/.cache" \
  XDG_STATE_HOME="$test_home/.local/state" \
  PATH="$stub_bin:$ROOT/bin:$PATH" \
    setsid "$ROOT/bin/omarchy-launch-shell" >"$log" 2>&1 &
  LAUNCHER_PID=$!

  elapsed=""
  pid=""
  for _ in {1..800}; do
    # The launcher relaunches a shell that dies; follow the replacement
    # instead of timing the dead one's bar forever.
    if [[ -n $pid ]] && ! kill -0 "$pid" 2>/dev/null; then
      pid=""
      QS_PID=""
    fi
    if [[ -z $pid ]]; then
      pid=$(launcher_shell_pid || true)
      [[ -n $pid ]] && QS_PID=$pid
    fi
    if [[ -n $pid ]] && bar_mapped_for "$pid"; then
      end=$EPOCHREALTIME
      elapsed=$(( (${end/[.,]/} - ${start/[.,]/}) / 1000 ))
      break
    fi
    kill -0 "$LAUNCHER_PID" 2>/dev/null || break
    sleep 0.01
  done

  stop_shell
  printf '%s' "$elapsed"
}

best=""
for _ in 1 2 3; do
  elapsed=$(cold_login_ms)
  if [[ -z $elapsed ]]; then
    sed -n '1,120p' "$log" >&2
    fail "login reaches a drawn bar through the launcher"
  fi
  if [[ -z $best ]] || (( elapsed < best )); then
    best=$elapsed
  fi
done

(( best <= BUDGET_MS )) || fail "login reaches a drawn bar within ${BUDGET_MS}ms" "Fastest of three logins took ${best}ms."
pass "login reaches a drawn bar within ${BUDGET_MS}ms (${best}ms)"
