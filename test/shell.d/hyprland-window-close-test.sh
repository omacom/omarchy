#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

tmpdir=$(mktemp -d)
trap 'rm -rf "$tmpdir"' EXIT

mock_bin="$tmpdir/bin"
log_file="$tmpdir/log"
state_dir="$tmpdir/state"
mkdir -p "$mock_bin" "$state_dir"

: >"$log_file"
cat >"$mock_bin/hyprctl" <<'SH'
#!/bin/bash
printf '%s\n' "$*" >>"$TEST_LOG"
case $1 in
  activewindow)
    printf '{"address":"0xdead","pid":4242,"xwayland":true,"fullscreen":0}\n'
    ;;
  clients)
    if [[ -f $STATE_DIR/closed ]]; then
      printf '[]\n'
    else
      printf '[{"address":"0xdead","pid":4242}]\n'
    fi
    ;;
  dispatch)
    touch "$STATE_DIR/closed"
    ;;
esac
SH
cat >"$mock_bin/sleep" <<'SH'
#!/bin/bash
exit 0
SH
chmod +x "$mock_bin"/*

PATH="$mock_bin:$PATH" TEST_LOG="$log_file" STATE_DIR="$state_dir" \
  bash "$ROOT/bin/omarchy-hyprland-window-close"

grep -q 'window.close({ window = "address:0xdead" })' "$log_file" ||
  fail "window-close dispatches a cooperative close" "log: $(< "$log_file")"
closes=$(grep -c '^dispatch ' "$log_file" || true)
(( closes == 1 )) || fail "unmapped window receives only one close"
pass "window-close dispatches a cooperative close without force-kill"

# A mapped live client may be waiting for a save/discard answer.
cat >"$mock_bin/kill" <<'SH'
#!/bin/bash
printf '%s\n' "$*" >>"$SIGNAL_LOG"
SH
cat >"$mock_bin/hyprctl" <<'SH'
#!/bin/bash
printf '%s\n' "$*" >>"$TEST_LOG"
case $1 in
  activewindow) printf '%s\n' "$ACTIVE_WINDOW" ;;
  clients) printf '[{"address":"0xdead"}]\n' ;;
esac
SH
chmod +x "$mock_bin"/*
signal_log="$tmpdir/signals"

assert_cooperative_only() {
  : >"$log_file"
  : >"$signal_log"
  PATH="$mock_bin:$PATH" TEST_LOG="$log_file" SIGNAL_LOG="$signal_log" ACTIVE_WINDOW="$1" \
    bash -c 'enable -n kill; source "$1"' bash "$ROOT/bin/omarchy-hyprland-window-close"

  [[ ! -s $signal_log ]] ||
    fail "$2 does not signal the process" "signals: $(< "$signal_log")"
  closes=$(grep -c '^dispatch ' "$log_file" || true)
  (( closes == 1 )) ||
    fail "$2 sends exactly one cooperative close" "log: $(< "$log_file")"
  grep -q 'window.close({' "$log_file" ||
    fail "$2 sends a cooperative close"
  if grep -q 'killwindow' "$log_file"; then
    fail "$2 does not force-clear the surface"
  fi
  pass "$2 remains cooperative"
}

for xwayland in false true; do
  assert_cooperative_only \
    "{\"address\":\"0xdead\",\"pid\":$$,\"xwayland\":$xwayland}" \
    "live client (xwayland=$xwayland) awaiting a save/discard answer"
done

for pid_data in '' ',"pid":null' ',"pid":0' ',"pid":-1' ',"pid":"invalid"'; do
  assert_cooperative_only \
    "{\"address\":\"0xdead\",\"xwayland\":true$pid_data}" \
    "XWayland client with missing or invalid PID ($pid_data)"
done

# Choose a PID beyond the kernel's PID range and verify it is absent.
missing_pid=$(< /proc/sys/kernel/pid_max)
(( missing_pid += 1 ))
[[ ! -e /proc/$missing_pid ]] || fail "orphan fixture PID is absent"
assert_cooperative_only \
  "{\"address\":\"0xdead\",\"pid\":$missing_pid,\"xwayland\":false}" \
  "native Wayland client with absent PID"

# Zombie path: window stays mapped; pid has no /proc entry.
: >"$log_file"
rm -f "$state_dir"/*
cat >"$mock_bin/hyprctl" <<'SH'
#!/bin/bash
printf '%s\n' "$*" >>"$TEST_LOG"
case $1 in
  activewindow)
    printf '{"address":"0xzombie","pid":%s,"xwayland":true,"fullscreen":0}\n' "$MISSING_PID"
    ;;
  clients)
    if [[ -f $STATE_DIR/force_closed ]]; then
      printf '[]\n'
    else
      printf '[{"address":"0xzombie","pid":%s}]\n' "$MISSING_PID"
    fi
    ;;
  dispatch)
    closes=0
    [[ -f $STATE_DIR/closes ]] && closes=$(wc -l <"$STATE_DIR/closes")
    echo x >>"$STATE_DIR/closes"
    if (( closes >= 1 )); then
      touch "$STATE_DIR/force_closed"
    fi
    ;;
esac
SH
chmod +x "$mock_bin/hyprctl"

PATH="$mock_bin:$PATH" TEST_LOG="$log_file" STATE_DIR="$state_dir" MISSING_PID="$missing_pid" \
  bash "$ROOT/bin/omarchy-hyprland-window-close"

grep -q 'window.close({ window = "address:0xzombie" })' "$log_file" ||
  fail "zombie close still sends an initial close" "log: $(< "$log_file")"
# Second close / killwindow after the surface refused to leave.
closes=$(grep -c '0xzombie' "$log_file" || true)
(( closes >= 2 )) ||
  fail "zombie close force-targets the stuck surface" "log: $(< "$log_file")"
pass "window-close force-clears an XWayland zombie that ignores close"

grep -q 'omarchy-hyprland-window-close' "$ROOT/default/hypr/bindings/tiling.lua" ||
  fail "tiling bindings use omarchy-hyprland-window-close"
pass "tiling bindings use omarchy-hyprland-window-close"
