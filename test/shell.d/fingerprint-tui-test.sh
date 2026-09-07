#!/bin/bash
set -euo pipefail
source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"
scratch=$(mktemp -d)
trap 'rm -rf "$scratch"' EXIT
mkdir -p "$scratch/bin" "$scratch/pam"
export CALL_LOG="$scratch/calls"
export PATH="$scratch/bin:$ROOT/bin:$PATH"
for script in omarchy-setup-security-fingerprint omarchy-remove-security-fingerprint; do
  sed "s|/etc/pam.d|$scratch/pam|g" "$ROOT/bin/$script" > "$scratch/$script"
done
printf '%s\n' 'auth required pam_unix.so' > "$scratch/pam/sudo"
cat > "$scratch/bin/pacman" <<'STUB'
#!/bin/bash
exit 1
STUB
cat > "$scratch/bin/omarchy-pkg-missing" <<'STUB'
#!/bin/bash
exit 1
STUB
cat > "$scratch/bin/omarchy-hw-fingerprint" <<'STUB'
#!/bin/bash
exit 0
STUB
cat > "$scratch/bin/omarchy-restart-gum" <<'STUB'
:
STUB
cat > "$scratch/bin/fingerprint-tui" <<'STUB'
#!/bin/bash
printf 'tui %s\n' "$*" >> "$CALL_LOG"
exit "${TUI_STATUS:-0}"
STUB
cat > "$scratch/bin/sudo" <<'STUB'
#!/bin/bash
printf 'sudo %s\n' "$*" >> "$CALL_LOG"
case "$1" in
  tee) cat >/dev/null ;;
  sed | rm) : ;;
  *) exit 99 ;;
esac
STUB
cat > "$scratch/bin/omarchy-pkg-drop" <<'STUB'
#!/bin/bash
printf 'DROPPED %s\n' "$*" >> "$CALL_LOG"
exit 99
STUB
chmod +x "$scratch/bin/"*
for status in 1 130; do
  : > "$CALL_LOG"
  if TUI_STATUS=$status bash "$scratch/omarchy-setup-security-fingerprint" > /dev/null; then
    fail "failed or cancelled TUI cannot enable authentication"
  fi
  ! grep -q '^sudo ' "$CALL_LOG" || fail "failed TUI leaves PAM untouched"
done
pass "failed and cancelled enrollment/verification leave PAM untouched"
: > "$CALL_LOG"
bash "$scratch/omarchy-setup-security-fingerprint" > /dev/null
[[ $(sed -n '1p' "$CALL_LOG") == 'tui setup' ]] || fail "TUI verifies before PAM changes"
grep -q '^sudo ' "$CALL_LOG" || fail "successful setup reaches PAM configuration"
pass "successful generic TUI setup precedes authentication configuration"
: > "$CALL_LOG"
bash "$scratch/omarchy-remove-security-fingerprint" > /dev/null
! grep -q '^DROPPED' "$CALL_LOG" || fail "disabling sign-in retains driver packages"
pass "disabling sign-in does not remove fingerprint drivers"
