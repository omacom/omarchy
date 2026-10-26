#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

test_tmp=$(mktemp -d)
trap 'rm -rf "$test_tmp"' EXIT

mock_bin="$test_tmp/bin"
mkdir -p "$mock_bin"

cat >"$mock_bin/hyprctl" <<'SH'
#!/bin/bash
if [[ $1 == "clients" ]]; then
  printf '%s\n' "$OMARCHY_TEST_CLIENTS_JSON"
elif [[ $1 == "dispatch" ]]; then
  printf '%s\n' "$2" >>"$OMARCHY_TEST_FOCUS_DISPATCH"
  [[ -z ${OMARCHY_TEST_DISPATCH_FAILS:-} ]]
fi
SH
chmod +x "$mock_bin/hyprctl"

dispatch_log="$test_tmp/dispatch"
clients_json='[{"address":"0xabc","class":"chromium"}]'
PATH="$mock_bin:$PATH" OMARCHY_TEST_CLIENTS_JSON="$clients_json" \
  OMARCHY_TEST_FOCUS_DISPATCH="$dispatch_log" \
  bash "$ROOT/bin/omarchy-hyprland-focus-app" '^chromium$'

grep -F 'hl.dsp.focus({ window = "address:0xabc" })' "$dispatch_log" >/dev/null || \
  fail "app focus uses the workspace-aware Hyprland dispatcher"

pass "app focus follows windows across workspaces"

rm -f "$dispatch_log"
clients_json='[
  {"address":"0xviber","class":"com.viber.Viber","initialClass":"com.viber.Viber","initialTitle":"Viber"},
  {"address":"0xagent","class":"org.omarchy.agent","initialClass":"org.omarchy.agent","initialTitle":"kitty"}
]'
PATH="$mock_bin:$PATH" OMARCHY_TEST_CLIENTS_JSON="$clients_json" \
  OMARCHY_TEST_FOCUS_DISPATCH="$dispatch_log" \
  bash "$ROOT/bin/omarchy-hyprland-focus-app" kitty

grep -F 'hl.dsp.focus({ window = "address:0xagent" })' "$dispatch_log" >/dev/null || \
  fail "app focus falls back to the initial window title"

pass "app focus finds terminals launched under a shared agent class"

clients_json='[
  {"address":"0xbrowser","class":"chromium","initialClass":"chromium","initialTitle":"Mail settings"}
]'
rm -f "$dispatch_log"
if PATH="$mock_bin:$PATH" OMARCHY_TEST_CLIENTS_JSON="$clients_json" \
  OMARCHY_TEST_FOCUS_DISPATCH="$dispatch_log" \
  bash "$ROOT/bin/omarchy-hyprland-focus-app" Mail; then
  fail "app focus rejects title matches from non-agent windows"
fi

[[ ! -e $dispatch_log ]] || fail "app focus leaves focus unchanged for unrelated title matches"

pass "app focus restricts title matching to agent terminals"

rm -f "$dispatch_log"
clients_json='[
  {"address":"0xolder","class":"chromium","focusHistoryID":4},
  {"address":"0xrecent","class":"chromium","focusHistoryID":1}
]'
PATH="$mock_bin:$PATH" OMARCHY_TEST_CLIENTS_JSON="$clients_json" \
  OMARCHY_TEST_FOCUS_DISPATCH="$dispatch_log" \
  bash "$ROOT/bin/omarchy-hyprland-focus-app" '^chromium$'

grep -F 'hl.dsp.focus({ window = "address:0xrecent" })' "$dispatch_log" >/dev/null || \
  fail "app focus picks the window focused last"

pass "app focus picks the window focused last among several"

# Focus alone leaves a floating window under the window it was behind, such as
# the app a link was clicked in, so the browser opening the link stays hidden.
rm -f "$dispatch_log"
clients_json='[{"address":"0xbrowser","class":"chromium","floating":true}]'
PATH="$mock_bin:$PATH" OMARCHY_TEST_CLIENTS_JSON="$clients_json" \
  OMARCHY_TEST_FOCUS_DISPATCH="$dispatch_log" \
  bash "$ROOT/bin/omarchy-hyprland-focus-app" '^chromium$'

[[ $(tail -n 1 "$dispatch_log") == 'hl.dsp.window.alter_zorder({ mode = "top", window = "address:0xbrowser" })' ]] || \
  fail "app focus raises a floating window above the windows over it" "$(cat "$dispatch_log")"

pass "app focus brings a floating window to the front"

# A window Hyprland would not focus, either way of asking, is a failure for the
# caller to see, as it was before floating windows were raised too.
rm -f "$dispatch_log"
clients_json='[{"address":"0xtiled","class":"chromium","floating":false}]'
if PATH="$mock_bin:$PATH" OMARCHY_TEST_CLIENTS_JSON="$clients_json" \
  OMARCHY_TEST_FOCUS_DISPATCH="$dispatch_log" OMARCHY_TEST_DISPATCH_FAILS=1 \
  bash "$ROOT/bin/omarchy-hyprland-focus-app" '^chromium$'; then
  fail "app focus reports success for a tiled window it could not focus"
fi

pass "app focus fails when Hyprland will not focus the window"
