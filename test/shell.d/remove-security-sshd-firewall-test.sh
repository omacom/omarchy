#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

remove="${REMOVE_SECURITY_SSHD_UNDER_TEST:-$ROOT/bin/omarchy-remove-security-sshd}"
test_dir=$(mktemp -d)
stub_bin="$test_dir/bin"
mkdir -p "$stub_bin"
trap 'rm -rf "$test_dir"' EXIT

cat >"$stub_bin/omarchy-cmd-present" <<'STUB'
#!/bin/bash
[[ $1 == "ufw" && ${UFW_PRESENT:-1} == 1 ]]
STUB

cat >"$stub_bin/sudo" <<'STUB'
#!/bin/bash
set -euo pipefail

printf '%s\n' "$*" >>"${CALL_LOG:?}"
[[ $1 == "systemctl" ]] && exit 0
[[ $1 == "ufw" ]] || exit 97
shift

case "$*" in
  "--force delete limit 22/tcp") failure=delete-limit; rule='limit 22/tcp' ;;
  "--force delete allow 22/tcp") failure=delete-port; rule='allow 22/tcp' ;;
  "--force delete allow ssh") failure=delete-service; rule='allow ssh' ;;
  reload) failure=reload ;;
  *) exit 97 ;;
esac

if [[ ${FAIL_UFW:-} == "$failure" ]]; then
  printf 'injected ufw failure: %s\n' "$failure" >&2
  exit 1
fi
[[ $failure == "reload" ]] && exit 0

next="${UFW_STATE:?}.next"
: >"$next"
while IFS= read -r current || [[ -n $current ]]; do
  [[ $current == "$rule" ]] || printf '%s\n' "$current" >>"$next"
done <"$UFW_STATE"
mv "$next" "$UFW_STATE"
STUB

cat >"$stub_bin/gum" <<'STUB'
#!/bin/bash
exit 1
STUB

chmod +x "$stub_bin"/*

prepare_case() {
  local name="$1"
  case_dir="$test_dir/$name"
  home="$case_dir/home"
  calls="$case_dir/calls"
  state="$case_dir/ufw-state"
  mkdir -p "$home/.ssh"
  printf 'ssh-ed25519 fake-key test@example\n' >"$home/.ssh/authorized_keys"
  : >"$calls"
  printf '%s\n' 'limit 22/tcp' 'allow 22/tcp' 'allow ssh' 'allow 443/tcp' >"$state"
}

run_remove() {
  local failure="${1:-}"
  set +e
  output=$(env HOME="$home" PATH="$stub_bin:$ROOT/bin:/usr/bin:/bin" \
    CALL_LOG="$calls" UFW_STATE="$state" UFW_PRESENT="${UFW_PRESENT:-1}" FAIL_UFW="$failure" \
    bash "$remove" 2>&1)
  status=$?
  set -e
}

assert_no_success_claim() {
  if grep -Eiq 'firewall[^[:cntrl:]]*(closed|removed)|((closed|removed)[^[:cntrl:]]*firewall)' <<<"$output"; then
    fail "output does not claim firewall success" "$output"
  fi
}

prepare_case standard
run_remove
(( status == 0 )) || fail "removal succeeds with standard SSH rules" "$output"
[[ $(<"$state") == 'allow 443/tcp' ]] || fail "removal deletes only standard SSH rules" "$(cat "$state")"
[[ -s $home/.ssh/authorized_keys ]] || fail "declined key removal preserves authorized keys"

run_remove
(( status == 0 )) || fail "repeated removal accepts absent rules" "$output"
[[ $(<"$state") == 'allow 443/tcp' ]] || fail "repeated removal preserves unrelated rules"
pass "removal deletes all standard SSH rules, preserves HTTPS, and is idempotent"

for failure in delete-limit delete-port delete-service reload; do
  prepare_case "$failure"
  run_remove "$failure"
  (( status != 0 )) || fail "$failure failure makes removal fail" "$output"
  grep -Fq "injected ufw failure: $failure" <<<"$output" ||
    fail "$failure stderr reaches the caller" "$output"
  assert_no_success_claim
  [[ -s $home/.ssh/authorized_keys ]] || fail "$failure preserves authorized keys"
done
pass "each UFW deletion and reload failure is returned without false success"

prepare_case no-ufw
UFW_PRESENT=0 run_remove
(( status == 0 )) || fail "removal succeeds without UFW" "$output"
! grep -q '^ufw ' "$calls" || fail "no-UFW removal does not invoke UFW" "$(cat "$calls")"
assert_no_success_claim
[[ -s $home/.ssh/authorized_keys ]] || fail "no-UFW removal preserves authorized keys"
pass "no-UFW removal does not claim firewall success"
