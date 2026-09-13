#!/bin/bash

set -euo pipefail
source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"
source "$SHELL_TEST_DIR/fixtures/passwordless-sudo-test.sh"

(
  source "$library"
  printf 'deleteduser ALL=(ALL) NOPASSWD: ALL\n' >"$(rule_file 1000)"
  printf 'buildbot$ ALL=(ALL) NOPASSWD: ALL\n' >"$test_tmp/etc/sudoers.d/99-omarchy-nopasswd-buildbot$"
  printf 'admin ALL=(ALL) NOPASSWD: /usr/bin/true\n' >"$test_tmp/etc/sudoers.d/99-omarchy-nopasswd-custom"
  TEST_DELETE_FAIL=1 assert_status 1 cleanup_all_locked
  [[ -e $(rule_file 1000) ]]
  cleanup_all_locked
  [[ ! -e $(rule_file 1000) && -e $test_tmp/etc/sudoers.d/99-omarchy-nopasswd-custom ]]
  ! compgen -G "$test_tmp/etc/sudoers.d/99-omarchy-nopasswd-buildbot*"
)
pass "legacy cleanup removes generated orphan rules and preserves custom policy"

# Run the actual migration queue for separate temporary homes. Sudo only calls
# the mapped helper and can be refused without requesting host authorization.
mkdir -p "$test_tmp/source/migrations"
sed "s|/usr/bin/omarchy-sudo-passwordless|$test_tmp/omarchy-sudo-passwordless|g" \
  "$ROOT/migrations/1788163635.sh" >"$test_tmp/source/migrations/1788163635.sh"
printf 'echo "later migration ran"\n' >"$test_tmp/source/migrations/1788163636.sh"
run_migrations() {
  TEST_MIGRATION=1 OMARCHY_PATH="$test_tmp/source" OMARCHY_MIGRATION_STATE="$test_tmp/$1" \
    PATH="$test_tmp/bin:$PATH" /usr/bin/bash "$ROOT/bin/omarchy-migrate" >"$test_tmp/migrations.log" 2>&1
}
marker="$test_tmp/var/lib/omarchy/migrations/1788163635"
(
  source "$library"
  printf 'audituser ALL=(ALL) NOPASSWD: ALL\n' >"$(rule_file 1000)"
  TEST_DELETE_FAIL=1 assert_status 1 run_migrations first
  [[ ! -e $marker && ! -e $test_tmp/first/1788163636.sh ]]
  run_migrations first
  [[ -f $marker && -f $test_tmp/first/1788163636.sh ]]
  enable_locked 1000 15
  cp "$(rule_file 1000)" "$test_tmp/renewed"
  : >"$test_tmp/commands"
  TEST_NO_SUDO=1 run_migrations second
  [[ -f $test_tmp/second/1788163636.sh ]]
  ! grep -q '^sudo ' "$test_tmp/commands"
  cmp "$(rule_file 1000)" "$test_tmp/renewed"
)
pass "migration completion is machine-wide, retryable, and needs no sudo for later users"

(
  source "$library"
  TEST_BAD_PATH="$marker" assert_status 1 migration_complete
  rm "$marker"
  ln -s "$test_tmp/renewed" "$marker"
  assert_status 1 migration_complete
  assert_status 1 migrate_locked
  [[ -L $marker ]]
  rm "$marker"
)
pass "migration checks marker ownership and rejects symlinks"

# Keep real package scripts in the contract: source and packaging share the
# same lock and blocker, including the legacy scriptlet fallback.
pkgs_path=${OMARCHY_PKGS_PATH:-$ROOT/../omarchy-pkgs}
[[ ! -d $pkgs_path/pkgbuilds ]] || pkgs_path=$pkgs_path/pkgbuilds
for name in omarchy-settings omarchy-settings-dev; do
  script="$pkgs_path/$name/$name.install"
  [[ -f $script ]] || fail "set OMARCHY_PKGS_PATH to the companion package checkout"
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
  )
done
pass "both settings packages revoke grants, block publication, and recover on installation"

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
touch "$test_tmp/release"
wait "$publisher" || fail "publisher failed" "$(cat "$test_tmp/publisher.log")"
wait "$removal" || fail "removal failed" "$(cat "$test_tmp/removal.log")"
children=()
[[ ! -e $test_tmp/etc/sudoers.d/99-omarchy-nopasswd-1000 ]]
[[ -f $test_tmp/run/omarchy-sudo-passwordless-package-removing ]]
pass "native lock serializes grant publication with package removal"

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
