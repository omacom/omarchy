#!/bin/bash

# An idle shell must not start processes. The shell runs all day, once per
# session, and a Timer that starts a Process costs that process every tick for
# as long as the machine is up (see "Keeping state current without polling" in
# agents/skills/shell-dev.md). This starts a second shell on the default config,
# lets its startup work finish, then watches it sit idle and fails naming every
# command it ran.
#
# Spawns are logged from inside the shell: a preloaded shim records every exec
# the shell or any of its descendants makes, so a probe that lives a few
# milliseconds is caught as surely as a long one, and nothing outside the
# shell's own process tree (this test included) can be mistaken for it.

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

# Long enough to catch any poll at 30s or faster, the slowest interval a
# widget has been seen polling at; override to look for slower ones.
IDLE_WINDOW=${OMARCHY_IDLE_SPAWN_WINDOW:-30}

TMPDIR=""
QS_PID=""
MONITOR_PIDS=()

descendants() {
  local child

  for child in $(cat /proc/"$1"/task/*/children 2>/dev/null); do
    echo "$child"
    descendants "$child"
  done
}

# Sends TERM, gives the processes a few seconds, then KILLs what is left.
stop_processes() {
  local pid

  (( $# > 0 )) || return 0
  kill "$@" 2>/dev/null || true
  for _ in {1..30}; do
    for pid in "$@"; do
      kill -0 "$pid" 2>/dev/null && break
      pid=""
    done
    [[ -z $pid ]] && return 0
    sleep 0.1
  done
  kill -KILL "$@" 2>/dev/null || true
}

# The event monitors run as pipelines in subshells; stop each whole one.
stop_event_monitors() {
  local pid pids=()

  for pid in "${MONITOR_PIDS[@]}"; do
    pids+=("$pid")
    mapfile -t -O "${#pids[@]}" pids < <(descendants "$pid")
  done
  stop_processes "${pids[@]}"
  MONITOR_PIDS=()
}

# Quickshell leaves some of its children running when it is stopped, among
# them the inotifywait watching the plugin directory, and one that outlives the
# test holds on to whatever it inherited. Stop everything the test shell
# started: what is still below it, and whatever still carries this run's log
# in its environment, which finds the ones that were reparented.
cleanup() {
  local pid leftovers=()

  stop_event_monitors
  if [[ -n $QS_PID ]] && kill -0 "$QS_PID" 2>/dev/null; then
    mapfile -t leftovers < <(descendants "$QS_PID")
    stop_processes "$QS_PID"
    wait "$QS_PID" 2>/dev/null || true
  fi
  if [[ -f ${exec_log:-} ]]; then
    for pid in $(cut -d' ' -f1 "$exec_log" | sort -u); do
      { tr '\0' '\n' <"/proc/$pid/environ"; } 2>/dev/null | grep -qxF "OMARCHY_EXEC_LOG=$exec_log" && leftovers+=("$pid")
    done
  fi
  stop_processes "${leftovers[@]}"
  [[ -n ${test_root:-} ]] && rm -f "$(shell_ipc_socket "$test_root")"
  [[ -n $TMPDIR && -d $TMPDIR ]] && rm -rf "$TMPDIR"
  return 0
}
trap cleanup EXIT

require_compositor "idle shell spawn test"

if ! command -v quickshell >/dev/null 2>&1; then
  skip "quickshell not installed; skipping idle shell spawn test"
  exit 0
fi

if ! command -v cc >/dev/null 2>&1; then
  skip "no C compiler to build the exec logger; skipping idle shell spawn test"
  exit 0
fi

require_command jq
require_command socat
require_command node

TMPDIR=$(mktemp -d)
test_root="$TMPDIR/omarchy"
test_home="$TMPDIR/home"
stub_bin="$TMPDIR/bin"
log="$TMPDIR/quickshell.log"
exec_log="$TMPDIR/exec.log"
mkdir -p "$test_root" "$test_home" "$stub_bin"

# Nobody touches the seat while the test watches, so a long enough window
# would reach the screensaver and the lock: actions on an event, not polling,
# and run against the session's desktop. Keep the test shell awake.
mkdir -p "$test_home/.local/state/omarchy/indicators"
touch "$test_home/.local/state/omarchy/indicators/stay-awake"

cc -shared -fPIC -O2 -o "$TMPDIR/exec-log.so" "$SHELL_TEST_DIR/fixtures/idle-shell/exec-log.c" -ldl ||
  fail "the exec logger builds"

# A copy, so the test shell gets its own IPC socket and never answers for, or
# replaces, the shell running the session.
cp -a "$ROOT/shell" "$test_root/shell"
ln -s "$ROOT/config" "$test_root/config"
ln -s "$ROOT/bin" "$test_root/bin"
ln -s "$ROOT/default" "$test_root/default"

stub() {
  printf '#!/bin/bash\n%s\n' "$2" >"$stub_bin/$1"
  chmod +x "$stub_bin/$1"
}

# Keep startup off the network. These only shape what startup does; a poll
# still shows up as an exec whether or not its command is stubbed.
stub omarchy-update-available 'exit 1'
# A weather fetch that fails is retried, so answer it the way wttr.in does.
stub curl 'case "${*: -1}" in
  *"?format=j1") printf "{\"current_condition\":[{\"weatherCode\":\"113\",\"temp_F\":\"72\"}]}\n" ;;
  *"?format=%l") printf "Test City, Test Region\n" ;;
  *) exit 1 ;;
esac'
# The test shell must not act on the session. The clipboard plugin clears
# stale watchers at startup with a pkill that matches the session shell's too,
# and a charger plugged in or out switches the power profile.
stub pkill 'exit 1'
stub killall 'exit 1'
stub omarchy-powerprofiles-set 'exit 0'
stub powerprofilesctl 'exit 0'
# The shell runs some commands under `bash -lc`, and a login shell resets PATH
# and OMARCHY_PATH from /etc/omarchy.conf, which would put the session's
# checkout and its real commands back ahead of these stubs.
stub bash '[[ ${1:-} == "-lc" ]] && shift && set -- -c "$@"
exec /bin/bash "$@"'

fail_with_log() {
  sed -n '1,120p' "$log" >&2
  fail "$@"
}

exec_count() {
  if [[ -f $exec_log ]]; then
    wc -l <"$exec_log"
  else
    echo 0
  fi
}

OMARCHY_PATH="$test_root" \
HOME="$test_home" \
XDG_CONFIG_HOME="$test_home/.config" \
XDG_CACHE_HOME="$test_home/.cache" \
XDG_STATE_HOME="$test_home/.local/state" \
PATH="$stub_bin:$ROOT/bin:$PATH" \
OMARCHY_EXEC_LOG="$exec_log" \
LD_PRELOAD="$TMPDIR/exec-log.so" \
QS_DISABLE_FILE_WATCHER=1 \
QS_NO_RELOAD_POPUP=1 \
  quickshell -p "$test_root/shell" --no-color >"$log" 2>&1 &
QS_PID=$!

ready=0
for _ in {1..150}; do
  if OMARCHY_PATH="$test_root" "$ROOT/bin/omarchy-shell" shell listPlugins 2>/dev/null | jq -e 'length > 0' >/dev/null 2>&1; then
    ready=1
    break
  fi
  kill -0 "$QS_PID" 2>/dev/null || fail_with_log "test shell exited before it became ready"
  sleep 0.1
done
(( ready )) || fail_with_log "test shell answers IPC within 15 seconds"

# Startup runs its one-off probes (hardware, packages, config) for a few seconds
# after IPC answers, and ends by restoring the cursor once the startup cover has
# faded, which waits on the wallpaper. Idle starts once that has happened and
# everything has been quiet for a few seconds. A shell that never goes quiet
# fails below with the commands it kept running.
startup_done() {
  grep -q 'omarchy_startup_cursor_restore' "$exec_log" 2>/dev/null
}

settle_start=$SECONDS
quiet_since=$SECONDS
last=$(exec_count)
while (( SECONDS - settle_start < 40 )); do
  sleep 0.5
  now=$(exec_count)
  if (( now != last )); then
    last=$now
    quiet_since=$SECONDS
  elif (( SECONDS - quiet_since >= 4 )) && { startup_done || (( SECONDS - settle_start >= 20 )); }; then
    break
  fi
done

kill -0 "$QS_PID" 2>/dev/null || fail_with_log "test shell exited during startup"
(( $(exec_count) > 0 )) || fail_with_log "the exec logger records what the shell starts"

# Commands an idle shell may legitimately run, as extended regexes matched
# against the logged command line. Each holds only while its reason does, and
# at most as often as that reason implies; a limit of "" leaves it unbounded.
# The reasons are looked at as each window opens and again as it closes, and
# one that held at either end holds for the window: a remote session can start
# or a Wi-Fi network connect while the test watches.
ALLOW_PATTERNS=()
ALLOW_LIMITS=()
ALLOW_REASONS=()
# An allowance seen at both ends of a window keeps the larger of its limits.
allow() {
  local i

  for i in "${!ALLOW_PATTERNS[@]}"; do
    if [[ ${ALLOW_PATTERNS[$i]} == "$1" ]]; then
      if [[ -n ${ALLOW_LIMITS[$i]} && -n $2 ]] && (( $2 > ALLOW_LIMITS[$i] )); then
        ALLOW_LIMITS[$i]=$2
      fi
      return 0
    fi
  done
  ALLOW_PATTERNS+=("$1")
  ALLOW_LIMITS+=("$2")
  ALLOW_REASONS+=("$3")
}

# Whether the keyboard layout widget keeps asking: while the seat has more
# than one keyboard someone can type on, or none of those reports a keymap.
# Which ones count is the widget's own call, so ask its model.
keyboard_widget_polls() {
  hyprctl -j devices 2>/dev/null | ROOT="$ROOT" node -e '
    const model = require(require("path").join(process.env.ROOT, "shell/plugins/bar/widgets/KeyboardLayoutModel.js"))
    let devices = {}
    try { devices = JSON.parse(require("fs").readFileSync(0, "utf8")) } catch (e) {}
    const typed = (devices.keyboards || []).filter(keyboard => model.isTypedKeyboard(keyboard.name))
    process.exit(typed.length > 1 || !typed.some(keyboard => keyboard.active_keymap) ? 0 : 1)
  '
}

# Whether UPower on this machine has latched the battery's energy-full far
# above its design capacity, which the battery service reads past by running
# the status script as the charge moves. The script asks UPower the same way.
battery_latched() {
  local candidate info

  while read -r candidate; do
    [[ -n $candidate ]] || continue
    info=$(upower -i "$candidate" 2>/dev/null) || continue
    grep -qE '^\s*power supply:\s+yes' <<<"$info" || continue
    awk '/energy-full:/ { full = $2 } /energy-full-design:/ { design = $2 } END { exit !(design > 0 && full > design * 2) }' <<<"$info"
    return
  done < <(upower -e 2>/dev/null | grep '/battery_')
  return 1
}

add_allowances() {
  # Per-screen widgets are counted afresh each time, since a monitor can be
  # plugged in while the test watches.
  local screens
  screens=$(hyprctl -j monitors 2>/dev/null | jq 'length' 2>/dev/null || true)
  [[ $screens =~ ^[0-9]+$ ]] && (( screens > 0 )) || screens=1

  # wl-paste runs the capture script for each clipboard change, which another
  # program on the desktop can make at any moment.
  allow '/shell/plugins/clipboard/capture\.sh ' "" "runs on each clipboard change"

  # The keyboard layout widget, one per screen, asks every 10s while the seat
  # has more than one keyboard: Hyprland raises no event when a keyboard
  # arrives or leaves, so which one the label describes can only be learned by
  # asking. It also keeps asking while no keyboard reports a keymap, until a
  # reading it can use lands.
  if keyboard_widget_polls; then
    allow '(^|/)hyprctl -j devices$' $(( screens * (IDLE_WINDOW / 10 + 1) )) \
      "the keyboard widget's 10s check of a seat with several keyboards, or none it can read"
  fi

  # The battery service reads the kernel's charge registers through the
  # status script while UPower's energy-full is latched (a MacBook after a
  # Smart Battery blip), once per tenth of a point UPower's percentage moves:
  # UPower refreshes every 30s, and sooner on a charger event.
  if battery_latched; then
    allow '/bin/omarchy-battery-status --shell$' $(( IDLE_WINDOW / 30 + 2 )) \
      "the battery service's re-read while UPower's energy-full is latched"
  fi

  # While a remote session is active its end has to be polled for, every 2s:
  # Hyprland reports the screencast stopped whenever frames pause, and nothing
  # at all when the server exits.
  if pgrep -x -u "$(id -u)" gliff-server >/dev/null; then
    allow '/shell/plugins/services/remote-session/probe\.sh$' $(( IDLE_WINDOW / 2 + 1 )) \
      "the remote session's 2s check while a session is active"
  fi

  # The network widget, one per screen, reads a connected Wi-Fi network's
  # strength from the access point list every 5s when NetworkManager reports
  # none for it, which raises no change signal. Whether it reports one can only
  # be seen from inside the shell, so this holds while Wi-Fi is connected at all.
  if LC_ALL=C nmcli -t -f TYPE,STATE device 2>/dev/null | grep -qx 'wifi:connected'; then
    allow '(^|/)nmcli -t -f IN-USE,SIGNAL device wifi list ifname ' $(( screens * (IDLE_WINDOW / 5 + 1) )) \
      "the network widget's 5s strength read while Wi-Fi is connected"
  fi
}

# Events that legitimately make the shell start something (a config reload, a
# theme switch, a charger plugged in, a screencast) come from the session
# around the test, which the test cannot hold still. Record them while
# watching, so a spawn that lines up with one can be told from a poll.
start_event_monitors() {
  local events="$1" socket="${XDG_RUNTIME_DIR:-/run/user/$UID}/hypr/${HYPRLAND_INSTANCE_SIGNATURE:-}/.socket2.sock"

  MONITOR_PIDS=()
  : >"$events"
  # Each monitor runs in a subshell of its own, so stopping its descendants
  # stops the whole pipeline.
  if [[ -n ${HYPRLAND_INSTANCE_SIGNATURE:-} && -S $socket ]]; then
    ( socat -u "UNIX-CONNECT:$socket" - 2>/dev/null | sed -u 's/^/hyprland /' >>"$events" ) &
    MONITOR_PIDS+=("$!")
  fi
  if command -v upower >/dev/null; then
    ( upower --monitor 2>/dev/null |
      sed -u -n 's/^\[[^]]*\][[:space:]]*\([a-z ]*\):.*/upower \1/p' >>"$events" ) &
    MONITOR_PIDS+=("$!")
  fi
  if command -v nmcli >/dev/null; then
    # It opens by stating that NetworkManager is running, which is no event.
    ( nmcli monitor 2>/dev/null | sed -u -e '/^NetworkManager is running$/d' -e 's/^/networkmanager /' >>"$events" ) &
    MONITOR_PIDS+=("$!")
  fi
}

# Watches the shell for one window and leaves what it started outside the
# allowances in `unexpected`, and the events seen meanwhile in $1.
watch_window() {
  local events="$1" window_log="$TMPDIR/window.log" start pid ppid command i count limit
  local -A parent=() matched=() execed=() running=() forked_from=() seen=() allowed_count=()

  ALLOW_PATTERNS=()
  ALLOW_LIMITS=()
  ALLOW_REASONS=()
  add_allowances
  start=$(exec_count)
  start_event_monitors "$events"
  sleep "$IDLE_WINDOW"
  # The shell keeps appending, so judge one copy taken as the window closes,
  # before anything else takes time out of it: both passes below have to read
  # the same lines, and the limits are for the window's length.
  cp "$exec_log" "$window_log"
  stop_event_monitors
  add_allowances
  kill -0 "$QS_PID" 2>/dev/null || fail_with_log "test shell exited while idle"

  # Whatever an allowed command goes on to run is allowed with it, through any
  # subshells in between. Ancestry is read from the whole log before anything
  # is judged, since a process started before the window can still exec during
  # it, and a spawned child is only logged once the spawn returns, which can be
  # after its own children.
  while read -r pid ppid command; do
    [[ -n ${parent[$pid]:-} ]] || parent[$pid]=$ppid
    if [[ -z $command ]]; then
      forked_from[$pid]=${running[$ppid]:-process $ppid}
      continue
    fi
    execed[$pid]=1
    running[$pid]=$command
    [[ -n ${matched[$pid]:-} ]] && continue
    for i in "${!ALLOW_PATTERNS[@]}"; do
      if [[ $command =~ ${ALLOW_PATTERNS[$i]} ]]; then
        matched[$pid]=$i
        break
      fi
    done
  done <"$window_log"

  allowed_by() {
    local pid="$1" depth=0

    while [[ -n $pid ]] && (( depth++ < 64 )); do
      if [[ -n ${matched[$pid]:-} ]]; then
        echo "${matched[$pid]}"
        return 0
      fi
      pid=${parent[$pid]:-}
    done
    return 1
  }

  unexpected=()
  local line_number=0 entry key
  while read -r pid ppid command; do
    line_number=$(( line_number + 1 ))
    (( line_number > start )) || continue

    if entry=$(allowed_by "$pid"); then
      # Count the allowed command itself, once per process, against its limit.
      if [[ -n $command && ${matched[$pid]:-} == "$entry" && -z ${seen[$pid]:-} ]]; then
        seen[$pid]=1
        allowed_count[$entry]=$(( ${allowed_count[$entry]:-0} + 1 ))
      fi
      continue
    fi

    if [[ -n $command ]]; then
      # A failed exec attempt is retried down PATH under the same pid, and a
      # process that execs on (bash -c's last command, a stub) keeps it, so
      # each process is named once, by the command it was started as.
      key=$pid
    elif [[ -z ${execed[$pid]:-} ]]; then
      # A process forked to run only built-ins never execs, but it is a process.
      key=$pid
      command="(subshell of ${forked_from[$pid]})"
    else
      continue
    fi
    if [[ -z ${seen[$key]:-} ]]; then
      seen[$key]=1
      unexpected+=("$command")
    fi
  done <"$window_log"

  for i in "${!ALLOW_PATTERNS[@]}"; do
    count=${allowed_count[$i]:-0}
    limit=${ALLOW_LIMITS[$i]}
    if [[ -n $limit ]] && (( count > limit )); then
      unexpected+=("$count runs matching ${ALLOW_PATTERNS[$i]}, more than the $limit allowed for ${ALLOW_REASONS[$i]}")
    fi
  done
}

report() {
  printf 'The shell started %d process(es) in %ds of idling:\n' "${#unexpected[@]}" "$IDLE_WINDOW"
  printf '%s\n' "${unexpected[@]}" | sort | uniq -c | sort -rn | sed 's/^/  /' | head -40
  if [[ -s $1 ]]; then
    printf 'Session events seen meanwhile:\n'
    cut -d'>' -f1 "$1" | sort | uniq -c | sort -rn | sed 's/^/  /' | head -20
  fi
  printf 'Poll on an event instead (agents/skills/shell-dev.md), or allow it in %s with the reason.\n' "${BASH_SOURCE[0]}"
}

events="$TMPDIR/events.log"
watch_window "$events"

# A spawn that lined up with a session event may have been the shell reacting
# to it. Watch once more: a poll comes back, a reaction needs its event again.
if (( ${#unexpected[@]} > 0 )) && [[ -s $events ]]; then
  printf '# %s\n' "Spawns coincided with session events; watching once more:" >&2
  report "$events" | sed 's/^/# /' >&2
  watch_window "$events"
fi

(( ${#unexpected[@]} == 0 )) || fail "an idle shell starts no processes" "$(report "$events")"
pass "an idle shell starts no processes over ${IDLE_WINDOW}s"
