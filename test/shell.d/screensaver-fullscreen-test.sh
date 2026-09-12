#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"
require_command jq
require_command pgrep
real_jq=$(command -v jq)
real_pgrep=$(command -v pgrep)

test_tmp=$(mktemp -d)
launch_pid=""
cleanup() {
  if [[ -n $launch_pid ]]; then
    kill "$launch_pid" 2>/dev/null || true
    wait "$launch_pid" 2>/dev/null || true
  fi
  rm -rf "$test_tmp"
}
trap cleanup EXIT

mkdir -p "$test_tmp/bin" "$test_tmp/home"
mkfifo "$test_tmp/events"
exec {events_fd}<>"$test_tmp/events"

cat >"$test_tmp/bin/jq" <<'STUB'
#!/bin/bash
if [[ $* == *'any(.[];'* ]]; then
  # Check the actual process argv, without killing any desktop processes.
  if "$OMARCHY_TEST_PGREP" -f '[o]rg.omarchy.screensaver' | grep -qx "$$"; then
    touch "$OMARCHY_TEST_DIR/pkill-collision"
    kill -TERM "$$"
  fi
  [[ ! -f $OMARCHY_TEST_DIR/jq-failed ]] || exit 2
fi
exec "$OMARCHY_TEST_JQ" "$@"
STUB
cat >"$test_tmp/bin/pgrep" <<'STUB'
#!/bin/bash
exit 1
STUB
cat >"$test_tmp/bin/omarchy-toggle-enabled" <<'STUB'
#!/bin/bash
exit "${OMARCHY_TEST_DISABLED:-1}"
STUB
cat >"$test_tmp/bin/omarchy-hyprland-monitor-focused" <<'STUB'
#!/bin/bash
printf 'DP-1\n'
STUB
cat >"$test_tmp/bin/xdg-terminal-exec" <<'STUB'
#!/bin/bash
printf 'foot.desktop\n'
STUB
cat >"$test_tmp/bin/socat" <<'STUB'
#!/bin/bash
exec cat "$OMARCHY_TEST_DIR/events"
STUB
cat >"$test_tmp/bin/hyprctl" <<'STUB'
#!/bin/bash
set -euo pipefail
state="$OMARCHY_TEST_DIR/clients.json"
printf '%s\n' "$*" >>"$OMARCHY_TEST_DIR/calls"
case "$*" in
  'clients -j')
    [[ ! -f $OMARCHY_TEST_DIR/query-failed ]] || exit 1
    if [[ -f $OMARCHY_TEST_DIR/query-misses ]]; then
      misses=$(cat "$OMARCHY_TEST_DIR/query-misses")
      if (( misses > 0 )); then
        printf '%s\n' "$((misses - 1))" >"$OMARCHY_TEST_DIR/query-misses"
        exit 1
      fi
    fi
    cat "$state"
    ;;
  'monitors -j')
    printf '[{"name":"DP-1"},{"name":"DP-2"}]\n'
    ;;
  *'hl.dsp.exec_cmd('* )
    count=$(cat "$OMARCHY_TEST_DIR/spawned")
    (( ++count ))
    # Mapping a screensaver clears the previous internal fullscreen state on
    # this monitor. Client-only fullscreen and hidden workspaces are untouched.
    jq --argjson monitor "$((count - 1))" --arg address "0xf$count" '
      map(if .monitor == $monitor and .fullscreen != 0 then
        .fullscreen = 0 | .fullscreenClient = 0 else . end)
      + [{address: $address, class: "org.omarchy.screensaver", mapped: true}]
    ' "$state" >"$state.tmp"
    mv "$state.tmp" "$state"
    printf '%s\n' "$count" >"$OMARCHY_TEST_DIR/spawned"
    printf 'openwindow>>f%s,1,org.omarchy.screensaver,Screensaver\n' "$count" >"$OMARCHY_TEST_DIR/events"
    ;;
  *'hl.dsp.window.fullscreen_state('* )
    # A restore while any screensaver is still mapped is a failure.
    jq -e 'all(.[]; .class != "org.omarchy.screensaver" or .mapped == false)' "$state" >/dev/null
    printf '%s\n' "$2" >>"$OMARCHY_TEST_DIR/restored"
    ;;
esac
STUB
chmod +x "$test_tmp/bin/"*

launch() {
  env PATH="$test_tmp/bin:$PATH" HOME="$test_tmp/home" OMARCHY_PATH="$ROOT" \
    XDG_RUNTIME_DIR="$test_tmp" HYPRLAND_INSTANCE_SIGNATURE=test \
    OMARCHY_TEST_DIR="$test_tmp" OMARCHY_TEST_JQ="$real_jq" OMARCHY_TEST_PGREP="$real_pgrep" \
    timeout --kill-after=1 15 "$ROOT/bin/omarchy-launch-screensaver" "$@"
}

wait_for_launch() {
  for (( attempt = 0; attempt < 100; attempt++ )); do
    [[ $(<"$test_tmp/spawned") == "2" ]] && return
    sleep 0.02
  done
  fail "screensaver maps on both monitors" "$(<"$test_tmp/calls")"
}

reset_state() {
  rm -f "$test_tmp/query-failed" "$test_tmp/jq-failed" "$test_tmp/query-misses"
  : >"$test_tmp/calls"
  : >"$test_tmp/restored"
  printf '0\n' >"$test_tmp/spawned"
  # Extra windows exercise stale addresses, unchanged state, both fullscreen
  # handlers, and a different process reusing an otherwise matching identity.
  jq -n '[
    {address:"0xa", pid:1, stableId:"a", monitor:0, fullscreen:2, fullscreenClient:2, fullscreenHandler:"default"},
    {address:"0xb", pid:2, stableId:"b", monitor:1, fullscreen:1, fullscreenClient:1, fullscreenHandler:"scrolling"},
    {address:"0xc", pid:3, stableId:"c", monitor:0, fullscreen:0, fullscreenClient:0},
    {address:"0xd", pid:4, stableId:"d", monitor:0, fullscreen:0, fullscreenClient:2},
    {address:"0xe", pid:5, stableId:"e", monitor:0, fullscreen:2, fullscreenClient:0},
    {address:"0x10", pid:6, stableId:"10", monitor:0, fullscreen:2, fullscreenClient:2},
    {address:"0x11", pid:7, stableId:"11", monitor:0, fullscreen:2, fullscreenClient:2},
    {address:"0x12", pid:8, stableId:"12", monitor:0, fullscreen:2, fullscreenClient:2},
    {address:"0x13", pid:9, stableId:"13", monitor:0, fullscreen:2, fullscreenClient:2},
    {address:"0x14", pid:10, stableId:"14", monitor:2, fullscreen:2, fullscreenClient:2}
  ] | map(. + {mapped:true, class:"test"})' >"$test_tmp/clients.json"
}

close_screensaver() {
  local address="$1"
  # Closed clients can remain listed while their closing animation plays.
  jq --arg address "$address" 'map(if .address == $address then .mapped = false else . end)' \
    "$test_tmp/clients.json" >"$test_tmp/clients.tmp"
  mv "$test_tmp/clients.tmp" "$test_tmp/clients.json"
  printf 'closewindow>>%s\n' "${address#0x}" >&"$events_fd"
}

reset_state
launch force &
launch_pid=$!
wait_for_launch
[[ ! -s $test_tmp/restored ]] || fail "nothing restores while screensavers are mapped"
pass "fullscreen state is saved before either screensaver maps"

# pgrep deliberately always misses: the lock must protect the snapshot itself.
launch force
[[ $(<"$test_tmp/spawned") == "2" ]] || fail "a concurrent launch is ignored"
pass "concurrent launches cannot replace the saved state"

close_screensaver 0xf1
sleep 0.1
[[ ! -s $test_tmp/restored ]] || fail "closing one monitor must not restore fullscreen yet"
pass "restoration waits for the last screensaver window"

jq 'map(select(.address != "0x10"))
  | map(if .address == "0x11" then .stableId = "reused"
    elif .address == "0x12" then .pid = 999
    elif .address == "0x13" then .mapped = false else . end)' \
  "$test_tmp/clients.json" >"$test_tmp/clients.tmp"
mv "$test_tmp/clients.tmp" "$test_tmp/clients.json"
close_screensaver 0xf2
wait "$launch_pid" || fail "the launcher exits after restoring fullscreen"
launch_pid=""

[[ $(wc -l <"$test_tmp/restored") == "3" ]] || fail "only three surviving changed windows are restored" "$(<"$test_tmp/restored")"
grep -F 'window = "address:0xa", action = "set", internal = 2, client = 2, layout_aware = false' "$test_tmp/restored" >/dev/null || fail "fullscreen state restores with the original handler"
grep -F 'window = "address:0xb", action = "set", internal = 1, client = 1, layout_aware = true' "$test_tmp/restored" >/dev/null || fail "maximized state restores with the layout handler"
grep -F 'window = "address:0xe", action = "set", internal = 2, client = 0' "$test_tmp/restored" >/dev/null || fail "independent client fullscreen state is preserved"
pass "fullscreen, maximized and independent client state restore by window address"
pass "normal, client-only, unchanged, closed, unmapped and reused windows are left alone"
[[ $(grep -c 'hl.dsp.focus(' "$test_tmp/calls") == "3" ]] || fail "restoration must not focus windows or switch workspaces"
pass "restoration does not steal focus"
[[ ! -f $test_tmp/pkill-collision ]] || fail "the polling process matched the screensaver kill pattern"
pass "the polling process cannot be killed by the screensaver's pkill pattern"
pass "unmapped screensavers do not delay restoration during their closing animation"

# A new cycle must acquire the lock even if no further compositor event arrives.
reset_state
OMARCHY_TEST_DISABLED=0 launch && fail "a disabled screensaver must not launch"
[[ $(<"$test_tmp/spawned") == "0" ]] || fail "disabled screensaver spawned a window"
pass "the event reader releases its lock and screensaver disabling still works"

# A busy compositor can miss a response without losing the session.
reset_state
launch force &
launch_pid=$!
wait_for_launch
printf '1\n' >"$test_tmp/query-misses"
close_screensaver 0xf1
close_screensaver 0xf2
wait "$launch_pid" || fail "a transient query failure loses the saved state"
launch_pid=""
[[ -s $test_tmp/restored ]] || fail "fullscreen was not restored after the query recovered"
pass "a transient compositor query failure retains the saved state"

# An interrupted or invalid jq result must not mean every screensaver closed.
reset_state
launch force &
launch_pid=$!
wait_for_launch
touch "$test_tmp/jq-failed"
printf 'closewindow>>unrelated\n' >&"$events_fd"
wait "$launch_pid" && fail "a failed jq query must not mean the screensaver closed"
launch_pid=""
[[ ! -s $test_tmp/restored ]] || fail "restoration followed a failed jq query"
pass "a failed jq query never restores while the screensaver is still mapped"

# The compositor failing to answer is not evidence the screensaver has closed.
reset_state
launch force &
launch_pid=$!
wait_for_launch
touch "$test_tmp/query-failed"
printf 'closewindow>>unrelated\n' >&"$events_fd"
wait "$launch_pid" && fail "a failed compositor query must not restore from stale state"
launch_pid=""
[[ ! -s $test_tmp/restored ]] || fail "restoration followed a failed compositor query"
pass "a failed compositor query never restores from stale state"
