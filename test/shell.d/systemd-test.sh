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

oomd_generator="$ROOT/default/systemd/user-generators/omarchy-oomd-generator"
[[ -x $oomd_generator ]] ||
  fail "app.slice candidacy is not installed through an executable user generator"

oomd_generator_test=$(mktemp -d)
mkdir -p "$oomd_generator_test/proc" "$oomd_generator_test/private-output"
OMARCHY_OOMD_PROC_ROOT="$oomd_generator_test/proc" \
  OMARCHY_OOMD_DROPIN="$oomd_slice" \
  "$oomd_generator" "$oomd_generator_test/private-output"
[[ ! -e $oomd_generator_test/private-output/app.slice.d/10-oomd.conf ]] ||
  fail "OOM candidacy is generated when procfs hides PID 1, which makes app.slice unloadable"

mkdir -p "$oomd_generator_test/proc/1" "$oomd_generator_test/normal-output"
touch "$oomd_generator_test/proc/1/cgroup"
OMARCHY_OOMD_PROC_ROOT="$oomd_generator_test/proc" \
  OMARCHY_OOMD_DROPIN="$oomd_slice" \
  "$oomd_generator" "$oomd_generator_test/normal-output"
[[ $(readlink "$oomd_generator_test/normal-output/app.slice.d/10-oomd.conf") == "$oomd_slice" ]] ||
  fail "OOM candidacy is not generated when systemd can inspect PID 1's cgroup"
rm -rf "$oomd_generator_test"
pass "systemd-oomd candidacy stays compatible with private procfs mounts"
