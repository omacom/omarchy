#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

require_command jq

tmp=$(mktemp -d)
trap 'rm -rf "$tmp"' EXIT

home="$tmp/home"
config="$home/.config"
data="$home/.local/share"
stubs="$tmp/bin"
mkdir -p "$config/chromium/Default/Web Applications/abcdefghijklmnopabcdefghijklmnop" \
  "$data/applications" "$stubs"

cat >"$config/chromium/Default/Web Applications/abcdefghijklmnopabcdefghijklmnop/manifest.json" <<'JSON'
{"name":"HEY","start_url":"https://app.hey.com/","scope":"https://app.hey.com/"}
JSON

cat >"$data/applications/chromium.desktop" <<'EOF'
[Desktop Entry]
Exec=/usr/bin/chromium --ozone-platform=wayland
EOF

cat >"$stubs/omarchy-cmd-default-browser" <<'EOF'
#!/bin/bash
echo chromium.desktop
EOF
cat >"$stubs/omarchy-cmd-browser-handoff" <<EOF
#!/bin/bash
printf '%s\\n' "\$@" >"$tmp/handoff"
exit \${HANDOFF_STATUS:-0}
EOF
cat >"$stubs/uwsm-app" <<'EOF'
#!/bin/bash
exit 0
EOF
chmod +x "$stubs"/*

webapp_env=(
  "HOME=$home" "XDG_CONFIG_HOME=$config" "XDG_DATA_HOME=$data"
  "XDG_DATA_DIRS=$data" "PATH=$stubs:$ROOT/bin:$PATH"
)

# The helper resolves an installed PWA by origin, not by the exact URL: a
# compose deep link must land in the same app as its start page.
id=$(env "${webapp_env[@]}" "$ROOT/bin/omarchy-webapp-pwa-id" \
  "https://app.hey.com/messages/new?to=someone@example.com")
[[ $id == "abcdefghijklmnopabcdefghijklmnop" ]] ||
  fail "webapp PWA lookup matches an installed app by origin" "$id"
pass "webapp PWA lookup matches an installed app by origin"

[[ -z $(env "${webapp_env[@]}" "$ROOT/bin/omarchy-webapp-pwa-id" "https://example.com/") ]] ||
  fail "webapp PWA lookup ignores unrelated origins"
pass "webapp PWA lookup ignores unrelated origins"

# A compose deep link goes into the running PWA through Chromium's shortcut
# URL flag, and never through --app= which would open a second window.
env "${webapp_env[@]}" "$ROOT/bin/omarchy-launch-webapp" \
  "https://app.hey.com/messages/new?to=someone@example.com"

grep -Fxq -- '--app-id=abcdefghijklmnopabcdefghijklmnop' "$tmp/handoff" ||
  fail "webapp deep link uses the installed PWA app id" "$(cat "$tmp/handoff")"
grep -Fxq -- '--app-launch-url-for-shortcuts-menu-item=https://app.hey.com/messages/new?to=someone@example.com' "$tmp/handoff" ||
  fail "webapp deep link carries the compose URL" "$(cat "$tmp/handoff")"
! grep -q -- '--app=' "$tmp/handoff" ||
  fail "webapp deep link does not open an --app shortcut" "$(cat "$tmp/handoff")"
pass "webapp deep links route into the installed PWA window"

# Origin-only launches leave URL selection to the app's own start_url.
env "${webapp_env[@]}" "$ROOT/bin/omarchy-launch-webapp" "https://app.hey.com/"
! grep -q -- '--app-launch-url-for-shortcuts-menu-item=' "$tmp/handoff" ||
  fail "webapp origin-only launch uses the PWA start_url" "$(cat "$tmp/handoff")"
pass "webapp origin-only launches use the PWA start_url"

# Without an installed PWA the old --app shortcut path is unchanged.
mv "$config/chromium/Default/Web Applications/abcdefghijklmnopabcdefghijklmnop/manifest.json" \
  "$tmp/manifest.saved"
env "${webapp_env[@]}" "$ROOT/bin/omarchy-launch-webapp" "https://app.hey.com/messages/new?to=x@y.com"
grep -Fxq -- '--app=https://app.hey.com/messages/new?to=x@y.com' "$tmp/handoff" ||
  fail "webapp without a PWA keeps the --app shortcut" "$(cat "$tmp/handoff")"
pass "webapps without an installed PWA keep the existing launch path"
