#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

require_command python3

scratch=$(mktemp -d)
trap 'rm -rf "$scratch"' EXIT
export HOME="$scratch/home" OMARCHY_PATH="$ROOT" PATH="$ROOT/bin:$PATH"
export OMARCHY_USER_NAME="Compose Person" OMARCHY_USER_EMAIL="compose@example.test"
mkdir -p "$HOME"

bash "$ROOT/install/user/xcompose.sh"

# Exercise libxkbcommon itself: one inaccessible include invalidates the whole
# table, including the user's identification sequences after it.
# A worker may have Omarchy installed at the host path. Hide that tree in a
# real mount namespace so the same regression still fails on its base branch.
compose_runner=()
run_compose=1
if [[ -d /usr/share/omarchy ]]; then
  if command -v bwrap >/dev/null; then
    compose_runner=(bwrap --die-with-parent --ro-bind / / --dev-bind /dev /dev --proc /proc --tmpfs /usr/share/omarchy --)
    if ! "${compose_runner[@]}" /usr/bin/true >"$scratch/bwrap.log" 2>&1; then
      skip "XCompose parsing without the host table (bubblewrap cannot create a sandbox)"
      run_compose=0
    fi
  else
    skip "XCompose parsing without the host table (bubblewrap is unavailable)"
    run_compose=0
  fi
fi

if (( run_compose )); then
  "${compose_runner[@]}" python3 - <<'PY'
import ctypes as c
import ctypes.util
import os
from pathlib import Path

library = ctypes.util.find_library("xkbcommon")
if not library:
    print("ok - XCompose parsing # SKIP libxkbcommon is unavailable")
    raise SystemExit
xkb = c.CDLL(library)
xkb.xkb_context_new.argtypes = [c.c_int]
xkb.xkb_context_new.restype = c.c_void_p
xkb.xkb_compose_table_new_from_buffer.argtypes = [c.c_void_p, c.c_char_p, c.c_size_t, c.c_char_p, c.c_int, c.c_int]
xkb.xkb_compose_table_new_from_buffer.restype = c.c_void_p
xkb.xkb_compose_state_new.argtypes = [c.c_void_p, c.c_int]
xkb.xkb_compose_state_new.restype = c.c_void_p
xkb.xkb_keysym_from_name.argtypes = [c.c_char_p, c.c_int]
xkb.xkb_keysym_from_name.restype = c.c_uint
xkb.xkb_compose_state_feed.argtypes = [c.c_void_p, c.c_uint]
xkb.xkb_compose_state_get_utf8.argtypes = [c.c_void_p, c.c_void_p, c.c_size_t]
context = xkb.xkb_context_new(0)
data = (Path.home() / ".XCompose").read_bytes()
table = xkb.xkb_compose_table_new_from_buffer(context, data, len(data), b"C.UTF-8", 1, 0)
assert table, "home-visible compose includes must compile without host Omarchy under /usr"
state = xkb.xkb_compose_state_new(table, 0)
for key in [b"Multi_key", b"space", b"n"]:
    xkb.xkb_compose_state_feed(state, xkb.xkb_keysym_from_name(key, 0))
result = c.create_string_buffer(128)
xkb.xkb_compose_state_get_utf8(state, result, len(result))
assert result.value.decode() == "Compose Person", result.value
print("ok - the generated XCompose table parses and preserves identification sequences")
PY
fi

# Refresh the real helper against an alternate packaged table, preserving a
# symlinked compose file and unrelated custom sequences during legacy repair.
mkdir -p "$scratch/package/default"
printf 'include "%%L"\n<Multi_key> <a> <a> : "A"\n' > "$scratch/package/default/xcompose"
printf 'include "/usr/share/omarchy/default/xcompose"\n<Multi_key> <z> <z> : "custom"\n' > "$HOME/custom-compose"
rm "$HOME/.XCompose"
ln -s custom-compose "$HOME/.XCompose"
OMARCHY_PATH="$scratch/package" bash "$ROOT/bin/omarchy-refresh-xcompose"
[[ -L $HOME/.XCompose ]] || fail "compose repair preserves a user's symlink"
grep -qFx 'include "%H/.XCompose.omarchy"' "$HOME/custom-compose" || fail "compose repair replaces the inaccessible packaged include"
grep -qFx '<Multi_key> <z> <z> : "custom"' "$HOME/custom-compose" || fail "compose repair preserves custom sequences"
cmp -s "$scratch/package/default/xcompose" "$HOME/.XCompose.omarchy" || fail "compose refresh updates the managed home table"
pass "compose refresh repairs legacy includes without replacing user content or symlinks"
