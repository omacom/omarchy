#!/bin/bash

set -euo pipefail
source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

test_tmp=$(mktemp -d)
children=()
cleanup() {
  local status=$?
  trap - EXIT
  if (( ${#children[@]} )); then
    kill "${children[@]}" 2>/dev/null || true
    wait "${children[@]}" 2>/dev/null || true
  fi
  rm -rf "$test_tmp"
  exit "$status"
}
trap cleanup EXIT

# All policy, state, locks and command mutations stay in this private fixture.
# Native visudo validates inert fragments; no test installs host sudo policy.
mkdir -p "$test_tmp/bin" "$test_tmp/state" "$test_tmp/etc/sudoers.d" "$test_tmp/etc/tmpfiles.d" "$test_tmp/run/lock" "$test_tmp/hooks"
export TEST_GRANT_ROOT="$test_tmp"
cat >"$test_tmp/bin/stat" <<'STUB'
#!/bin/bash
case $2 in
  '%u') printf '0\n' ;;
  '%a') if [[ -d ${@: -1} ]]; then printf '755\n'; else printf '644\n'; fi ;;
  '%u %a') if [[ -d ${@: -1} ]]; then printf '0 755\n'; else printf '0 644\n'; fi ;;
  *) exec /usr/bin/stat "$@" ;;
esac
STUB
cat >"$test_tmp/bin/install" <<'STUB'
#!/bin/bash
args=()
while (($#)); do
  case $1 in -o|-g) shift 2 ;; *) args+=("$1"); shift ;; esac
done
exec /usr/bin/install "${args[@]}"
STUB
cat >"$test_tmp/bin/rm" <<'STUB'
#!/bin/bash
for path in "$@"; do
  if [[ ${TEST_FAIL_TEMP_CLEANUP:-0} == 1 && $path == "$TEST_GRANT_ROOT/state/".sudoers.* ]]; then exit 1; fi
  if [[ ${TEST_FAIL_RULE_DELETE:-0} == 1 && $path == "$TEST_GRANT_ROOT/etc/sudoers.d/"* ]]; then exit 1; fi
done
exec /usr/bin/rm "$@"
STUB
cat >"$test_tmp/bin/systemctl" <<'STUB'
#!/bin/bash
printf '%s\n' "$*" >>"$TEST_GRANT_ROOT/systemctl.log"
exit 0
STUB
chmod +x "$test_tmp/bin/"*
library="$test_tmp/grant-functions.sh"
{
  printf 'source %q\n' "$ROOT/bin/omarchy-security-functions"
  awk '/^set -euo pipefail$/ { functions=1 } /^case "\$\{1:-\}" in$/ { exit } functions { print }' "$ROOT/bin/omarchy-sudo-passwordless"
} | sed \
  -e "s|/var/lib/omarchy/sudo-passwordless|$test_tmp/state|g" \
  -e "s|/etc/sudoers.d|$test_tmp/etc/sudoers.d|g" \
  -e "s|/etc/tmpfiles.d|$test_tmp/etc/tmpfiles.d|g" \
  -e "s|/usr/share/libalpm/hooks|$test_tmp/hooks|g" \
  -e "s|/run/lock/omarchy-sudo-passwordless.lock|$test_tmp/run/lock/omarchy-sudo-passwordless.lock|g" \
  -e "s|/run/omarchy-sudo-passwordless-package-removing|$test_tmp/run/omarchy-sudo-passwordless-package-removing|g" \
  -e "s|/usr/bin/stat|$test_tmp/bin/stat|g" \
  -e "s|/usr/bin/install|$test_tmp/bin/install|g" \
  -e "s|/usr/bin/rm|$test_tmp/bin/rm|g" \
  -e "s|/usr/bin/systemctl|$test_tmp/bin/systemctl|g" \
  -e 's|/usr/bin/chown|/usr/bin/true|g' >"$library"

cp "$ROOT/default/libalpm/hooks/05-omarchy-passwordless-revoke.hook" "$test_tmp/hooks/"

printf 'r! /etc/sudoers.d/99-omarchy-nopasswd-*\n' >"$test_tmp/etc/tmpfiles.d/omarchy-nopasswd-sudo.conf"
# The expected policy text is mapped along with its filename in this fixture.
sed -i "s|/etc/sudoers.d|$test_tmp/etc/sudoers.d|" "$test_tmp/etc/tmpfiles.d/omarchy-nopasswd-sudo.conf"

(
  source "$library"
  for name in 'buildbot$' audituser aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa; do
    valid_account_name "$name" || fail "supported account name rejected: $name"
    printf '%s ALL=(ALL) NOPASSWD: ALL\n' "$name" >"$test_tmp/name-policy"
    /usr/sbin/visudo -cf "$test_tmp/name-policy" >/dev/null
  done
  for name in 'a$b' '$' aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa; do
    ! valid_account_name "$name" || fail "invalid account name accepted"
  done
  ! valid_uid 18446744073709551617 || fail "overflowed UID accepted"
  printf 'buildbot$ ALL=(ALL) NOPASSWD: ALL\n' >"$test_tmp/etc/sudoers.d/99-omarchy-nopasswd-buildbot$"
  remove_known_legacy_rules
  [[ ! -e $test_tmp/etc/sudoers.d/99-omarchy-nopasswd-buildbot\$ ]]
) || fail "supported account names and legacy cleanup disagree"
pass "provisioning-compatible names validate as sudoers and clean up correctly"

transaction_setup() {
  resolve_account() { ACCOUNT_NAME=audituser; ACCOUNT_UID=1000; }
  prepare_root_state() { :; }
  start_expiry_timer() { printf '%s\n' "$3" >>"$test_tmp/armed"; }
  stop_timer() { printf '%s\n' "$1" >>"$test_tmp/stopped"; }
}

(
  source "$library"
  transaction_setup
  TEST_FAIL_TEMP_CLEANUP=1 enable_locked 1000 15 && exit 1
  [[ ! -e $(rule_file 1000) && ! -e $(state_file 1000) && -s $test_tmp/stopped ]]
) || fail "post-publication cleanup failure did not revoke before timer cleanup"
pass "failed temporary cleanup after publication revokes the live policy"

rm -f "$test_tmp/stopped"
(
  source "$library"
  transaction_setup
  TEST_FAIL_TEMP_CLEANUP=1 TEST_FAIL_RULE_DELETE=1 enable_locked 1000 15 && exit 1
  [[ -f $(rule_file 1000) && -f $(state_file 1000) && ! -e $test_tmp/stopped ]]
  if TEST_FAIL_RULE_DELETE=1 revoke_inactive_grant 1000; then exit 1; else status=$?; fi
  (( status == 2 ))
) || fail "failed policy revocation disarmed expiry or claimed inactive status"
pass "failed revocation preserves expiry jobs and returns a distinct error"

(
  source "$library"
  transaction_setup
  current_timer=$(read_state_timer 1000)
  expire_locked 1000 omarchy-nopasswd-expire-1000-ffffffffffffffffffffffffffffffff
  [[ -f $(rule_file 1000) ]]
  expire_locked 1000
  [[ -f $(rule_file 1000) ]]
  expire_locked 1000 "$current_timer"
  [[ ! -e $(rule_file 1000) ]]
) || fail "a predecessor timer invalidates its replacement"
pass "old and legacy timer callbacks preserve a newer valid grant"

(
  source "$library"
  transaction_setup
  start_expiry_timer() {
    : >"$REMOVAL_BLOCKER"
    return 0
  }
  enable_locked 1000 15 && exit 1
  [[ ! -e $(rule_file 1000) ]]
) || fail "publication ignores a lost package prerequisite"
rm "$test_tmp/run/omarchy-sudo-passwordless-package-removing"
pass "grant publication rechecks package availability after timer setup"

pkgs_path=${OMARCHY_PKGS_PATH:-$ROOT/../omarchy-pkgs}
[[ ! -d $pkgs_path/pkgbuilds ]] || pkgs_path=$pkgs_path/pkgbuilds
package_script="$pkgs_path/omarchy-settings/omarchy-settings.install"
[[ -f $package_script ]] || fail "package checkout is required for shared lifecycle coverage"
sed -e "s|/etc/|$test_tmp/etc/|g" \
  -e "s|/run|$test_tmp/run|g" \
  -e "s|/usr/bin/stat|$test_tmp/bin/stat|g" \
  -e "s|/usr/bin/rm|$test_tmp/bin/rm|g" "$package_script" >"$test_tmp/package.install"

worker="$test_tmp/publisher.sh"
{
  printf '#!/bin/bash\nset -euo pipefail\nsource %q\n' "$library"
  declare -f transaction_setup
  printf 'test_tmp=%q\ntransaction_setup\n' "$test_tmp"
  cat <<'WORKER'
publish_rule() {
  : >"$test_tmp/publisher.entered"
  while [[ ! -e $test_tmp/publisher.release ]]; do sleep 0.02; done
  printf 'audituser ALL=(ALL) NOPASSWD: ALL\n' >"$(rule_file "$1")"
}
with_root_lock enable_locked 1000 15
WORKER
} >"$worker"
bash "$worker" >"$test_tmp/publisher.output" 2>&1 &
children+=("$!")
for ((attempt = 0; attempt < 250; attempt++)); do
  [[ ! -e $test_tmp/publisher.entered ]] || break
  sleep 0.02
done
[[ -e $test_tmp/publisher.entered ]] || fail "grant publisher did not enter the shared lock"
bash -euo pipefail -c 'source "$1"; : >"$2"; pre_remove; post_remove' bash \
  "$test_tmp/package.install" "$test_tmp/removal.started" >"$test_tmp/removal.output" 2>&1 &
children+=("$!")
for ((attempt = 0; attempt < 250; attempt++)); do
  [[ ! -e $test_tmp/removal.started ]] || break
  sleep 0.02
done
[[ -e $test_tmp/removal.started ]] || fail "package removal did not start"
touch "$test_tmp/publisher.release"
for child in "${children[@]}"; do wait "$child" || fail "shared lifecycle worker failed"; done
children=()
[[ ! -e $test_tmp/etc/sudoers.d/99-omarchy-nopasswd-1000 ]] || fail "removal left a concurrently published grant"
[[ -f $test_tmp/run/omarchy-sudo-passwordless-package-removing ]] || fail "removal did not block later publication"
(
  source "$library"
  transaction_setup
  ! with_root_lock enable_locked 1000 15
) || fail "a publisher can create a grant after package removal begins"
pass "package removal shares the grant lock and blocks later publication"

printf 'audituser ALL=(ALL) NOPASSWD: ALL\n' >"$test_tmp/etc/sudoers.d/99-omarchy-nopasswd-1000"
if TEST_FAIL_RULE_DELETE=1 bash -euo pipefail -c 'source "$1"; post_remove' bash "$test_tmp/package.install" >"$test_tmp/removal-failure.output" 2>&1; then
  fail "package removal hid a failed policy deletion"
fi
grep -q 'Administrator cleanup is required' "$test_tmp/removal-failure.output" || fail "package deletion failure lacks recovery guidance"
pass "package removal reports cleanup failures instead of successful revocation"

(
  source "$library"
  transaction_setup
  rm -f "$REMOVAL_BLOCKER"
  enable_locked 1000 5
  record=$(read_state_record 1000)
  expiry=${record#*$'\t'}
  expiry=${expiry%%$'\t'*}
  deadline=$(/usr/bin/date -u -d "@$expiry" +%Y%m%d%H%M%SZ)
  [[ $(cat "$(rule_file 1000)") == "audituser ALL=(ALL) NOTAFTER=$deadline NOPASSWD: ALL" ]]
  /usr/sbin/visudo -cf "$(rule_file 1000)" >/dev/null
  classify_generated_rule "$(rule_file 1000)"
  rm -f "$(state_file 1000)"
  remove_known_legacy_rules
  [[ ! -e $(rule_file 1000) ]]
) || fail "native sudo deadline or state-independent bounded rule cleanup is incorrect"
pass "sudo policy contains the same deadline and bounded orphan rules are recognized"

(
  source "$library"
  transaction_setup
  rm -f "$REMOVAL_BLOCKER"
  enable_locked 1000 5
  if TEST_FAIL_RULE_DELETE=1 package_removing_locked; then exit 1; fi
  [[ -f $REMOVAL_BLOCKER && -f $(rule_file 1000) ]]
  ! enable_locked 1000 5
  package_removing_locked
  [[ ! -e $(rule_file 1000) ]]
  rm -f "$REMOVAL_BLOCKER" "$PACKAGE_HOOK"
  ! enable_locked 1000 5
) || fail "pre-transaction revocation error or missing hook does not prevent new grants"
pass "package hook fails closed and grants require its installed policy"
