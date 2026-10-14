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
  printf '%s\n' "$2" >"$OMARCHY_TEST_FOCUS_DISPATCH"
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

focus_app() {
  rm -f "$dispatch_log"
  PATH="$mock_bin:$PATH" OMARCHY_TEST_CLIENTS_JSON="$clients_json" \
    OMARCHY_TEST_FOCUS_DISPATCH="$dispatch_log" \
    bash "$ROOT/bin/omarchy-hyprland-focus-app" "$@"
}

focused() {
  grep -F "hl.dsp.focus({ window = \"address:$1\" })" "$dispatch_log" >/dev/null 2>&1
}

clients_json='[
  {"address":"0xbeta","class":"org.telegram.desktop.beta"},
  {"address":"0xtelegram","class":"org.telegram.desktop"}
]'
focus_app "Telegram Desktop"
focused 0xtelegram || fail "app focus matches an app name to the tail of a reverse-DNS class"
pass "app focus matches an app name to the tail of a reverse-DNS class"

focus_app "" org.telegram.desktop
focused 0xtelegram || fail "app focus matches the desktop entry to the whole class"
pass "app focus matches the desktop entry to the whole class"

clients_json='[
  {"address":"0xbrowser","class":"chromium"},
  {"address":"0xwebapp","class":"chrome-web.whatsapp.com__-Default"}
]'
focus_app Chromium chrome-web.whatsapp.com__-Default
focused 0xwebapp || fail "app focus prefers the desktop entry over the app name"
pass "app focus prefers the desktop entry over the app name"

clients_json='[{"address":"0xgroup","class":"org.example.groupchat"}]'
if focus_app "Example Chat" || focus_app "_-"; then
  fail "app focus needs whole words of the class to match the app name"
fi
pass "app focus needs whole words of the class to match the app name"

clients_json='[
  {"address":"0xfirst","class":"org.telegram.desktop"},
  {"address":"0xsecond","class":"org.telegram.desktop"},
  {"address":"0xother","class":"foot"}
]'
focus_app --address 0xsecond "Telegram Desktop" org.telegram.desktop
focused 0xsecond || fail "app focus by address focuses that window"
pass "app focus by address focuses that window"

if focus_app --address 0xother "Telegram Desktop" org.telegram.desktop; then
  fail "app focus by address rejects a window of another app"
fi
pass "app focus by address rejects a window of another app"
