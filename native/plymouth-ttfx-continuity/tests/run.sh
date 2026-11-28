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
# The desktop outro links the TTFX engine (built with cargo unless
# TTFX_ENGINE_LIB names libttfx_plymouth.a).
outro_output=$(mktemp "${TMPDIR:-/var/tmp}/omarchy-continuity-outro-test.XXXXXX")
engine=${TTFX_ENGINE_LIB:-}
if [[ -z $engine ]]; then
  engine_target=$(mktemp -d "${TMPDIR:-/var/tmp}/omarchy-continuity-engine.XXXXXX")
  (cd "$root/../plymouth-ttfx-engine" &&
    CARGO_TARGET_DIR="$engine_target" cargo build --locked --offline --profile plymouth >/dev/null 2>&1)
  engine=$engine_target/plymouth/libttfx_plymouth.a
fi
gcc "${cflags[@]}" -I"$root" "$root/tests/outro-test.c" "$root/outro.c" \
  "$root/../plymouth-ttfx-plugin/state.c" "$engine" -ldl -lpthread -lm -o "$outro_output"
# The engine interns glyph visuals in a process-wide cache on purpose (as
# in the plugin's real-engine test), so leak detection stays off here.
ASAN_OPTIONS=detect_leaks=0 UBSAN_OPTIONS=halt_on_error=1 "$outro_output"
rm -f "$outro_output"
outro_fixture=$(mktemp "${TMPDIR:-/var/tmp}/omarchy-continuity-outro-fixture.XXXXXX")
gcc -std=c11 -O2 -Wall -Wextra -Werror -I"$root" "$root/tests/outro-fixture.c" "$root/outro.c" \
  "$root/../plymouth-ttfx-plugin/state.c" "$engine" -ldl -lpthread -lm -o "$outro_fixture"
export OMARCHY_CONTINUITY_OUTRO_FIXTURE=$outro_fixture
bash -n "$root/omarchy-plymouth-continuity-run"
"$root/tests/launcher-test.sh"
if pkg-config --exists wayland-client wayland-protocols && command -v wayland-scanner >/dev/null; then
  build_dir=$(mktemp -d "${TMPDIR:-/var/tmp}/omarchy-continuity-build.XXXXXX")
  TTFX_ENGINE_LIB=$engine "$root/build.sh" "$build_dir" >/dev/null
  printf 'continuity client build: PASS (%s)\n' "$build_dir/omarchy-plymouth-continuity"
  bash "$root/tests/wayland-test.sh" "$build_dir/omarchy-plymouth-continuity"
else
  printf 'continuity client build: SKIP (wayland development files unavailable)\n'
fi
