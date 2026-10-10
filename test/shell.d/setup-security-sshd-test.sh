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
case $1 in
  ssh-keygen) exit 1 ;;
  ufw) [[ ${UFW_PRESENT:-1} == 0 ]] ;;
  *) exit 97 ;;
esac
STUB
cat >"$stub_bin/gum" <<'STUB'
#!/bin/bash
exit 130
STUB
cat >"$stub_bin/curl" <<'STUB'
#!/bin/bash
[[ ${FETCH_OK:-1} == 1 ]] || exit 22
printf '%s\n' "${FETCH_KEYS:-}"
STUB
cat >"$stub_bin/sudo" <<'STUB'
#!/bin/bash
set -euo pipefail
printf 'sudo %s\n' "$*" >>"${CALL_LOG:?}"
command=$1
shift
case $command in
  ssh-keygen)
    [[ $* == '-A' ]] || exit 97
    touch "$TEST_ROOT/host-keys"
    ;;
  sshd)
    [[ -e $TEST_ROOT/host-keys ]] || exit 98
    case $1 in
      -t) [[ ${SSHD_SYNTAX_VALID:-1} == 1 ]] ;;
      -T)
        if [[ ${SSHD_DUMP_LOWERCASE:-0} == 1 ]]; then
          printf 'passwordauthentication %s\n' "${SSHD_PASSWORD_AUTH:-no}"
          printf 'kbdinteractiveauthentication %s\n' "${SSHD_KBD_AUTH:-no}"
        else
          printf 'PasswordAuthentication %s\n' "${SSHD_PASSWORD_AUTH:-no}"
          printf 'KbdInteractiveAuthentication %s\n' "${SSHD_KBD_AUTH:-no}"
        fi
        ;;
      *) exit 97 ;;
    esac
    ;;
  systemctl)
    case $1 in
      is-active) [[ -e $TEST_ROOT/active ]] ;;
      start|reload)
        [[ -s $TEST_HOME/.ssh/authorized_keys ]] || exit 99
        [[ ${SERVICE_FAIL:-} != "$1" ]] || exit 1
        touch "$TEST_ROOT/active"
        ;;
      enable) touch "$TEST_ROOT/enabled" ;;
      *) exit 97 ;;
    esac
    ;;
  ufw)
    [[ -e $TEST_ROOT/active ]] || exit 99
    [[ ${FIREWALL_FAIL:-} != "$1" ]] || exit 1
    touch "$TEST_ROOT/firewall"
    ;;
  install|mktemp|mv|cp|rm|test|cat)
    args=()
    for arg in "$@"; do
      if [[ $arg == /etc/* ]]; then arg="$TEST_ROOT$arg"; fi
      args+=("$arg")
    done
    exec "/usr/bin/$command" "${args[@]}"
    ;;
  *) exit 97 ;;
esac
STUB
chmod +x "$stub_bin"/*

ssh-keygen -q -t ed25519 -N "" -f "$test_dir/key"
ssh-keygen -q -t ed25519 -N "" -f "$test_dir/old-key"
public_key=$(<"$test_dir/key.pub")
old_key=$(<"$test_dir/old-key.pub")

prepare_case() {
  case_dir="$test_dir/$1"
  case_home="$case_dir/home"
  case_root="$case_dir/root"
  config="$case_root/etc/ssh/sshd_config.d/10-omarchy-hardening.conf"
  calls="$case_dir/calls"
  mkdir -p "$case_home/.ssh" "$case_root/etc/ssh/sshd_config.d"
  : >"$calls"
}

run_setup() {
  set +e
  output=$(env HOME="$case_home" TEST_HOME="$case_home" TEST_ROOT="$case_root" CALL_LOG="$calls" \
    SSHD_SYNTAX_VALID="${SSHD_SYNTAX_VALID:-1}" \
    SSHD_PASSWORD_AUTH="${SSHD_PASSWORD_AUTH:-no}" \
    SSHD_KBD_AUTH="${SSHD_KBD_AUTH:-no}" \
    SSHD_DUMP_LOWERCASE="${SSHD_DUMP_LOWERCASE:-0}" \
    FETCH_OK="${FETCH_OK:-1}" FETCH_KEYS="${FETCH_KEYS:-}" \
    SERVICE_FAIL="${SERVICE_FAIL:-}" FIREWALL_FAIL="${FIREWALL_FAIL:-}" \
    UFW_PRESENT="${UFW_PRESENT:-1}" PATH="$stub_bin:/usr/bin:/bin" \
    bash "$ROOT/bin/omarchy-setup-security-sshd" "$@" 2>&1)
  status=$?
  set -e
}

assert_no_exposure() {
  ! grep -Eq '^sudo (systemctl (start|reload|enable)|ufw)' "$calls" ||
    fail "failed preparation must not start, reload, enable or expose SSH" "$(cat "$calls")"
  ! grep -q 'The SSH server is running' <<<"$output" || fail "failure must not claim success" "$output"
}

for scenario in fresh running lowercase; do
  prepare_case "$scenario"
  if [[ $scenario == running ]]; then touch "$case_root/active"; fi
  if [[ $scenario == lowercase ]]; then
    SSHD_DUMP_LOWERCASE=1 run_setup --key="$public_key"
  else
    run_setup --key="$public_key"
  fi
  (( status == 0 )) || fail "$scenario setup succeeds" "$output"
  grep -qxF 'PasswordAuthentication no' "$config" || fail "password auth is disabled"
  grep -qxF 'KbdInteractiveAuthentication no' "$config" || fail "keyboard auth is disabled"
  grep -qxF "$public_key" "$case_home/.ssh/authorized_keys" || fail "key is saved before service activation"
  [[ -e $case_root/enabled && -e $case_root/firewall ]] || fail "successful setup enables SSH and opens firewall"
  if [[ $scenario == running ]]; then
    grep -qxF 'sudo systemctl reload sshd.service' "$calls" || fail "running server reloads its validated policy"
    ! grep -q 'systemctl start' "$calls" || fail "running server is not restarted"
  else
    grep -qxF 'sudo systemctl start sshd.service' "$calls" || fail "fresh server starts after preparation"
  fi
  awk '/^sudo sshd -T$/ { validated=1 } /^sudo systemctl (start|reload)/ && !validated { exit 1 } /^sudo systemctl (start|reload)/ { active=1 } /^sudo ufw/ && !active { exit 1 }' "$calls" ||
    fail "effective policy validation precedes activation and firewall exposure"
done
pass "fresh and existing servers validate key-only policy before activation and exposure"

for scenario in invalid-key cancel failed-fetch empty-fetch mixed-fetch multiline-key; do
  prepare_case "$scenario"
  printf '%s\n' "$old_key" >"$case_home/.ssh/authorized_keys"
  case $scenario in
    invalid-key) run_setup --key=invalid ;;
    cancel) run_setup ;;
    failed-fetch) FETCH_OK=0 run_setup --gh-keys example ;;
    empty-fetch) FETCH_KEYS='' run_setup --gh-keys example ;;
    mixed-fetch) FETCH_KEYS="$public_key"$'\ninvalid' run_setup --gh-keys example ;;
    multiline-key) run_setup --key="$public_key"$'\ninvalid' ;;
  esac
  (( status != 0 )) || fail "$scenario must fail" "$output"
  assert_no_exposure
  [[ ! -s $calls ]] || fail "$scenario must not invoke privileged or package operations" "$(cat "$calls")"
  [[ $(<"$case_home/.ssh/authorized_keys") == "$old_key" ]] || fail "$scenario preserves existing authorized keys"
done
pass "cancel, invalid keys and failed key downloads leave service, firewall and keys unchanged"

for scenario in invalid-syntax ineffective-password ineffective-keyboard; do
  prepare_case "$scenario"
  printf '%s\n' "$old_key" >"$case_home/.ssh/authorized_keys"
  printf '# administrator policy\nPasswordAuthentication no\nAllowUsers existing\n' >"$config"
  cp "$config" "$case_dir/original"
  chmod 640 "$config"
  case $scenario in
    invalid-syntax) SSHD_SYNTAX_VALID=0 run_setup --key="$public_key" ;;
    ineffective-password) SSHD_PASSWORD_AUTH=yes run_setup --key="$public_key" ;;
    ineffective-keyboard) SSHD_KBD_AUTH=yes run_setup --key="$public_key" ;;
  esac
  (( status != 0 )) || fail "$scenario must fail" "$output"
  assert_no_exposure
  cmp "$case_dir/original" "$config" || fail "$scenario restores existing config contents"
  [[ $(stat -c %a "$config") == 640 ]] || fail "$scenario restores existing config mode"
  [[ $(<"$case_home/.ssh/authorized_keys") == "$old_key" ]] || fail "$scenario preserves existing key access"
done
pass "syntax or effective-policy failures restore existing policy and leave keys intact"

prepare_case failed-new-policy
SSHD_SYNTAX_VALID=0 run_setup --key="$public_key"
(( status != 0 )) || fail "invalid fresh policy must fail"
[[ ! -e $config ]] || fail "failed fresh policy is removed"
assert_no_exposure
pass "failed initial configuration leaves no invalid drop-in"

prepare_case failed-linked-policy
printf 'PasswordAuthentication no\n# external administrator policy\n' >"$case_root/etc/ssh/external-policy"
ln -s ../external-policy "$config"
SSHD_SYNTAX_VALID=0 run_setup --key="$public_key"
(( status != 0 )) || fail "invalid candidate replacing a linked policy must fail"
[[ -L $config && $(readlink "$config") == ../external-policy ]] || fail "rollback restores the original policy symlink"
grep -qxF '# external administrator policy' "$case_root/etc/ssh/external-policy" || fail "candidate does not alter the symlink target"
assert_no_exposure
pass "rollback preserves a pre-existing policy symlink and its target"

prepare_case fetched-keys
FETCH_KEYS="$old_key"$'\n'"$public_key" run_setup --gh-keys example
(( status == 0 )) || fail "valid fetched key batch succeeds" "$output"
grep -qxF "$old_key" "$case_home/.ssh/authorized_keys" || fail "first fetched key is authorized"
grep -qxF "$public_key" "$case_home/.ssh/authorized_keys" || fail "second fetched key is authorized"
pass "all validated fetched keys are authorized before activation"

prepare_case preserve-customization
printf '%s' "$old_key" >"$case_home/.ssh/authorized_keys"
printf '# administrator additions\nPasswordAuthentication yes\nAllowUsers existing\n' >"$config"
run_setup --key="$public_key"
(( status == 0 )) || fail "customized policy setup succeeds" "$output"
grep -qxF 'AllowUsers existing' "$config" || fail "unrelated administrator settings survive"
grep -qxF "$old_key" "$case_home/.ssh/authorized_keys" || fail "existing final key without newline survives"
grep -qxF "$public_key" "$case_home/.ssh/authorized_keys" || fail "new key occupies its own line"
run_setup --key="$public_key"
(( status == 0 )) || fail "repeated setup succeeds" "$output"
[[ $(grep -c '^PasswordAuthentication ' "$config") == 1 ]] || fail "repeated setup does not duplicate policy"
[[ $(grep -cxF "$public_key" "$case_home/.ssh/authorized_keys") == 1 ]] || fail "repeated setup does not duplicate keys"
pass "successful repeated setup preserves unrelated policy and existing keys"

for scenario in start reload enable-firewall reload-firewall; do
  prepare_case "failed-$scenario"
  case $scenario in
    start) SERVICE_FAIL=start run_setup --key="$public_key" ;;
    reload) touch "$case_root/active"; SERVICE_FAIL=reload run_setup --key="$public_key" ;;
    enable-firewall) FIREWALL_FAIL=limit run_setup --key="$public_key" ;;
    reload-firewall) FIREWALL_FAIL=reload run_setup --key="$public_key" ;;
  esac
  (( status != 0 )) || fail "$scenario failure must be reported" "$output"
  grep -qxF 'PasswordAuthentication no' "$config" || fail "validated policy stays key-only after $scenario failure"
  grep -qxF "$public_key" "$case_home/.ssh/authorized_keys" || fail "authorized key survives $scenario failure"
  ! grep -q 'The SSH server is running' <<<"$output" || fail "$scenario failure must not claim success"
  grep -q 'setup did not finish' <<<"$output" || fail "$scenario failure explains partial setup"
  if [[ $scenario == start || $scenario == reload ]]; then
    ! grep -q '^sudo ufw' "$calls" || fail "failed service activation must not open firewall"
  fi
done
pass "service and firewall failures retain validated secure configuration and report incomplete setup"
