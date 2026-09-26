#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

test_tmp=$(mktemp -d)
trap 'rm -rf "$test_tmp"' EXIT

mock_bin="$test_tmp/bin"
test_home="$test_tmp/home"
mkdir -p "$mock_bin" "$test_home/.local/share/applications"

cat >"$test_home/.local/share/applications/brave-browser.desktop" <<'EOF'
[Desktop Entry]
Exec=/usr/bin/env LIBVA_DRIVER_NAME=iHD brave %U
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
printf '%s\n' "$*" >"$OMARCHY_TEST_WEBAPP_LAUNCH"
SH
chmod +x "$mock_bin"/*

launch_log="$test_tmp/launch"
HOME="$test_home" PATH="$mock_bin:$PATH" OMARCHY_TEST_WEBAPP_LAUNCH="$launch_log" \
  bash "$ROOT/bin/omarchy-launch-webapp" "https://discord.com/channels/@me"

grep -F '/usr/bin/env' "$launch_log" >/dev/null || fail "webapp launcher keeps the env wrapper"
grep -F 'LIBVA_DRIVER_NAME=iHD' "$launch_log" >/dev/null || fail "webapp launcher keeps env assignments"
grep -F 'brave' "$launch_log" >/dev/null || fail "webapp launcher still runs the browser binary"
grep -F -e '--app=https://discord.com/channels/@me' "$launch_log" >/dev/null ||
  fail "webapp launcher appends --app after the resolved Exec"
! grep -E -e '^--app=' "$launch_log" >/dev/null ||
  fail "webapp launcher does not pass --app to env"
pass "webapp launcher resolves env-wrapped desktop Exec lines"
