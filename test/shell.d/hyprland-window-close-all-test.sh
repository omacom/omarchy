#!/bin/bash

source "$(dirname "$0")/base-test.sh"

test_tmp=$(mktemp -d)
trap 'rm -rf "$test_tmp"' EXIT

mock_bin="$test_tmp/bin"
hyprctl_log="$test_tmp/hyprctl.log"
mkdir -p "$mock_bin"

cat >"$mock_bin/hyprctl" <<'SH'
#!/bin/bash

if [[ $1 == "clients" ]]; then
  default_clients='[{"address":"0xabc"},{"address":"0xdef"}]'
  printf '%s\n' "${TEST_CLIENTS:-$default_clients}"
else
  printf '%s\n' "$*" >>"$HYPRCTL_LOG"
fi
SH
chmod +x "$mock_bin/hyprctl"

PATH="$mock_bin:$PATH" HYPRCTL_LOG="$hyprctl_log" "$ROOT/bin/omarchy-hyprland-window-close-all"

expected_log="$test_tmp/expected.log"
cat >"$expected_log" <<'EOF'
dispatch hl.dsp.window.close({ window = "address:0xabc" })
dispatch hl.dsp.window.close({ window = "address:0xdef" })
dispatch o.workspaces.focus(1)
EOF

diff -u "$expected_log" "$hyprctl_log" || fail "close-all targets each window with the Lua dispatcher"
pass "close-all targets each window with the Lua dispatcher"

export PATH="$mock_bin:$PATH" HYPRCTL_LOG="$hyprctl_log"
sleep 0.2 &
first_pid=$!
sleep 0.4 &
second_pid=$!
export TEST_CLIENTS="[{\"address\":\"0xabc\",\"pid\":$first_pid},{\"address\":\"0xdef\",\"pid\":$second_pid},{\"address\":\"0x123\",\"pid\":$first_pid}]"
timeout 1s "$ROOT/bin/omarchy-hyprland-window-close-all" --wait || fail "waiting succeeds"
! kill -0 "$first_pid" 2>/dev/null || fail "wait includes first application"
! kill -0 "$second_pid" 2>/dev/null || fail "wait includes last application"
pass "wait follows application exits, including multiple windows from one process"

# A desktop without clients must not start an unfiltered process wait.
TEST_CLIENTS='[]' timeout 1s "$ROOT/bin/omarchy-hyprland-window-close-all" --wait || fail "empty desktop exits immediately"
pass "empty desktop exits immediately"

TEST_CLIENTS="[{\"address\":\"0xabc\",\"pid\":$first_pid},{\"address\":\"0xdef\",\"pid\":0},{\"address\":\"0x123\"}]" timeout 1s "$ROOT/bin/omarchy-hyprland-window-close-all" --wait || fail "already exited and missing PIDs succeed"
pass "already exited and missing PIDs succeed"
