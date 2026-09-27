#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

tmp=$(mktemp -d)
trap 'rm -rf "$tmp"' EXIT
home="$tmp/home"
mock="$tmp/bin"
mkdir -p "$mock" "$home/.local/share/applications" "$home/.local/share/omarchy-chromium"
export HOME="$home"
export PATH="$mock:$PATH"

cat >"$home/.local/share/applications/chromium.desktop" <<'EOF'
[Desktop Entry]
Exec=/usr/bin/chromium %U
EOF

cat >"$mock/xdg-settings" <<'SH'
#!/bin/bash
echo chromium.desktop
SH
chmod +x "$mock/xdg-settings"

printf '%s\n' "$tmp/not-used-chrome" >"$home/.local/share/omarchy-chromium/chrome.path"
got=$("$ROOT/bin/omarchy-webapp-browser")
[[ $got == "/usr/bin/chromium" ]] ||
  fail "webapp-browser uses the default-browser desktop Exec" "$got"
pass "webapp-browser uses the default-browser desktop Exec"

cat >"$tmp/override-chrome" <<'SH'
#!/bin/bash
echo override
SH
chmod +x "$tmp/override-chrome"
got=$(OMARCHY_WEBAPP_CHROMIUM="$tmp/override-chrome" "$ROOT/bin/omarchy-webapp-browser")
[[ $got == "$tmp/override-chrome" ]] ||
  fail "OMARCHY_WEBAPP_CHROMIUM overrides the desktop Exec" "$got"
pass "OMARCHY_WEBAPP_CHROMIUM overrides the desktop Exec"
