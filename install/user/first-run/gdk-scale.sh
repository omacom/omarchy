#!/bin/bash

# Match GDK_SCALE to the displays this machine actually has. The monitors.lua
# template ships omarchy_gdk_scale = 2 for HiDPI panels, but its "auto" monitor
# scale resolves 1080p and smaller displays to 1x, where GDK_SCALE=2 doubles
# every XWayland window (Steam, Java apps) past its own bounds. Runs at
# first-run rather than at finalize-user time because the monitors only exist
# once the session is up.
#
# Only the untouched template is changed: a monitors.lua the user already
# edited is left alone.

set -euo pipefail

monitor_lua="$HOME/.config/hypr/monitors.lua"

[[ -f $monitor_lua ]] || exit 0
grep -qx 'local omarchy_monitor_scale = "auto"' "$monitor_lua" || exit 0
grep -qx 'local omarchy_gdk_scale = 2' "$monitor_lua" || exit 0

# GTK only honors whole numbers, so round each monitor's scale the way
# omarchy-hyprland-monitor-scaling does, and keep the largest: a HiDPI panel
# in a mixed setup still gets 2x.
gdk_scale=$(hyprctl monitors -j | jq -r '[.[].scale | . + 0.5 | floor] | max // empty') || exit 0
[[ $gdk_scale =~ ^[1-9]$ ]] || exit 0
((gdk_scale != 2)) || exit 0

sed -i "s|^local omarchy_gdk_scale = 2\$|local omarchy_gdk_scale = $gdk_scale|" "$monitor_lua"

# Apps launched from now on get the new value. Processes already running keep
# the login-time one until the next login.
hyprctl eval "hl.env(\"GDK_SCALE\", \"$gdk_scale\")" >/dev/null || true
dbus-update-activation-environment --systemd GDK_SCALE="$gdk_scale" || true
