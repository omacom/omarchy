#!/bin/bash
#
# The connectivity check migration must reload a running NetworkManager's
# config, so it picks up the ping.omacom.io drop-in omarchy-settings ships, and
# must fail (staying pending) when that reload fails, rather than marking the
# migration done while the daemon keeps probing the old URL. A stopped
# NetworkManager reads the drop-in when it starts, so it is left alone.
#
# Only the system calls are stubbed: systemctl answers whether NetworkManager
# is active, sudo drops its prefix, and nmcli records its call.

set -euo pipefail

source "$(dirname "${BASH_SOURCE[0]}")/base-test.sh"

migration="$ROOT/migrations/1792507034.sh"
test_dir=$(mktemp -d)
trap 'rm -rf "$test_dir"' EXIT

stub_bin="$test_dir/bin"
mkdir -p "$stub_bin"

cat >"$stub_bin/systemctl" <<'STUB'
#!/bin/bash
[[ $* == "is-active --quiet NetworkManager" ]] || exit 2
exit "${NM_ACTIVE_STATUS:?}"
STUB
cat >"$stub_bin/sudo" <<'STUB'
#!/bin/bash
exec "$@"
STUB
cat >"$stub_bin/nmcli" <<'STUB'
#!/bin/bash
echo "$@" >>"${NMCLI_CALLS:?}"
exit "${NMCLI_STATUS:-0}"
STUB
chmod +x "$stub_bin/systemctl" "$stub_bin/sudo" "$stub_bin/nmcli"

nmcli_calls="$test_dir/nmcli-calls"

run_migration() {
  rm -f "$nmcli_calls"
  NM_ACTIVE_STATUS="$1" NMCLI_STATUS="${2:-0}" NMCLI_CALLS="$nmcli_calls" HOME="$test_dir" \
    PATH="$stub_bin:$PATH" bash -euo pipefail "$migration" >/dev/null 2>&1
}

run_migration 0 || fail "migration succeeds when NetworkManager reloads its config"
[[ $(<"$nmcli_calls") == "general reload conf" ]] || fail "migration reloads a running NetworkManager's config" "$(cat "$nmcli_calls" 2>/dev/null)"
pass "migration reloads a running NetworkManager's config"

if run_migration 0 1; then
  fail "migration stays pending when the reload fails"
fi
pass "migration stays pending when the reload fails"

run_migration 3 || fail "migration succeeds when NetworkManager is not running"
[[ ! -e $nmcli_calls ]] || fail "migration leaves a stopped NetworkManager alone" "$(<"$nmcli_calls")"
pass "migration leaves a stopped NetworkManager alone"
