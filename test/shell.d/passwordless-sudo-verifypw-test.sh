#!/bin/bash

set -euo pipefail
source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"
source "$SHELL_TEST_DIR/fixtures/passwordless-sudo-test.sh"

# Under sudo's default verifypw=all, `sudo -v` asks for a password unless every
# entry the user has is passwordless. The installer's own admin grant is
# password-requiring, so a user who asked for passwordless sudo could not
# validate credentials without a password. The published grant therefore
# carries the sudoers default that makes validation read the grant instead of
# every other entry in the policy. The default names the account that asked
# for the grant, so it changes the rule for that account alone.

(
  source "$library"
  enable_locked 1000 15
  head -1 "$(rule_file 1000)" | grep -qx 'Defaults:audituser verifypw = any'
  tail -1 "$(rule_file 1000)" | grep -qxE 'audituser ALL=\(ALL\) NOTAFTER=[0-9]{14}Z NOPASSWD: ALL'
)
pass "the published grant carries the sudoers default above its rule"

(
  source "$library"
  enable_locked 1000 permanent
  head -1 "$(rule_file 1000 permanent)" | grep -qx 'Defaults:audituser verifypw = any'
  tail -1 "$(rule_file 1000 permanent)" | grep -qx 'audituser ALL=(ALL) NOPASSWD: ALL'
)
pass "a permanent grant carries the sudoers default above its rule"

# The default is scoped to the account that asked for the grant, so it never
# changes the rule for another account on the host.
(
  source "$library"
  enable_locked 1000 15
  ! grep -q '^Defaults verifypw' "$(rule_file 1000)"
)
pass "the published default is scoped to the account that asked for the grant"

# A grant published before the default existed is still this command's grant,
# so it keeps working until it is rewritten.
(
  source "$library"
  reset_grant
  printf 'audituser ALL=(ALL) NOPASSWD: ALL\n' >"$(rule_file 1000 permanent)"
  read_grant 1000
  [[ $GRANT_NAME == "audituser" ]]
)
pass "a grant published before the default existed is still read as the user's grant"

# A default that names another account is not this command's grant.
(
  source "$library"
  reset_grant
  printf 'Defaults:root verifypw = any\naudituser ALL=(ALL) NOPASSWD: ALL\n' >"$(rule_file 1000 permanent)"
  assert_status 2 read_grant 1000
)
pass "a default that names another account is not read as the user's grant"

# Readable policy under the generated prefix that is not this command's grant
# is foreign, so cleanup takes it out of sudoers instead of leaving it live.
(
  source "$library"
  reset_grant
  printf 'Defaults:root verifypw = any\naudituser ALL=(ALL) NOPASSWD: ALL\n' >"$(rule_file 1000)"
  cleanup_all_locked
  [[ ! -e $(rule_file 1000) ]]
  grep -qx 'Defaults:root verifypw = any' "$test_tmp"/var/lib/omarchy/sudoers-quarantine/*/policy
)
pass "cleanup quarantines a grant whose default names another account"

# The upgrade rewrites such a grant in place, keeping the rule and its
# deadline exactly as they were.
(
  source "$library"
  reset_grant
  printf 'audituser ALL=(ALL) NOTAFTER=20261231235959Z NOPASSWD: ALL\n' >"$(rule_file 1000)"
  upgrade_grant_format_locked
  head -1 "$(rule_file 1000)" | grep -qx 'Defaults:audituser verifypw = any'
  tail -1 "$(rule_file 1000)" | grep -qx 'audituser ALL=(ALL) NOTAFTER=20261231235959Z NOPASSWD: ALL'
  [[ $(wc -l <"$(rule_file 1000)") == 2 ]]
)
pass "the upgrade rewrites a grant published before the default existed"

(
  source "$library"
  reset_grant
  printf 'audituser ALL=(ALL) NOPASSWD: ALL\n' >"$(rule_file 1000 permanent)"
  upgrade_grant_format_locked
  upgrade_grant_format_locked
  [[ $(wc -l <"$(rule_file 1000 permanent)") == 2 ]]
  head -1 "$(rule_file 1000 permanent)" | grep -qx 'Defaults:audituser verifypw = any'
  tail -1 "$(rule_file 1000 permanent)" | grep -qx 'audituser ALL=(ALL) NOPASSWD: ALL'
)
pass "the upgrade leaves a grant that already carries the default alone"

# Policy this command did not generate stays untouched: it belongs to the
# administrator, and rewriting it would publish a rule nobody asked for.
(
  source "$library"
  printf 'admin ALL=(ALL) NOPASSWD: /usr/bin/true\n' >"$test_tmp/etc/sudoers.d/99-omarchy-nopasswd-custom"
  upgrade_grant_format_locked
  [[ $(cat "$test_tmp/etc/sudoers.d/99-omarchy-nopasswd-custom") == 'admin ALL=(ALL) NOPASSWD: /usr/bin/true' ]]
)
pass "the upgrade leaves administrator policy under the generated prefix alone"

# Status and revocation run the installed copy. A dev-linked checkout newer
# than the package must not rewrite a grant into a form that copy cannot revoke.
(
  source "$library"
  reset_grant
  printf 'audituser ALL=(ALL) NOPASSWD: ALL\n' >"$(rule_file 1000 permanent)"
  rm "$test_tmp/installed/omarchy-sudo-passwordless"
  sed '/__upgrade-grant-format/d' "$test_tmp/omarchy-sudo-passwordless" >"$test_tmp/installed/omarchy-sudo-passwordless"
  upgrade_grant_format_locked
  [[ $(cat "$(rule_file 1000 permanent)") == 'audituser ALL=(ALL) NOPASSWD: ALL' ]]
)
rm -f "$test_tmp/installed/omarchy-sudo-passwordless"
ln -s ../omarchy-sudo-passwordless "$test_tmp/installed/omarchy-sudo-passwordless"
pass "the upgrade leaves grants alone while the installed copy cannot read the new form"

# The migration reaches the upgrade through the command's own dispatch, so the
# action has to be reachable from the executable and not only from inside it.
(
  PATH="$test_tmp/bin:$PATH" TEST_EUID=0 "$test_tmp/omarchy-sudo-passwordless" __upgrade-grant-format
)
pass "the upgrade action is reachable through the command's own dispatch"

# The migration itself has to run: it reaches the upgrade through that
# dispatch, and a failure there would stop the queue and leave every later
# migration pending.
mkdir -p "$test_tmp/source/bin"
ln -sf "$test_tmp/omarchy-sudo-passwordless" "$test_tmp/source/bin/omarchy-sudo-passwordless"
(
  source "$library"
  reset_grant
  printf 'audituser ALL=(ALL) NOPASSWD: ALL\n' >"$(rule_file 1000 permanent)"
  PATH="$test_tmp/bin:$PATH" TEST_MIGRATION=1 TEST_STATUS=0 OMARCHY_PATH="$test_tmp/source" \
    /usr/bin/bash -euo pipefail "$ROOT/migrations/1792527479.sh"
  head -1 "$(rule_file 1000 permanent)" | grep -qx 'Defaults:audituser verifypw = any'
)
pass "the migration rewrites the grant of an account that holds one"

# Migrations run for every account, and one without a grant, or without sudo
# at all, must not be stopped by a prompt to authorize nothing.
(
  source "$library"
  reset_grant
  PATH="$test_tmp/bin:$PATH" TEST_MIGRATION=1 TEST_NO_SUDO=1 OMARCHY_PATH="$test_tmp/source" \
    /usr/bin/bash -euo pipefail "$ROOT/migrations/1792527479.sh"
  ! grep -q '__upgrade-grant-format' "$test_tmp/commands"
)
pass "the migration asks nothing of an account without a grant"
