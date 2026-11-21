#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

TMPDIR=""
QS_PID=""
COMPOSITOR_PID=""

stop_group() {
  local pid=$1
  [[ -n $pid ]] || return 0
  kill -TERM -- "-$pid" 2>/dev/null || true
  for _ in {1..20}; do
    kill -0 "$pid" 2>/dev/null || break
    sleep 0.1
  done
  kill -KILL -- "-$pid" 2>/dev/null || true
  wait "$pid" 2>/dev/null || true
}

cleanup() {
  stop_group "$QS_PID"
  stop_group "$COMPOSITOR_PID"
  if [[ -n $TMPDIR && -d $TMPDIR ]]; then
    rm -rf "$TMPDIR"
  fi
}
trap cleanup EXIT
trap 'exit 130' INT
trap 'exit 143' TERM

# Unlike ordinary QML fixtures, this one can acquire ext-session-lock when
# screens change. Never connect it to the caller's compositor, even in CI.
# Sway is a test-only dependency: its headless backend needs no GPU or seat.
for command in sway quickshell; do
  if ! command -v "$command" >/dev/null 2>&1; then
    skip "$command not installed; skipping isolated lock activity reblank test"
    exit 0
  fi
done
require_command swaymsg
require_command jq
require_command setsid
ulimit -c 0

TMPDIR=$(mktemp -d)
result="$TMPDIR/result.json"
log="$TMPDIR/quickshell.log"
blank_marker="$TMPDIR/blank-called"
config_dir="$TMPDIR/lock-activity-reblank"
fake_bin="$TMPDIR/bin"
mkdir -p "$config_dir" "$TMPDIR/home" "$fake_bin"
mkdir -m 700 "$TMPDIR/runtime"

# An allowlist, not just WAYLAND_DISPLAY replacement: inherited WAYLAND_SOCKET,
# X11, Hyprland IPC and session/system D-Bus connections must not leak through.
# Absolute private sockets also prevent libwayland falling back to the session.
private_env=(env -i PATH="$fake_bin:$ROOT/bin:/usr/bin:/bin" HOME="$TMPDIR/home"
  LANG=C.UTF-8 XDG_RUNTIME_DIR="$TMPDIR/runtime"
  DBUS_SESSION_BUS_ADDRESS="unix:path=$TMPDIR/runtime/no-session-bus"
  DBUS_SYSTEM_BUS_ADDRESS="unix:path=$TMPDIR/runtime/no-system-bus")

# Both process groups have their own deadline, including if the runner is killed.
printf 'xwayland disable\noutput HEADLESS-1 mode 1280x720\n' >"$TMPDIR/sway.conf"
"${private_env[@]}" WLR_BACKENDS=headless WLR_RENDERER=pixman WLR_HEADLESS_OUTPUTS=1 \
  setsid timeout --kill-after=2 45 sway --config "$TMPDIR/sway.conf" >"$TMPDIR/sway.log" 2>&1 &
COMPOSITOR_PID=$!
sway_socket=""
wayland_socket=""
for _ in {1..100}; do
  for socket in "$TMPDIR/runtime"/wayland-*; do
    [[ -S $socket ]] && wayland_socket=$socket
  done
  for socket in "$TMPDIR/runtime"/sway-ipc."$UID".*.sock; do
    [[ -S $socket ]] && sway_socket=$socket
  done
  [[ -n $wayland_socket && -n $sway_socket ]] && break
  kill -0 "$COMPOSITOR_PID" 2>/dev/null || break
  sleep 0.1
done
if [[ -z $wayland_socket || ! -S $sway_socket ]] ||
   ! "${private_env[@]}" swaymsg -s "$sway_socket" -t get_outputs -r | jq -e 'length == 1 and .[0].name == "HEADLESS-1" and .[0].active' >/dev/null; then
  cat "$TMPDIR/sway.log" >&2
  fail "private headless compositor starts with its own output and IPC socket"
fi
cp "$SHELL_TEST_DIR/fixtures/lock-activity-reblank/shell.qml" "$config_dir/shell.qml"
ln -s "$ROOT/shell/Ui" "$config_dir/Ui"
ln -s "$ROOT/shell/Commons" "$config_dir/Commons"

# The fixture drives the real lock service, so a fired blank timer spawns the
# real brightness commands. Shadow them: the test wants to know the spawn
# reached the command, not to drive Hyprland from the private Sway compositor.
cat >"$fake_bin/omarchy-brightness-display" <<SH
#!/bin/bash
printf '%s\n' "\$*" >> "$blank_marker"
SH
chmod +x "$fake_bin/omarchy-brightness-display"

cat >"$fake_bin/omarchy-brightness-keyboard" <<'SH'
#!/bin/bash
exit 0
SH
chmod +x "$fake_bin/omarchy-brightness-keyboard"

cat >"$fake_bin/omarchy-system-wake" <<'SH'
#!/bin/bash
exit 0
SH
chmod +x "$fake_bin/omarchy-system-wake"

# There is no pre-existing stranded lock in the disposable compositor.
cat >"$fake_bin/omarchy-hyprland-session-lock-stranded" <<'SH'
#!/bin/bash
exit 1
SH
chmod +x "$fake_bin/omarchy-hyprland-session-lock-stranded"

"${private_env[@]}" \
WAYLAND_DISPLAY="$wayland_socket" \
SWAYSOCK="$sway_socket" \
QT_QPA_PLATFORM=wayland \
OMARCHY_PATH="$ROOT" \
OMARCHY_QML_TEST_RESULT="$result" \
HOME="$TMPDIR/home" \
XDG_CONFIG_HOME="$TMPDIR/home/.config" \
XDG_CACHE_HOME="$TMPDIR/home/.cache" \
XDG_STATE_HOME="$TMPDIR/home/.local/state" \
QML2_IMPORT_PATH="$ROOT/shell" \
QML_IMPORT_PATH="$ROOT/shell" \
  setsid timeout --kill-after=2 40 quickshell -p "$config_dir" --no-color >"$log" 2>&1 &
QS_PID=$!

# Bound startup, the real blank countdown and the screen-change lock check.
for _ in {1..350}; do
  [[ -s $result ]] && break
  if ! kill -0 "$QS_PID" 2>/dev/null; then
    sed -n '1,220p' "$log" >&2
    fail "lock activity reblank quickshell exited before writing result"
  fi
  sleep 0.1
done

[[ -s $result ]] || {
  sed -n '1,220p' "$log" >&2
  fail "lock activity reblank test timed out"
}

if ! jq -e '.ok == true' "$result" >/dev/null; then
  printf 'Lock activity reblank result:\n' >&2
  jq . "$result" >&2
  printf 'Lock activity reblank log:\n' >&2
  sed -n '1,220p' "$log" >&2
  fail "lock screen re-arms its blank from raw input while locked"
fi

# The re-armed timer is the only one allowed to reach the blank command in
# this run; the marker proves the spawn went all the way through.
for _ in {1..30}; do
  [[ -e $blank_marker ]] && break
  sleep 0.1
done
[[ -e $blank_marker ]] || {
  sed -n '1,220p' "$log" >&2
  fail "the re-armed blank timer runs omarchy-brightness-display"
}

pass "lock activity handlers re-arm blanking and screen changes lock only the disposable compositor"
