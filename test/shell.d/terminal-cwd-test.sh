#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

require_command jq
require_command pgrep
require_command script
require_command python3

resolver="$ROOT/bin/omarchy-cmd-terminal-cwd"

test_tmp=$(mktemp -d)
windows=()

cleanup() {
  local window

  for window in "${windows[@]}"; do
    pkill -P "$window" 2>/dev/null || true
    kill "$window" 2>/dev/null || true
  done

  rm -rf "$test_tmp"
}

trap cleanup EXIT

mock_bin="$test_tmp/bin"
fake_bin="$test_tmp/fake"
fallback_home="$test_tmp/home"
mkdir -p "$mock_bin" "$fake_bin" "$fallback_home"

# The window pid the resolver asks Hyprland for.
cat >"$mock_bin/hyprctl" <<'SH'
#!/bin/bash
[[ -n ${OMARCHY_TEST_WINDOW_PID:-} ]] && printf '\tpid: %s\n' "$OMARCHY_TEST_WINDOW_PID"
SH

# A tmux server answering for one client, plus a decoy client that must not be
# mistaken for it.
cat >"$mock_bin/tmux" <<'SH'
#!/bin/bash
printf '%s\n' "$*" >>"$OMARCHY_TEST_TMUX_LOG"
[[ -n ${OMARCHY_TEST_TMUX_PANE:-} ]] || exit 0
printf '1 %s\n' "$OMARCHY_TEST_TMUX_DECOY"
printf '%s %s\n' "$OMARCHY_TEST_TMUX_CLIENT" "$OMARCHY_TEST_TMUX_PANE"
SH

cat >"$mock_bin/herdr" <<'SH'
#!/bin/bash
printf '%s\n' "$*" >>"$OMARCHY_TEST_HERDR_LOG"
jq -n --arg unfocused "$OMARCHY_TEST_HERDR_DECOY" --arg focused "$OMARCHY_TEST_HERDR_PANE" \
  '{result: {panes: [{focused: false, cwd: $unfocused}, {focused: true, foreground_cwd: $focused, cwd: $unfocused}]}}'
SH

chmod +x "$mock_bin"/*

# Stands in for a shell or a multiplexer client: keeps the name the resolver
# matches on, without needing the real program.
fake_program() {
  cp /bin/bash "$fake_bin/$1"
}

cat >"$test_tmp/idle" <<'SH'
[[ -n ${OMARCHY_TEST_PIDFILE:-} ]] && echo $$ >"$OMARCHY_TEST_PIDFILE"
sleep 300 &
wait
SH

# A window whose descendants hold a controlling terminal, as a real terminal's do.
start_terminal_window() {
  setsid script -qec "$*" /dev/null >/dev/null 2>&1 &
  windows+=("$!")
  echo "$!"
}

# A window with no controlling terminal anywhere, as a GUI app has.
start_headless_window() {
  setsid "$@" >/dev/null 2>&1 &
  windows+=("$!")
  echo "$!"
}

wait_for_file() {
  local file=$1 attempt

  for attempt in {1..50}; do
    [[ -s $file ]] && return 0
    sleep 0.1
  done

  return 1
}

resolve() {
  env -i PATH="$mock_bin:$PATH" HOME="$fallback_home" XDG_RUNTIME_DIR="$test_tmp" \
    "$@" bash "$resolver"
}

# The deepest process in the terminal answers, even when its program is not
# listed in /etc/shells.
mkdir -p "$test_tmp/outer" "$test_tmp/inner"
fake_program nu
window=$(start_terminal_window "cd '$test_tmp/outer' && '$fake_bin/nu' -c \"cd '$test_tmp/inner'; sleep 300\"")
sleep 1
resolved=$(resolve OMARCHY_TEST_WINDOW_PID="$window")
[[ $resolved == "$test_tmp/inner" ]] ||
  fail "terminal cwd follows the deepest process in the terminal" "expected: $test_tmp/inner
actual:   $resolved"
pass "terminal cwd follows the deepest process in the terminal"

# A tmux client is not always a direct child of the window: the stock launcher
# runs `bash -c "tmux attach || tmux new"`.
mkdir -p "$test_tmp/launched" "$test_tmp/pane"
fake_program tmux
tmux_log="$test_tmp/tmux-log"
client_pidfile="$test_tmp/tmux-client.pid"
window=$(start_terminal_window "cd '$test_tmp/launched' && bash -c \"OMARCHY_TEST_PIDFILE='$client_pidfile' '$fake_bin/tmux' '$test_tmp/idle' -L probe attach\"")
wait_for_file "$client_pidfile" || fail "tmux client starts"
client_pid=$(<"$client_pidfile")

resolved=$(resolve OMARCHY_TEST_WINDOW_PID="$window" OMARCHY_TEST_TMUX_LOG="$tmux_log" \
  OMARCHY_TEST_TMUX_CLIENT="$client_pid" OMARCHY_TEST_TMUX_PANE="$test_tmp/pane" \
  OMARCHY_TEST_TMUX_DECOY="$test_tmp/launched")
[[ $resolved == "$test_tmp/pane" ]] ||
  fail "tmux answers with the focused pane, not the process tree" "expected: $test_tmp/pane
actual:   $resolved"
pass "tmux answers with the focused pane, not the process tree"

grep -Fq -- "-L probe" "$tmux_log" ||
  fail "tmux is queried on the client's own socket" "$(cat "$tmux_log")"
pass "tmux is queried on the client's own socket"

# A multiplexer that cannot answer must not hand back the client's own launch
# directory as if it were the pane's.
resolved=$(resolve OMARCHY_TEST_WINDOW_PID="$window" OMARCHY_TEST_TMUX_LOG="$tmux_log")
[[ $resolved == "$test_tmp/launched" ]] ||
  fail "a silent multiplexer falls back to the terminal, not the client" "expected: $test_tmp/launched
actual:   $resolved"
pass "a silent multiplexer falls back to the terminal, not the client"

# herdr keys its answer off the session named in the client's argv.
mkdir -p "$test_tmp/herdr-pane"
fake_program herdr
herdr_log="$test_tmp/herdr-log"
window=$(start_terminal_window "cd '$test_tmp/launched' && '$fake_bin/herdr' '$test_tmp/idle' --session work")
sleep 1
resolved=$(resolve OMARCHY_TEST_WINDOW_PID="$window" OMARCHY_TEST_HERDR_LOG="$herdr_log" \
  OMARCHY_TEST_HERDR_PANE="$test_tmp/herdr-pane" OMARCHY_TEST_HERDR_DECOY="$test_tmp/launched")
[[ $resolved == "$test_tmp/herdr-pane" ]] ||
  fail "herdr answers with the focused pane" "expected: $test_tmp/herdr-pane
actual:   $resolved"
pass "herdr answers with the focused pane"

grep -Fq -- "--session work" "$herdr_log" ||
  fail "herdr is queried for the client's own session" "$(cat "$herdr_log")"
pass "herdr is queried for the client's own session"

# A window that is not a terminal has no process attached to one.
mkdir -p "$test_tmp/gui"
window=$(start_headless_window bash -c "cd '$test_tmp/gui'; sleep 300")
sleep 1
resolved=$(resolve OMARCHY_TEST_WINDOW_PID="$window")
[[ $resolved == "$fallback_home" ]] ||
  fail "a window that is not a terminal falls back to home" "expected: $fallback_home
actual:   $resolved"
pass "a window that is not a terminal falls back to home"

# kitty answers over its own socket, before the process tree is walked.
mkdir -p "$test_tmp/kitty-pane"
cat >"$mock_bin/kitten" <<'SH'
#!/bin/bash
jq -n --arg cwd "$OMARCHY_TEST_KITTY_PANE" '[{tabs: [{windows: [{cwd: $cwd}]}]}]'
SH
chmod +x "$mock_bin/kitten"

window=$(start_terminal_window "cd '$test_tmp/launched' && sleep 300")
sleep 1
python3 -c 'import socket, sys; s = socket.socket(socket.AF_UNIX); s.bind(sys.argv[1])' \
  "$test_tmp/omarchy-kitty-$window"
resolved=$(resolve OMARCHY_TEST_WINDOW_PID="$window" OMARCHY_TEST_KITTY_PANE="$test_tmp/kitty-pane")
[[ $resolved == "$test_tmp/kitty-pane" ]] ||
  fail "kitty answers over its remote control socket" "expected: $test_tmp/kitty-pane
actual:   $resolved"
pass "kitty answers over its remote control socket"

# No focused window at all.
resolved=$(resolve)
[[ $resolved == "$fallback_home" ]] ||
  fail "no active window falls back to home" "expected: $fallback_home
actual:   $resolved"
pass "no active window falls back to home"
