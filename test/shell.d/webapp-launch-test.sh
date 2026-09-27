#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

tmp=$(mktemp -d)
trap 'rm -rf "$tmp"' EXIT

mock="$tmp/bin"
home="$tmp/home"
mkdir -p "$mock" "$home/.local/share/applications"
export HOME="$home"
export OMARCHY_WEBAPP_MAP="$tmp/webapps.map"
export PATH="$mock:$PATH"

cat >"$home/.local/share/applications/chromium.desktop" <<'EOF'
[Desktop Entry]
Exec=/usr/bin/chromium %U
EOF

cat >"$mock/xdg-settings" <<'SH'
#!/bin/bash
echo chromium.desktop
SH

cat >"$mock/setsid" <<'SH'
#!/bin/bash
printf 'setsid:%s\n' "$*" >"$OMARCHY_TEST_LAUNCH"
SH

cat >"$mock/uwsm-app" <<'SH'
#!/bin/bash
printf 'uwsm:%s\n' "$*" >>"$OMARCHY_TEST_LAUNCH"
SH

chmod +x "$mock"/*

export OMARCHY_TEST_LAUNCH="$tmp/launch"

: >"$OMARCHY_TEST_LAUNCH"
bash "$ROOT/bin/omarchy-launch-webapp" "https://example.com/"
grep -Fq -- '--app=https://example.com/' "$OMARCHY_TEST_LAUNCH" ||
  fail "launch-webapp uses --app= when no app id is recorded" "$(cat "$OMARCHY_TEST_LAUNCH")"
grep -Fq -- '--app-id=' "$OMARCHY_TEST_LAUNCH" &&
  fail "launch-webapp does not pass --app-id= without a mapping" "$(cat "$OMARCHY_TEST_LAUNCH")"
pass "launch-webapp falls back to --app= without a recorded id"

"$ROOT/bin/omarchy-webapp-id" set "https://example.com/" abcdefghijklmnopqrstuvwx
: >"$OMARCHY_TEST_LAUNCH"
bash "$ROOT/bin/omarchy-launch-webapp" "https://example.com/"
grep -Fq -- '--app-id=abcdefghijklmnopqrstuvwx' "$OMARCHY_TEST_LAUNCH" ||
  fail "launch-webapp uses --app-id= when a mapping exists" "$(cat "$OMARCHY_TEST_LAUNCH")"
grep -Fq -- '--app-launch-url-for-shortcuts-menu-item=' "$OMARCHY_TEST_LAUNCH" &&
  fail "launch-webapp does not pass a shortcut URL for an origin-only launch" "$(cat "$OMARCHY_TEST_LAUNCH")"
grep -Fq -- '--app=https://example.com/' "$OMARCHY_TEST_LAUNCH" &&
  fail "launch-webapp does not also pass --app= for an installed app" "$(cat "$OMARCHY_TEST_LAUNCH")"
pass "launch-webapp launches an installed web app by id"

: >"$OMARCHY_TEST_LAUNCH"
bash "$ROOT/bin/omarchy-launch-webapp" "https://example.com/watch?v=1"
grep -Fq -- '--app-id=abcdefghijklmnopqrstuvwx' "$OMARCHY_TEST_LAUNCH" ||
  fail "launch-webapp still uses --app-id= for a deep link" "$(cat "$OMARCHY_TEST_LAUNCH")"
grep -Fq -- '--app-launch-url-for-shortcuts-menu-item=https://example.com/watch?v=1' "$OMARCHY_TEST_LAUNCH" ||
  fail "launch-webapp passes a path as a deep link" "$(cat "$OMARCHY_TEST_LAUNCH")"
pass "launch-webapp passes a path as a shortcut deep link"
