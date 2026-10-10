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
exit 0
STUB
cat >"$stub_bin/systemctl" <<'STUB'
#!/bin/bash
printf 'systemctl %s\n' "$*" >>"${CALL_LOG:?}"
STUB
cat >"$stub_bin/sshd" <<'STUB'
#!/bin/bash
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
*)
  exec "$@"
  ;;
esac
STUB
# gum input stops at 400 characters unless the caller sets --char-limit=0.
cat >"$stub_bin/gum" <<'STUB'
#!/bin/bash
mode=""
limit=400
prompt=""

while (( $# )); do
  case $1 in
  input | choose) mode=$1 ;;
  --char-limit=*) limit=${1#--char-limit=} ;;
  --prompt)
    shift
    prompt=$1
    ;;
  --prompt=*) prompt=${1#--prompt=} ;;
  esac
  shift
done

printf 'mode=%s limit=%s prompt=%s\n' "$mode" "$limit" "$prompt" >>"${GUM_LOG:?}"

if [[ $mode == "choose" ]]; then
  printf '%s\n' "Paste key manually"
  exit 0
fi

key=$(tr -d '\n' <"${PASTE_PUBLIC_KEY:?}")
if (( limit != 0 && ${#key} > limit )); then
  key=${key:0:limit}
fi
printf '%s\n' "$key"
STUB
chmod +x "$stub_bin"/*

ssh-keygen -q -t ed25519 -N "" -f "$test_dir/key"
public_key=$(<"$test_dir/key.pub")

run_setup() {
  local scenario="$1"
  local home="$test_dir/$scenario/home"
  local root="$test_dir/$scenario/root"

  mkdir -p "$home" "$root"
  : >"$test_dir/$scenario.calls"

  HOME="$home" TEST_ROOT="$root" CALL_LOG="$test_dir/$scenario.calls" \
    SSHD_SYNTAX_VALID="${SSHD_SYNTAX_VALID:-1}" \
    SSHD_PASSWORD_AUTH="${SSHD_PASSWORD_AUTH:-no}" \
    SSHD_KBD_AUTH="${SSHD_KBD_AUTH:-no}" \
    PATH="$stub_bin:$PATH" \
    bash "$ROOT/bin/omarchy-setup-security-sshd" --key="$public_key"
}

output=$(run_setup success)
config="$test_dir/success/root/etc/ssh/sshd_config.d/10-omarchy-hardening.conf"
grep -qxF "PasswordAuthentication no" "$config" || fail "SSH setup disables password authentication"
grep -qxF "KbdInteractiveAuthentication no" "$config" || fail "SSH setup disables keyboard-interactive authentication"
grep -qxF "systemctl reload sshd.service" "$test_dir/success.calls" || fail "SSH setup reloads the validated config"
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
! grep -qF "systemctl reload sshd.service" "$test_dir/ineffective.calls" ||
  fail "SSH setup must not reload ineffective hardening"
! grep -q "Password logins are off" "$test_dir/ineffective.output" ||
  fail "SSH setup must not claim ineffective hardening succeeded"
pass "SSH setup verifies the effective daemon settings"

if SSHD_SYNTAX_VALID=0 run_setup invalid >"$test_dir/invalid.output" 2>&1; then
  fail "SSH setup must fail when sshd rejects its config"
fi
[[ ! -e $test_dir/invalid/root/etc/ssh/sshd_config.d/10-omarchy-hardening.conf ]] ||
  fail "SSH setup removes a rejected hardening config"
! grep -qF "systemctl reload sshd.service" "$test_dir/invalid.calls" ||
  fail "SSH setup must not reload a rejected config"
! grep -q "Password logins are off" "$test_dir/invalid.output" ||
  fail "SSH setup must not claim rejected hardening succeeded"
pass "SSH setup fails safely when sshd rejects the config"

ssh-keygen -q -t rsa -b 3072 -N "" -C "sshd-setup-test" -f "$test_dir/rsa"
rsa_key=$(tr -d '\n' <"$test_dir/rsa.pub")
(( ${#rsa_key} > 400 )) || fail "generated RSA public key is longer than gum's default limit" "${#rsa_key}"

paste_home="$test_dir/paste/home"
paste_root="$test_dir/paste/root"
mkdir -p "$paste_home" "$paste_root"
: >"$test_dir/paste.calls"
: >"$test_dir/paste.gum"

paste_output=$(
  HOME="$paste_home" TEST_ROOT="$paste_root" CALL_LOG="$test_dir/paste.calls" \
    PASTE_PUBLIC_KEY="$test_dir/rsa.pub" GUM_LOG="$test_dir/paste.gum" \
    PATH="$stub_bin:$PATH" \
    bash "$ROOT/bin/omarchy-setup-security-sshd" 2>&1
) || fail "pasted RSA public key is authorized" "$paste_output"
grep -qxF "$rsa_key" "$paste_home/.ssh/authorized_keys" ||
  fail "pasted RSA public key is stored in full"
grep -qxF "mode=input limit=0 prompt=Public key> " "$test_dir/paste.gum" ||
  fail "public key prompt disables gum's character limit" "$(<"$test_dir/paste.gum")"
grep -q "Password logins are off" <<<"$paste_output" ||
  fail "pasted RSA public key still disables password logins"
pass "pasted RSA public key is authorized in full"
