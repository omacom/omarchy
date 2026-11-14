#!/bin/bash

set -euo pipefail
source "$(dirname "$0")/base-test.sh"

tmp=$(mktemp -d)
trap 'rm -rf "$tmp"' EXIT
mkdir -p "$tmp/photos" "$tmp/album"
printf 'P3\n1 1\n255\n0 0 255\n' >"$tmp/photos/original.ppm"
ln -s ../photos/original.ppm "$tmp/album/cover.ppm"

# Exercise the real MIME probe, recording where the converter would write.
magick() { touch "${@: -1}"; }
wl-copy() { cat >/dev/null; }
omarchy-notification-send() { :; }
export -f magick wl-copy omarchy-notification-send
export PATH="$ROOT/bin:$PATH"
unset POSIXLY_CORRECT

"$ROOT/bin/omarchy-transcode" "$tmp/album/cover.ppm" png low
[[ -f $tmp/album/cover-low.png ]] || fail "transcode writes output beside the selected link"
pass "transcode recognizes the linked image and uses the selected name"
