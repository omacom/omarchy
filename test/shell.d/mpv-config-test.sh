#!/bin/bash

set -euo pipefail
source "$(dirname "${BASH_SOURCE[0]}")/base-test.sh"

if ! command -v mpv >/dev/null; then
  skip "mpv is not installed, so the shipped system config cannot be loaded"
  exit 0
fi

test_dir=$(mktemp -d)
trap 'rm -rf "$test_dir"' EXIT

# Print the hwdec option mpv settles on after reading its config files. mpv's
# own output is kept, so a failure shows why mpv could not load the config.
configured_hwdec() {
  local output
  output=$(mpv --no-config "$@" --vo=null --ao=null --frames=1 --term-status-msg= \
    --term-playing-msg='hwdec=${hwdec}' av://lavfi:testsrc 2>&1) ||
    fail "mpv loads the config and plays a test source" "$output"
  sed -n 's/^hwdec=//p' <<<"$output"
}

stock=$(configured_hwdec)
[[ $stock == "no" ]] || fail "mpv's own default is software decoding" "got: $stock"

shipped=$(configured_hwdec --include="$ROOT/etc/mpv/mpv.conf")
[[ $shipped == "auto-safe" ]] || fail "the shipped system config turns on safe hardware decoding" "got: $shipped"
pass "the shipped system config turns on safe hardware decoding"

# mpv reads /etc/mpv/mpv.conf before ~/.config/mpv/mpv.conf, so a user's choice wins.
echo "hwdec=no" >"$test_dir/user.conf"
layered=$(configured_hwdec --include="$ROOT/etc/mpv/mpv.conf" --include="$test_dir/user.conf")
[[ $layered == "no" ]] || fail "a user config read after the system config keeps its hwdec" "got: $layered"
pass "a user config read after the system config keeps its hwdec"
