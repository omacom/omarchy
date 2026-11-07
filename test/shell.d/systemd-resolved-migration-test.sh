#!/bin/bash
#
# Migration 1790048120 recovers DNS when /etc/resolv.conf still points at the
# systemd-resolved stub but the unit is inactive (historical migration
# 1782002156 swallowed restart failures with || true). Assert the recovery
# migration enables resolved only when needed, and that the historical
# migration no longer swallows a failed restart.

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

historical="$ROOT/migrations/1782002156.sh"
recovery="$ROOT/migrations/1790048120.sh"

test_dir=$(mktemp -d)
trap 'rm -rf "$test_dir"' EXIT

stub_bin="$test_dir/bin"
mkdir -p "$stub_bin"

# Historical migration must enable resolved and fail loudly, not swallow errors.
! grep -E 'systemd-resolved\.service.*>/dev/null 2>&1 \|\| true' "$historical" >/dev/null ||
  fail "historical migration must not swallow systemd-resolved failures"
grep -F 'ensure_systemd_resolved' "$historical" >/dev/null ||
  fail "historical migration still has ensure_systemd_resolved"
grep -F 'systemctl enable --now systemd-resolved.service' "$historical" >/dev/null ||
  fail "historical migration enables systemd-resolved"
grep -F 'Failed to start systemd-resolved' "$historical" >/dev/null ||
  fail "historical migration reports a failed systemd-resolved start"
pass "historical migration no longer swallows a failed systemd-resolved restart"

cat >"$stub_bin/sudo" <<'STUB'
#!/bin/bash
exec "$@"
STUB

write_systemctl_stub() {
  cat >"$stub_bin/systemctl" <<'STUB'
#!/bin/bash
printf 'systemctl %s\n' "$*" >>"${CALL_LOG:?}"
case "$1 $2" in
"is-active --quiet")
  [[ $(cat "${RESOLVED_ACTIVE_FILE:?}" 2>/dev/null || echo 0) == 1 ]]
  ;;
"enable --now")
  if [[ ${RESOLVED_ENABLE_OK:-1} != 1 ]]; then
    exit 1
  fi
  printf '1\n' >"${RESOLVED_ACTIVE_FILE:?}"
  ;;
*)
  exit 2
  ;;
esac
STUB
  chmod +x "$stub_bin/systemctl"
}

write_systemctl_stub
chmod +x "$stub_bin/sudo"

run_recovery() {
  local scenario=$1
  local root="$test_dir/$scenario"
  local resolv="$root/etc/resolv.conf"
  mkdir -p "$root/etc"
  : >"$test_dir/$scenario.calls"
  printf '%s\n' "${RESOLVED_ACTIVE_INIT:-0}" >"$test_dir/$scenario.active"

  case "${RESOLV_STATE:-stub}" in
  stub)
    ln -sfn /run/systemd/resolve/stub-resolv.conf "$resolv"
    ;;
  stub-relative)
    # Exact form written by omarchy-upgrade-to-quattro.
    ln -sfn ../run/systemd/resolve/stub-resolv.conf "$resolv"
    ;;
  missing)
    rm -f "$resolv"
    ;;
  plain)
    printf 'nameserver 1.1.1.1\n' >"$resolv"
    ;;
  other-link)
    ln -sfn /etc/resolv.conf.tail "$resolv"
    ;;
  esac

  # Point the migration at this scenario's resolv.conf without editing the
  # shipped file permanently: rewrite only the path in the fed script.
  sed "s|/etc/resolv.conf|$resolv|g" "$recovery" |
    CALL_LOG="$test_dir/$scenario.calls" \
      RESOLVED_ACTIVE_FILE="$test_dir/$scenario.active" \
      RESOLVED_ENABLE_OK="${RESOLVED_ENABLE_OK:-1}" \
      PATH="$stub_bin:$PATH" \
      bash -euo pipefail
}

# Stub resolv.conf + inactive resolved: enable --now and succeed.
RESOLV_STATE=stub RESOLVED_ACTIVE_INIT=0 RESOLVED_ENABLE_OK=1 \
  run_recovery inactive-stub || fail "recovery enables resolved when the stub is inactive"
grep -qxF "systemctl enable --now systemd-resolved.service" "$test_dir/inactive-stub.calls" ||
  fail "recovery runs systemctl enable --now systemd-resolved.service"
[[ $(cat "$test_dir/inactive-stub.active") == 1 ]] ||
  fail "recovery leaves systemd-resolved marked active"
pass "recovery enables systemd-resolved when the stub is inactive"

# Same recovery for the relative stub link Quattro's upgrade writes.
RESOLV_STATE=stub-relative RESOLVED_ACTIVE_INIT=0 RESOLVED_ENABLE_OK=1 \
  run_recovery inactive-stub-relative ||
  fail "recovery enables resolved for the upgrade's relative stub link"
grep -qxF "systemctl enable --now systemd-resolved.service" "$test_dir/inactive-stub-relative.calls" ||
  fail "relative stub still runs systemctl enable --now systemd-resolved.service"
[[ $(cat "$test_dir/inactive-stub-relative.active") == 1 ]] ||
  fail "relative stub recovery leaves systemd-resolved marked active"
pass "recovery enables systemd-resolved for the upgrade's relative stub link"

# Already active: no enable.
RESOLV_STATE=stub RESOLVED_ACTIVE_INIT=1 \
  run_recovery already-active || fail "recovery is a no-op when resolved is already active"
! grep -q 'enable --now' "$test_dir/already-active.calls" ||
  fail "recovery must not re-enable an already-active resolved"
pass "recovery is a no-op when systemd-resolved is already active"

# No stub symlink: leave resolved alone.
RESOLV_STATE=plain RESOLVED_ACTIVE_INIT=0 \
  run_recovery plain-resolv || fail "recovery skips non-stub resolv.conf"
! grep -q 'enable --now' "$test_dir/plain-resolv.calls" ||
  fail "recovery must not touch resolved without the stub symlink"
pass "recovery skips hosts that do not use the stub resolv.conf"

RESOLV_STATE=missing RESOLVED_ACTIVE_INIT=0 \
  run_recovery missing-resolv || fail "recovery skips a missing resolv.conf"
! grep -q 'enable --now' "$test_dir/missing-resolv.calls" ||
  fail "recovery must not touch resolved when resolv.conf is missing"
pass "recovery skips a missing resolv.conf"

# Enable fails: migration must fail (bash -e exits on the failed systemctl).
if RESOLV_STATE=stub RESOLVED_ACTIVE_INIT=0 RESOLVED_ENABLE_OK=0 \
  run_recovery enable-fails >/dev/null 2>&1; then
  fail "recovery must fail when enable --now fails"
fi
pass "recovery fails loudly when systemd-resolved will not start"

# Enable succeeds at the process level but is-active still reports inactive.
cat >"$stub_bin/systemctl" <<'STUB'
#!/bin/bash
printf 'systemctl %s\n' "$*" >>"${CALL_LOG:?}"
case "$1 $2" in
"is-active --quiet")
  exit 1
  ;;
"enable --now")
  exit 0
  ;;
*)
  exit 2
  ;;
esac
STUB
chmod +x "$stub_bin/systemctl"

if RESOLV_STATE=stub run_recovery still-inactive >/dev/null 2>&1; then
  fail "recovery must fail when resolved stays inactive after enable"
fi
pass "recovery fails when systemd-resolved stays inactive after enable"
