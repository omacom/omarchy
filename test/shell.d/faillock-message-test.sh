#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

grep -q 'preauth deny=10 unlock_time=120' "$ROOT/install/config/increase-lockout-limit.sh" ||
  fail "install lockout script drops preauth silent"
! grep -q 'preauth silent' "$ROOT/install/config/increase-lockout-limit.sh" ||
  fail "install lockout script no longer writes preauth silent"
pass "install lockout script drops preauth silent"

grep -q 'pam_faillock.so preauth deny=10 unlock_time=120' "$ROOT/bin/omarchy-apply-lock" ||
  fail "lock PAM template drops preauth silent"
! grep -q 'preauth silent' "$ROOT/bin/omarchy-apply-lock" ||
  fail "lock PAM template no longer writes preauth silent"
pass "lock PAM template drops preauth silent"

! grep -q 'preauth silent' "$ROOT/bin/omarchy-upgrade-to-quattro" ||
  fail "upgrade-to-quattro no longer writes preauth silent"
pass "upgrade-to-quattro no longer writes preauth silent"

migration=$(ls "$ROOT"/migrations/*.sh | xargs -n1 basename | sort -n | while read -r name; do
  if grep -q 'Tell users when pam_faillock has locked the account' "$ROOT/migrations/$name"; then
    echo "$name"
    break
  fi
done)
[[ -n $migration ]] || fail "faillock message migration exists"
pass "faillock message migration exists"

tmp=$(mktemp -d)
trap 'rm -rf "$tmp"' EXIT
mkdir -p "$tmp/etc/pam.d" "$tmp/bin"
cat >"$tmp/etc/pam.d/system-auth" <<'PAM'
auth       required                    pam_faillock.so preauth silent deny=10 unlock_time=120
auth       [default=die]               pam_faillock.so authfail deny=10 unlock_time=120
PAM
cat >"$tmp/etc/pam.d/omarchy-lock-password" <<'PAM'
auth       required                    pam_faillock.so preauth silent deny=10 unlock_time=120
PAM
cat >"$tmp/bin/sudo" <<'SUDO'
#!/bin/bash
exec "$@"
SUDO
chmod +x "$tmp/bin/sudo"

# Rewrite absolute paths in a temp copy of the migration for the fixture.
sed \
  -e "s|/etc/pam.d/system-auth|$tmp/etc/pam.d/system-auth|g" \
  -e "s|/etc/pam.d/omarchy-lock-password|$tmp/etc/pam.d/omarchy-lock-password|g" \
  "$ROOT/migrations/$migration" >"$tmp/migration.sh"

PATH="$tmp/bin:$PATH" bash -euo pipefail "$tmp/migration.sh"

grep -q 'preauth deny=10' "$tmp/etc/pam.d/system-auth" || fail "migration strips silent from system-auth"
! grep -q 'preauth silent' "$tmp/etc/pam.d/system-auth" || fail "system-auth no longer has preauth silent"
grep -q 'preauth deny=10' "$tmp/etc/pam.d/omarchy-lock-password" || fail "migration strips silent from lock PAM"
! grep -q 'preauth silent' "$tmp/etc/pam.d/omarchy-lock-password" || fail "lock PAM no longer has preauth silent"
pass "migration strips preauth silent from existing PAM files"
