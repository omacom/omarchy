#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

# systemd-xdg-autostart-generator names the unit after the desktop file that
# limine-snapper-sync ships, so the drop-in only applies under this exact name.
unit="app-$(systemd-escape limine-restore-notify)@autostart.service"
dropin="$ROOT/etc/systemd/user/$unit.d/10-wait-for-notifications.conf"

[[ -f $dropin ]] || fail "snapshot restore offer has a drop-in for $unit"
grep -Fx '[Service]' "$dropin" >/dev/null || fail "snapshot restore drop-in sets service options"
grep -Fx 'ExecStartPre=-/usr/bin/omarchy-notification-wait 30' "$dropin" >/dev/null ||
  fail "snapshot restore offer waits for the notification server, bounded and non-fatal"
[[ -x $ROOT/bin/omarchy-notification-wait ]] || fail "notification wait helper ships as a command"
pass "snapshot restore offer waits for the shell before notifying"
