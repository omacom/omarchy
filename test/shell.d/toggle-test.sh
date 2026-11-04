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

HOME="$test_home" omarchy-toggle-bar on
[[ -f $bar_flag ]] || fail "bar on enables bar-off toggle"
pass "bar on enables bar-off toggle"

HOME="$test_home" omarchy-toggle-bar on
[[ -f $bar_flag ]] || fail "bar on is idempotent"
pass "bar on is idempotent"

HOME="$test_home" omarchy-toggle-bar off
[[ ! -f $bar_flag ]] || fail "bar off disables bar-off toggle"
pass "bar off disables bar-off toggle"

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

HOME="$test_home" omarchy-toggle-bar on
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

ratio_flag="$test_home/.local/state/omarchy/toggles/hypr/single-window-aspect-ratio.lua"

HOME="$test_home" omarchy-hyprland-window-single-square-aspect-toggle
[[ -f $ratio_flag ]] || fail "square aspect toggle places the single-window-aspect-ratio flag"
pass "square aspect toggle places the single-window-aspect-ratio flag"

HOME="$test_home" omarchy-hyprland-window-single-square-aspect-toggle
[[ ! -f $ratio_flag ]] || fail "square aspect toggle removes the single-window-aspect-ratio flag"
pass "square aspect toggle removes the single-window-aspect-ratio flag"

if command -v lua >/dev/null; then
  ratio_load() {
    local dir="$TMPDIR/ratio_load"
    rm -rf "$dir"
    mkdir -p "$dir"
    cp "$ROOT/default/hypr/toggles/single-window-aspect-ratio.lua" "$dir/"
    ROOT="$ROOT" DIR="$dir" lua - <<'LUA'
package.path = os.getenv("ROOT") .. "/?.lua;" .. os.getenv("DIR") .. "/?.lua;" .. package.path
local ratio, fs_one_col
hl = {
  config = function(c)
    if c.layout and c.layout.single_window_aspect_ratio then ratio = c.layout.single_window_aspect_ratio end
    if c.scrolling and c.scrolling.fullscreen_on_one_column ~= nil then fs_one_col = c.scrolling.fullscreen_on_one_column end
  end
}
require("default.hypr.require_all").files(os.getenv("DIR"), nil, { reload = true })
if ratio and ratio[1] == 1 and ratio[2] == 1 and fs_one_col == false then
  print("ok")
else
  print("fail")
end
LUA
  }
  [[ $(ratio_load) == "ok" ]] || fail "single-window-aspect-ratio sets layout ratio and disables scrolling fullscreen_on_one_column"
  pass "single-window-aspect-ratio configures both layout aspect ratio and scrolling mode"
fi
animations_flag="$test_home/.local/state/omarchy/toggles/hypr/no-animations.lua"

HOME="$test_home" omarchy-toggle-animations off
[[ -f $animations_flag ]] || fail "animations off places the no-animations flag"
HOME="$test_home" omarchy-toggle-animations on
[[ ! -f $animations_flag ]] || fail "animations on removes the no-animations flag"
HOME="$test_home" omarchy-toggle-animations
[[ -f $animations_flag ]] || fail "toggling animations flips the flag"
pass "animations toggle turns the no-animations flag the right way round"

# A session that renders on the CPU has animations off without the flag;
# turning them on there is remembered, and turning them off forgets it.
cpu_runtime="$TMPDIR/run"
mkdir -p "$cpu_runtime/hypr/cpu"
touch "$cpu_runtime/hypr/cpu/omarchy-software-rendering"
without_gpu="$test_home/.local/state/omarchy/toggles/animations-without-gpu"
cpu_session() {
  HOME="$test_home" XDG_RUNTIME_DIR="$cpu_runtime" HYPRLAND_INSTANCE_SIGNATURE=cpu "$@"
}
rm -f "$animations_flag"
cpu_session omarchy-hyprland-animations-off || fail "a CPU session counts animations as off without the flag"
cpu_session omarchy-toggle-animations
[[ -f $without_gpu && ! -f $animations_flag ]] || fail "turning animations on in a CPU session is remembered"
! cpu_session omarchy-hyprland-animations-off || fail "animations turned on in a CPU session count as on"
cpu_session omarchy-toggle-animations
[[ ! -f $without_gpu && -f $animations_flag ]] || fail "turning animations off again forgets the choice"
rm -f "$animations_flag"
printf '#!/bin/bash\necho %s\n' "'{\"bool\": true}'" >"$stub_bin/hyprctl"
! cpu_session omarchy-hyprland-animations-off || fail "animations the user's looknfeel.lua kept on in a CPU session count as on"
printf '#!/bin/bash\nexit 0\n' >"$stub_bin/hyprctl"
pass "the animations toggle works in a session that renders on the CPU"

# A VM install starts without animations; other machines keep them.
for virt in vm none; do
  rm -rf "$test_home/.local/state/omarchy/toggles/hypr"
  printf '#!/bin/bash\n[[ %s == vm ]]\n' "$virt" >"$stub_bin/omarchy-hw-vm"
  chmod +x "$stub_bin/omarchy-hw-vm"
  HOME="$test_home" OMARCHY_PATH="$ROOT" bash "$ROOT/install/user/hardware/vm-no-animations.sh" >/dev/null
  if [[ $virt == "vm" ]]; then
    [[ -f $animations_flag ]] || fail "a VM install turns animations off"
    [[ -f ${animations_flag%/*}/window-opaque.lua ]] || fail "a VM install starts with opaque windows"
  else
    [[ ! -f $animations_flag ]] || fail "a machine that is not a VM keeps its animations"
    [[ ! -f ${animations_flag%/*}/window-opaque.lua ]] || fail "a machine that is not a VM keeps transparent windows"
  fi
done
pass "a VM install starts without animations and with opaque windows"
