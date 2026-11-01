#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

test_tmp=$(mktemp -d)
trap 'rm -rf "$test_tmp"' EXIT

mock_bin="$test_tmp/bin"
test_home="$test_tmp/home"
mkdir -p "$mock_bin" "$test_home/.local/share/applications" "$test_tmp/system/applications"
# Keep the launcher away from the running browser's singleton socket, which it
# would otherwise hand these test URLs to, and from the host's own browsers.
export XDG_CONFIG_HOME="$test_home/.config" XDG_CONFIG_DIRS="$test_tmp/etc"
export XDG_DATA_HOME="$test_home/.local/share" XDG_DATA_DIRS="$test_tmp/system"

cat >"$test_home/.local/share/applications/chromium.desktop" <<'EOF'
[Desktop Entry]
Exec=chromium %U
EOF

cat >"$test_home/.local/share/applications/firefox.desktop" <<'EOF'
[Desktop Entry]
Exec=firefox %U
EOF

cat >"$mock_bin/xdg-settings" <<'SH'
#!/bin/bash
[[ -z ${BROWSER:-} ]] || printf '%s\n' "$BROWSER" >"$OMARCHY_TEST_XDG_SETTINGS_BROWSER"
[[ ${OMARCHY_TEST_XDG_SETTINGS_EMPTY:-0} == "1" ]] || echo "${OMARCHY_TEST_BROWSER_DESKTOP:-chromium.desktop}"
SH
cat >"$mock_bin/xdg-mime" <<'SH'
#!/bin/bash
if [[ $* == "query default x-scheme-handler/https" ]]; then
  echo chromium.desktop
fi
SH
cat >"$mock_bin/chromium" <<'SH'
#!/bin/bash
printf '%s\n' "$*" >>"$OMARCHY_TEST_BROWSER_EXEC"
SH
ln -s chromium "$mock_bin/firefox"
cat >"$mock_bin/systemd-run" <<'SH'
#!/bin/bash
printf '%s\n' "$@" >"$OMARCHY_TEST_BROWSER_LAUNCH"
SH
cp "$mock_bin/systemd-run" "$mock_bin/uwsm-app"
cat >"$mock_bin/omarchy-hyprland-focus-app" <<'SH'
#!/bin/bash
printf '%s\n' "$1" >"$OMARCHY_TEST_BROWSER_FOCUS"
SH
chmod +x "$mock_bin"/*

launch_log="$test_tmp/launch"
focus_log="$test_tmp/focus"
xdg_settings_browser="$test_tmp/xdg-settings-browser"
browser_exec_log="$test_tmp/browser-exec"
HOME="$test_home" PATH="$mock_bin:$ROOT/bin:$PATH" HYPRLAND_INSTANCE_SIGNATURE=test \
  OMARCHY_TEST_BROWSER_LAUNCH="$launch_log" OMARCHY_TEST_BROWSER_FOCUS="$focus_log" \
  OMARCHY_TEST_BROWSER_EXEC="$browser_exec_log" \
  bash "$ROOT/bin/omarchy-launch-browser"

[[ ! -e $focus_log ]] || fail "browser launcher leaves a new window on the current workspace"
[[ ! -e $browser_exec_log ]] || fail "browser launcher does not execute a browser to detect its family" "$(cat "$browser_exec_log")"

HOME="$test_home" PATH="$mock_bin:$ROOT/bin:$PATH" \
  OMARCHY_TEST_BROWSER_DESKTOP=firefox.desktop \
  OMARCHY_TEST_BROWSER_LAUNCH="$launch_log" OMARCHY_TEST_BROWSER_EXEC="$browser_exec_log" \
  bash "$ROOT/bin/omarchy-launch-browser" --private

grep -F -- '--private-window' "$launch_log" >/dev/null || fail "Firefox private launches use its private-window flag" "$(cat "$launch_log")"
[[ ! -e $browser_exec_log ]] || fail "Firefox detection does not execute the browser" "$(cat "$browser_exec_log")"

HOME="$test_home" PATH="$mock_bin:$ROOT/bin:$PATH" HYPRLAND_INSTANCE_SIGNATURE=test \
  OMARCHY_TEST_BROWSER_LAUNCH="$launch_log" OMARCHY_TEST_BROWSER_FOCUS="$focus_log" \
  OMARCHY_TEST_BROWSER_EXEC="$browser_exec_log" \
  bash "$ROOT/bin/omarchy-launch-browser" --private

[[ ! -e $focus_log ]] || fail "private browser launcher leaves a new window on the current workspace"
[[ ! -e $browser_exec_log ]] || fail "Chromium private launch does not probe the browser" "$(cat "$browser_exec_log")"
grep -Fq -- '--incognito' "$launch_log" || fail "Chromium private launch receives its incognito flag"

HOME="$test_home" PATH="$mock_bin:$ROOT/bin:$PATH" HYPRLAND_INSTANCE_SIGNATURE=test \
  OMARCHY_TEST_BROWSER_LAUNCH="$launch_log" OMARCHY_TEST_BROWSER_FOCUS="$focus_log" \
  bash "$ROOT/bin/omarchy-launch-browser" "https://example.test/authorize"

grep -F 'https://example.test/authorize' "$launch_log" >/dev/null || fail "browser launcher passes through the URL"
grep -Fx '^chromium.*$' "$focus_log" >/dev/null || fail "browser launcher focuses the default browser window"

rm -f "$focus_log" "$xdg_settings_browser"

HOME="$test_home" PATH="$mock_bin:$ROOT/bin:$PATH" HYPRLAND_INSTANCE_SIGNATURE=test \
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

HOME="$test_home" PATH="$mock_bin:$ROOT/bin:$PATH" OMARCHY_TEST_BROWSER_LAUNCH="$launch_log" \
  OMARCHY_TEST_BROWSER_FOCUS="$focus_log" bash "$ROOT/bin/omarchy-launch-browser" "https://example.test/running"

[[ ! -e $launch_log ]] || fail "browser launcher starts no browser when the running one takes the URL"
pass "browser launcher hands a URL to the running browser"

rm "$mock_bin/omarchy-cmd-browser-handoff"
for browser in floorp helium custom-browser; do
  ln -s chromium "$mock_bin/$browser"
  printf '[Desktop Entry]\nExec=%s %%U\n' "$browser" >"$test_home/.local/share/applications/$browser.desktop"
  rm -f "$launch_log"
  if HOME="$test_home" PATH="$mock_bin:$ROOT/bin:$PATH" OMARCHY_TEST_BROWSER_DESKTOP="$browser.desktop" \
    OMARCHY_TEST_BROWSER_LAUNCH="$launch_log" OMARCHY_TEST_BROWSER_EXEC="$browser_exec_log" \
    bash "$ROOT/bin/omarchy-launch-browser" --private >"$test_tmp/out" 2>"$test_tmp/errors"; then
    if [[ $browser == "floorp" ]]; then
      flag=--private-window
    else
      [[ $browser == "helium" ]] || fail "unknown browser families must not receive a guessed private flag"
      flag=--incognito
    fi
    grep -Fq -- "$flag" "$launch_log" || fail "$browser receives its known private flag"
  else
    [[ $browser == "custom-browser" ]] || fail "Floorp private launch succeeds"
    [[ ! -e $launch_log ]] || fail "unknown private launches start no normal browser window"
    grep -Fq 'Cannot determine the private browsing flag' "$test_tmp/errors" || fail "unknown private browsing reports a clear error"
  fi
done
pass "Firefox forks use the correct private flag and unknown families fail closed"

for browser in custom-browser helium; do
  url='https://example.test/--private?value=--private'
  HOME="$test_home" PATH="$mock_bin:$ROOT/bin:$PATH" OMARCHY_TEST_BROWSER_DESKTOP="$browser.desktop" \
    OMARCHY_TEST_BROWSER_LAUNCH="$launch_log" OMARCHY_TEST_BROWSER_EXEC="$browser_exec_log" \
    bash "$ROOT/bin/omarchy-launch-browser" "$url"
  grep -Fxq "$url" "$launch_log" || fail "literal --private text in URLs is preserved"
done
pass "private option translation leaves ordinary URLs unchanged"

# The resolver reads every XDG data dir, so the launcher has to read Exec=
# from the same ones; a browser outside ~/.local and /usr used to resolve and
# then launch an empty command.
cat >"$XDG_DATA_DIRS/applications/vivaldi-stable.desktop" <<'EOF'
[Desktop Entry]
Exec=vivaldi %U
EOF
cat >"$mock_bin/vivaldi" <<'SH'
#!/bin/bash
exit 0
SH
chmod +x "$mock_bin/vivaldi"
mkdir -p "$XDG_CONFIG_HOME"
cat >"$XDG_CONFIG_HOME/mimeapps.list" <<'EOF'
[Default Applications]
x-scheme-handler/http=vivaldi-stable.desktop
EOF

rm -f "$launch_log"
HOME="$test_home" PATH="$mock_bin:$ROOT/bin:$PATH" OMARCHY_TEST_BROWSER_LAUNCH="$launch_log" \
  OMARCHY_TEST_BROWSER_FOCUS="$focus_log" bash "$ROOT/bin/omarchy-launch-browser" "https://example.test/vivaldi"
grep -Fx vivaldi "$launch_log" >/dev/null && grep -Fx 'https://example.test/vivaldi' "$launch_log" >/dev/null ||
  fail "a browser in XDG_DATA_DIRS launches from its desktop entry" "$(cat "$launch_log")"
pass "browser launcher reads Exec= from the data dirs the resolver searched"

# With nothing to launch, the failure has to be visible from a keybinding,
# where stderr goes nowhere, and must never reach uwsm-app as an empty command.
rm -f "$XDG_CONFIG_HOME/mimeapps.list" "$test_home/.local/share/applications/chromium.desktop" "$launch_log"
cat >"$mock_bin/xdg-settings" <<'SH'
#!/bin/bash
echo omarchy-browser.desktop
SH
cat >"$mock_bin/xdg-mime" <<'SH'
#!/bin/bash
echo omarchy-browser.desktop
SH
cat >"$mock_bin/omarchy-notification-send" <<'SH'
#!/bin/bash
printf '%s\n' "$*" >"$OMARCHY_TEST_BROWSER_NOTIFY"
SH
chmod +x "$mock_bin/xdg-settings" "$mock_bin/xdg-mime" "$mock_bin/omarchy-notification-send"
notify_log="$test_tmp/notify"
rm -f "$notify_log"

status=0
HOME="$test_home" PATH="$mock_bin:$ROOT/bin:$PATH" OMARCHY_PATH="$ROOT" \
  OMARCHY_TEST_BROWSER_LAUNCH="$launch_log" OMARCHY_TEST_BROWSER_NOTIFY="$notify_log" \
  bash "$ROOT/bin/omarchy-launch-browser" "https://example.test/none" 2>/dev/null || status=$?

(( status == 1 )) || fail "browser launcher exits 1 when no browser is found" "status: $status"
[[ ! -e $launch_log ]] || fail "browser launcher starts nothing when no browser is found" "$(cat "$launch_log")"
grep -F "No default browser found" "$notify_log" >/dev/null ||
  fail "browser launcher says no default browser was found" "$(cat "$notify_log" 2>/dev/null)"
pass "browser launcher fails visibly instead of handing uwsm-app an empty command"

# A web app reaches the same empty command through its chromium.desktop
# fallback when the default is not Chromium-based, so it needs its own guard
# and message.
cat >"$XDG_DATA_DIRS/applications/firefox.desktop" <<'EOF'
[Desktop Entry]
Exec=firefox %u
EOF
cat >"$mock_bin/firefox" <<'SH'
#!/bin/bash
exit 0
SH
chmod +x "$mock_bin/firefox"
cat >"$XDG_CONFIG_HOME/mimeapps.list" <<'EOF'
[Default Applications]
x-scheme-handler/http=firefox.desktop
EOF
rm -f "$notify_log" "$launch_log"
status=0
HOME="$test_home" PATH="$mock_bin:$ROOT/bin:$PATH" OMARCHY_PATH="$ROOT" \
  OMARCHY_TEST_BROWSER_LAUNCH="$launch_log" OMARCHY_TEST_BROWSER_NOTIFY="$notify_log" \
  bash "$ROOT/bin/omarchy-launch-webapp" "https://example.test/app" 2>/dev/null || status=$?

(( status == 1 )) || fail "web app launcher exits 1 when no browser is found" "status: $status"
[[ ! -e $launch_log ]] || fail "web app launcher starts nothing when no browser is found" "$(cat "$launch_log")"
grep -F "Web apps need a Chromium-based browser" "$notify_log" >/dev/null ||
  fail "web app launcher asks for a Chromium-based browser" "$(cat "$notify_log" 2>/dev/null)"
pass "web app launcher fails visibly instead of handing uwsm-app an empty command"
