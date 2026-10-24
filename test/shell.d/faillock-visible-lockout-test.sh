#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

install_script="$ROOT/install/config/increase-lockout-limit.sh"
migration="$ROOT/migrations/1790385000.sh"

[[ -f $install_script ]] || fail "lockout install script is present"
[[ -f $migration ]] || fail "lockout visibility migration is present"

sudoers="$ROOT/etc/sudoers.d/omarchy-passwd-tries"
[[ -f $sudoers ]] || fail "passwd_tries sudoers drop-in is present"
grep -Eq '^Defaults[[:space:]]+!pam_silent[[:space:]]*$' "$sudoers" ||
  fail "sudoers clears pam_silent so faillock messages reach the terminal" "$(cat "$sudoers")"
pass "sudoers allows pam_faillock messages through sudo"


tmpdir=$(mktemp -d)
trap 'rm -rf "$tmpdir"' EXIT

pam="$tmpdir/system-auth"
# Shape of an Arch/Omarchy system-auth preauth line before this fix.
cat >"$pam" <<'EOF'
auth      required                    pam_faillock.so preauth silent deny=10 unlock_time=120
auth      [success=1 default=bad]     pam_unix.so try_first_pass nullok
auth      [default=die]               pam_faillock.so authfail deny=10 unlock_time=120
auth      sufficient                  pam_faillock.so authsucc
EOF

# Apply the actual install transform before migration, using the same synthetic
# system-auth file and restricted sudo stub as the existing-install path.
cp "$pam" "$tmpdir/original-pam"

# Run the actual migration, relocating its sole PAM target into this fixture.
# The sudo stub accepts only sed against that synthetic file; it never elevates.
mkdir -p "$tmpdir/bin"
cat >"$tmpdir/bin/sudo" <<'STUB'
#!/bin/bash
[[ $1 == "sed" && ${*: -1} == "$TEST_PAM" ]] || exit 99
shift
exec sed "$@"
STUB
chmod +x "$tmpdir/bin/sudo"
export TEST_PAM="$pam"
export TEST_AUTOLOGIN="$tmpdir/sddm-autologin" TEST_REAL_SED
TEST_REAL_SED=$(command -v sed)
printf 'auth required pam_permit.so\n' >"$TEST_AUTOLOGIN"
cat >"$tmpdir/bin/sed" <<'STUB'
#!/bin/bash
[[ ${*: -1} == "$TEST_PAM" || ${*: -1} == "$TEST_AUTOLOGIN" ]] || exit 99
exec "$TEST_REAL_SED" "$@"
STUB
chmod +x "$tmpdir/bin/sed"

sed "s|/etc/pam.d/system-auth|$pam|g; s|/etc/pam.d/sddm-autologin|$TEST_AUTOLOGIN|g" "$install_script" >"$tmpdir/install.sh"
PATH="$tmpdir/bin:$PATH" bash -euo pipefail "$tmpdir/install.sh"
grep -Eq 'pam_faillock\.so preauth deny=10 unlock_time=120' "$pam" ||
  fail "fresh install removes silent and sets lockout parameters" "$(cat "$pam")"
! grep -Eq 'preauth[[:space:]]+silent' "$pam" || fail "fresh install leaves no silent preauth token"
pass "actual install transform makes lockout messages visible"
cp "$tmpdir/original-pam" "$pam"

sed "s|/etc/pam.d/system-auth|$pam|g" "$migration" >"$tmpdir/migration.sh"
PATH="$tmpdir/bin:$PATH" bash -euo pipefail "$tmpdir/migration.sh"

grep -Eq 'pam_faillock\.so preauth deny=10 unlock_time=120' "$pam" ||
  fail "migration strips silent and keeps deny/unlock_time" "$(grep faillock "$pam")"
! grep -Eq 'preauth[[:space:]]+silent' "$pam" ||
  fail "migration leaves no silent on preauth" "$(grep faillock "$pam")"
grep -Eq 'authfail deny=10 unlock_time=120' "$pam" ||
  fail "migration leaves authfail args alone" "$(grep faillock "$pam")"
pass "migration strips silent from an existing preauth line"

# Idempotent on an already-fixed line.
PATH="$tmpdir/bin:$PATH" bash -euo pipefail "$tmpdir/migration.sh"
grep -c 'pam_faillock\.so' "$pam" | grep -qx 3 ||
  fail "re-running the strip does not duplicate faillock lines" "$(grep faillock "$pam")"
pass "stripping silent is idempotent"

# The migration file itself targets system-auth with the same transform.
grep -Fq '/etc/pam.d/system-auth' "$migration" ||
  fail "migration edits system-auth"
grep -Fq 'preauth' "$migration" && grep -Fq 'silent' "$migration" ||
  fail "migration mentions the silent preauth token"
pass "migration targets the silent preauth on system-auth"

# The upgrade can run before or after the migration. Exercise its actual
# system-auth transforms on both so it neither keeps nor restores silent.
grep -F 'as_root sed -i' "$ROOT/bin/omarchy-upgrade-to-quattro" |
  grep -F '/etc/pam.d/system-auth' >"$tmpdir/upgrade.sh"
[[ -s $tmpdir/upgrade.sh ]] || fail "upgrade system-auth transforms were found"
sed -i "s|/etc/pam.d/system-auth|$pam|g; s/as_root sed/sudo sed/g" "$tmpdir/upgrade.sh"
for state in repaired original; do
  if [[ $state == "original" ]]; then
    cp "$tmpdir/original-pam" "$pam"
  fi
  PATH="$tmpdir/bin:$PATH" bash -euo pipefail "$tmpdir/upgrade.sh"
  grep -Eq 'pam_faillock\.so preauth deny=10 unlock_time=120' "$pam" ||
    fail "upgrade leaves a visible lockout on the $state system-auth" "$(cat "$pam")"
  ! grep -Eq 'preauth[[:space:]]+silent' "$pam" ||
    fail "upgrade leaves no silent preauth on the $state system-auth" "$(cat "$pam")"
done
pass "upgrade makes and keeps the lockout visible"
