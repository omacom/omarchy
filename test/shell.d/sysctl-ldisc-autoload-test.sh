#!/bin/bash

set -euo pipefail

# Omarchy ships hardening-adjacent sysctls in etc/sysctl.d/.
# dev.tty.ldisc_autoload=0 must stay present so unprivileged TIOCSETD cannot
# cold-load obscure line-discipline modules.

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

conf="$ROOT/etc/sysctl.d/99-omarchy-sysctl.conf"
[[ -f $conf ]] || fail "99-omarchy-sysctl.conf is packaged under etc/sysctl.d"

grep -Eq '^[[:space:]]*dev\.tty\.ldisc_autoload[[:space:]]*=[[:space:]]*0[[:space:]]*$' "$conf" ||
  fail "99-omarchy-sysctl.conf sets dev.tty.ldisc_autoload=0" "$(grep ldisc "$conf" || true)"

! grep -Eq '^[[:space:]]*dev\.tty\.ldisc_autoload[[:space:]]*=[[:space:]]*1[[:space:]]*$' "$conf" ||
  fail "99-omarchy-sysctl.conf must not set ldisc_autoload=1"

pass "sysctl drop-in disables unprivileged TTY ldisc autoload"

migration="$ROOT/migrations/1789261000.sh"
[[ -f $migration ]] || fail "a migration applies the ldisc_autoload drop-in on existing installs"
grep -q '99-omarchy-sysctl.conf' "$migration" ||
  fail "migration loads the omarchy sysctl drop-in specifically"
grep -q 'sysctl -p' "$migration" ||
  fail "migration applies the drop-in at runtime rather than only on next boot"

pass "migration reapplies the sysctl drop-in without waiting for reboot"
