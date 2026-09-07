#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

dropin="$ROOT/etc/systemd/system/linux-modules-cleanup.service.d/10-omarchy.conf"
[[ -f $dropin ]] || fail "linux-modules-cleanup drop-in exists"

grep -Fx '[Service]' "$dropin" >/dev/null || fail "drop-in starts with [Service]"
grep -Fx 'ProtectSystem=strict' "$dropin" >/dev/null || fail "drop-in makes the rootfs read-only"
grep -Fx 'ReadWritePaths=/usr/lib/modules' "$dropin" >/dev/null || fail "drop-in grants write access only to /usr/lib/modules"
grep -Fx 'ProtectHome=yes' "$dropin" >/dev/null || fail "drop-in protects /home"
grep -Fx 'PrivateNetwork=yes' "$dropin" >/dev/null || fail "drop-in gives the oneshot no network"
grep -Fx 'PrivateTmp=yes' "$dropin" >/dev/null || fail "drop-in uses a private tmp"
grep -Fx 'NoNewPrivileges=yes' "$dropin" >/dev/null || fail "drop-in forbids privilege gain"
grep -Fx 'RestrictSUIDSGID=yes' "$dropin" >/dev/null || fail "drop-in blocks setuid/setgid binaries"
grep -Fx 'RestrictRealtime=yes' "$dropin" >/dev/null || fail "drop-in forbids realtime scheduling"
grep -Fx 'MemoryDenyWriteExecute=yes' "$dropin" >/dev/null || fail "drop-in denies writable-executable mappings"
grep -Fx 'SystemCallArchitectures=native' "$dropin" >/dev/null || fail "drop-in limits syscalls to native architecture"
grep -E '^ProtectKernelModules' "$dropin" >/dev/null &&
  fail "drop-in must not protect /usr/lib/modules from the cleanup itself" ||
  true

pass "linux-modules-cleanup drop-in is correctly hardened"
