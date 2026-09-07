#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

hook="$ROOT/default/systemd/system-sleep/50-fprintd-release"
[[ -x $hook ]] || fail "fprintd sleep release hook is executable"

grep -Fx '#!/bin/bash' "$hook" >/dev/null || fail "sleep hook uses bash"
grep -F 'if [[ $1 == "pre" ]]; then' "$hook" >/dev/null || fail "sleep hook only acts on pre-sleep"
grep -F 'systemctl is-active --quiet fprintd.service' "$hook" >/dev/null || fail "sleep hook checks fprintd is active"
grep -F 'systemctl stop fprintd.service' "$hook" >/dev/null || fail "sleep hook stops fprintd"
grep -F '|| true' "$hook" >/dev/null || fail "sleep hook does not abort suspend on a stop failure"

migration="$ROOT/migrations/1788797303.sh"
[[ -f $migration ]] || fail "fprintd sleep hook migration exists"
grep -F '50-fprintd-release' "$migration" >/dev/null || fail "migration installs the fprintd sleep hook"
grep -F 'install -Dm755' "$migration" >/dev/null || fail "migration preserves the executable hook"

setup="$ROOT/bin/omarchy-setup-security-fingerprint"
grep -F 'install_sleep_hook' "$setup" >/dev/null || fail "setup installs the fprintd sleep hook"

pass "fprintd sleep release hook is wired into setup and migrations"
