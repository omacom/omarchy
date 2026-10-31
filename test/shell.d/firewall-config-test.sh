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

cat >"$stub_dir/ufw-docker" <<'STUB'
#!/bin/bash
set -euo pipefail
PATH="/bin:/usr/bin:/sbin:/usr/sbin:/snap/bin/"
printf 'ufw-docker %s\n' "$*" >>"$TEST_LOG"
[[ ${DOCKER_INSTALL_FAIL:-0} == "0" ]] || exit 1
if ! ufw status 2>/dev/null | grep -Fq 'Status: active'; then
  echo 'inactive' >&2
  exit 1
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

grep -q '^ufw-docker install$' "$TEST_LOG" || fail "ufw-docker rules are installed"
grep -q '^systemctl enable ufw$' "$TEST_LOG" || fail "ufw is enabled for next boot"

pass "firewall config installs ufw-docker rules without activating live UFW"

for rule in \
  'ufw default deny incoming' \
  'ufw default allow outgoing' \
  'ufw allow 53317/udp' \
  'ufw allow 53317/tcp' \
  'ufw allow in proto udp from 172.16.0.0/12 to 172.17.0.1 port 53 comment allow-docker-dns' \
  'ufw allow in proto udp from 192.168.0.0/16 to 172.17.0.1 port 53 comment allow-docker-dns' \
  'sed -i s/^ENABLED=.*/ENABLED=yes/ /etc/ufw/ufw.conf'; do
  grep -Fxq "$rule" "$TEST_LOG" || fail "installer writes policy: $rule"
done
if grep -Eq '^ufw (--force )?(enable|reload)|^systemctl .*--now' "$TEST_LOG"; then
  fail "installer must not activate the live firewall"
fi
pass "firewall policy preserves LocalSend and Docker DNS without live activation"

grep -v '^sed 0,' "$TEST_LOG" >"$stub_dir/first-run.log"
: >"$TEST_LOG"
PATH="$stub_dir:$PATH" bash -eE -c 'source "$1"' bash "$ROOT/install/config/firewall.sh"
grep -v '^sed 0,' "$TEST_LOG" >"$stub_dir/repeat.log"
cmp "$stub_dir/first-run.log" "$stub_dir/repeat.log" || fail "repeat setup has the same policy"
pass "firewall policy remains consistent on repeat setup"

: >"$TEST_LOG"
if DOCKER_INSTALL_FAIL=1 PATH="$stub_dir:$PATH" bash -eE -c 'source "$1"' bash "$ROOT/install/config/firewall.sh"; then
  fail "Docker firewall installation errors propagate"
fi
if grep -Fxq 'systemctl enable ufw' "$TEST_LOG"; then
  fail "failed setup must stop before enabling the firewall"
fi
pass "firewall setup propagates Docker rule installation failures"
