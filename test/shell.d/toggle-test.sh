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
[[ -f $bar_flag ]] || fail "bar off hides the bar (sets bar-off)"
pass "bar off hides the bar (sets bar-off)"

HOME="$test_home" omarchy-toggle-bar off
[[ -f $bar_flag ]] || fail "bar off is idempotent"
pass "bar off is idempotent"

HOME="$test_home" omarchy-toggle-bar on
[[ ! -f $bar_flag ]] || fail "bar on shows the bar (clears bar-off)"
pass "bar on shows the bar (clears bar-off)"

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

# The flag records animations being off, so on and off are the other way round.
printf '#!/bin/bash\nexit 0\n' >"$stub_bin/omarchy-notification-send"
chmod +x "$stub_bin/omarchy-notification-send"
animations_flag="$test_home/.local/state/omarchy/toggles/hypr/no-animations.lua"

HOME="$test_home" omarchy-toggle-animations off
[[ -f $animations_flag ]] || fail "animations off places the no-animations flag"
HOME="$test_home" omarchy-toggle-animations on
[[ ! -f $animations_flag ]] || fail "animations on removes the no-animations flag"
HOME="$test_home" omarchy-toggle-animations
[[ -f $animations_flag ]] || fail "toggling animations flips the flag"
pass "animations toggle turns the no-animations flag the right way round"

# A VM install starts without animations; other machines keep them.
for virt in vm none; do
  rm -rf "$test_home/.local/state/omarchy/toggles/hypr"
  printf '#!/bin/bash\n[[ %s == vm ]]\n' "$virt" >"$stub_bin/omarchy-hw-vm"
  chmod +x "$stub_bin/omarchy-hw-vm"
  HOME="$test_home" OMARCHY_PATH="$ROOT" bash "$ROOT/install/user/hardware/vm-no-animations.sh" >/dev/null
  if [[ $virt == "vm" ]]; then
    [[ -f $animations_flag ]] || fail "a VM install turns animations off"
  else
    [[ ! -f $animations_flag ]] || fail "a machine that is not a VM keeps its animations"
  fi
done
pass "a VM install starts without animations"
