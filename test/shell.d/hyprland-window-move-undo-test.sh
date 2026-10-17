#!/bin/bash

source "$(dirname "$0")/base-test.sh"

test_tmp=$(mktemp -d)
trap 'rm -rf "$test_tmp"' EXIT

mock_bin="$test_tmp/bin"
runtime_dir="$test_tmp/runtime"
hyprctl_log="$test_tmp/hyprctl.log"
mkdir -p "$mock_bin" "$runtime_dir"

cat >"$mock_bin/hyprctl" <<'SH'
#!/bin/bash

if [[ $1 == "activewindow" && $2 == "-j" ]]; then
  printf '{"address":"0xabc","workspace":{"id":3}}\n'
else
  printf '%s\n' "$*" >>"$HYPRCTL_LOG"
fi
SH
chmod +x "$mock_bin/hyprctl"

run_move_undo() {
  PATH="$mock_bin:$PATH" HYPRCTL_LOG="$hyprctl_log" XDG_RUNTIME_DIR="$runtime_dir" \
    "$ROOT/bin/omarchy-hyprland-window-move-undo" "$@"
}

state_file="$runtime_dir/omarchy-window-move-undo"

# Moving to a workspace remembers the window's address and origin, then
# dispatches a silent move so the active workspace never changes.
run_move_undo 5

grep -Fq 'dispatch hl.dsp.window.move({ window = "address:0xabc", workspace = "5", follow = false })' "$hyprctl_log" ||
  fail "moving to a workspace dispatches a silent move"

[[ -f $state_file ]] || fail "moving to a workspace records state for undo"
diff <(printf '0xabc\n3\n') "$state_file" >/dev/null || fail "state file records the window address and origin workspace"
pass "moving to a workspace dispatches a silent move and records undo state"

# Undo sends the same window back to its origin workspace and clears state.
>"$hyprctl_log"
run_move_undo undo

grep -Fq 'dispatch hl.dsp.window.move({ window = "address:0xabc", workspace = "3", follow = false })' "$hyprctl_log" ||
  fail "undo dispatches a silent move back to the origin workspace"

[[ ! -f $state_file ]] || fail "undo clears the recorded state"
pass "undo sends the window back to its origin workspace and clears state"

# Undo with nothing recorded is a no-op, not an error.
>"$hyprctl_log"
run_move_undo undo || fail "undo with no recorded move should not fail"
[[ ! -s $hyprctl_log ]] || fail "undo with no recorded move should not dispatch anything"
pass "undo with no recorded move is a no-op"
