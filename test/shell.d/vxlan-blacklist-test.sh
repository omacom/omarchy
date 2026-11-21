#!/bin/bash

set -euo pipefail

# Omarchy ships a modprobe drop-in that refuses the vxlan module while the
# public FDB-flush UAF (#10833) has no Arch kernel release carrying the fix.

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

conf="$ROOT/etc/modprobe.d/omarchy-vxlan-blacklist.conf"
[[ -f $conf ]] || fail "omarchy-vxlan-blacklist.conf is packaged under etc/modprobe.d"

grep -Eq '^[[:space:]]*blacklist[[:space:]]+vxlan[[:space:]]*$' "$conf" ||
  fail "drop-in blacklists vxlan" "$(cat "$conf")"

grep -Eq '^[[:space:]]*install[[:space:]]+vxlan[[:space:]]+/bin/true[[:space:]]*$' "$conf" ||
  fail "drop-in installs vxlan as /bin/true so explicit modprobe also fails" "$(cat "$conf")"

pass "modprobe drop-in blacklists vxlan"

migration="$ROOT/migrations/1789400100.sh"
[[ -f $migration ]] || fail "a migration installs the vxlan blacklist on existing installs"
grep -q 'omarchy-vxlan-blacklist.conf' "$migration" ||
  fail "migration installs the vxlan blacklist drop-in by name"
grep -q 'blacklist vxlan' "$migration" ||
  fail "migration embeds the blacklist so it does not wait on omarchy-settings"
grep -q 'reboot-required' "$migration" ||
  fail "migration requests a reboot when vxlan is already loaded"

pass "migration installs the vxlan blacklist and flags a loaded module for reboot"
