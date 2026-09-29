#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

require_command jq

test_tmp=$(mktemp -d)
stub_bin="$test_tmp/bin"
test_home="$test_tmp/home"
work_dir="$test_tmp/project dir"
active_window="$test_tmp/active-window.json"
mkdir -p "$stub_bin" "$test_home" "$work_dir"

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
if [[ ${1:-} == -j && ${2:-} == activewindow ]]; then
  cat "$OMARCHY_TEST_ACTIVE_WINDOW"
  exit 0
fi
exit 1
SH
chmod +x "$stub_bin/hyprctl"

run_cwd() {
  HOME="$test_home" \
    XDG_RUNTIME_DIR="$test_tmp" \
    PATH="$stub_bin:$PATH" \
    OMARCHY_TEST_ACTIVE_WINDOW="$active_window" \
    "$ROOT/bin/omarchy-cmd-terminal-cwd" "$@"
}

printf '{"pid":%s,"class":"kitty","tags":["terminal*"]}\n' "$terminal_pid" >"$active_window"
cwd=$(run_cwd)
[[ $cwd == "$work_dir" ]] ||
  fail "a dynamically tagged terminal inherits its shell directory" "got: $cwd"
pass "a dynamically tagged terminal inherits its shell directory"

printf '{"pid":%s,"class":"kitty","tags":["terminal"]}\n' "$terminal_pid" >"$active_window"
cwd=$(run_cwd)
[[ $cwd == "$work_dir" ]] ||
  fail "a tagged terminal inherits its shell directory" "got: $cwd"
pass "a tagged terminal inherits its shell directory"

# A non-terminal app may own a helper shell. That shell must not make a new
# terminal inherit the app's working directory.
printf '{"pid":%s,"class":"microsoft-edge","tags":[]}\n' "$terminal_pid" >"$active_window"
cwd=$(run_cwd)
[[ $cwd == "$test_home" ]] ||
  fail "a non-terminal focused window falls back to HOME" "got: $cwd"
pass "a non-terminal focused window does not leak a helper shell cwd"

printf '{"pid":%s,"class":"org.wezfurlong.wezterm","tags":[]}\n' "$terminal_pid" >"$active_window"
cwd=$(run_cwd)
[[ $cwd == "$work_dir" ]] ||
  fail "WezTerm's canonical app-id keeps cwd inheritance" "got: $cwd"
pass "WezTerm's canonical app-id keeps cwd inheritance"

printf '{}\n' >"$active_window"
cwd=$(run_cwd)
[[ $cwd == "$test_home" ]] ||
  fail "with no focused terminal the new one opens in HOME" "got: $cwd"
pass "with no focused terminal the new one opens in HOME, quietly"

# The Super+Return binding hands over the focused terminal's pid, so the cwd
# helper must preserve upstream's no-extra-Hyprland-query fast path.
cat >"$stub_bin/hyprctl" <<'SH'
#!/bin/bash
echo "hyprctl was asked for the active window" >&2
exit 1
SH
chmod +x "$stub_bin/hyprctl"

cwd=$(run_cwd "$terminal_pid" 2>&1)
[[ $cwd == "$work_dir" ]] ||
  fail "a terminal pid passed in finds its shell directory without hyprctl" "got: $cwd"
pass "a terminal pid passed in finds its shell directory without hyprctl"
