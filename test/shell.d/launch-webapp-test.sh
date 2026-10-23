#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

test_tmp=$(mktemp -d)
trap 'rm -rf "$test_tmp"' EXIT

mock_bin="$test_tmp/bin"
test_home="$test_tmp/home"
mkdir -p "$mock_bin" "$test_home/.local/share/applications"
export XDG_CONFIG_HOME="$test_home/.config" XDG_DATA_HOME="$test_home/.local/share"

cat >"$test_home/.local/share/applications/brave-browser.desktop" <<'EOF'
[Desktop Entry]
Exec=/usr/bin/env LIBVA_DRIVER_NAME=iHD brave "--profile-directory=Work Profile" %U
EOF

cat >"$mock_bin/xdg-settings" <<'SH'
#!/bin/bash
echo brave-browser.desktop
SH
cat >"$mock_bin/setsid" <<'SH'
#!/bin/bash
exec "$@"
SH
cat >"$mock_bin/uwsm-app" <<'SH'
#!/bin/bash
printf '%s\n' "$@" >"$OMARCHY_TEST_WEBAPP_LAUNCH"
SH
chmod +x "$mock_bin"/*

launch_log="$test_tmp/launch"
HOME="$test_home" PATH="$mock_bin:$ROOT/bin:$PATH" OMARCHY_TEST_WEBAPP_LAUNCH="$launch_log" \
  bash "$ROOT/bin/omarchy-launch-webapp" "https://discord.com/channels/@me" --start-maximized

expected=$(printf '%s\n' -- /usr/bin/env LIBVA_DRIVER_NAME=iHD brave "--profile-directory=Work Profile" \
  --app=https://discord.com/channels/@me --start-maximized)
[[ $(<"$launch_log") == "$expected" ]] ||
  fail "webapp launcher runs the whole unquoted Exec line, then --app and the caller's arguments"
pass "webapp launcher resolves env-wrapped desktop Exec lines"

cat >"$test_home/.local/share/applications/brave-browser.desktop" <<'EOF'
[Desktop Entry]
Name=Brave
Exec=brave --class=%c --desktop=%k -- %U
EOF

HOME="$test_home" PATH="$mock_bin:$ROOT/bin:$PATH" OMARCHY_TEST_WEBAPP_LAUNCH="$launch_log" \
  bash "$ROOT/bin/omarchy-launch-webapp" "https://example.test/app"

expected=$(printf '%s\n' -- brave --class=Brave "--desktop=$test_home/.local/share/applications/brave-browser.desktop" \
  --app=https://example.test/app)
[[ $(<"$launch_log") == "$expected" ]] ||
  fail "webapp launcher expands %c and %k and keeps --app ahead of the Exec line's closing --"
pass "webapp launcher expands %c and %k and keeps --app an option"

cat >"$test_home/.local/share/applications/brave-browser Work.desktop" <<'DESKTOP'
[Desktop Entry]
Exec=brave %U
DESKTOP
cat >"$mock_bin/xdg-settings" <<'SH'
#!/bin/bash
echo "brave-browser Work.desktop"
SH

HOME="$test_home" PATH="$mock_bin:$ROOT/bin:$PATH" OMARCHY_TEST_WEBAPP_LAUNCH="$launch_log" \
  bash "$ROOT/bin/omarchy-launch-webapp" "https://example.test/spaced"

expected=$(printf '%s\n' -- brave --app=https://example.test/spaced)
[[ $(<"$launch_log") == "$expected" ]] || fail "webapp launcher finds a desktop id with spaces"
pass "webapp launcher finds a desktop id with spaces"
