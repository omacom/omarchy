#!/bin/bash
#
# Removing fingerprint auth has to take the autosuspend override with it --
# leaving it behind after the PAM stacks are gone would keep re-enabling
# power/control=on for a device fingerprint auth no longer uses.

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

scratch=$(mktemp -d)
trap 'rm -rf "$scratch"' EXIT
mkdir -p "$scratch/bin"
export CALL_LOG="$scratch/calls"
export OMARCHY_FINGERPRINT_UDEV_RULE_PATH="$scratch/fingerprint-no-autosuspend.rules"
export PATH="$scratch/bin:$ROOT/bin:$PATH"

# remove_pam_config (sed -i) and remove_lock_fingerprint_pam (rm) touch real,
# hardcoded /etc/pam.d paths -- no host authentication file may be touched by
# this test. Block any call naming one, whatever the command; let everything
# else (the scratch-path rm for the autosuspend rule) through to the real tool.
cat > "$scratch/bin/sudo" <<STUB
#!/bin/bash
for arg in "\$@"; do
  case "\$arg" in
    /etc/pam.d/*)
      echo "blocked-real-write:\$arg" >> "$CALL_LOG"
      exit 0
      ;;
  esac
done
exec "\$@"
STUB
cat > "$scratch/bin/pacman" <<'STUB'
#!/bin/bash
case "$1" in
  -Qq) ;; # no installed packages, so omarchy-pkg-drop has nothing to remove
  *) printf 'pacman %s\n' "$*" >> "$CALL_LOG"; exit 99 ;;
esac
STUB
chmod +x "$scratch/bin/"*

echo 'ACTION=="add"' > "$OMARCHY_FINGERPRINT_UDEV_RULE_PATH"

"$ROOT/bin/omarchy-remove-security-fingerprint" > "$scratch/output" 2>&1 ||
  fail "removal completes" "$(cat "$scratch/output")"

[[ ! -f $OMARCHY_FINGERPRINT_UDEV_RULE_PATH ]] || fail "removal deletes the autosuspend rule"
pass "removal deletes the autosuspend rule"

# A machine that never had the rule (fingerprint set up before this hardening
# step existed, or never had a matched USB reader) must not error on removal.
"$ROOT/bin/omarchy-remove-security-fingerprint" > "$scratch/output" 2>&1 ||
  fail "removal completes with no rule already present" "$(cat "$scratch/output")"
pass "removal is a no-op when no autosuspend rule exists"
