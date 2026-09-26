#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

require_command jq

tmpdir=$(mktemp -d)
trap 'rm -rf "$tmpdir"' EXIT

stub_dir="$tmpdir/bin"
home_dir="$tmpdir/home"
monitors_json="$tmpdir/monitors.json"
flag_dir="$home_dir/.local/state/omarchy/toggles/hypr"
mkdir -p "$stub_dir" "$flag_dir"

disable_flag="$flag_dir/internal-monitor-disable.lua"
clamshell_flag="$flag_dir/internal-monitor-clamshell.lua"

make_stub() {
  local name=$1
  local body=$2
  printf '#!/bin/bash\n%s\n' "$body" >"$stub_dir/$name"
  chmod +x "$stub_dir/$name"
}

make_stub omarchy-notification-send ':'
make_stub omarchy-hyprland-monitor-external-active 'exit 0'
make_stub omarchy-hyprland-monitor-internal ':'
make_stub omarchy-hyprland-monitor-internal-mirror ':'
make_stub omarchy-hw-clamshell 'exit 0'
make_stub omarchy-hyprland-monitor-laptop 'printf "%s\n" eDP-1'
make_stub hyprctl 'case "$1 $2" in
  "monitors all") cat "$MONITORS_JSON" ;;
esac'

printf '[{"name":"eDP-1","disabled":false,"scale":1.6}]\n' >"$monitors_json"

run() {
  local command=$1
  shift
  HOME="$home_dir" \
    XDG_STATE_HOME="$home_dir/.local/state" \
    MONITORS_JSON="$monitors_json" \
    PATH="$stub_dir:$ROOT/bin:$PATH" \
    "$ROOT/bin/$command" "$@"
}

# A crash between the truncate and the write leaves a flag that every reader
# believes and that applies nothing. It is the file's contents that disable the
# panel, so an empty one is corruption, never a state a user can be in.
: >"$disable_flag"

run omarchy-hyprland-toggle-enabled internal-monitor-disable &&
  fail "a zero-length flag does not read as enabled"
pass "a zero-length flag does not read as enabled"

run omarchy-hyprland-toggle-disabled internal-monitor-disable ||
  fail "a zero-length flag reads as disabled"
pass "a zero-length flag reads as disabled"

# A directory carries a nonzero size, so a size test on its own would call one
# an active flag that the loader's `find -type f` never sources.
rm -f "$disable_flag"
mkdir "$disable_flag"
run omarchy-hyprland-toggle-enabled internal-monitor-disable &&
  fail "only a regular file reads as an enabled flag"
pass "only a regular file reads as an enabled flag"
rmdir "$disable_flag"
: >"$disable_flag"

rm -f "$clamshell_flag"
run omarchy-hyprland-monitor-clamshell
grep -Fx 'hl.monitor({ output = "eDP-1", disabled = true })' "$clamshell_flag" >/dev/null ||
  fail "a zero-length manual flag does not veto the clamshell disable" \
    "clamshell flag: $(cat "$clamshell_flag" 2>&1)"
pass "clamshell disables the panel despite a zero-length manual flag"

# The writer is the only thing that creates these flags, so the invariant every
# reader depends on belongs here: absent or whole, never empty.
rm -f "$disable_flag"
printf 'hl.monitor({ output = "eDP-1", disabled = true })\n' |
  run omarchy-hyprland-toggle-write internal-monitor-disable
grep -Fx 'hl.monitor({ output = "eDP-1", disabled = true })' "$disable_flag" >/dev/null ||
  fail "the writer installs the flag it was given"
pass "the writer installs the flag it was given"

: | run omarchy-hyprland-toggle-write internal-monitor-disable &&
  fail "the writer refuses an empty body"
grep -Fx 'hl.monitor({ output = "eDP-1", disabled = true })' "$disable_flag" >/dev/null ||
  fail "a refused write leaves the previous flag intact" \
    "flag is now: $(cat "$disable_flag" 2>&1)"
pass "the writer refuses an empty body and leaves the previous flag intact"

[[ -z $(find "$flag_dir" -name '.internal-monitor-disable.*' -print -quit) ]] ||
  fail "the writer leaves no temporary file behind" \
    "$(find "$flag_dir" -name '.internal-monitor-disable.*')"
pass "the writer leaves no temporary file behind"

# off() used to redirect straight into a directory that may not exist yet, then
# notify and reload as though it had written something.
rm -rf "$home_dir/.local"
run omarchy-hyprland-monitor-internal off
grep -Fx 'hl.monitor({ output = "eDP-1", disabled = true })' "$disable_flag" >/dev/null ||
  fail "disabling the panel creates the toggles directory it writes into"
pass "disabling the panel creates the toggles directory it writes into"
