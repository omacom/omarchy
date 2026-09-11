#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

TMPDIR=""

export PATH="$ROOT/bin:$PATH"

cleanup() {
  if [[ -n $TMPDIR && -d $TMPDIR ]]; then
    rm -rf "$TMPDIR"
  fi
}
trap cleanup EXIT

TMPDIR=$(mktemp -d)
test_home="$TMPDIR/home"
flag="$test_home/.local/state/omarchy/toggles/example"
bar_flag="$test_home/.local/state/omarchy/toggles/bar-off"

HOME="$test_home" omarchy-toggle example on
[[ -f $flag ]] || fail "generic toggle enables explicit on state"
pass "generic toggle enables explicit on state"

HOME="$test_home" omarchy-toggle example on
[[ -f $flag ]] || fail "generic toggle on is idempotent"
pass "generic toggle on is idempotent"

HOME="$test_home" omarchy-toggle example off
[[ ! -f $flag ]] || fail "generic toggle disables explicit off state"
pass "generic toggle disables explicit off state"

HOME="$test_home" omarchy-toggle example
[[ -f $flag ]] || fail "generic toggle flips disabled state on"
pass "generic toggle flips disabled state on"

HOME="$test_home" omarchy-toggle example toggle
[[ ! -f $flag ]] || fail "generic toggle flips enabled state off"
pass "generic toggle flips enabled state off"

HOME="$test_home" omarchy-toggle-bar off
[[ -f $bar_flag ]] || fail "bar off hides bar"
pass "bar off hides bar"

HOME="$test_home" omarchy-toggle-bar off
[[ -f $bar_flag ]] || fail "bar off is idempotent"
pass "bar off is idempotent"

HOME="$test_home" omarchy-toggle-bar on
[[ ! -f $bar_flag ]] || fail "bar on shows bar"
pass "bar on shows bar"

HOME="$test_home" omarchy-toggle-bar on
[[ ! -f $bar_flag ]] || fail "bar on is idempotent"
pass "bar on is idempotent"

HOME="$test_home" omarchy-toggle-bar toggle
[[ -f $bar_flag ]] || fail "bar toggle hides visible bar"
pass "bar toggle hides visible bar"

HOME="$test_home" omarchy-toggle-bar
[[ ! -f $bar_flag ]] || fail "bare bar toggle shows hidden bar"
pass "bare bar toggle shows hidden bar"

# The gaps half of full screen copies a flag file in and reloads Hyprland, so
# give it this checkout to copy from and a hyprctl that answers without a
# compositor.
export OMARCHY_PATH="$ROOT"
stub_bin="$TMPDIR/bin"
mkdir -p "$stub_bin"
printf '#!/bin/bash\nexit 0\n' >"$stub_bin/hyprctl"
chmod +x "$stub_bin/hyprctl"
export PATH="$stub_bin:$PATH"

gaps_flag="$test_home/.local/state/omarchy/toggles/hypr/window-no-gaps.lua"

HOME="$test_home" omarchy-toggle-fullscreen-desktop
[[ -f $bar_flag && -f $gaps_flag ]] || fail "fullscreen toggle hides the bar and the gaps together"
pass "fullscreen toggle hides the bar and the gaps together"

HOME="$test_home" omarchy-toggle-fullscreen-desktop
[[ ! -f $bar_flag && ! -f $gaps_flag ]] || fail "fullscreen toggle restores the bar and the gaps together"
pass "fullscreen toggle restores the bar and the gaps together"

HOME="$test_home" omarchy-toggle-bar off
HOME="$test_home" omarchy-toggle-fullscreen-desktop
[[ -f $bar_flag && -f $gaps_flag ]] || fail "fullscreen toggle pulls a half-hidden desktop into full screen"
pass "fullscreen toggle pulls a half-hidden desktop into full screen"

HOME="$test_home" omarchy-toggle-fullscreen-desktop off
[[ ! -f $bar_flag && ! -f $gaps_flag ]] || fail "fullscreen off leaves full screen"
pass "fullscreen off leaves full screen"

HOME="$test_home" omarchy-toggle-fullscreen-desktop on
[[ -f $bar_flag && -f $gaps_flag ]] || fail "fullscreen on enters full screen"
pass "fullscreen on enters full screen"
