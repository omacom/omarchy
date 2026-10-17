#!/bin/bash

source "$(dirname "${BASH_SOURCE[0]}")/base-test.sh"

test_tmp=$(mktemp -d)
trap 'rm -rf "$test_tmp"' EXIT

test_home="$test_tmp/home"
mock_bin="$test_tmp/bin"
mkdir -p "$test_home/.config/kitty" "$mock_bin"

printf '%s\n' '#!/bin/bash' 'printf "%s\\n" "Test Sans"' >"$mock_bin/fc-list"
printf '#!/bin/bash\nexit 0\n' >"$mock_bin/omarchy-cmd-present"
printf '#!/bin/bash\nexit 0\n' >"$mock_bin/pkill"
printf '#!/bin/bash\nexit 0\n' >"$mock_bin/omarchy-restart-shell"
printf '#!/bin/bash\nexit 1\n' >"$mock_bin/pgrep"
printf '#!/bin/bash\nexit 0\n' >"$mock_bin/omarchy-hook"
chmod +x "$mock_bin"/*

printf '%s\n' \
  'font_family Old Sans' \
  'bold_font Old Sans Bold' \
  'italic_font Old Sans Italic' \
  'bold_italic_font Old Sans Bold Italic' \
  'background #111111' \
  >"$test_home/.config/kitty/kitty.conf"

HOME="$test_home" PATH="$mock_bin:$PATH" bash "$ROOT/bin/omarchy-font-set" 'Test Sans' >/dev/null

grep -qxF 'font_family Test Sans' "$test_home/.config/kitty/kitty.conf" ||
  fail "font set changes Kitty's regular font family"
for variant in bold_font italic_font bold_italic_font; do
  grep -qxF "$variant auto" "$test_home/.config/kitty/kitty.conf" ||
    fail "font set resets Kitty's $variant"
done
pass "font set resets explicit Kitty font variants"
