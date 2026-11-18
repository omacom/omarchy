#!/bin/bash
#
# D-Bus can start xdg-desktop-portal before Hyprland imports the session
# environment. The import and the restart have to be one command, or the new
# portal can come up before WAYLAND_DISPLAY and QT_QPA_PLATFORM are published.

set -euo pipefail

source "$(dirname "${BASH_SOURCE[0]}")/base-test.sh"

autostart="$ROOT/default/hypr/autostart.lua"
chain='dbus-update-activation-environment --systemd --all && systemctl --user restart xdg-desktop-portal.service'

grep -qF "$chain" "$autostart" \
  || fail "autostart replaces the portal after importing the session environment" \
    "$(grep -n 'dbus-update-activation-environment' "$autostart")"

pass "autostart replaces the portal after importing the session environment"
