#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

test_tmp=$(mktemp -d)
trap 'rm -rf "$test_tmp"' EXIT

mock_bin="$test_tmp/bin"
user_data="$test_tmp/user/applications"
system_data="$test_tmp/system/applications"
mkdir -p "$mock_bin" "$user_data" "$system_data"

export HOME="$test_tmp/home"
export XDG_DATA_HOME="$test_tmp/user"
export XDG_DATA_DIRS="$test_tmp/system"
export PATH="$mock_bin:$ROOT/bin:$PATH"

for command in chromium firefox vivaldi-stable; do
  printf '#!/bin/bash\n' >"$mock_bin/$command"
done
chmod +x "$mock_bin"/*

browser_entry() {
  cat >"$1" <<EOF
[Desktop Entry]
Name=$2
Exec=$3 %U
MimeType=x-scheme-handler/http;x-scheme-handler/https;
EOF
}

browser_entry "$user_data/chromium.desktop" "Chromium" chromium
browser_entry "$system_data/vivaldi-stable.desktop" "Vivaldi" vivaldi-stable

# A chat app that claims both schemes but declares no WebBrowser category is
# not a browser.
browser_entry "$system_data/org.telegram.desktop" "Telegram" chromium
cat >>"$system_data/org.telegram.desktop" <<'EOF'
Categories=Utility;Development;
EOF

# Omarchy's own routing entry must never appear as a choice.
browser_entry "$system_data/omarchy-browser.desktop" "Omarchy" chromium

# A hidden alias for a browser already listed must not add a duplicate row.
browser_entry "$system_data/com.vivaldi.Vivaldi.desktop" "Hidden Vivaldi" vivaldi-stable
echo "NoDisplay=true" >>"$system_data/com.vivaldi.Vivaldi.desktop"

# A handler whose Exec is gone is not installed.
cat >"$system_data/stale.desktop" <<'EOF'
[Desktop Entry]
Name=Stale
Exec=missing-browser %U
MimeType=x-scheme-handler/http;x-scheme-handler/https;
EOF

expected=$(printf 'Chromium\tchromium.desktop\nVivaldi\tvivaldi-stable.desktop\n')
[[ $(omarchy-browser-list) == "$expected" ]] ||
  fail "browser list shows installed browsers by name and desktop id" "$(omarchy-browser-list)"

pass "browser list finds installed browsers by their real desktop ids"

# A user entry shadows a system entry of the same id, as with XDG lookups.
browser_entry "$system_data/chromium.desktop" "System Chromium" chromium
[[ $(omarchy-browser-list) == "$expected" ]] ||
  fail "browser list does not duplicate a browser found in two data dirs" "$(omarchy-browser-list)"

pass "browser list deduplicates desktop entries across data dirs"
