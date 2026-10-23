#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

test_tmp=$(mktemp -d)
trap 'rm -rf "$test_tmp"' EXIT

mock_bin="$test_tmp/bin"
test_home="$test_tmp/home"
mkdir -p "$mock_bin" "$test_home/.local/share/applications"
# Keep the launcher away from the running browser's singleton socket, which it
# would otherwise hand these test URLs to.
export XDG_CONFIG_HOME="$test_home/.config" XDG_DATA_HOME="$test_home/.local/share"

cat >"$test_home/.local/share/applications/chromium.desktop" <<'EOF'
[Desktop Entry]
Exec=chromium %U
EOF

cat >"$mock_bin/xdg-settings" <<'SH'
#!/bin/bash
[[ -z ${BROWSER:-} ]] || printf '%s\n' "$BROWSER" >"$OMARCHY_TEST_XDG_SETTINGS_BROWSER"
[[ ${OMARCHY_TEST_XDG_SETTINGS_EMPTY:-0} == "1" ]] || echo chromium.desktop
SH
cat >"$mock_bin/xdg-mime" <<'SH'
#!/bin/bash
if [[ $* == "query default x-scheme-handler/https" ]]; then
  echo chromium.desktop
fi
SH
cat >"$mock_bin/chromium" <<'SH'
#!/bin/bash
exit 0
SH
cat >"$mock_bin/systemd-run" <<'SH'
#!/bin/bash
printf '%s\n' "$*" >"$OMARCHY_TEST_BROWSER_LAUNCH"
SH
cat >"$mock_bin/omarchy-hyprland-focus-app" <<'SH'
#!/bin/bash
printf '%s\n' "$1" >"$OMARCHY_TEST_BROWSER_FOCUS"
SH
chmod +x "$mock_bin"/*
ln -s "$ROOT/bin/omarchy-cmd-default-browser" "$mock_bin/omarchy-cmd-default-browser"

launch_log="$test_tmp/launch"
focus_log="$test_tmp/focus"
xdg_settings_browser="$test_tmp/xdg-settings-browser"
HOME="$test_home" PATH="$mock_bin:$PATH" HYPRLAND_INSTANCE_SIGNATURE=test \
  OMARCHY_TEST_BROWSER_LAUNCH="$launch_log" OMARCHY_TEST_BROWSER_FOCUS="$focus_log" \
  bash "$ROOT/bin/omarchy-launch-browser"

[[ ! -e $focus_log ]] || fail "browser launcher leaves a new window on the current workspace"

HOME="$test_home" PATH="$mock_bin:$PATH" HYPRLAND_INSTANCE_SIGNATURE=test \
  OMARCHY_TEST_BROWSER_LAUNCH="$launch_log" OMARCHY_TEST_BROWSER_FOCUS="$focus_log" \
  bash "$ROOT/bin/omarchy-launch-browser" --private

[[ ! -e $focus_log ]] || fail "private browser launcher leaves a new window on the current workspace"

HOME="$test_home" PATH="$mock_bin:$PATH" HYPRLAND_INSTANCE_SIGNATURE=test \
  OMARCHY_TEST_BROWSER_LAUNCH="$launch_log" OMARCHY_TEST_BROWSER_FOCUS="$focus_log" \
  bash "$ROOT/bin/omarchy-launch-browser" "https://example.test/authorize"

grep -F 'https://example.test/authorize' "$launch_log" >/dev/null || fail "browser launcher passes through the URL"
grep -Fx '^chromium.*$' "$focus_log" >/dev/null || fail "browser launcher focuses the default browser window"

rm -f "$focus_log" "$xdg_settings_browser"

HOME="$test_home" PATH="$mock_bin:$PATH" HYPRLAND_INSTANCE_SIGNATURE=test \
  BROWSER=omarchy-launch-browser OMARCHY_TEST_XDG_SETTINGS_EMPTY=1 \
  OMARCHY_TEST_BROWSER_LAUNCH="$launch_log" OMARCHY_TEST_BROWSER_FOCUS="$focus_log" \
  OMARCHY_TEST_XDG_SETTINGS_BROWSER="$xdg_settings_browser" \
  bash "$ROOT/bin/omarchy-launch-browser" "https://example.test/fallback"

grep -F 'https://example.test/fallback' "$launch_log" >/dev/null ||
  fail "browser launcher falls back to the HTTPS handler when xdg-settings is empty"
[[ ! -e $xdg_settings_browser ]] ||
  fail "browser launcher unsets BROWSER before reading xdg-settings"
grep -Fx '^chromium.*$' "$focus_log" >/dev/null ||
  fail "browser launcher focuses the browser resolved from the HTTPS handler"

pass "browser launcher follows opened links to the browser workspace"

rm -f "$launch_log"
cat >"$mock_bin/omarchy-cmd-browser-handoff" <<'SH'
#!/bin/bash
[[ $1 == "chromium" && $2 == "https://example.test/running" ]]
SH
chmod +x "$mock_bin/omarchy-cmd-browser-handoff"

HOME="$test_home" PATH="$mock_bin:$PATH" OMARCHY_TEST_BROWSER_LAUNCH="$launch_log" \
  OMARCHY_TEST_BROWSER_FOCUS="$focus_log" bash "$ROOT/bin/omarchy-launch-browser" "https://example.test/running"

[[ ! -e $launch_log ]] || fail "browser launcher starts no browser when the running one takes the URL"
pass "browser launcher hands a URL to the running browser"

rm -f "$mock_bin/omarchy-cmd-browser-handoff" "$launch_log"
help_log="$test_tmp/help"
cat >"$mock_bin/chromium" <<'SH'
#!/bin/bash
[[ $1 != "--help" ]] || printf 'probed\n' >>"$OMARCHY_TEST_BROWSER_HELP"
SH
chmod +x "$mock_bin/chromium"
launch() {
  HOME="$test_home" PATH="$mock_bin:$PATH" OMARCHY_TEST_BROWSER_LAUNCH="$launch_log" \
    OMARCHY_TEST_BROWSER_FOCUS="$focus_log" OMARCHY_TEST_BROWSER_HELP="$help_log" \
    bash "$ROOT/bin/omarchy-launch-browser" "$@"
}

launch "https://example.test/a--private-b"
[[ ! -e $help_log ]] || fail "an ordinary launch doesn't probe the browser's flags"
grep -F 'https://example.test/a--private-b' "$launch_log" >/dev/null || fail "an ordinary launch leaves its arguments alone"
pass "an ordinary launch doesn't probe the browser's flags"

launch --private
[[ -s $help_log ]] || fail "a private launch probes the browser's private flag"
grep -F -- 'chromium --incognito' "$launch_log" >/dev/null || fail "a private launch passes the browser's private flag"
pass "a private launch passes the browser's private flag"

spaced_desktop="userapp-Firefox Developer Edition-U5J9W3.desktop"
cat >"$test_home/.local/share/applications/$spaced_desktop" <<'EOF'
[Desktop Entry]
Exec=chromium %u
EOF
rm -f "$mock_bin/omarchy-cmd-default-browser"
cat >"$mock_bin/omarchy-cmd-default-browser" <<EOF
#!/bin/bash
printf '%s\n' '$spaced_desktop'
EOF
cat >"$mock_bin/omarchy-notification-send" <<'SH'
#!/bin/bash
printf '%s\n' "$*" >"$OMARCHY_TEST_BROWSER_NOTIFY"
SH
chmod +x "$mock_bin/omarchy-cmd-default-browser" "$mock_bin/omarchy-notification-send"
rm -f "$launch_log"
notify_log="$test_tmp/notify"
HOME="$test_home" PATH="$mock_bin:$PATH" OMARCHY_TEST_BROWSER_LAUNCH="$launch_log" \
  OMARCHY_TEST_BROWSER_FOCUS="$focus_log" OMARCHY_TEST_BROWSER_NOTIFY="$notify_log" \
  bash "$ROOT/bin/omarchy-launch-browser" "https://example.test/spaced"
[[ ! -e $notify_log ]] || fail "a desktop id with spaces still resolves to a browser command"
grep -F 'https://example.test/spaced' "$launch_log" >/dev/null || fail "a desktop id with spaces still opens the URL"
grep -F -- '-- chromium' "$launch_log" >/dev/null || fail "a desktop id with spaces launches the desktop entry's command"
pass "a desktop id with spaces still launches the browser"

missing_desktop="missing browser.desktop"
rm -f "$mock_bin/omarchy-cmd-default-browser"
cat >"$mock_bin/omarchy-cmd-default-browser" <<EOF
#!/bin/bash
printf '%s\n' '$missing_desktop'
EOF
chmod +x "$mock_bin/omarchy-cmd-default-browser"
rm -f "$launch_log" "$notify_log"
missing_status=0
HOME="$test_home" PATH="$mock_bin:$ROOT/bin:$PATH" OMARCHY_PATH="$ROOT" \
  OMARCHY_TEST_BROWSER_LAUNCH="$launch_log" OMARCHY_TEST_BROWSER_FOCUS="$focus_log" \
  OMARCHY_TEST_BROWSER_NOTIFY="$notify_log" \
  bash "$ROOT/bin/omarchy-launch-browser" "https://example.test/missing" || missing_status=$?
[[ $missing_status == 1 ]] || fail "a missing browser command exits 1"
[[ ! -e $launch_log ]] || fail "a missing browser command does not launch a browser"
expected=$(OMARCHY_PATH="$ROOT" "$ROOT/bin/omarchy-i18n" browser.commandNotFound "$missing_desktop")
grep -F -- '-u critical' "$notify_log" >/dev/null || fail "a missing browser command sends a critical notification"
grep -F -- "$expected" "$notify_log" >/dev/null || fail "a missing browser command reports the desktop id through the catalog"
pass "a missing browser command reports the failure and does not launch"

rm -f "$mock_bin/omarchy-cmd-default-browser"
cat >"$mock_bin/omarchy-cmd-default-browser" <<'EOF'
#!/bin/bash
printf '%s\n' 'google-chrome missing.desktop'
EOF
cat >"$mock_bin/setsid" <<'SH'
#!/bin/bash
printf '%s\n' "$*" >"$OMARCHY_TEST_WEBAPP_LAUNCH"
exit 0
SH
chmod +x "$mock_bin/omarchy-cmd-default-browser" "$mock_bin/setsid"
webapp_log="$test_tmp/webapp"
rm -f "$notify_log" "$webapp_log"
webapp_status=0
HOME="$test_home" PATH="$mock_bin:$ROOT/bin:$PATH" OMARCHY_PATH="$ROOT" \
  OMARCHY_TEST_BROWSER_NOTIFY="$notify_log" OMARCHY_TEST_WEBAPP_LAUNCH="$webapp_log" \
  bash "$ROOT/bin/omarchy-launch-webapp" "https://example.test/app" || webapp_status=$?
[[ $webapp_status == 1 ]] || fail "a missing web app browser exits 1"
[[ ! -e $webapp_log ]] || fail "a missing web app browser does not launch"
webapp_expected=$(OMARCHY_PATH="$ROOT" "$ROOT/bin/omarchy-i18n" browser.commandNotFound "google-chrome missing.desktop")
grep -F -- '-u critical' "$notify_log" >/dev/null || fail "a missing web app browser sends a critical notification"
grep -F -- "$webapp_expected" "$notify_log" >/dev/null || fail "a missing web app browser reports the desktop id through the catalog"
pass "a missing web app browser reports the failure and does not launch"
