#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

install_script="$ROOT/install/config/increase-lockout-limit.sh"
migration="$ROOT/migrations/1790385000.sh"

[[ -f $install_script ]] || fail "lockout install script is present"
[[ -f $migration ]] || fail "lockout visibility migration is present"

# The install script must write a preauth line that can report lockout.
grep -Eq 'preauth deny=10 unlock_time=120' "$install_script" ||
  fail "install script sets preauth deny/unlock_time without silent" "$(grep preauth "$install_script" || true)"
! grep -Eq 'preauth[[:space:]]+silent' "$install_script" ||
  fail "install script must not keep preauth silent" "$(grep preauth "$install_script" || true)"
pass "install script drops silent from pam_faillock preauth"

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

# Same transform the migration applies (GNU sed on Arch; python here for macOS CI hosts).
python3 - "$pam" <<'PY'
import pathlib, re, sys
path = pathlib.Path(sys.argv[1])
text = path.read_text()
fixed = re.sub(r"(pam_faillock\.so[ \t]+preauth)[ \t]+silent", r"\1", text)
path.write_text(fixed)
PY

grep -Eq 'pam_faillock\.so preauth deny=10 unlock_time=120' "$pam" ||
  fail "migration strips silent and keeps deny/unlock_time" "$(grep faillock "$pam")"
! grep -Eq 'preauth[[:space:]]+silent' "$pam" ||
  fail "migration leaves no silent on preauth" "$(grep faillock "$pam")"
grep -Eq 'authfail deny=10 unlock_time=120' "$pam" ||
  fail "migration leaves authfail args alone" "$(grep faillock "$pam")"
pass "migration strips silent from an existing preauth line"

# Idempotent on an already-fixed line.
python3 - "$pam" <<'PY'
import pathlib, re, sys
path = pathlib.Path(sys.argv[1])
text = path.read_text()
path.write_text(re.sub(r"(pam_faillock\.so[ \t]+preauth)[ \t]+silent", r"\1", text))
PY
grep -c 'pam_faillock\.so' "$pam" | grep -qx 3 ||
  fail "re-running the strip does not duplicate faillock lines" "$(grep faillock "$pam")"
pass "stripping silent is idempotent"

# The migration file itself targets system-auth with the same transform.
grep -Fq '/etc/pam.d/system-auth' "$migration" ||
  fail "migration edits system-auth"
grep -Fq 'preauth' "$migration" && grep -Fq 'silent' "$migration" ||
  fail "migration mentions the silent preauth token"
pass "migration targets the silent preauth on system-auth"
