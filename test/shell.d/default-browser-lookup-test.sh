#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

test_tmp=$(mktemp -d)
trap 'rm -rf "$test_tmp"' EXIT

mock_bin="$test_tmp/bin"
mkdir -p "$mock_bin" "$test_tmp/config" "$test_tmp/data/applications" "$test_tmp/system/applications"

export HOME="$test_tmp/home"
export XDG_CONFIG_HOME="$test_tmp/config"
export XDG_CONFIG_DIRS="$test_tmp/etc"
export XDG_DATA_HOME="$test_tmp/data"
export XDG_DATA_DIRS="$test_tmp/system"
export XDG_CURRENT_DESKTOP=Hyprland
export BROWSER=omarchy-launch-browser
export OMARCHY_TEST_XDG_SETTINGS_LOG="$test_tmp/xdg-settings"

cat >"$mock_bin/xdg-settings" <<'SH'
#!/bin/bash
printf '%s\n' "${BROWSER:-unset}" >"$OMARCHY_TEST_XDG_SETTINGS_LOG"
echo fallback.desktop
SH
export PATH="$mock_bin:$ROOT/bin:$PATH"

for browser in chromium firefox brave; do
  printf '#!/bin/bash\n' >"$mock_bin/$browser"
done
chmod +x "$mock_bin"/*

echo "Exec=chromium %U" >"$XDG_DATA_HOME/applications/chromium.desktop"
echo "Exec=firefox %u" >"$XDG_DATA_HOME/applications/firefox.desktop"
echo "Exec=brave %U" >"$XDG_DATA_DIRS/applications/brave-browser.desktop"
# An entry of Omarchy's own left behind by a browser since removed, shadowing
# a system copy that the launchers would never read.
echo "Exec=removed-browser %U" >"$XDG_DATA_HOME/applications/removed.desktop"
echo "Exec=brave %U" >"$XDG_DATA_DIRS/applications/removed.desktop"

cat >"$XDG_CONFIG_HOME/mimeapps.list" <<'EOF'
[Added Associations]
x-scheme-handler/http=firefox.desktop;

[Default Applications]
text/html=firefox.desktop
x-scheme-handler/http=missing.desktop;removed.desktop;chromium.desktop;
EOF

[[ $(omarchy-cmd-default-browser) == "chromium.desktop" ]] ||
  fail "default browser is the first installed http handler in mimeapps.list"
[[ ! -e $OMARCHY_TEST_XDG_SETTINGS_LOG ]] ||
  fail "default browser skips xdg-settings when mimeapps.list names one"

cat >"$XDG_CONFIG_HOME/hyprland-mimeapps.list" <<'EOF'
[Default Applications]
x-scheme-handler/http=brave-browser.desktop
EOF

[[ $(omarchy-cmd-default-browser) == "brave-browser.desktop" ]] ||
  fail "default browser prefers the desktop-specific mimeapps.list"

rm "$XDG_CONFIG_HOME/hyprland-mimeapps.list"
printf '[Default Applications]\nx-scheme-handler/http=missing.desktop\n' >"$XDG_CONFIG_HOME/mimeapps.list"

[[ $(omarchy-cmd-default-browser) == "fallback.desktop" ]] ||
  fail "default browser falls back to xdg-settings when no listed handler is installed"
[[ $(<"$OMARCHY_TEST_XDG_SETTINGS_LOG") == "unset" ]] ||
  fail "default browser unsets BROWSER before asking xdg-settings"

pass "default browser reads mimeapps.list and falls back to xdg-settings"

# When xdg-settings and xdg-mime return the routing entry and mimeapps.list has no installed handler,
# fall back to the first installed supported browser.
cat >"$mock_bin/xdg-settings" <<'SH'
#!/bin/bash
echo omarchy-browser.desktop
SH
cat >"$mock_bin/xdg-mime" <<'SH'
#!/bin/bash
echo omarchy-browser.desktop
SH
chmod +x "$mock_bin/xdg-mime"

# Install brave-origin as an installed browser
printf '#!/bin/bash\n' >"$mock_bin/brave-origin"
chmod +x "$mock_bin/brave-origin"
echo "Exec=brave-origin %U" >"$XDG_DATA_HOME/applications/brave-origin.desktop"

rm -f "$XDG_DATA_HOME/applications/chromium.desktop" "$XDG_DATA_HOME/applications/firefox.desktop" "$XDG_DATA_DIRS/applications/brave-browser.desktop"

[[ $(omarchy-cmd-default-browser) == "brave-origin.desktop" ]] ||
  fail "default browser falls back to installed browser when xdg-settings returns the routing entry"
pass "default browser falls back to installed browser when xdg-settings returns the routing entry"

# When no browser is installed at all, omarchy-launch-browser warns and exits 1 without handing off or launching anything
rm -f "$XDG_DATA_HOME/applications/brave-origin.desktop" "$mock_bin/brave-origin"
cat >"$mock_bin/omarchy-notification-send" <<'SH'
#!/bin/bash
printf 'omarchy-notification-send %s\n' "$*" >>"$OMARCHY_TEST_XDG_SETTINGS_LOG"
SH
cat >"$mock_bin/omarchy-cmd-browser-handoff" <<'SH'
#!/bin/bash
printf 'omarchy-cmd-browser-handoff %s\n' "$*" >>"$OMARCHY_TEST_XDG_SETTINGS_LOG"
exit 1
SH
cat >"$mock_bin/systemd-run" <<'SH'
#!/bin/bash
printf 'systemd-run %s\n' "$*" >>"$OMARCHY_TEST_XDG_SETTINGS_LOG"
SH
chmod +x "$mock_bin/omarchy-notification-send" "$mock_bin/omarchy-cmd-browser-handoff" "$mock_bin/systemd-run"

err_out=$(OMARCHY_PATH="$ROOT" bash "$ROOT/bin/omarchy-launch-browser" 2>&1) && fail "launch browser must fail when no browser is installed" || true
grep -q "No default browser found" <<<"$err_out" || fail "launch browser outputs actionable error message"
grep -q "^omarchy-notification-send .*No default browser found" "$OMARCHY_TEST_XDG_SETTINGS_LOG" ||
  fail "launch browser notifies that no default browser was found"
! grep -qE "^(omarchy-cmd-browser-handoff|systemd-run) " "$OMARCHY_TEST_XDG_SETTINGS_LOG" ||
  fail "launch browser must never hand off or launch an empty command"
pass "omarchy-launch-browser fails gracefully with notification when no browser is available"
