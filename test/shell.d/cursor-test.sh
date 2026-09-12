#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

test_tmp=$(mktemp -d)
trap 'rm -rf "$test_tmp"' EXIT

stub_bin="$test_tmp/bin"
test_home="$test_tmp/home"
log_file="$test_tmp/cursor.log"
checksum_file="$test_tmp/checksum"
mkdir -p "$stub_bin" "$test_home"

write_stub() {
  local name="$1"
  local body="$2"

  printf '%s\n' "$body" >"$stub_bin/$name"
  chmod +x "$stub_bin/$name"
}

write_stub curl '#!/bin/bash
printf "curl" >>"$CURSOR_TEST_LOG"
output=""
while (( $# )); do
  printf "\t%s" "$1" >>"$CURSOR_TEST_LOG"
  if [[ $1 == "-o" ]]; then
    output="$2"
    shift
    printf "\t%s" "$1" >>"$CURSOR_TEST_LOG"
  fi
  shift
done
printf "\n" >>"$CURSOR_TEST_LOG"
: >"$output"
'

write_stub sha256sum '#!/bin/bash
cat >"$CURSOR_TEST_CHECKSUM"
'

write_stub tar '#!/bin/bash
printf "tar" >>"$CURSOR_TEST_LOG"
destination=""
while (( $# )); do
  printf "\t%s" "$1" >>"$CURSOR_TEST_LOG"
  if [[ $1 == "-C" ]]; then
    destination="$2"
    shift
    printf "\t%s" "$1" >>"$CURSOR_TEST_LOG"
  fi
  shift
done
printf "\n" >>"$CURSOR_TEST_LOG"
mkdir -p "$destination/macOS/cursors"
: >"$destination/macOS/cursors/left_ptr"
'

write_stub gsettings '#!/bin/bash
printf "gsettings\t%s\n" "$*" >>"$CURSOR_TEST_LOG"
'

write_stub hyprctl '#!/bin/bash
printf "hyprctl\t%s\n" "$*" >>"$CURSOR_TEST_LOG"
'

write_stub omarchy-hook '#!/bin/bash
printf "hook\t%s\n" "$*" >>"$CURSOR_TEST_LOG"
'

CURSOR_TEST_LOG="$log_file" \
CURSOR_TEST_CHECKSUM="$checksum_file" \
DBUS_SESSION_BUS_ADDRESS=test \
HOME="$test_home" \
XDG_DATA_HOME="$test_home/.local/share" \
PATH="$stub_bin:/usr/bin" \
  "$ROOT/bin/omarchy-cursor-set" macOS

grep -Fq 'https://github.com/ful1e5/apple_cursor/releases/download/v2.0.1/macOS.tar.xz' "$log_file" ||
  fail "macOS cursor downloads the pinned release asset" "$(cat "$log_file")"
pass "macOS cursor downloads the pinned release asset"

grep -Fq '9c6e5e13b068ce51a9e90a9abd6ce232ec7d25d4ceb05aa8ac76efbb99c76762' "$checksum_file" ||
  fail "macOS cursor verifies the release checksum" "$(cat "$checksum_file")"
pass "macOS cursor verifies the release checksum"

[[ $(<"$test_home/.config/omarchy/cursor-theme") == "macOS" ]] ||
  fail "macOS cursor writes the active theme state"
grep -Fq 'hl.env("XCURSOR_THEME", "macOS")' "$test_home/.config/hypr/cursor.lua" ||
  fail "macOS cursor persists the XCursor theme"
grep -Fq 'hl.env("XCURSOR_SIZE", "24")' "$test_home/.config/hypr/cursor.lua" ||
  fail "macOS cursor persists the XCursor size"
grep -Fq 'enable_hyprcursor = false' "$test_home/.config/hypr/cursor.lua" ||
  fail "macOS cursor enables Hyprland's XCursor fallback"
if grep -Fq 'HYPRCURSOR_THEME' "$test_home/.config/hypr/cursor.lua"; then
  fail "macOS cursor does not masquerade as a Hyprcursor theme"
fi
pass "macOS cursor persists its managed XCursor state"

grep -Fxq $'hyprctl\treload' "$log_file" ||
  fail "macOS cursor reloads Hyprland" "$(cat "$log_file")"
grep -Fxq $'hyprctl\tsetcursor macOS 24' "$log_file" ||
  fail "macOS cursor reloads Hyprland's XCursor manager" "$(cat "$log_file")"
[[ $(grep -n $'hyprctl\t' "$log_file") == *$'reload\n'*$'setcursor macOS 24' ]] ||
  fail "macOS cursor enables XCursor mode before changing the live theme" "$(cat "$log_file")"
grep -Fxq $'gsettings\tset org.gnome.desktop.interface cursor-theme macOS' "$log_file" ||
  fail "macOS cursor applies to GTK" "$(cat "$log_file")"
pass "macOS cursor applies to the running desktop"

grep -Fq '"style.cursor.macos"' "$ROOT/default/omarchy/omarchy-menu.jsonc" ||
  fail "macOS cursor is present in the Style menu"
pass "macOS cursor is present in the Style menu"
