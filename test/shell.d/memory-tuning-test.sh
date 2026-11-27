#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

# 1. sysctl baseline raises swappiness for zram + MGLRU.
grep -Fqx 'vm.swappiness=100' "$ROOT/etc/sysctl.d/99-omarchy-sysctl.conf" ||
  fail "99-omarchy-sysctl.conf sets vm.swappiness=100"
pass "99-omarchy-sysctl.conf sets vm.swappiness=100"

# 2. systemd-oomd thresholds prevent long incompressible stalls and post-kill
#    collateral kills (avg10 decays from 100% below 60% in 5.1s < 10s).
oomd_conf="$ROOT/etc/systemd/oomd.conf.d/10-omarchy.conf"
grep -Fqx 'SwapUsedLimit=80%' "$oomd_conf" ||
  fail "10-omarchy.conf sets SwapUsedLimit=80%"
grep -Fqx 'DefaultMemoryPressureLimit=60%' "$oomd_conf" ||
  fail "10-omarchy.conf sets DefaultMemoryPressureLimit=60%"
grep -Fqx 'DefaultMemoryPressureDurationSec=10s' "$oomd_conf" ||
  fail "10-omarchy.conf sets DefaultMemoryPressureDurationSec=10s"
pass "systemd-oomd config sets 80% swap and 60%/10s pressure thresholds"

# 3. cgroup v2 MemoryLow=768M must be delegated across the full ancestor chain
#    from user.slice down to session.slice, without setting MemoryLow on app.slice.
for dropin in \
  "$ROOT/etc/systemd/system/user.slice.d/10-omarchy-memory.conf" \
  "$ROOT/etc/systemd/system/user-.slice.d/10-omarchy-memory.conf" \
  "$ROOT/etc/systemd/system/user@.service.d/20-omarchy-memory.conf" \
  "$ROOT/etc/systemd/user/session.slice.d/10-omarchy.conf"; do
  grep -Fqx 'MemoryLow=768M' "$dropin" ||
    fail "MemoryLow=768M must be set in $dropin"
done
if grep -q '^MemoryLow=' "$ROOT/default/systemd/user/app.slice.d/10-oomd.conf"; then
  fail "app.slice must not set MemoryLow so user apps remain reclaimable"
fi
pass "MemoryLow=768M is delegated down to session.slice only"

# 4. Compositor kernel-OOM shield: user@.service lowers floor to -200,
#    wayland-wm@.service opts into -200, and user.conf.d keeps apps at +200.
grep -Fqx 'OOMScoreAdjust=-200' "$ROOT/etc/systemd/system/user@.service.d/20-omarchy-memory.conf" ||
  fail "user@.service sets OOMScoreAdjust=-200"
grep -Fqx 'OOMScoreAdjust=-200' "$ROOT/etc/systemd/user/wayland-wm@.service.d/10-omarchy-oom.conf" ||
  fail "wayland-wm@.service sets OOMScoreAdjust=-200"
grep -Fqx 'DefaultOOMScoreAdjust=200' "$ROOT/etc/systemd/user.conf.d/30-omarchy-oom.conf" ||
  fail "user.conf.d preserves DefaultOOMScoreAdjust=200 for user apps"
pass "wayland-wm@.service is shielded at OOMScoreAdjust=-200 while apps stay at +200"
