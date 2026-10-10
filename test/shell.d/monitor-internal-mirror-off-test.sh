#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

tmpdir=$(mktemp -d)
trap 'rm -rf "$tmpdir"' EXIT

stub_dir="$tmpdir/bin"
home_dir="$tmpdir/home"
flag_dir="$home_dir/.local/state/omarchy/toggles/hypr"
mkdir -p "$stub_dir" "$flag_dir"

make_stub() {
  printf '#!/bin/bash\n%s\n' "$2" >"$stub_dir/$1"
  chmod +x "$stub_dir/$1"
}

make_stub omarchy-notification-send ':'
make_stub omarchy-hyprland-monitor-external-active 'exit 0'
make_stub omarchy-hyprland-monitor-laptop 'echo eDP-1'
make_stub hyprctl ':'

disable_flag="$flag_dir/internal-monitor-disable.lua"
mirror_flag="$flag_dir/internal-monitor-mirror.lua"

# The real toggle helpers run, so the flags on disk are what Hyprland would source.
printf 'hl.monitor({ output = "DP-3", mirror = "eDP-1" })\n' >"$mirror_flag"
HOME="$home_dir" OMARCHY_PATH="$ROOT" PATH="$stub_dir:$ROOT/bin:$PATH" \
  "$ROOT/bin/omarchy-hyprland-monitor-internal" toggle

[[ ! -e $mirror_flag ]] || fail "toggling the laptop display off while mirrored drops the mirror"
grep -Fx 'hl.monitor({ output = "eDP-1", disabled = true })' "$disable_flag" >/dev/null ||
  fail "toggling the laptop display off while mirrored disables it"
pass "laptop display toggles off from a mirrored state"
