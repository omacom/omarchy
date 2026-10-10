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
export OMARCHY_TEST_XDG_MIME_LOG="$test_tmp/xdg-mime"

cat >"$mock_bin/xdg-mime" <<'SH'
#!/bin/bash
printf '%s\n' "$*" >"$OMARCHY_TEST_XDG_MIME_LOG"
[[ $* == "query default text/html" ]] && echo fallback.desktop
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

# x-scheme-handler/http points at omarchy-url-open now, so the lookup must read
# the real browser from text/html and ignore the http handler entirely.
cat >"$XDG_CONFIG_HOME/mimeapps.list" <<'EOF'
[Added Associations]
text/html=firefox.desktop;

[Default Applications]
x-scheme-handler/http=omarchy-url-open.desktop
text/html=missing.desktop;removed.desktop;chromium.desktop;
EOF

[[ $(omarchy-cmd-default-browser) == "chromium.desktop" ]] ||
  fail "default browser is the first installed text/html handler in mimeapps.list"
[[ ! -e $OMARCHY_TEST_XDG_MIME_LOG ]] ||
  fail "default browser skips xdg-mime when mimeapps.list names one"

cat >"$XDG_CONFIG_HOME/hyprland-mimeapps.list" <<'EOF'
[Default Applications]
text/html=brave-browser.desktop
EOF

[[ $(omarchy-cmd-default-browser) == "brave-browser.desktop" ]] ||
  fail "default browser prefers the desktop-specific mimeapps.list"

rm "$XDG_CONFIG_HOME/hyprland-mimeapps.list"
printf '[Default Applications]\ntext/html=missing.desktop\n' >"$XDG_CONFIG_HOME/mimeapps.list"

[[ $(omarchy-cmd-default-browser) == "fallback.desktop" ]] ||
  fail "default browser falls back to xdg-mime when no listed handler is installed"
[[ $(<"$OMARCHY_TEST_XDG_MIME_LOG") == "query default text/html" ]] ||
  fail "default browser asks xdg-mime for the text/html handler"

pass "default browser reads mimeapps.list and falls back to xdg-mime"
