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
