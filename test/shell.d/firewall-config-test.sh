#!/bin/bash

set -euo pipefail

source "$(dirname -- "${BASH_SOURCE[0]}")/base-test.sh"

stub_dir=$(mktemp -d)
trap 'rm -rf "$stub_dir"' EXIT

cat >"$stub_dir/ufw" <<'STUB'
#!/bin/bash
printf 'ufw %s\n' "$*" >>"$TEST_LOG"
if [[ ${1:-} == status ]]; then
  echo 'Status: inactive'
fi
STUB

cat >"$stub_dir/sed" <<'STUB'
#!/bin/bash
printf 'sed %s\n' "$*" >>"$TEST_LOG"
if [[ ${1:-} == 0,/^PATH=* ]]; then
  exec /usr/bin/sed "$@"
fi
exit 0
STUB

cat >"$stub_dir/systemctl" <<'STUB'
#!/bin/bash
printf 'systemctl %s\n' "$*" >>"$TEST_LOG"
STUB

chmod +x "$stub_dir"/*

export TEST_LOG="$stub_dir/firewall.log"
PATH="$stub_dir:$PATH" bash -eE -c 'source "$1"' bash "$ROOT/install/config/firewall.sh"

grep -q '^ufw allow in on podman+ to any port 53 proto udp' "$TEST_LOG" || fail "Podman DNS is allowed"
grep -q '^ufw allow in on podman+ to any port 53 proto tcp' "$TEST_LOG" || fail "Podman TCP DNS is allowed"
grep -q '^ufw route allow in on podman+' "$TEST_LOG" || fail "Podman egress is allowed"
! grep -Eq '^ufw (enable|reload)|^ufw-docker ' "$TEST_LOG" || fail "installation changes the live firewall"
grep -q '^systemctl enable ufw$' "$TEST_LOG" || fail "ufw is enabled for next boot"

pass "firewall config permits Podman DNS and egress without activating live UFW"
