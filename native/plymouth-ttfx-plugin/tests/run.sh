#!/bin/bash
set -euo pipefail
root=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
engine_include="$root/../plymouth-ttfx-engine/include"
state_output=$(mktemp "${TMPDIR:-/var/tmp}/plymouth-ttfx-state-test.XXXXXX")
lifecycle_output=$(mktemp "${TMPDIR:-/var/tmp}/plymouth-ttfx-lifecycle-test.XXXXXX")
activation_output=$(mktemp "${TMPDIR:-/var/tmp}/plymouth-ttfx-activation-test.XXXXXX")
handoff_output=$(mktemp "${TMPDIR:-/var/tmp}/plymouth-ttfx-handoff-test.XXXXXX")
pixelbuffer_output=$(mktemp "${TMPDIR:-/var/tmp}/plymouth-ttfx-pixelbuffer-test.XXXXXX")
trap 'rm -f "$state_output" "$lifecycle_output" "$activation_output" "$handoff_output" "$pixelbuffer_output"' EXIT
cflags=(-std=c11 -Wall -Wextra -Wpedantic -Werror -fno-omit-frame-pointer \
  -fsanitize=address,undefined)
"$root/generate-embedded-logo.py" --check
gcc "${cflags[@]}" -I"$root" \
  "$root/tests/state-test.c" "$root/state.c" -o "$state_output"
ASAN_OPTIONS=detect_leaks=1 UBSAN_OPTIONS=halt_on_error=1 "$state_output"
gcc "${cflags[@]}" -I"$root" -I"$root/tests/stubs" -I"$engine_include" \
  "$root/tests/plugin-lifecycle-test.c" "$root/state.c" -o "$lifecycle_output"
ASAN_OPTIONS=detect_leaks=1 UBSAN_OPTIONS=halt_on_error=1 "$lifecycle_output"
(
  cd "$root/../plymouth-ttfx-engine"
  cargo build --locked --offline --profile plymouth
)
gcc -std=c11 -Wall -Wextra -Wpedantic -Werror -I"$root" -I"$engine_include" \
  "$root/tests/real-engine-activation-test.c" \
  "$root/../plymouth-ttfx-engine/target/plymouth/libttfx_plymouth.a" \
  -ldl -lpthread -lm -o "$activation_output"
"$activation_output"
gcc "${cflags[@]}" -I"$root" "$root/tests/handoff-test.c" -o "$handoff_output"
ASAN_OPTIONS=detect_leaks=1 UBSAN_OPTIONS=halt_on_error=1 "$handoff_output"
if pkg-config --exists ply-splash-graphics ply-splash-core; then
  # As in the module build, Plymouth's headers are system headers: they are
  # not -Wpedantic clean on every gcc.
  plymouth_cflags=()
  for flag in $(pkg-config --cflags ply-splash-graphics ply-splash-core); do
    if [[ $flag == -I* ]]; then
      plymouth_cflags+=(-isystem "${flag#-I}")
    else
      plymouth_cflags+=("$flag")
    fi
  done
  gcc -std=c11 -Wall -Wextra -Wpedantic -Werror -I"$root" "${plymouth_cflags[@]}" \
    "$root/tests/real-pixelbuffer-test.c" "$root/state.c" \
    $(pkg-config --libs ply-splash-graphics ply-splash-core) \
    -o "$pixelbuffer_output"
  "$pixelbuffer_output"
else
  printf 'real Plymouth pixelbuffer: SKIP (pkg-config dependencies unavailable)\n'
fi
"$root/tests/contract.sh"
