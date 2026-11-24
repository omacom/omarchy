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

mock_bin="$tmpdir/bin"
call_log="$tmpdir/systemctl-calls"
mkdir -p "$mock_bin"

cat >"$mock_bin/systemctl" <<SH
#!/bin/bash
printf '%s\n' "\$*" >>"$call_log"
if [[ \$1 == "is-active" ]]; then
  [[ \${SDDM_ACTIVE:-1} == "1" ]]
fi
SH

cat >"$mock_bin/loginctl" <<'SH'
#!/bin/bash
if [[ ${LOGINCTL_FAIL:-0} == "1" ]]; then
  exit 1
fi
printf '%s' "${LOGINCTL_SESSIONS:-}"
SH

chmod +x "$mock_bin/systemctl" "$mock_bin/loginctl"

run_recover() {
  : >"$call_log"
  PATH="$mock_bin:$PATH" "$@" "$recover"
}

run_recover env SDDM_ACTIVE=1 LOGINCTL_SESSIONS=""
grep -Fxq "restart --no-block sddm.service" "$call_log" ||
  fail "active SDDM with no sessions restarts SDDM" "$(<"$call_log")"
pass "active SDDM with no sessions restarts SDDM"

seatless=$'4 1000 viktor - 2199 manager - no -\n'
run_recover env SDDM_ACTIVE=1 LOGINCTL_SESSIONS="$seatless"
grep -Fxq "restart --no-block sddm.service" "$call_log" ||
  fail "seatless background sessions do not block SDDM recovery" "$(<"$call_log")"
pass "seatless background sessions do not block SDDM recovery"

seat_session=$'3 1000 viktor seat0 1234 user tty1 no -\n4 1000 viktor - 2199 manager - no -\n'
run_recover env SDDM_ACTIVE=1 LOGINCTL_SESSIONS="$seat_session"
if grep -q "restart" "$call_log"; then
  fail "local seat session skips SDDM restart" "$(<"$call_log")"
fi
pass "local seat session skips SDDM restart"

run_recover env SDDM_ACTIVE=0 LOGINCTL_SESSIONS=""
if grep -q "restart" "$call_log"; then
  fail "inactive SDDM is left alone" "$(<"$call_log")"
fi
pass "inactive SDDM is left alone"

run_recover env SDDM_ACTIVE=1 LOGINCTL_FAIL=1
if grep -q "restart" "$call_log"; then
  fail "failed loginctl query fails closed without restarting SDDM" "$(<"$call_log")"
fi
pass "failed loginctl query fails closed without restarting SDDM"
