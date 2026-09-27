#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

test_tmp=$(mktemp -d)
stub_bin="$test_tmp/bin"
work_dir="$test_tmp/project dir"
mkdir -p "$stub_bin" "$work_dir"

# A stand-in terminal whose newest child is a shell sitting in work_dir. The
# trailing ":" keeps bash from exec'ing sleep, so the child stays a shell.
bash -c '(cd "$1" && bash -c "sleep 30; :") & wait' _ "$work_dir" &
terminal_pid=$!

# Children first: killing a parent reparents its children out of reach.
kill_tree() {
  local child
  for child in $(cat /proc/"$1"/task/*/children 2>/dev/null); do
    kill_tree "$child"
  done
  kill "$1" 2>/dev/null || true
}
trap 'kill_tree "$terminal_pid"; wait "$terminal_pid" 2>/dev/null || true; rm -rf "$test_tmp"' EXIT

for _ in $(seq 50); do
  [[ -n $(cat /proc/"$terminal_pid"/task/*/children 2>/dev/null) ]] && break
  sleep 0.05
done

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
