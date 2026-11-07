#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

conf="$ROOT/etc/xdg-desktop-portal/hyprland-portals.conf"

[[ -f $conf ]] || fail "Hyprland portal override is shipped"

grep -qxF 'org.freedesktop.impl.portal.Inhibit=none' "$conf" ||
  fail "Inhibit portal is disabled so browsers fall back to Wayland idle-inhibit"

grep -qxF 'default=hyprland;gtk' "$conf" ||
  fail "portal default keeps hyprland before gtk"

pass "Inhibit portal override lets video playback hold off the screensaver"
