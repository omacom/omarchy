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
  if [[ $2 == "focuswindow" ]]; then
    exit "${OMARCHY_TEST_FALLBACK_EXIT:-0}"
  else
    exit "${OMARCHY_TEST_DISPATCH_EXIT:-0}"
  fi
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

clients_json='[
  {"address":"0x561019ece4c0","class":"kitty","initialClass":"kitty","initialTitle":"kitty"},
  {"address":"0x561019ece480","class":"kitty","initialClass":"kitty","initialTitle":"kitty"}
]'
rm -f "$dispatch_log"
PATH="$mock_bin:$PATH" OMARCHY_TEST_CLIENTS_JSON="$clients_json" \
  OMARCHY_TEST_FOCUS_DISPATCH="$dispatch_log" \
  bash "$ROOT/bin/omarchy-hyprland-focus-app" 'address:0x561019ece480'

grep -F 'hl.dsp.focus({ window = "address:0x561019ece480" })' "$dispatch_log" >/dev/null || \
  fail "app focus by address dispatches that window"

pass "app focus by address targets that window and no other"

rm -f "$dispatch_log"
if PATH="$mock_bin:$PATH" OMARCHY_TEST_CLIENTS_JSON="$clients_json" \
  OMARCHY_TEST_FOCUS_DISPATCH="$dispatch_log" \
  bash "$ROOT/bin/omarchy-hyprland-focus-app" 'address:0xdead'; then
  fail "app focus by address accepts a window that is not open"
fi

[[ ! -e $dispatch_log ]] || fail "app focus by address leaves focus unchanged when the window is gone"

pass "app focus by address refuses a stale window"

rm -f "$dispatch_log"
PATH="$mock_bin:$PATH" OMARCHY_TEST_CLIENTS_JSON="$clients_json" \
  OMARCHY_TEST_FOCUS_DISPATCH="$dispatch_log" OMARCHY_TEST_DISPATCH_EXIT=6 \
  bash "$ROOT/bin/omarchy-hyprland-focus-app" 'address:0x561019ece480'

grep -Fx 'focuswindow' "$dispatch_log" >/dev/null || \
  fail "app focus by address tries the fallback after a failed primary dispatch"

pass "app focus by address succeeds when its fallback succeeds"

for app in 'address:0x561019ece480' kitty; do
  if PATH="$mock_bin:$PATH" OMARCHY_TEST_CLIENTS_JSON="$clients_json" \
    OMARCHY_TEST_FOCUS_DISPATCH="$dispatch_log" OMARCHY_TEST_DISPATCH_EXIT=6 \
    OMARCHY_TEST_FALLBACK_EXIT=7 \
    bash "$ROOT/bin/omarchy-hyprland-focus-app" "$app"; then
    fail "app focus reports success when both dispatches fail: $app"
  else
    focus_status=$?
  fi
  (( focus_status == 7 )) || fail "app focus returns the fallback failure: $app"
done

pass "app focus propagates dispatch failures for address and identity callers"
