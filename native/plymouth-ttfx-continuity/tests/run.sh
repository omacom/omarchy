#!/bin/bash
# Unit tests for the pure parsing/validation code, plus a full client build
# when the Wayland development files are present, and an end-to-end run under
# a headless sway when sway is installed.
set -euo pipefail
root=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
frame_output=$(mktemp "${TMPDIR:-/var/tmp}/omarchy-continuity-frame-test.XXXXXX")
trap 'rm -f "$frame_output"' EXIT
cflags=(-std=c11 -Wall -Wextra -Wpedantic -Werror -fno-omit-frame-pointer \
  -fsanitize=address,undefined)
gcc "${cflags[@]}" -I"$root" "$root/tests/frame-test.c" "$root/frame.c" -o "$frame_output"
ASAN_OPTIONS=detect_leaks=1 UBSAN_OPTIONS=halt_on_error=1 "$frame_output"
bash -n "$root/omarchy-plymouth-continuity-run"
"$root/tests/launcher-test.sh"
if pkg-config --exists wayland-client wayland-protocols && command -v wayland-scanner >/dev/null; then
  build_dir=$(mktemp -d "${TMPDIR:-/var/tmp}/omarchy-continuity-build.XXXXXX")
  "$root/build.sh" "$build_dir" >/dev/null
  printf 'continuity client build: PASS (%s)\n' "$build_dir/omarchy-plymouth-continuity"
  bash "$root/tests/wayland-test.sh" "$build_dir/omarchy-plymouth-continuity"
else
  printf 'continuity client build: SKIP (wayland development files unavailable)\n'
fi
