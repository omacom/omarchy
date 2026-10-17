#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

tmp=$(mktemp -d)
trap 'rm -rf "$tmp"' EXIT

mkdir -p "$tmp/bin" "$tmp/etc/mkinitcpio.conf.d"
export PATH="$tmp/bin:$ROOT/bin:$PATH"
export OMARCHY_PATH="$ROOT"
export OMARCHY_MKINITCPIO_CONF="$tmp/etc/mkinitcpio.conf"
export OMARCHY_MKINITCPIO_DIR="$tmp/etc/mkinitcpio.conf.d"

# Shipped-like configuration: uses encrypt hook, comment mentions sd-encrypt
printf 'HOOKS=(base udev block encrypt filesystems)\n' >"$OMARCHY_MKINITCPIO_CONF"
printf '# comment mentions sd-encrypt which must not count as active hook\n' >"$OMARCHY_MKINITCPIO_DIR/00-omarchy-hooks.conf"

# Fake sudo that just executes the command
cat >"$tmp/bin/sudo" <<'SH'
#!/bin/bash
exec "$@"
SH
chmod +x "$tmp/bin/sudo"

# Default mock commands
cat >"$tmp/bin/findmnt" <<'SH'
#!/bin/bash
if [[ -n ${FAKE_FINDMNT_FAIL:-} ]]; then
  exit 1
fi
echo '/dev/mapper/root[/@]'
SH
chmod +x "$tmp/bin/findmnt"

cat >"$tmp/bin/lsblk" <<'SH'
#!/bin/bash
if [[ -n ${FAKE_LSBLK_FAIL:-} ]]; then
  exit 1
fi
cat <<'EOF'
NAME TYPE FSTYPE
root crypt btrfs
nvme0n1p3 part crypto_LUKS
EOF
SH
chmod +x "$tmp/bin/lsblk"

cat >"$tmp/bin/cryptsetup" <<'SH'
#!/bin/bash
if [[ $1 == "isLuks" ]]; then
  if [[ -n ${FAKE_NOT_LUKS:-} ]]; then
    exit 1
  fi
  if [[ ${2:-} == "--type" && ${3:-} == "luks2" && -n ${FAKE_LUKS1:-} ]]; then
    exit 1
  fi
  exit 0
elif [[ $1 == "luksDump" ]]; then
  if [[ -n ${FAKE_TPM_ENROLLED:-} ]]; then
    cat <<'EOF'
LUKS header information
Version: 2
Tokens:
  0: systemd-tpm2
	Keyslot: 2
EOF
  else
    cat <<'EOF'
LUKS header information
Version: 2
Tokens:
EOF
  fi
  exit 0
fi
exit 0
SH
chmod +x "$tmp/bin/cryptsetup"

cat >"$tmp/bin/systemd-cryptenroll" <<'SH'
#!/bin/bash
echo "$@" >>"$TEST_CRYPTENROLL_CALLS"
if [[ ${1:-} == "--tpm2-device=list" ]]; then
  if [[ -n ${FAKE_NO_TPM:-} ]]; then
    echo "No suitable TPM2 devices found."
    exit 1
  fi
  cat <<'EOF'
PATH DEVICE DRIVER
/dev/tpmrm0 /sys/devices/pnp0/00:05/tpm/tpm0/tpmrm0 tpm_crb
EOF
  exit 0
fi
exit 0
SH
chmod +x "$tmp/bin/systemd-cryptenroll"

export TEST_CRYPTENROLL_CALLS="$tmp/cryptenroll.calls"
: >"$TEST_CRYPTENROLL_CALLS"

drive_tpm="$ROOT/bin/omarchy-drive-tpm"

# Test 1: Status with no TPM device
out=$(FAKE_NO_TPM=1 "$drive_tpm" status /dev/fake || true)
assert_output_contains() {
  local desc=$1 text=$2 substr=$3
  if [[ $text != *"$substr"* ]]; then
    fail "$desc: expected to contain '$substr'" "$text"
  fi
  pass "$desc"
}
assert_output_contains "status reports missing TPM2 device" "$out" "TPM 2.0 Device: Not detected"

# Test 2: Status with TPM device and unenrolled LUKS2 drive
out=$("$drive_tpm" status /dev/fake)
assert_output_contains "status reports available TPM2 device" "$out" "TPM 2.0 Device: Available"
assert_output_contains "status reports unenrolled drive" "$out" "TPM 2.0 Unlock: Not enrolled"
assert_output_contains "status reports mkinitcpio notice when sd-encrypt is absent (even with comment)" "$out" "requires 'sd-encrypt' hook"

# Test 2b: Status when sd-encrypt is actively configured in HOOKS
printf 'HOOKS=(base systemd block sd-encrypt filesystems)\n' >"$OMARCHY_MKINITCPIO_CONF"
out_sd=$("$drive_tpm" status /dev/fake)
assert_output_contains "status reports ready when sd-encrypt is active in HOOKS" "$out_sd" "Ready (sd-encrypt hook active)"
# Reset back to notice configuration
printf 'HOOKS=(base udev block encrypt filesystems)\n' >"$OMARCHY_MKINITCPIO_CONF"

# Test 3: Status when TPM is already enrolled
out=$(FAKE_TPM_ENROLLED=1 "$drive_tpm" status /dev/fake)
assert_output_contains "status reports enrolled keyslot" "$out" "TPM 2.0 Unlock: Enrolled (keyslot: 2)"

# Test 4: Enroll fails when no TPM device is available
: >"$TEST_CRYPTENROLL_CALLS"
FAKE_NO_TPM=1 status=0
err=$(FAKE_NO_TPM=1 "$drive_tpm" enroll /dev/fake 2>&1) || status=$?
(( status != 0 )) || fail "enroll should fail without TPM"
assert_output_contains "enroll warns about missing TPM" "$err" "No suitable TPM 2.0 device found"

# Test 5: Enroll fails when drive is LUKS1 instead of LUKS2
status=0
err=$(FAKE_LUKS1=1 "$drive_tpm" enroll /dev/fake 2>&1) || status=$?
(( status != 0 )) || fail "enroll should fail for non-LUKS2 volume"
assert_output_contains "enroll requires LUKS2" "$err" "TPM 2.0 enrollment requires LUKS2"

# Test 6: Enroll succeeds and invokes systemd-cryptenroll with PCRs 0+7
: >"$TEST_CRYPTENROLL_CALLS"
# Simulate that after enrollment, FAKE_TPM_ENROLLED becomes true
cat >"$tmp/bin/cryptsetup" <<'SH'
#!/bin/bash
if [[ $1 == "isLuks" ]]; then
  exit 0
elif [[ $1 == "luksDump" ]]; then
  if [[ -f "$TEST_ENROLLED_FLAG" ]]; then
    cat <<'EOF'
LUKS header information
Version: 2
Tokens:
  0: systemd-tpm2
	Keyslot: 3
EOF
  else
    cat <<'EOF'
LUKS header information
Version: 2
Tokens:
EOF
  fi
fi
exit 0
SH
chmod +x "$tmp/bin/cryptsetup"

cat >"$tmp/bin/systemd-cryptenroll" <<'SH'
#!/bin/bash
echo "$@" >>"$TEST_CRYPTENROLL_CALLS"
if [[ ${1:-} == "--tpm2-device=list" ]]; then
  echo "/dev/tpmrm0"
  exit 0
fi
touch "$TEST_ENROLLED_FLAG"
exit 0
SH
chmod +x "$tmp/bin/systemd-cryptenroll"

export TEST_ENROLLED_FLAG="$tmp/enrolled.flag"
rm -f "$TEST_ENROLLED_FLAG"

out=$("$drive_tpm" enroll /dev/fake)
assert_output_contains "enroll reports success" "$out" "TPM 2.0 successfully enrolled in keyslot 3"
grep -qF -e '--tpm2-device=auto --tpm2-pcrs=0+7 /dev/fake' "$TEST_CRYPTENROLL_CALLS" || fail "enroll called with expected arguments"

pass "enroll calls systemd-cryptenroll with auto device and PCRs 0+7"

# Test 7: Enroll is a no-op if already enrolled
out=$("$drive_tpm" enroll /dev/fake)
assert_output_contains "enroll detects existing enrollment" "$out" "already enrolled in keyslot 3"

# Test 8: Wipe removes TPM token
: >"$TEST_CRYPTENROLL_CALLS"
out=$("$drive_tpm" wipe /dev/fake)
assert_output_contains "wipe reports removal" "$out" "TPM 2.0 token removed from /dev/fake"
grep -qF -e '--wipe-slot=tpm2 /dev/fake' "$TEST_CRYPTENROLL_CALLS" || fail "wipe invoked --wipe-slot=tpm2"
pass "wipe calls systemd-cryptenroll --wipe-slot=tpm2"

# Test 9: Wipe when not enrolled is a clean no-op
rm -f "$TEST_ENROLLED_FLAG"
: >"$TEST_CRYPTENROLL_CALLS"
out=$("$drive_tpm" wipe /dev/fake)
assert_output_contains "wipe when unenrolled reports no token" "$out" "No TPM 2.0 token found"
[[ ! -s "$TEST_CRYPTENROLL_CALLS" ]] || fail "wipe should not call cryptenroll when no token is present"
pass "wipe when unenrolled does not call cryptenroll"
