#!/bin/bash
#
# Goodix (and other) USB fingerprint readers commonly come back from USB
# autosuspend in a state libfprint can't re-claim, breaking lock-screen
# fingerprint auth after every suspend/resume. A successful setup run has to
# pin the enrolled reader's own power/control to "on" so it never autosuspends.

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

scratch=$(mktemp -d)
trap 'rm -rf "$scratch"' EXIT
mkdir -p "$scratch/bin" "$scratch/devices/1-0/power"
export CALL_LOG="$scratch/calls"
export OMARCHY_USB_DEVICES_PATH="$scratch/devices"
export OMARCHY_FINGERPRINT_UDEV_RULE_PATH="$scratch/fingerprint-no-autosuspend.rules"
export PATH="$scratch/bin:$ROOT/bin:$PATH"

printf '%s\n' 27c6 >"$scratch/devices/1-0/idVendor"
printf '%s\n' 609c >"$scratch/devices/1-0/idProduct"
printf '%s\n' "Goodix Fingerprint USB Device" >"$scratch/devices/1-0/product"
printf '%s\n' auto >"$scratch/devices/1-0/power/control"

# setup_pam_config and setup_lock_fingerprint_pam write to real, hardcoded
# /etc/pam.d paths -- no host authentication file may be touched by this test.
# Swallow exactly those writes (consume stdin, report success) and let every
# other `sudo tee` -- the rule and power/control paths, both under $scratch --
# through to the real tee.
cat > "$scratch/bin/sudo" <<STUB
#!/bin/bash
case "\$1" in
  pacman | fprintd-enroll) exec "\$@" ;;
  tee)
    shift
    for path in "\$@"; do
      case "\$path" in
        /etc/pam.d/*)
          cat >/dev/null
          echo "blocked-real-write:\$path" >> "$CALL_LOG"
          exit 0
          ;;
      esac
    done
    exec tee "\$@"
    ;;
  *) echo "Unexpected privileged call: \$*" >> "$CALL_LOG"; exit 99 ;;
esac
STUB
cat > "$scratch/bin/pacman" <<'STUB'
#!/bin/bash
case "$1" in
  -Q) exit 0 ;;
  *) printf 'pacman %s\n' "$*" >> "$CALL_LOG"; exit 99 ;;
esac
STUB
cat > "$scratch/bin/fprintd-enroll" <<'STUB'
#!/bin/bash
echo enroll >> "$CALL_LOG"
exit 0
STUB
cat > "$scratch/bin/fprintd-verify" <<'STUB'
#!/bin/bash
echo verify >> "$CALL_LOG"
exit 0
STUB
chmod +x "$scratch/bin/"*

: > "$CALL_LOG"
"$ROOT/bin/omarchy-setup-security-fingerprint" > "$scratch/output" 2>&1 ||
  fail "a successful enrollment completes" "$(cat "$scratch/output")"

[[ -f $OMARCHY_FINGERPRINT_UDEV_RULE_PATH ]] || fail "a successful setup writes the autosuspend rule"
pass "a successful setup writes the autosuspend rule"

grep -qx 'ACTION=="add", SUBSYSTEM=="usb", ATTR{idVendor}=="27c6", ATTR{idProduct}=="609c", TEST=="power/control", ATTR{power/control}="on"' \
  "$OMARCHY_FINGERPRINT_UDEV_RULE_PATH" ||
  fail "the rule names the enrolled reader's own vendor and product IDs" "$(cat "$OMARCHY_FINGERPRINT_UDEV_RULE_PATH")"
pass "the rule names the enrolled reader's own vendor and product IDs"

[[ $(<"$scratch/devices/1-0/power/control") == "on" ]] ||
  fail "the currently plugged-in reader is switched off autosuspend immediately"
pass "the currently plugged-in reader is switched off autosuspend immediately"

# A reader matched purely by its self-reported product string (the FPC/Elan
# branches in omarchy-hw-fingerprint) has no idVendor/idProduct guarantee.
# That must not fail the whole setup over this hardening step -- PAM is
# already configured by the time disable_usb_autosuspend runs.
rm -rf "$scratch/devices"/*
mkdir -p "$scratch/devices/1-0"
printf '%s\n' "FPC Sensor Controller L:0002 FW:25.26.23.14" >"$scratch/devices/1-0/product"
: > "$CALL_LOG"
rm -f "$OMARCHY_FINGERPRINT_UDEV_RULE_PATH"
"$ROOT/bin/omarchy-setup-security-fingerprint" > "$scratch/output" 2>&1 ||
  fail "setup still completes when the matched device has no idVendor/idProduct" "$(cat "$scratch/output")"
[[ ! -f $OMARCHY_FINGERPRINT_UDEV_RULE_PATH ]] || fail "no rule is written when the matched device has no idVendor/idProduct"
pass "setup completes with no autosuspend rule when the matched device has no idVendor/idProduct"
