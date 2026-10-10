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

# Use a fake Vivaldi installation: no real browser, compositor, or profile is touched.
test_omarchy="$test_tmp/omarchy"
mkdir -p "$test_omarchy/default/vivaldi"
cat >"$test_home/.local/share/applications/vivaldi-test.desktop" <<'EOF'
[Desktop Entry]
Exec=vivaldi-test %U
EOF
cat >"$mock_bin/omarchy-cmd-default-browser" <<'SH'
#!/bin/bash
echo vivaldi-test.desktop
SH
cat >"$mock_bin/vivaldi-test" <<'SH'
#!/bin/bash
exit 0
SH
cat >"$mock_bin/pgrep" <<'SH'
#!/bin/bash
[[ $* == "-u $UID -x vivaldi|vivaldi-bin" ]] || exit 2
[[ ${RUNNING_VIVALDI:-} == "vivaldi" || ${RUNNING_VIVALDI:-} == "vivaldi-bin" ]]
SH
cat >"$test_omarchy/default/vivaldi/vivaldi-theme-refresh" <<'SH'
#!/bin/bash
echo refresh >>"$VIVALDI_REFRESH_LOG"
exit "${VIVALDI_REFRESH_STATUS:-0}"
SH
chmod +x "$mock_bin"/* "$test_omarchy/default/vivaldi/vivaldi-theme-refresh"

vivaldi_refresh_log="$test_tmp/vivaldi-refresh"
run_vivaldi_launch() {
  HOME="$test_home" PATH="$mock_bin:$PATH" OMARCHY_PATH="$test_omarchy" \
    RUNNING_VIVALDI="$1" VIVALDI_REFRESH_LOG="$vivaldi_refresh_log" \
    OMARCHY_TEST_BROWSER_LAUNCH="$launch_log" OMARCHY_TEST_BROWSER_FOCUS="$focus_log" \
    bash "$ROOT/bin/omarchy-launch-browser" "https://example.test/vivaldi"
}

for process in vivaldi vivaldi-bin; do
  run_vivaldi_launch "$process"
  [[ ! -e $vivaldi_refresh_log ]] || fail "opening a link skips refresh for running $process"
  grep -Fq 'https://example.test/vivaldi' "$launch_log" ||
    fail "skipping the Vivaldi refresh still opens the URL"
done
pass "opening links skips the theme refresh while the user's Vivaldi runs"

# A Vivaldi belonging to another account must not skip this user's startup refresh.
run_vivaldi_launch other-user
[[ $(cat "$vivaldi_refresh_log") == "refresh" ]] ||
  fail "Vivaldi startup refreshes when no Vivaldi runs for the current user"
pass "Vivaldi startup refresh is scoped to the current user"

rm -f "$launch_log"
VIVALDI_REFRESH_STATUS=1 run_vivaldi_launch stopped
grep -Fq 'https://example.test/vivaldi' "$launch_log" ||
  fail "a failed startup theme refresh still opens Vivaldi"
pass "a failed startup theme refresh does not block Vivaldi launch"
