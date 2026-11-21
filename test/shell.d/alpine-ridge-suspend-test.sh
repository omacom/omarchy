#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

fix="$ROOT/install/hardware/apple/fix-suspend-alpine-ridge.sh"
wakeup="$ROOT/bin/omarchy-hw-alpine-ridge-wakeup"
all="$ROOT/install/hardware/all.sh"
migration="$ROOT/migrations/1789604768.sh"

grep -F 'MacBookPro13,[123]|MacBookPro14,[123]' "$fix" >/dev/null
grep -F 'pcie_port_pm=off' "$fix" >/dev/null
grep -F '/etc/omarchy/lid-suspend-delay' "$fix" >/dev/null
grep -F '20' "$fix" >/dev/null
grep -F '8086:15d2' "$fix" >/dev/null
grep -F '8086:15d4' "$fix" >/dev/null
! grep -E '^[^#]*pm_async=off' "$fix" >/dev/null ||
  fail "Alpine Ridge setup does not set pm_async=off"
! grep -E '^[^#]*blacklist thunderbolt' "$fix" >/dev/null ||
  fail "Alpine Ridge setup does not blacklist thunderbolt"
pass "Alpine Ridge setup keeps deep S3 and Thunderbolt loaded"

grep -F 'fix-suspend-alpine-ridge.sh' "$all" >/dev/null
pass "hardware install runs the Alpine Ridge suspend fix"

grep -F 'RP05 RP09 XHC2 XHC3 RP12' "$wakeup" >/dev/null
! grep -E '^[^#]*LID0' "$wakeup" >/dev/null || fail "lid wake stays enabled"
! grep -E '^[^#]*SPIT' "$wakeup" >/dev/null || fail "keyboard wake stays enabled"
pass "Alpine Ridge wakeup disables TB and Wi-Fi PME only"

grep -F 'source "$fix"' "$migration" >/dev/null
pass "migration reapplies the Alpine Ridge suspend fix"

tmpdir=$(mktemp -d)
trap 'rm -rf "$tmpdir"' EXIT
wakeup_file="$tmpdir/wakeup"
cat >"$wakeup_file" <<'EOF'
RP05	S3	*enabled   pci:0000:00:1c.4
LID0	S4	*enabled   platform:PNP0C0D:00
SPIT	S3	*enabled   spi:spi-APP000D:00
EOF

OMARCHY_ACPI_WAKEUP="$wakeup_file" "$wakeup"
[[ $(<"$wakeup_file") == RP05 ]] ||
  fail "wakeup helper toggles an enabled TB node" "got: $(<"$wakeup_file")"
pass "wakeup helper toggles an enabled TB node"
