#!/bin/bash

set -euo pipefail
source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"
source "$SHELL_TEST_DIR/fixtures/passwordless-sudo-test.sh"

quarantine="$test_tmp/var/lib/omarchy/sudoers-quarantine"
quarantined_policy() {
  local entry
  for entry in "$quarantine"/*/; do
    if [[ $(cat "$entry/name") == "$1" ]]; then
      cat "$entry/policy"
      return 0
    fi
  done
  return 1
}
# The old writer accepted any $USER, so a basename can sit just under NAME_MAX.
long_suffix=$(printf 'l%.0s' {1..223})
(
  source "$library"
  printf 'deleteduser ALL=(ALL) NOPASSWD: ALL\n' >"$(rule_file 1000)"
  printf 'buildbot$ ALL=(ALL) NOPASSWD: ALL\n' >"$test_tmp/etc/sudoers.d/99-omarchy-nopasswd-buildbot$"
  # The legacy command never validated the account name, so a manual or NSS
  # account outside the current policy still has its exact old grant removed.
  printf 'Alice ALL=(ALL) NOPASSWD: ALL\n' >"$test_tmp/etc/sudoers.d/99-omarchy-nopasswd-Alice"
  # The legacy writer produced the body with echo. Under BASH_ENV with
  # xpg_echo, USER='ali\0143e' yields this filename with an 'alice' rule, so
  # a suffix/body mismatch does not prove administrator authorship.
  printf 'alice ALL=(ALL) NOPASSWD: ALL\n' >"$test_tmp/etc/sudoers.d/99-omarchy-nopasswd-ali\\0143e"
  printf 'alice ALL=(ALL) NOPASSWD: ALL\n' >"$test_tmp/etc/sudoers.d/99-omarchy-nopasswd-$long_suffix"
  printf 'admin ALL=(ALL) NOPASSWD: /usr/bin/true\n' >"$test_tmp/etc/sudoers.d/99-omarchy-nopasswd-custom"
  TEST_DELETE_FAIL=1 assert_status 1 cleanup_all_locked
  [[ -e $(rule_file 1000) ]]
  cleanup_all_locked
  ! compgen -G "$test_tmp/etc/sudoers.d/99-omarchy-nopasswd-*"
  [[ $(stat -c '%a' "$quarantine") == 700 ]]
  [[ $(quarantined_policy '99-omarchy-nopasswd-ali\0143e') == 'alice ALL=(ALL) NOPASSWD: ALL' ]]
  [[ $(quarantined_policy "99-omarchy-nopasswd-$long_suffix") == 'alice ALL=(ALL) NOPASSWD: ALL' ]]
  [[ $(quarantined_policy 99-omarchy-nopasswd-custom) == 'admin ALL=(ALL) NOPASSWD: /usr/bin/true' ]]
  (( $(ls -A "$quarantine" | wc -l) == 3 ))
)
pass "legacy cleanup removes generated rules for any account and quarantines everything else in the prefix"

marker="$test_tmp/var/lib/omarchy/migrations/1788163635"
: >"$test_tmp/marker-target"
(
  source "$library"
  migrate_locked
  [[ -f $marker ]]
  TEST_BAD_PATH="$marker" assert_status 1 migration_complete
  rm "$marker"
  ln -s "$test_tmp/marker-target" "$marker"
  assert_status 1 migration_complete
  assert_status 1 migrate_locked
  [[ -L $marker ]]
  rm "$marker"
)
pass "migration checks marker ownership and rejects symlinks"

# systemd-tmpfiles operates on an explicit disposable root, never the host.
reset_grant
: >"$test_tmp/etc/sudoers.d/99-omarchy-nopasswd-1000"
: >"$test_tmp/etc/sudoers.d/unrelated"
rule='r! /etc/sudoers.d/99-omarchy-nopasswd-*'
/usr/bin/systemd-tmpfiles --root="$test_tmp" --remove --inline "$rule"
[[ -f $test_tmp/etc/sudoers.d/99-omarchy-nopasswd-1000 ]] || fail "routine tmpfiles shortened a live grant"
/usr/bin/systemd-tmpfiles --root="$test_tmp" --remove --boot --inline "$rule"
[[ ! -e $test_tmp/etc/sudoers.d/99-omarchy-nopasswd-1000 && -f $test_tmp/etc/sudoers.d/unrelated ]] || fail "boot cleanup boundary"
pass "native boot cleanup removes grants while routine tmpfiles preserves them"

# Keep real package scripts in the contract: source and packaging share the
# same lock and blocker, including the legacy scriptlet fallback.
if ! find_omarchy_pkgs; then
  skip "package scriptlets need the omarchy-pkgs checkout; set OMARCHY_PKGS_PATH to it"
  exit 0
fi
pkgs_path=$OMARCHY_PKGS_ROOT
# The scriptlet half of this contract is omacom/omarchy-pkgs#944, still open.
# Skip only while the checkout is in the state before it: neither settings
# package defines pre_remove nor mentions the passwordless-sudo helper. Once
# either does, both are held to the full contract below, so a scriptlet that
# loses its pre_remove fails rather than skips.
# Remove this gate once omacom/omarchy-pkgs#944 lands.
pre_944=true
for name in omarchy-settings omarchy-settings-dev; do
  script="$pkgs_path/$name/$name.install"
  [[ -f $script && -r $script ]] || fail "the omarchy-pkgs checkout at $pkgs_path ships a readable $name.install"
  if grep -Eq '^[[:space:]]*(function[[:space:]]+pre_remove\b|pre_remove[[:space:]]*\(\))|omarchy-sudo-passwordless' "$script"; then
    pre_944=false
  fi
done
if [[ $pre_944 == "true" ]]; then
  skip "package scriptlets: the omarchy-pkgs checkout predates the settings packages' sudo cleanup (omacom/omarchy-pkgs#944)"
  exit 0
fi
for name in omarchy-settings omarchy-settings-dev; do
  script="$pkgs_path/$name/$name.install"
  [[ -f $script ]] || fail "the omarchy-pkgs checkout at $pkgs_path ships $name.install"
  sed -e "s|/etc/|$test_tmp/etc/|g" -e "s|/run|$test_tmp/run|g" \
    -e "s|/usr/bin/stat|$test_tmp/bin/stat|g" -e "s|/usr/bin/rm|$test_tmp/bin/rm|g" \
    "$script" >"$test_tmp/$name.install"
  reset_grant
  (
    source "$library"
    source "$test_tmp/$name.install"
    _etc_overrides_apply() { :; }
    enable_locked 1000 15
    TEST_DELETE_FAIL=1 assert_status 1 pre_remove
    [[ -e $REMOVAL_BLOCKER && -e $(rule_file 1000) ]]
    assert_status 1 enable_locked 1000 15
    pre_remove && post_remove
    [[ ! -e $(rule_file 1000) ]]
    post_install
    [[ ! -e $REMOVAL_BLOCKER ]]
    enable_locked 1000 15
    pre_upgrade && post_upgrade
    [[ ! -e $(rule_file 1000) && ! -e $REMOVAL_BLOCKER ]]
    # pacman does not stop a transaction on a failed scriptlet, so a failed
    # pre_upgrade can be followed directly by post_upgrade. Completion must
    # not clear the blocker while a rule remains, and a clean retry recovers.
    enable_locked 1000 15
    TEST_DELETE_FAIL=1 assert_status 1 pre_upgrade
    TEST_DELETE_FAIL=1 assert_status 1 post_upgrade
    [[ -e $REMOVAL_BLOCKER && -e $(rule_file 1000) ]]
    assert_status 1 enable_locked 1000 15
    post_upgrade
    [[ ! -e $(rule_file 1000) && ! -e $REMOVAL_BLOCKER ]]
    # A stranded blocker plus a live rule from an interrupted removal is
    # cleaned by the next completed installation, not merely unblocked.
    enable_locked 1000 15
    : >"$REMOVAL_BLOCKER"
    post_install
    [[ ! -e $(rule_file 1000) && ! -e $REMOVAL_BLOCKER ]]
    # A fresh install has no earlier step, so completion must hold the blocker
    # itself while it sweeps: a leftover rule it cannot remove leaves
    # publication refused rather than merely reporting an error.
    enable_locked 1000 15
    rm -f "$REMOVAL_BLOCKER"
    TEST_DELETE_FAIL=1 assert_status 1 post_install
    [[ -e $REMOVAL_BLOCKER && -e $(rule_file 1000) ]]
    assert_status 1 enable_locked 1000 15
    post_install
    [[ ! -e $(rule_file 1000) && ! -e $REMOVAL_BLOCKER ]]
    # The sweep must not depend on the glob state pacman's shell inherits.
    enable_locked 1000 15
    ( set -f; GLOBIGNORE='*' post_upgrade )
    [[ ! -e $(rule_file 1000) && ! -e $REMOVAL_BLOCKER ]]
    # A failure before the lock is even taken, such as an untrusted lock
    # directory, must still leave publication refused.
    enable_locked 1000 15
    rm -f "$REMOVAL_BLOCKER"
    TEST_BAD_PATH="$test_tmp/run/lock" assert_status 1 post_install
    [[ -e $REMOVAL_BLOCKER && -e $(rule_file 1000) ]]
    TEST_BAD_PATH="$test_tmp/run/lock" assert_status 1 pre_upgrade
    [[ -e $REMOVAL_BLOCKER ]]
    post_install
    [[ ! -e $(rule_file 1000) && ! -e $REMOVAL_BLOCKER ]]
  )
done
pass "both settings packages revoke grants, block publication, and recover on installation only with the namespace empty"

reset_grant
# Hold the source lock, then start package removal. A native flock on the
# mapped file must serialize both implementations.
cat >"$test_tmp/worker" <<'WORKER'
#!/bin/bash
set -euo pipefail
source "$TEST_LIBRARY"
critical() {
  touch "$TEST_GRANT_ROOT/entered"
  for (( attempt=0; attempt<500; attempt++ )); do
    [[ ! -e $TEST_GRANT_ROOT/release ]] || break
    sleep 0.01
  done
  [[ -e $TEST_GRANT_ROOT/release ]] || return 1
  enable_locked 1000 15
}
with_root_lock critical
WORKER
TEST_LIBRARY="$library" /usr/bin/bash "$test_tmp/worker" >"$test_tmp/publisher.log" 2>&1 &
publisher=$!
children+=("$publisher")
for (( attempt=0; attempt<200; attempt++ )); do
  [[ ! -e $test_tmp/entered ]] || break
  sleep 0.01
done
[[ -f $test_tmp/entered ]] || fail "publisher failed to acquire the lock"
/usr/bin/bash -euo pipefail -c 'source "$1"; pre_remove; post_remove' bash "$test_tmp/omarchy-settings.install" >"$test_tmp/removal.log" 2>&1 &
removal=$!
children+=("$removal")
# The removal announces itself before waiting for the lock, so a publisher
# still holding it is refused rather than allowed to publish a rule that the
# removal would delete a moment later.
for (( attempt=0; attempt<200; attempt++ )); do
  [[ ! -f $test_tmp/run/omarchy-sudo-passwordless-package-removing ]] || break
  sleep 0.01
done
[[ -f $test_tmp/run/omarchy-sudo-passwordless-package-removing ]] || fail "removal did not announce itself before waiting for the lock"
touch "$test_tmp/release"
if wait "$publisher"; then fail "publisher was allowed to publish after removal announced itself" "$(cat "$test_tmp/publisher.log")"; fi
wait "$removal" || fail "removal failed" "$(cat "$test_tmp/removal.log")"
children=()
[[ ! -e $test_tmp/etc/sudoers.d/99-omarchy-nopasswd-1000 ]]
[[ -f $test_tmp/run/omarchy-sudo-passwordless-package-removing ]]
pass "an announced package removal refuses a waiting publisher and clears the namespace"
