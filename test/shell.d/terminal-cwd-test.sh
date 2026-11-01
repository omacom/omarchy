#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

test_tmp=$(mktemp -d)
stub_bin="$test_tmp/bin"
work_dir="$test_tmp/project dir"
downloads_dir="$test_tmp/Downloads"
mkdir -p "$stub_bin" "$work_dir" "$downloads_dir"

# A stand-in terminal: script puts its shell on a pty in a session of its own,
# as a terminal does. The trailing ":" keeps bash from exec'ing sleep.
(cd "$work_dir" && SHELL=/bin/bash exec script -qec "sleep 30; :" /dev/null) </dev/null >/dev/null 2>&1 &
terminal_pid=$!

# A stand-in browser whose newest child is a helper shell in Downloads, with no
# pty or session of its own.
bash -c '(cd "$1" && bash -c "sleep 30; :") & wait' _ "$downloads_dir" &
browser_pid=$!

# The same browser started from a terminal's shell: it and its helper share that
# shell's pty, but only the browser leads a session.
(cd "$test_tmp" && DIR="$downloads_dir" SHELL=/bin/bash exec script -qec '(cd "$DIR" && bash -c "sleep 30; :") & wait' /dev/null) </dev/null >/dev/null 2>&1 &
pty_script_pid=$!

# Children first: killing a parent reparents its children out of reach.
kill_tree() {
  local child
  for child in $(cat /proc/"$1"/task/*/children 2>/dev/null); do
    kill_tree "$child"
  done
  kill "$1" 2>/dev/null || true
}
trap 'kill_tree "$terminal_pid"; kill_tree "$browser_pid"; kill_tree "$pty_script_pid"; wait 2>/dev/null || true; rm -rf "$test_tmp"' EXIT

# Ready once each newest child has exec'd bash in its directory: script's child
# takes its session and pty before the exec, so a ready terminal shell has both.
wait_for_shell() {
  local child
  for _ in $(seq 100); do
    child=$(cat /proc/"$1"/task/*/children 2>/dev/null | tr ' ' '\n' | sort -n | tail -n1)
    if [[ -n $child && $(readlink /proc/"$child"/exe 2>/dev/null) == */bash && $(readlink -f /proc/"$child"/cwd 2>/dev/null) == "$2" ]]; then
      ready_shell=$child
      return
    fi
    sleep 0.05
  done
  fail "the stand-in shell starts in $2"
}
wait_for_shell "$terminal_pid" "$work_dir"
wait_for_shell "$browser_pid" "$downloads_dir"
wait_for_shell "$pty_script_pid" "$test_tmp"
pty_browser_pid=$ready_shell
wait_for_shell "$pty_browser_pid" "$downloads_dir"

cat >"$stub_bin/hyprctl" <<'SH'
#!/bin/bash
[[ -n ${ACTIVE_PID:-} ]] && printf 'Window 1 -> terminal:\n\tpid: %s\n' "$ACTIVE_PID"
exit 0
SH
chmod +x "$stub_bin/hyprctl"

cwd=$(ACTIVE_PID="$terminal_pid" PATH="$stub_bin:$PATH" XDG_RUNTIME_DIR="$test_tmp" "$ROOT/bin/omarchy-cmd-terminal-cwd")
[[ $cwd == "$work_dir" ]] || fail "a new terminal opens in the focused terminal's shell directory" "got: $cwd"
pass "a new terminal opens in the focused terminal's shell directory"

output=$(PATH="$stub_bin:$PATH" XDG_RUNTIME_DIR="$test_tmp" HOME="$test_tmp" "$ROOT/bin/omarchy-cmd-terminal-cwd" 2>&1)
[[ $output == "$test_tmp" ]] || fail "with no focused terminal the new one opens in HOME" "got: $output"
pass "with no focused terminal the new one opens in HOME, quietly"

# The Super+Return binding hands over the focused window's pid, so Hyprland is
# not asked again; a hyprctl that fails the test proves it goes unasked.
cat >"$stub_bin/hyprctl" <<'SH'
#!/bin/bash
echo "hyprctl was asked for the active window" >&2
exit 1
SH

cwd=$(PATH="$stub_bin:$PATH" XDG_RUNTIME_DIR="$test_tmp" "$ROOT/bin/omarchy-cmd-terminal-cwd" "$terminal_pid" 2>&1)
[[ $cwd == "$work_dir" ]] || fail "a terminal pid passed in finds its shell directory without hyprctl" "got: $cwd"
pass "a terminal pid passed in finds its shell directory without hyprctl"

cwd=$(PATH="$stub_bin:$PATH" XDG_RUNTIME_DIR="$test_tmp" HOME="$test_tmp" "$ROOT/bin/omarchy-cmd-terminal-cwd" "$browser_pid" 2>&1)
[[ $cwd == "$test_tmp" ]] || fail "a focused app that is not a terminal opens a new terminal in HOME, not its helper shell's directory" "got: $cwd"
pass "a focused app that is not a terminal opens a new terminal in HOME, not its helper shell's directory"

cwd=$(PATH="$stub_bin:$PATH" XDG_RUNTIME_DIR="$test_tmp" HOME="$test_tmp" "$ROOT/bin/omarchy-cmd-terminal-cwd" "$pty_browser_pid" 2>&1)
[[ $cwd == "$test_tmp" ]] || fail "an app started from a terminal, sharing its pty, still opens a new terminal in HOME" "got: $cwd"
pass "an app started from a terminal, sharing its pty, still opens a new terminal in HOME"
