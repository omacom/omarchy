#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

if grep -rlE '^(Path[A-Za-z]+|DirectoryNotEmpty)=.*/usr/share/omarchy/migrations' "$ROOT/default/systemd/user" >/dev/null 2>&1; then
  fail "a user unit watches the migration directory again; the notifier must stay login-only"
fi
pass "no unit watches the migration directory, so package updates cannot trigger the notifier"

# Hyprland lives in session.slice/wayland-wm@hyprland.desktop.service. Marking
# any ancestor of that as a kill candidate puts the compositor back in the
# victim pool, which is the crash this whole thing exists to prevent.
oomd_slice="$ROOT/default/systemd/user/app.slice.d/10-oomd.conf"
candidates=$(grep -rlE '^ManagedOOM(MemoryPressure|Swap)=kill' "$ROOT/default/systemd" "$ROOT/etc/systemd" 2>/dev/null || true)
[[ $candidates == "$oomd_slice" ]] ||
  fail "systemd-oomd kill candidacy must be set on app.slice and nowhere else: $candidates"
pass "only user app scopes are systemd-oomd kill candidates"

recover="$ROOT/bin/omarchy-system-sddm-recover"
tmpdir=$(mktemp -d)
trap 'rm -rf "$tmpdir"' EXIT

gpd_rotate="$ROOT/default/systemd/user/omarchy-gpd-pocket-4-rotate.service"
grep -Fx 'ExecCondition=${OMARCHY_PATH}/bin/omarchy-hw-gpd-pocket-4' "$gpd_rotate" >/dev/null ||
  fail "the GPD rotate unit restart-loops on machines without the hardware"
grep -F 'omarchy-gpd-pocket-4-rotate.service' "$first_run_units" >/dev/null ||
  fail "first-run does not enable GPD Pocket 4 rotation"
pass "first-run enables GPD Pocket 4 rotation, inert off-hardware"

grep -Fx 'systemctl enable systemd-oomd.service' "$ROOT/install/config/enable-services.sh" >/dev/null ||
  fail "new installs ship the oomd drop-ins with the daemon that reads them disabled"
pass "new installs enable systemd-oomd"
