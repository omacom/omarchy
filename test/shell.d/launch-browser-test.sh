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
printf '%s\n' "$@" >"$OMARCHY_TEST_BROWSER_LAUNCH"
SH
cat >"$mock_bin/omarchy-hyprland-focus-app" <<'SH'
#!/bin/bash
printf '%s\n' "$1" >"$OMARCHY_TEST_BROWSER_FOCUS"
SH
chmod +x "$mock_bin"/*

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
[[ $(sed '1,/^--$/d' "$launch_log") == $'chromium\n--incognito' ]] || fail "a private launch passes the browser's private flag"
pass "a private launch passes the browser's private flag"

cat >"$test_home/.local/share/applications/chromium.desktop" <<'EOF'
[Desktop Entry]
Exec=/usr/bin/env LIBVA_DRIVER_NAME=iHD chromium "--profile-directory=Work Profile" --class=100%% %U
EOF

rm -f "$focus_log"
HOME="$test_home" PATH="$mock_bin:$PATH" HYPRLAND_INSTANCE_SIGNATURE=test \
  OMARCHY_TEST_BROWSER_LAUNCH="$launch_log" OMARCHY_TEST_BROWSER_FOCUS="$focus_log" \
  bash "$ROOT/bin/omarchy-launch-browser" "https://example.test/wrapped"

expected=$(printf '%s\n' /usr/bin/env LIBVA_DRIVER_NAME=iHD chromium "--profile-directory=Work Profile" --class=100% https://example.test/wrapped)
[[ $(sed '1,/^--$/d' "$launch_log") == "$expected" ]] ||
  fail "wrapped Exec launcher runs the whole unquoted Exec line, then the URL"
grep -Fx '^chromium.*$' "$focus_log" >/dev/null ||
  fail "wrapped Exec launcher focuses the real browser, not env"
pass "browser launcher resolves env-wrapped desktop Exec lines"

rm -f "$help_log"
launch --private
[[ -s $help_log ]] || fail "a wrapped private launch probes the real browser, not env"
expected=$(printf '%s\n' /usr/bin/env LIBVA_DRIVER_NAME=iHD chromium "--profile-directory=Work Profile" --class=100% --incognito)
[[ $(sed '1,/^--$/d' "$launch_log") == "$expected" ]] ||
  fail "a wrapped private launch passes the real browser's private flag"
pass "a wrapped private launch passes the real browser's private flag"

cat >"$test_home/.local/share/applications/chromium.desktop" <<'EOF'
[Desktop Entry]
Name=Work\sChromium
Exec=/usr/bin/env -u BROWSER chromium --name %c -- https://start.example.test/ %U
EOF

rm -f "$help_log"
launch --private
[[ -s $help_log ]] || fail "a private launch probes the browser behind env -u, not the name it unsets"
expected=$(printf '%s\n' /usr/bin/env -u BROWSER chromium --name "Work Chromium" https://start.example.test/ --incognito)
[[ $(sed '1,/^--$/d' "$launch_log") == "$expected" ]] ||
  fail "a private launch expands %c and keeps its flag an option despite the Exec line's --"
pass "a private launch finds the browser behind env options and keeps its flag an option"

spaced_desktop="userapp-Firefox Developer Edition-U5J9W3.desktop"
cat >"$test_home/.local/share/applications/$spaced_desktop" <<'DESKTOP'
[Desktop Entry]
Exec=chromium %u
DESKTOP
cat >"$mock_bin/omarchy-cmd-default-browser" <<SH
#!/bin/bash
echo "$spaced_desktop"
SH
chmod +x "$mock_bin/omarchy-cmd-default-browser"

rm -f "$launch_log"
launch "https://example.test/spaced"
[[ $(sed '1,/^--$/d' "$launch_log") == $'chromium\nhttps://example.test/spaced' ]] ||
  fail "a desktop id with spaces launches its entry's command"
pass "a desktop id with spaces launches its entry's command"
