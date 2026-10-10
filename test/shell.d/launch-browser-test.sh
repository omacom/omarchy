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

launched_command() {
  sed 's/.* uwsm-app -- //' "$launch_log"
}

HOME="$test_home" PATH="$mock_bin:$PATH" OMARCHY_TEST_BROWSER_LAUNCH="$launch_log" \
  OMARCHY_TEST_BROWSER_FOCUS="$focus_log" bash "$ROOT/bin/omarchy-launch-browser" --private "https://knowledge.test/"

[[ $(launched_command) == "chromium --incognito https://knowledge.test/" ]] ||
  fail "private browser launch puts the flag before the URL" "actual: $(launched_command)"
pass "browser launcher keeps the private flag ahead of the URL"

cat >"$test_home/.local/share/applications/chromium.desktop" <<'EOF'
[Desktop Entry]
Exec=/usr/bin/env "BROWSER_NOTE=two words" chromium --class=wrapped %U
EOF

HOME="$test_home" PATH="$mock_bin:$PATH" OMARCHY_TEST_BROWSER_LAUNCH="$launch_log" \
  OMARCHY_TEST_BROWSER_FOCUS="$focus_log" bash "$ROOT/bin/omarchy-launch-browser" "https://example.test/wrapped"

[[ $(launched_command) == "/usr/bin/env BROWSER_NOTE=two words chromium --class=wrapped https://example.test/wrapped" ]] ||
  fail "browser launcher runs a wrapped Exec command in full" "actual: $(launched_command)"
pass "browser launcher runs a wrapped Exec command in full"

cat >"$test_home/.local/share/applications/chromium.desktop" <<'EOF'
[Desktop Entry]
Exec=chromium --user-data-dir=/tmp/microsoft-edge %U
EOF

HOME="$test_home" PATH="$mock_bin:$PATH" OMARCHY_TEST_BROWSER_LAUNCH="$launch_log" \
  OMARCHY_TEST_BROWSER_FOCUS="$focus_log" bash "$ROOT/bin/omarchy-launch-browser" --private

[[ $(launched_command) == "chromium --user-data-dir=/tmp/microsoft-edge --incognito" ]] ||
  fail "browser launcher takes only Edge's own name for Edge" "actual: $(launched_command)"

cat >"$test_home/.local/share/applications/chromium.desktop" <<'EOF'
[Desktop Entry]
Exec=/opt/microsoft/msedge/msedge %U
EOF

HOME="$test_home" PATH="$mock_bin:$PATH" OMARCHY_TEST_BROWSER_LAUNCH="$launch_log" \
  OMARCHY_TEST_BROWSER_FOCUS="$focus_log" bash "$ROOT/bin/omarchy-launch-browser" --private

[[ $(launched_command) == "/opt/microsoft/msedge/msedge --inprivate" ]] ||
  fail "browser launcher asks Edge for an InPrivate window" "actual: $(launched_command)"

cat >"$test_home/.local/share/applications/chromium.desktop" <<'EOF'
[Desktop Entry]
Exec=/usr/bin/flatpak run --command=edge com.microsoft.Edge @@u %U @@
EOF

HOME="$test_home" PATH="$mock_bin:$PATH" OMARCHY_TEST_BROWSER_LAUNCH="$launch_log" \
  OMARCHY_TEST_BROWSER_FOCUS="$focus_log" bash "$ROOT/bin/omarchy-launch-browser" --private "https://example.test/edge"

[[ $(launched_command) == "/usr/bin/flatpak run --command=edge com.microsoft.Edge @@u --inprivate https://example.test/edge @@" ]] ||
  fail "browser launcher asks a Flatpak Edge for an InPrivate window" "actual: $(launched_command)"
pass "browser launcher picks the private flag from the browser, not its arguments"

cat >"$test_home/.local/share/applications/chromium.desktop" <<'EOF'
[Desktop Entry]
Exec=chromium %U
EOF

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
