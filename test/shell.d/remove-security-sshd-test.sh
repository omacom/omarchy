#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

test_tmp=$(mktemp -d)
trap 'rm -rf "$test_tmp"' EXIT
stub_bin="$test_tmp/bin"
mkdir -p "$stub_bin" "$test_tmp/root/.ssh" "$test_tmp/alice/.ssh"
echo "root-key" >"$test_tmp/root/.ssh/authorized_keys"
echo "alice-key" >"$test_tmp/alice/.ssh/authorized_keys"

# sudo and gum record what they were asked; getent knows only alice; no firewall.
cat >"$stub_bin/sudo" <<'SH'
#!/bin/bash
echo "sudo $*" >>"$TEST_LOG"
SH
cat >"$stub_bin/gum" <<'SH'
#!/bin/bash
echo "gum $*" >>"$TEST_LOG"
exit 1
SH
cat >"$stub_bin/getent" <<'SH'
#!/bin/bash
[[ $1 == passwd && ( $2 == alice || $2 == 1000 ) ]] || exit 2
echo "alice:x:1000:1000::$TEST_ALICE_HOME:/bin/bash"
SH
cat >"$stub_bin/omarchy-cmd-present" <<'SH'
#!/bin/bash
exit 1
SH
chmod +x "$stub_bin"/*

run_remove() {
  : >"$test_tmp/log"
  env -i PATH="$stub_bin:$ROOT/bin:/usr/bin:/bin" OMARCHY_PATH="$ROOT" HOME="$test_tmp/root" USER=root TEST_LOG="$test_tmp/log" TEST_ALICE_HOME="$test_tmp/alice" "$@" \
    bash "$ROOT/bin/omarchy-remove-security-sshd" >/dev/null
}

run_remove SUDO_USER=alice
grep "^gum" "$test_tmp/log" | grep -Fq "$test_tmp/alice/.ssh/authorized_keys" || fail "under sudo, the invoking user's keys are the ones offered for removal"
pass "under sudo, the invoking user's keys are the ones offered for removal"

run_remove PKEXEC_UID=1000
grep "^gum" "$test_tmp/log" | grep -Fq "$test_tmp/alice/.ssh/authorized_keys" || fail "under pkexec, the invoking user's keys are the ones offered for removal"
pass "under pkexec, the invoking user's keys are the ones offered for removal"

for who in SUDO_USER=ghost PKEXEC_UID=4242; do
  run_remove "$who"
  ! grep -q "^gum" "$test_tmp/log" || fail "an unresolved user ($who) is never offered root's keys"
  grep -Fq "sudo systemctl disable --now sshd.service" "$test_tmp/log" || fail "an unresolved user ($who) still has the server disabled"
done
pass "an unresolved user is never offered root's keys, and the server still goes down"
