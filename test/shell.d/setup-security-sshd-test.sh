#!/bin/bash

set -euo pipefail

source "$(dirname "$0")/base-test.sh"

test_dir=$(mktemp -d)
trap 'rm -rf "$test_dir"' EXIT

stub_bin="$test_dir/bin"
mkdir -p "$stub_bin"

cat >"$stub_bin/omarchy-pkg-add" <<'STUB'
#!/bin/bash
printf 'pkg %s\n' "$*" >>"${CALL_LOG:?}"
STUB
cat >"$stub_bin/omarchy-cmd-missing" <<'STUB'
#!/bin/bash
exit 1
STUB
cat >"$stub_bin/ufw" <<'STUB'
#!/bin/bash
printf 'ufw %s\n' "$*" >>"${CALL_LOG:?}"
[[ -e ${TEST_ROOT:?}/etc/ssh/sshd_config.d/10-omarchy-hardening.conf ]] || echo "exposed before hardening" >>"$CALL_LOG"
STUB
cat >"$stub_bin/systemctl" <<'STUB'
#!/bin/bash
printf 'systemctl %s\n' "$*" >>"${CALL_LOG:?}"
[[ -e ${TEST_ROOT:?}/etc/ssh/sshd_config.d/10-omarchy-hardening.conf ]] || echo "exposed before hardening" >>"$CALL_LOG"
STUB
cat >"$stub_bin/gum" <<'STUB'
#!/bin/bash
printf 'gum %s\n' "$1" >>"${CALL_LOG:?}"
# Esc at the first prompt.
exit 130
STUB
cat >"$stub_bin/sshd" <<'STUB'
#!/bin/bash
# A fresh install has no host keys until ssh-keygen -A runs, and sshd -t and
# sshd -T refuse to run without them.
[[ -e ${TEST_ROOT:?}/host-keys ]] || exit 1
case $1 in
-t)
  [[ ${SSHD_SYNTAX_VALID:-1} == 1 ]]
  ;;
-T)
  # OpenSSH 10.x dumps keywords in CamelCase; 9.x dumped them lowercase.
  if [[ ${SSHD_DUMP_LOWERCASE:-0} == 1 ]]; then
    printf 'passwordauthentication %s\n' "${SSHD_PASSWORD_AUTH:-no}"
    printf 'kbdinteractiveauthentication %s\n' "${SSHD_KBD_AUTH:-no}"
  else
    printf 'PasswordAuthentication %s\n' "${SSHD_PASSWORD_AUTH:-no}"
    printf 'KbdInteractiveAuthentication %s\n' "${SSHD_KBD_AUTH:-no}"
  fi
  ;;
*)
  exit 2
  ;;
esac
STUB
cat >"$stub_bin/sudo" <<'STUB'
#!/bin/bash
case $1 in
install)
  destination="${TEST_ROOT:?}${4:?}"
  /usr/bin/mkdir -p "${destination%/*}"
  /usr/bin/install -Dm644 /dev/stdin "$destination"
  ;;
rm)
  /usr/bin/rm -f "${TEST_ROOT:?}${3:?}"
  ;;
ssh-keygen)
  : >"${TEST_ROOT:?}/host-keys"
  ;;
*)
  exec "$@"
  ;;
esac
STUB
chmod +x "$stub_bin"/*

ssh-keygen -q -t ed25519 -N "" -f "$test_dir/key"
public_key=$(<"$test_dir/key.pub")

run_setup() {
  local scenario="$1" key="${2:-$public_key}"
  local home="$test_dir/$scenario/home"
  local root="$test_dir/$scenario/root"

  mkdir -p "$home" "$root"
  : >"$test_dir/$scenario.calls"

  HOME="$home" TEST_ROOT="$root" CALL_LOG="$test_dir/$scenario.calls" \
    SSHD_SYNTAX_VALID="${SSHD_SYNTAX_VALID:-1}" \
    SSHD_PASSWORD_AUTH="${SSHD_PASSWORD_AUTH:-no}" \
    SSHD_KBD_AUTH="${SSHD_KBD_AUTH:-no}" \
    PATH="$stub_bin:$PATH" \
    bash "$ROOT/bin/omarchy-setup-security-sshd" --key="$key"
}

# Nothing may listen or be opened while passwords could still be accepted.
assert_nothing_exposed() {
  local scenario="$1"

  ! grep -qE "^systemctl (enable|start|restart|reload)" "$test_dir/$scenario.calls" ||
    fail "SSH setup must not start sshd when $scenario"
  ! grep -q "^ufw " "$test_dir/$scenario.calls" ||
    fail "SSH setup must not open the firewall when $scenario"
}

output=$(run_setup success)
config="$test_dir/success/root/etc/ssh/sshd_config.d/10-omarchy-hardening.conf"
grep -qxF "PasswordAuthentication no" "$config" || fail "SSH setup disables password authentication"
grep -qxF "KbdInteractiveAuthentication no" "$config" || fail "SSH setup disables keyboard-interactive authentication"
grep -qxF "systemctl reload-or-restart sshd.service" "$test_dir/success.calls" || fail "SSH setup starts sshd with the validated config"
grep -qxF "ufw limit 22/tcp comment omarchy-sshd" "$test_dir/success.calls" || fail "SSH setup opens the SSH port"
! grep -qxF "exposed before hardening" "$test_dir/success.calls" || fail "SSH setup starts sshd and opens the port only after passwords are off"
grep -qxF "$public_key" "$test_dir/success/home/.ssh/authorized_keys" || fail "SSH setup writes the authorized key"
grep -q "Password logins are off" <<<"$output" || fail "SSH setup reports hardening after it succeeds"
pass "SSH setup authorizes a key and disables password logins"

output=$(SSHD_DUMP_LOWERCASE=1 run_setup success-legacy)
config="$test_dir/success-legacy/root/etc/ssh/sshd_config.d/10-omarchy-hardening.conf"
[[ -e $config ]] || fail "SSH setup accepts the lowercase sshd -T dump of OpenSSH 9.x"
grep -q "Password logins are off" <<<"$output" || fail "SSH setup reports hardening on OpenSSH 9.x"
pass "SSH setup verifies settings across sshd -T keyword casings"

if SSHD_PASSWORD_AUTH=yes run_setup ineffective >"$test_dir/ineffective.output" 2>&1; then
  fail "SSH setup must fail when password authentication remains effective"
fi
[[ ! -e $test_dir/ineffective/root/etc/ssh/sshd_config.d/10-omarchy-hardening.conf ]] ||
  fail "SSH setup removes an ineffective hardening config"
assert_nothing_exposed ineffective
! grep -q "Password logins are off" "$test_dir/ineffective.output" ||
  fail "SSH setup must not claim ineffective hardening succeeded"
pass "SSH setup verifies the effective daemon settings"

if SSHD_SYNTAX_VALID=0 run_setup invalid >"$test_dir/invalid.output" 2>&1; then
  fail "SSH setup must fail when sshd rejects its config"
fi
[[ ! -e $test_dir/invalid/root/etc/ssh/sshd_config.d/10-omarchy-hardening.conf ]] ||
  fail "SSH setup removes a rejected hardening config"
assert_nothing_exposed invalid
! grep -q "Password logins are off" "$test_dir/invalid.output" ||
  fail "SSH setup must not claim rejected hardening succeeded"
pass "SSH setup fails safely when sshd rejects the config"

if run_setup rejected-key "not-a-key" >"$test_dir/rejected-key.output" 2>&1; then
  fail "SSH setup must fail when the key is rejected"
fi
assert_nothing_exposed rejected-key
[[ ! -e $test_dir/rejected-key/root/etc/ssh/sshd_config.d/10-omarchy-hardening.conf ]] ||
  fail "SSH setup writes no hardening config without a key"
pass "SSH setup starts nothing and opens nothing when no key is authorized"

mkdir -p "$test_dir/cancelled/home" "$test_dir/cancelled/root"
: >"$test_dir/cancelled.calls"
if HOME="$test_dir/cancelled/home" TEST_ROOT="$test_dir/cancelled/root" CALL_LOG="$test_dir/cancelled.calls" \
  PATH="$stub_bin:$ROOT/bin:$PATH" bash "$ROOT/bin/omarchy-setup-security-sshd" >/dev/null 2>&1; then
  fail "SSH setup must fail when the key prompt is cancelled"
fi
grep -q "^gum choose" "$test_dir/cancelled.calls" || fail "SSH setup reaches the key prompt"
assert_nothing_exposed cancelled
pass "SSH setup starts nothing and opens nothing when the key prompt is cancelled"

if run_setup multiline-key "$public_key"$'\n'"$public_key" >"$test_dir/multiline-key.output" 2>&1; then
  fail "SSH setup must reject multi-line --key input"
fi
assert_nothing_exposed multiline-key
pass "SSH setup rejects multi-line keys"

for bad_user in "alice/bob" "alice?x=1" "../etc" "alice..bob"; do
  mkdir -p "$test_dir/bad-gh/home" "$test_dir/bad-gh/root"
  : >"$test_dir/bad-gh.calls"
  if HOME="$test_dir/bad-gh/home" TEST_ROOT="$test_dir/bad-gh/root" CALL_LOG="$test_dir/bad-gh.calls" \
    PATH="$stub_bin:$ROOT/bin:$PATH" bash "$ROOT/bin/omarchy-setup-security-sshd" --gh-keys "$bad_user" >/dev/null 2>&1; then
    fail "SSH setup must reject invalid GitHub username: $bad_user"
  fi
  [[ ! -s $test_dir/bad-gh.calls ]] || fail "invalid GitHub username '$bad_user' must fail before installing or changing system state"
done
pass "SSH setup rejects invalid GitHub usernames before installing packages"

cat >"$stub_bin/curl" <<STUB
#!/bin/bash
printf '%s\r\nnot-a-valid-key\n' "$public_key"
STUB
chmod +x "$stub_bin/curl"

mkdir -p "$test_dir/mixed-gh/home" "$test_dir/mixed-gh/root"
: >"$test_dir/mixed-gh.calls"
HOME="$test_dir/mixed-gh/home" TEST_ROOT="$test_dir/mixed-gh/root" CALL_LOG="$test_dir/mixed-gh.calls" \
  PATH="$stub_bin:$ROOT/bin:$PATH" bash "$ROOT/bin/omarchy-setup-security-sshd" --gh-keys octocat \
  >"$test_dir/mixed-gh.output" 2>&1 || fail "SSH setup completes when GitHub returns a valid key alongside an invalid entry"
grep -qxF -- "$public_key" "$test_dir/mixed-gh/home/.ssh/authorized_keys" ||
  fail "SSH setup saves the valid key from a mixed GitHub key list"
[[ $(stat -c %a "$test_dir/mixed-gh/home/.ssh/authorized_keys") == "600" ]] ||
  fail "SSH setup keeps authorized_keys mode 600"
grep -q "Password logins are off" "$test_dir/mixed-gh.output" ||
  fail "SSH setup finishes hardening after authorizing valid GitHub keys"
pass "SSH setup saves valid keys and completes when a GitHub key list contains an invalid entry"
