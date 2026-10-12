#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

# When omarchy-provision-hardware can't confirm Limine's rebuild of the boot
# image, it leaves a marker and finishes, and owner setup rebuilds and checks
# it again before handing off. A rebuild it still can't confirm fails the
# attempt, so the owner gets setup's Try again or a console, with a message
# that says what to fix. The functions run as omarchy-provision-owner defines
# them, against a fixture image root and a limine-mkinitcpio that prints
# $LIMINE_OUTPUT.

if (( EUID == 0 )); then
  skip "running as root, where image setup ignores fixture roots; skipping"
  exit 0
fi

tmp=$(cd -- "$(mktemp -d)" && pwd -P)
trap 'rm -rf "$tmp"' EXIT

stub_bin=$tmp/bin
mkdir -p "$stub_bin"
cat >"$stub_bin/limine-mkinitcpio" <<'SH'
#!/bin/bash
echo run >>"$REBUILDS"
cat "$LIMINE_OUTPUT"
SH
chmod +x "$stub_bin/limine-mkinitcpio"
export PATH="$stub_bin:$PATH" REBUILDS=$tmp/rebuilds LIMINE_OUTPUT=$tmp/limine-output

export OMARCHY_IMAGE_ROOT=$tmp/root
mkdir -p "$OMARCHY_IMAGE_ROOT/var/lib/omarchy/image" "$OMARCHY_IMAGE_ROOT/var/log"
# shellcheck disable=SC1091
source "$ROOT/install/helpers/image-target.sh"
omarchy_image_init
marker=$OMARCHY_IMAGE_ROOT/var/lib/omarchy/image/boot-rebuild-unconfirmed
[[ ${omarchy_image_rebuild_unconfirmed:-} == "$marker" ]] || fail "the helper names the marker omarchy-provision-hardware leaves"

LOG_FILE=$tmp/provision-owner.log
install_log=$OMARCHY_IMAGE_ROOT/var/log/omarchy-install.log
STATE_FILE=$tmp/state
BOOT_IMAGE_FAILED_FLAG=$tmp/boot-image-unconfirmed
log_step() { echo "$1" >>"$LOG_FILE"; }

sed -n '/^confirm_boot_image() {/,/^}/p; /^setup_error_message() {/,/^}/p' "$ROOT/bin/omarchy-provision-owner" >"$tmp/owner.sh"
grep -q '^confirm_boot_image() {' "$tmp/owner.sh" && grep -q '^setup_error_message() {' "$tmp/owner.sh" ||
  fail "omarchy-provision-owner confirms the boot image and explains a setup error"
# shellcheck disable=SC1091
source "$tmp/owner.sh"

limine_built() {
  printf '%s\n' "$@" >"$LIMINE_OUTPUT"
}

# Nothing left unconfirmed: nothing is rebuilt.
rm -f "$marker" "$REBUILDS"
confirm_boot_image || fail "without a marker the boot image needs nothing"
[[ ! -e $REBUILDS ]] || fail "without a marker nothing is rebuilt"
[[ $(setup_error_message) == "Setup hit an error (details in $LOG_FILE)." ]] || fail "without a marker a setup error reads as before" "$(setup_error_message)"
pass "without a marker owner setup rebuilds nothing and its error message is unchanged"

# Another step failing first (an account or re-key step, say) is not the boot
# image's doing, though the marker is already there: the usual message.
echo unconfirmed >"$marker"
rm -f "$BOOT_IMAGE_FAILED_FLAG"
[[ $(setup_error_message) == "Setup hit an error (details in $LOG_FILE)." ]] ||
  fail "an earlier failure with the marker present gets the usual message" "$(setup_error_message)"
pass "an earlier failure with the marker present still gets the usual message"

# A rebuild that still can't be confirmed fails the attempt and keeps the marker.
limine_built 'Building UKI for linux (6.18.0)' '==> Initcpio image generation successful' \
  '==> Unified kernel image generation successful' \
  'Failed to copy: /tmp/limine-mkinitcpio.Xy12Ab/linux.efi -> /boot/EFI/Linux/omarchy_linux.efi (No space left on device)'
if confirm_boot_image; then fail "an unconfirmed rebuild fails the setup attempt"; fi
[[ $(cat "$REBUILDS") == run && -e $marker ]] || fail "owner setup rebuilds once and keeps the marker" "$(cat "$REBUILDS" 2>/dev/null)"
grep -q 'No space left on device' "$install_log" || fail "the rebuild's output goes to the install log"
message=$(setup_error_message)
[[ $message == *"The boot image rebuild couldn't be confirmed (see /var/log/omarchy-install.log)"* &&
  $message == *"Choose Drop to console to fix what it reports"* && $message == *"then run omarchy-provision-owner"* &&
  $message != *limine-mkinitcpio* ]] ||
  fail "the retry screen says the boot image couldn't be confirmed and how to fix it from the console" "$message"
[[ $(cat "$STATE_FILE") == boot ]] || fail "the progress bar shows the boot phase while it rebuilds"
pass "an unconfirmed rebuild fails the attempt, keeps the marker, and the retry screen says why"

# Try again starts a new attempt, which clears the flag, then reruns the
# rebuild; once it is confirmed the marker goes.
rm -f "$BOOT_IMAGE_FAILED_FLAG"
limine_built 'Building UKI for linux (6.18.0)' '==> Initcpio image generation successful' \
  '==> Unified kernel image generation successful'
confirm_boot_image || fail "a confirmed rebuild lets the attempt go on"
[[ $(grep -c '^run$' "$REBUILDS") == 2 && ! -e $marker ]] || fail "Try again rebuilds again and clears the marker"
[[ $(setup_error_message) == "Setup hit an error (details in $LOG_FILE)." ]] || fail "with the marker gone the error message is the usual one"
pass "Try again reruns the rebuild and clears the marker once it is confirmed"

# Wiring: the check runs inside the attempt, before owner setup removes the
# pending state that a retried attempt needs, and the retry screen uses its message.
provisioning=$(sed -n '/^run_provisioning() {/,/^}/p' "$ROOT/bin/omarchy-provision-owner")
confirm_line=$(grep -n 'confirm_boot_image || return 1' <<<"$provisioning" | cut -d: -f1)
cleanup_line=$(grep -n '^  cleanup_oem_state$' <<<"$provisioning" | cut -d: -f1)
[[ -n $confirm_line && -n $cleanup_line ]] && (( confirm_line < cleanup_line )) ||
  fail "run_provisioning confirms the boot image before it cleans up the pending state" "$provisioning"
sed -n '/^main() {/,/^}/p' "$ROOT/bin/omarchy-provision-owner" | grep -q '"$(setup_error_message)"' ||
  fail "the retry screen shows setup_error_message"
sed -n '/^run_setup() {/,/^}/p' "$ROOT/bin/omarchy-provision-owner" | sed -n '1,5p' | grep -qx '  rm -f "$BOOT_IMAGE_FAILED_FLAG"' ||
  fail "each attempt starts by clearing the last attempt's boot image failure"
pass "owner setup confirms the boot image inside each attempt, before its cleanup, and its retry screen explains it"
