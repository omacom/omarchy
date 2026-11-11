#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

test_tmp=$(mktemp -d)
trap 'rm -rf "$test_tmp"' EXIT

mock_bin="$test_tmp/bin"
mkdir -p "$mock_bin"

cat >"$mock_bin/hyprctl" <<'SH'
#!/bin/bash
case ${1:-} in
  clients) printf '%s\n' "$OMARCHY_TEST_CLIENTS_JSON" ;;
  monitors) printf '%s\n' "${OMARCHY_TEST_MONITORS_JSON:-[]}" ;;
  dispatch)
    printf '%s\n' "${*:2}" >>"$OMARCHY_TEST_FOCUS_DISPATCH"
    if [[ -n ${OMARCHY_TEST_LUA_DISPATCH_FAILS:-} && $2 == "hl.dsp."* ]]; then
      exit 1
    fi
    ;;
esac
SH
chmod +x "$mock_bin/hyprctl"

dispatch_log="$test_tmp/dispatch"
clients_json='[{"address":"0xabc","class":"chromium"}]'
PATH="$mock_bin:$ROOT/bin:$PATH" OMARCHY_TEST_CLIENTS_JSON="$clients_json" \
  OMARCHY_TEST_FOCUS_DISPATCH="$dispatch_log" \
  bash "$ROOT/bin/omarchy-hyprland-focus-app" '^chromium$'

grep -F 'hl.dsp.focus({ window = "address:0xabc" })' "$dispatch_log" >/dev/null || \
  fail "app focus uses the workspace-aware Hyprland dispatcher"

pass "app focus follows windows across workspaces"

# A window focus alone only applies on the focused monitor, so a window parked
# on another one stayed where it was.
clients_json='[
  {"address":"0xremote","class":"chromium","monitor":2,"workspace":{"id":12,"name":"12"}}
]'
monitors_json='[
  {"id":0,"name":"eDP-1","focused":true},
  {"id":2,"name":"DP-6","focused":false}
]'
rm -f "$dispatch_log"
PATH="$mock_bin:$ROOT/bin:$PATH" OMARCHY_TEST_CLIENTS_JSON="$clients_json" \
  OMARCHY_TEST_MONITORS_JSON="$monitors_json" \
  OMARCHY_TEST_FOCUS_DISPATCH="$dispatch_log" \
  bash "$ROOT/bin/omarchy-hyprland-focus-app" '^chromium$'

expected_dispatches='hl.dsp.focus({ monitor = "DP-6" })
hl.dsp.focus({ workspace = "12" })
hl.dsp.focus({ window = "address:0xremote" })'
actual_dispatches=$(cat "$dispatch_log")
[[ $actual_dispatches == "$expected_dispatches" ]] || \
  fail "app focus switches to the window's monitor and workspace first" "expected:
$expected_dispatches
actual:
$actual_dispatches"

pass "app focus reaches a window on another monitor"

# Hyprland before 0.5 has no Lua dispatcher to fail into.
clients_json='[{"address":"0xlegacy","class":"chromium"}]'
rm -f "$dispatch_log"
PATH="$mock_bin:$ROOT/bin:$PATH" OMARCHY_TEST_CLIENTS_JSON="$clients_json" \
  OMARCHY_TEST_LUA_DISPATCH_FAILS=1 \
  OMARCHY_TEST_FOCUS_DISPATCH="$dispatch_log" \
  bash "$ROOT/bin/omarchy-hyprland-focus-app" '^chromium$'

grep -Fx 'focuswindow address:0xlegacy' "$dispatch_log" >/dev/null || \
  fail "app focus falls back to the plain dispatcher when the Lua one fails"

pass "app focus still works on a Hyprland without the Lua dispatcher"

clients_json='[
  {"address":"0xviber","class":"com.viber.Viber","initialClass":"com.viber.Viber","initialTitle":"Viber"},
  {"address":"0xagent","class":"org.omarchy.agent","initialClass":"org.omarchy.agent","initialTitle":"kitty"}
]'
PATH="$mock_bin:$ROOT/bin:$PATH" OMARCHY_TEST_CLIENTS_JSON="$clients_json" \
  OMARCHY_TEST_FOCUS_DISPATCH="$dispatch_log" \
  bash "$ROOT/bin/omarchy-hyprland-focus-app" kitty

grep -F 'hl.dsp.focus({ window = "address:0xagent" })' "$dispatch_log" >/dev/null || \
  fail "app focus falls back to the initial window title"

pass "app focus finds terminals launched under a shared agent class"

clients_json='[
  {"address":"0xbrowser","class":"chromium","initialClass":"chromium","initialTitle":"Mail settings"}
]'
rm -f "$dispatch_log"
if PATH="$mock_bin:$ROOT/bin:$PATH" OMARCHY_TEST_CLIENTS_JSON="$clients_json" \
  OMARCHY_TEST_FOCUS_DISPATCH="$dispatch_log" \
  bash "$ROOT/bin/omarchy-hyprland-focus-app" Mail; then
  fail "app focus rejects title matches from non-agent windows"
fi

[[ ! -e $dispatch_log ]] || fail "app focus leaves focus unchanged for unrelated title matches"

pass "app focus restricts title matching to agent terminals"

clients_json='[
  {"address":"0xolder","class":"chromium","focusHistoryID":4},
  {"address":"0xrecent","class":"chromium","focusHistoryID":1}
]'
PATH="$mock_bin:$ROOT/bin:$PATH" OMARCHY_TEST_CLIENTS_JSON="$clients_json" \
  OMARCHY_TEST_FOCUS_DISPATCH="$dispatch_log" \
  bash "$ROOT/bin/omarchy-hyprland-focus-app" '^chromium$'

grep -F 'hl.dsp.focus({ window = "address:0xrecent" })' "$dispatch_log" >/dev/null || \
  fail "app focus picks the window focused last"

pass "app focus picks the window focused last among several"
