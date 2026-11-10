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

cat >"$mock_bin/busctl" <<'SH2'
#!/bin/bash
[[ $1 == "--user" && $2 == "status" && $3 == "org.mpris.MediaPlayer2.brave.instance42" ]] && echo "PID=42"
SH2
chmod +x "$mock_bin/busctl"

# A browser owns every one of its windows under one PID; the playing tab's
# window carries the track in its title even when another was focused later.
clients_json='[
  {"address":"0xother","pid":7,"title":"Mr. Crowley","focusHistoryID":0},
  {"address":"0xmail","pid":42,"title":"Inbox - Mail","focusHistoryID":1},
  {"address":"0xmusic","pid":42,"title":"Mr. Crowley - Apple Music","focusHistoryID":3}
]'
PATH="$mock_bin:$PATH" OMARCHY_TEST_CLIENTS_JSON="$clients_json" \
  OMARCHY_TEST_FOCUS_DISPATCH="$dispatch_log" \
  bash "$ROOT/bin/omarchy-hyprland-focus-player" org.mpris.MediaPlayer2.brave.instance42 "mr. crowley"

grep -F 'hl.dsp.focus({ window = "address:0xmusic" })' "$dispatch_log" >/dev/null || \
  fail "player focus picks the player's window showing the track"

PATH="$mock_bin:$PATH" OMARCHY_TEST_CLIENTS_JSON="$clients_json" \
  OMARCHY_TEST_FOCUS_DISPATCH="$dispatch_log" \
  bash "$ROOT/bin/omarchy-hyprland-focus-player" org.mpris.MediaPlayer2.brave.instance42 "Unlisted song"

grep -F 'hl.dsp.focus({ window = "address:0xmail" })' "$dispatch_log" >/dev/null || \
  fail "player focus falls back to the player's window focused last"

pass "player focus finds the playing window among a browser's windows"
