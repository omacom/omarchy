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

cat >"$mock_bin/uwsm-app" <<'SH'
#!/bin/bash
printf '%s\n' "$*" >"$OMARCHY_TEST_LAUNCH_LOG"
SH
chmod +x "$mock_bin/uwsm-app"

# Keep desktop entry lookups away from the machine's real applications dirs.
share_dir="$test_tmp/share"
mkdir -p "$share_dir/applications"
export XDG_DATA_HOME="$share_dir" XDG_DATA_DIRS="$share_dir"

dispatch_log="$test_tmp/dispatch"
launch_log="$test_tmp/launch"
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

# Chat apps closed to their tray keep running and notifying with no window to
# focus. Their entries rarely share the notification's app name: Slack's is
# slack.desktop, Discord's Discord.desktop, Telegram's org.telegram.desktop —
# and a Slack webapp with the same display name must not win over native Slack.
apps="$share_dir/applications"
printf '[Desktop Entry]\nType=Application\nName=Slack\nExec=slack\nStartupWMClass=Slack\n' >"$apps/slack.desktop"
printf '[Desktop Entry]\nType=Application\nName=Slack\nExec=chromium --app=https://app.slack.com\nStartupWMClass=chrome-app.slack.com__-Default\n' >"$apps/Slack.desktop"
printf '[Desktop Entry]\nType=Application\nName=Discord\nExec=discord\n' >"$apps/Discord.desktop"
printf '[Desktop Entry]\nType=Application\nName=Telegram Desktop\nExec=telegram-desktop\n' >"$apps/org.telegram.desktop.desktop"

focus_windowless() {
  rm -f "$dispatch_log" "$launch_log"
  PATH="$mock_bin:$PATH" OMARCHY_TEST_CLIENTS_JSON='[]' \
    OMARCHY_TEST_FOCUS_DISPATCH="$dispatch_log" OMARCHY_TEST_LAUNCH_LOG="$launch_log" \
    bash "$ROOT/bin/omarchy-hyprland-focus-app" "$@"
}

launched() {
  grep -Fxq -- "-- gtk-launch $1" "$launch_log" 2>/dev/null
}

if focus_windowless Slack; then
  fail "app focus fails for windowless apps unless asked to launch them"
fi

[[ ! -e $launch_log ]] || fail "app focus never launches without --or-launch"

pass "app focus keeps focus-only semantics by default"

focus_windowless --or-launch Slack
launched slack.desktop || fail "app focus launches the entry declaring the missing window class"
[[ ! -e $dispatch_log ]] || fail "app focus does not dispatch a focus when there is no window"

pass "app focus launches windowless apps by the entry declaring their window class"

focus_windowless --or-launch discord
launched Discord.desktop || fail "app focus matches entry ids case-insensitively"

pass "app focus launches windowless apps by entry id"

focus_windowless --or-launch 'Telegram Desktop'
launched org.telegram.desktop.desktop || fail "app focus falls back to the entry's display name"

pass "app focus launches windowless apps by display name"

focus_windowless --or-launch --entry org.telegram.desktop Telegram
launched org.telegram.desktop.desktop || fail "app focus trusts the sender's desktop-entry hint"

focus_windowless --or-launch --entry org.telegram.desktop.desktop Nope
launched org.telegram.desktop.desktop || fail "app focus accepts a desktop-entry hint carrying its suffix"

pass "app focus launches the sender's own desktop entry when it names one"

if focus_windowless --or-launch Nope; then
  fail "app focus fails when there is neither a window nor a desktop entry"
fi

[[ ! -e $launch_log ]] || fail "app focus does not launch apps without a desktop entry"

pass "app focus reports apps it can neither focus nor launch"
