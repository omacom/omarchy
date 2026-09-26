#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

test_tmp=$(mktemp -d)
trap 'rm -rf "$test_tmp"' EXIT

mock_bin="$test_tmp/bin"
test_home="$test_tmp/home"
setup_log="$test_tmp/setup-log"
mkdir -p "$mock_bin" "$test_home/.config"

cat >"$mock_bin/omarchy-pkg-add" <<'SH'
#!/bin/bash
exit 0
SH

cat >"$mock_bin/omarchy-pkg-aur-add" <<'SH'
#!/bin/bash
exit 0
SH

cat >"$mock_bin/sudo" <<'SH'
#!/bin/bash
exit 0
SH

cat >"$mock_bin/omarchy-test-setup-call" <<'SH'
#!/bin/bash
printf '%s\n' "${0##*/}" >>"$OMARCHY_TEST_SETUP_LOG"
SH

for setup_command in \
  omarchy-install-chromium-copy-url \
  omarchy-install-chromium-ytdlp \
  omarchy-theme-set-browser; do
  ln -s omarchy-test-setup-call "$mock_bin/$setup_command"
done

chmod +x "$mock_bin"/*

export HOME="$test_home"
export PATH="$mock_bin:$ROOT/bin:$PATH"
export OMARCHY_PATH="$ROOT"
export OMARCHY_TEST_SETUP_LOG="$setup_log"

: >"$setup_log"
output=$(omarchy-install-browser chromium)
cmp -s "$ROOT/config/chromium-flags.conf" "$test_home/.config/chromium-flags.conf" ||
  fail "Chromium install copies default flags including --load-extension"
grep -q '^--load-extension=' "$test_home/.config/chromium-flags.conf" ||
  fail "Chromium flags keep --load-extension"
pass "Chromium install keeps --load-extension"

: >"$setup_log"
output=$(omarchy-install-browser chrome)
grep -q '^--load-extension=' "$test_home/.config/chrome-flags.conf" &&
  fail "Chrome install must omit --load-extension" "$(cat "$test_home/.config/chrome-flags.conf")"
grep -q '^--ozone-platform=wayland$' "$test_home/.config/chrome-flags.conf" ||
  fail "Chrome flags still include shared Chromium flags"
printf '%s\n' "$output" | grep -Fq 'Google Chrome 137+' ||
  fail "Chrome install warns that bundled extensions will not load" "$output"
grep -Fxq 'omarchy-install-chromium-copy-url' "$setup_log" ||
  fail "Chrome install still registers the Copy URL host"
grep -Fxq 'omarchy-install-chromium-ytdlp' "$setup_log" ||
  fail "Chrome install still registers the yt-dlp host"
pass "Chrome install omits --load-extension and warns"

: >"$setup_log"
output=$(omarchy-install-browser brave)
grep -q '^--load-extension=' "$test_home/.config/brave-flags.conf" ||
  fail "Brave install keeps --load-extension"
pass "Brave install keeps --load-extension"

: >"$setup_log"
output=$(omarchy-install-browser edge)
grep -q '^--load-extension=' "$test_home/.config/microsoft-edge-stable-flags.conf" ||
  fail "Edge install keeps --load-extension"
pass "Edge install keeps --load-extension"

# Migration strips existing chrome/google-chrome flags only.
mkdir -p "$test_home/.config"
cp -f "$ROOT/config/chromium-flags.conf" "$test_home/.config/chrome-flags.conf"
cp -f "$ROOT/config/chromium-flags.conf" "$test_home/.config/google-chrome-flags.conf"
cp -f "$ROOT/config/chromium-flags.conf" "$test_home/.config/chromium-flags.conf"
cp -f "$ROOT/config/chromium-flags.conf" "$test_home/.config/brave-flags.conf"

HOME="$test_home" OMARCHY_PATH="$ROOT" bash -euo pipefail "$ROOT/migrations/1790098827.sh"

grep -q '^--load-extension=' "$test_home/.config/chrome-flags.conf" &&
  fail "migration strips --load-extension from chrome-flags.conf"
grep -q '^--load-extension=' "$test_home/.config/google-chrome-flags.conf" &&
  fail "migration strips --load-extension from google-chrome-flags.conf"
grep -q '^--load-extension=' "$test_home/.config/chromium-flags.conf" ||
  fail "migration leaves Chromium --load-extension alone"
grep -q '^--load-extension=' "$test_home/.config/brave-flags.conf" ||
  fail "migration leaves Brave --load-extension alone"
pass "migration strips Chrome flags only"

# Idempotent second run.
HOME="$test_home" OMARCHY_PATH="$ROOT" bash -euo pipefail "$ROOT/migrations/1790098827.sh"
pass "migration is idempotent"
