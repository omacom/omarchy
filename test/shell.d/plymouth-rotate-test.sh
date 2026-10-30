#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

require_command jq

# The real command, with the drop-in it writes moved into a scratch directory.
rtmp=$(mktemp -d)
trap 'rm -rf "$rtmp"' EXIT
mkdir -p "$rtmp/bin"
drop_in=$rtmp/limine-entry-tool.d/monitor-rotation.conf
sed "s|/etc/limine-entry-tool.d|$rtmp/limine-entry-tool.d|g" "$ROOT/bin/omarchy-plymouth-rotate" >"$rtmp/rotate"

printf '#!/bin/bash\nexit 1\n' >"$rtmp/bin/omarchy-cmd-missing"
printf '#!/bin/bash\n:\n' >"$rtmp/bin/omarchy-state"
printf '#!/bin/bash\nexec "$@"\n' >"$rtmp/bin/sudo"
printf '#!/bin/bash\n[[ -z $HYPRCTL_FAIL ]] && cat "$MONITORS_JSON"\n' >"$rtmp/bin/hyprctl"
printf '#!/bin/bash\necho rebuilt >>"$REBUILD_LOG"\n' >"$rtmp/bin/limine-mkinitcpio"
chmod +x "$rtmp/bin/"*

rotate() {
  printf '%s\n' "$1" >"$rtmp/monitors.json"
  : >"$rtmp/rebuilds"
  env PATH="$rtmp/bin:$PATH" MONITORS_JSON="$rtmp/monitors.json" REBUILD_LOG="$rtmp/rebuilds" \
    HYPRCTL_FAIL="${HYPRCTL_FAIL:-}" bash "$rtmp/rotate" >"$rtmp/out" 2>&1
}

# Plymouth turns a left-side-up screen counter-clockwise, which is what a 90°
# transform does on the desktop, so swapping the two turns the boot screen
# upside down. The drop-in is sourced as root, so a name with shell in it stays
# out.
rotate '[{"name":"DP-1","transform":0},{"name":"DP-2","transform":1},{"name":"eDP-1","transform":3},{"name":"DP-3\"$(touch pwned)","transform":1}]' ||
  fail "rotate writes the rotated monitors" "$(<"$rtmp/out")"
[[ $(tail -n1 "$drop_in") == 'KERNEL_CMDLINE[default]+=" video=DP-2:panel_orientation=left_side_up video=eDP-1:panel_orientation=right_side_up"' ]] ||
  fail "rotate maps transforms 1 and 3 to the orientations Plymouth corrects them with" "$(<"$drop_in")"
[[ -s $rtmp/rebuilds ]] || fail "rotate rebuilds the boot image"
pass "rotate maps monitor transforms to panel orientations and refuses unsafe names"

# A compositor that does not answer must not undo the rotation.
HYPRCTL_FAIL=1 rotate '' && fail "rotate fails when Hyprland does not answer"
[[ -f $drop_in && ! -s $rtmp/rebuilds ]] || fail "rotate keeps the boot rotation when Hyprland does not answer"
pass "rotate keeps the boot rotation when Hyprland does not answer"

# Turning the monitor upright again must reach the boot screen too.
rotate '[{"name":"DP-1","transform":0},{"name":"DP-2","transform":0}]' || fail "rotate on upright monitors" "$(<"$rtmp/out")"
[[ ! -e $drop_in && -s $rtmp/rebuilds ]] || fail "rotate clears the boot rotation once no monitor is rotated"
pass "rotate clears the boot rotation once no monitor is rotated"
