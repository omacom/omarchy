#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

tmp=$(mktemp -d)
trap 'rm -rf "$tmp"' EXIT

# enroll asks before changing anything when it has a terminal.
exec </dev/null

mkdir -p "$tmp/bin" "$tmp/etc/mkinitcpio.conf.d"
export PATH="$tmp/bin:$ROOT/bin:$PATH"
export OMARCHY_PATH="$ROOT"
export OMARCHY_MKINITCPIO_CONF="$tmp/etc/mkinitcpio.conf"
export OMARCHY_MKINITCPIO_DIR="$tmp/etc/mkinitcpio.conf.d"
export OMARCHY_SECURE_BOOT_VAR="$tmp/no-secure-boot-var"
export OMARCHY_CRYPTTAB_INITRAMFS="$tmp/etc/crypttab.initramfs"
export OMARCHY_LIMINE_DROP_INS="$tmp/etc/limine-entry-tool.d"
export OMARCHY_LIMINE_USR_DROP_INS="$tmp/usr/share/limine-entry-tool.d"
export OMARCHY_LIMINE_ENTRY_CONF="$tmp/etc/limine-entry-tool.conf"
export OMARCHY_LIMINE_DEFAULT_CONF="$tmp/etc/default/limine"
export OMARCHY_SDDM_AUTOLOGIN="$tmp/etc/sddm.conf.d/autologin.conf"
export OMARCHY_TPM_STATE_DIR="$tmp/var/lib/omarchy/drive-tpm"
export OMARCHY_PROC_CMDLINE="$tmp/proc-cmdline"
unset OMARCHY_TPM_ALLOW_UNSAFE OMARCHY_TPM_PCRS OMARCHY_TPM_KEEP_AUTOLOGIN

# The root volume as an Omarchy install boots it: archinstall's PARTUUID on the
# busybox encrypt line, and SDDM logging the owner straight in.
luks_uuid=0b7c3f4e-5d6a-4b8c-9e1f-2a3b4c5d6e7f
partuuid=e6f2ad2b-8b10-4bbe-b2ca-aa7d6db27340
export FAKE_LUKS_UUID=$luks_uuid FAKE_PARTUUID=$partuuid
printf 'cryptdevice=PARTUUID=%s:root root=/dev/mapper/root zswap.enabled=0 rootflags=subvol=@ rw rootfstype=btrfs resume=/dev/mapper/root resume_offset=1931266 quiet splash\n' "$partuuid" >"$OMARCHY_PROC_CMDLINE"
mkdir -p "$(dirname "$OMARCHY_SDDM_AUTOLOGIN")"
printf '[Autologin]\nUser=owner\nSession=omarchy.desktop\n' >"$OMARCHY_SDDM_AUTOLOGIN"
autologin_original=$(<"$OMARCHY_SDDM_AUTOLOGIN")

# Shipped-like configuration: uses encrypt hook, comment mentions sd-encrypt
printf 'HOOKS=(base udev block encrypt filesystems)\n' >"$OMARCHY_MKINITCPIO_CONF"
printf '# comment mentions sd-encrypt which must not count as active hook\n' >"$OMARCHY_MKINITCPIO_DIR/00-omarchy-hooks.conf"

# Fake sudo that just executes the command
cat >"$tmp/bin/sudo" <<'SH'
#!/bin/bash
exec "$@"
SH
chmod +x "$tmp/bin/sudo"

cat >"$tmp/bin/bootctl" <<'SH'
#!/bin/bash
if [[ $1 == "is-secure-boot" ]]; then
  if [[ -n ${FAKE_SECURE_BOOT:-} ]]; then
    echo "yes"
    exit 0
  fi
  echo "no"
  exit 1
fi
exit 0
SH
chmod +x "$tmp/bin/bootctl"

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
if [[ " $* " == *" PARTUUID "* ]]; then
  echo "$FAKE_PARTUUID"
  exit 0
fi
cat <<'EOF'
NAME TYPE FSTYPE
/dev/mapper/root crypt btrfs
/dev/nvme0n1p3 part crypto_LUKS
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
elif [[ $1 == "luksUUID" ]]; then
  echo "$FAKE_LUKS_UUID"
  exit 0
elif [[ $1 == "luksDump" && ${2:-} == "--dump-json-metadata" ]]; then
  if [[ -n ${FAKE_TPM_ENROLLED:-} ]]; then
    echo '{"keyslots":{"0":{"type":"luks2"},"2":{"type":"luks2"}},"tokens":{"0":{"type":"systemd-tpm2","keyslots":["2"]}}}'
  else
    echo '{"keyslots":{"0":{"type":"luks2"}},"tokens":{}}'
  fi
  exit 0
elif [[ $1 == "luksDump" ]]; then
  if [[ -n ${FAKE_TPM_ENROLLED:-} ]]; then
    # Like real cryptsetup 2.8: the token plugin prints its details on stderr.
    cat <<'EOF'
LUKS header information
Version: 2
Tokens:
  0: systemd-tpm2
EOF
    printf '\tKeyslot:    2\n' >&2
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

# limine-mkinitcpio reports a kernel it could not rebuild and still exits 0.
# Each rebuild records the drop-ins it built from. Systemd hooks without
# rd.luks.* make an image that never opens root, so that build is recorded as
# broken. FAKE_REBUILD_FAIL=once fails the first rebuild, =all every one.
cat >"$tmp/bin/limine-mkinitcpio" <<'SH'
#!/bin/bash
hooks=busybox cmdline=""
[[ ! -f $OMARCHY_MKINITCPIO_DIR/omarchy_tpm_unlock.conf ]] || hooks=systemd
[[ ! -f $OMARCHY_LIMINE_DROP_INS/99-omarchy-tpm-unlock.conf ]] || cmdline=+rd.luks
[[ $hooks$cmdline != "systemd" ]] || touch "$TEST_REBUILD_BROKEN"
echo "$hooks$cmdline" >>"$TEST_REBUILD_CALLS"
if [[ ${FAKE_REBUILD_FAIL:-} == "all" || ( ${FAKE_REBUILD_FAIL:-} == "once" && ! -f $TEST_REBUILD_FAILED ) ]]; then
  touch "$TEST_REBUILD_FAILED"
  echo "==> ERROR: mkinitcpio failed for kernel linux-omarchy"
fi
exit 0
SH
chmod +x "$tmp/bin/limine-mkinitcpio"
export TEST_REBUILD_CALLS="$tmp/rebuild.calls" TEST_REBUILD_FAILED="$tmp/rebuild.failed" TEST_REBUILD_BROKEN="$tmp/rebuild.broken"
: >"$TEST_REBUILD_CALLS"

# The mkinitcpio hooks this machine can build.
export OMARCHY_INITCPIO_INSTALL_DIRS="$tmp/initcpio/install"
mkdir -p "$OMARCHY_INITCPIO_INSTALL_DIRS"
for hook in base systemd plymouth keyboard autodetect microcode modconf kms sd-vconsole block sd-encrypt filesystems fsck sd-btrfs-overlayfs; do
  : >"$OMARCHY_INITCPIO_INSTALL_DIRS/$hook"
done

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

# Test 5b: Enroll refuses default PCRs 0+7 when Secure Boot is disabled
status=0
err=$("$drive_tpm" enroll /dev/fake 2>&1) || status=$?
(( status != 0 )) || fail "enroll should refuse when Secure Boot is disabled"
assert_output_contains "enroll warns about disabled Secure Boot" "$err" "Refusing TPM enrollment: Secure Boot is disabled"

# Test 6: Enroll succeeds with Secure Boot and invokes systemd-cryptenroll with PCRs 0+7
: >"$TEST_CRYPTENROLL_CALLS"
# Simulate that after enrollment, FAKE_TPM_ENROLLED becomes true
cat >"$tmp/bin/cryptsetup" <<'SH'
#!/bin/bash
if [[ $1 == "isLuks" ]]; then
  exit 0
elif [[ $1 == "luksUUID" ]]; then
  echo "$FAKE_LUKS_UUID"
elif [[ $1 == "luksDump" && ${2:-} == "--dump-json-metadata" ]]; then
  if [[ -f "$TEST_ENROLLED_FLAG" ]]; then
    echo '{"keyslots":{"0":{"type":"luks2"},"3":{"type":"luks2"}},"tokens":{"0":{"type":"systemd-tpm2","keyslots":["3"]}}}'
  else
    echo '{"keyslots":{"0":{"type":"luks2"}},"tokens":{}}'
  fi
  exit 0
elif [[ $1 == "luksDump" ]]; then
  if [[ -f "$TEST_ENROLLED_FLAG" ]]; then
    # Like real cryptsetup 2.8: the token plugin prints its details on stderr.
    cat <<'EOF'
LUKS header information
Version: 2
Tokens:
  0: systemd-tpm2
EOF
    printf '\tKeyslot:    3\n' >&2
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
if [[ ${1:-} == "--wipe-slot=tpm2" ]]; then
  rm -f "$TEST_ENROLLED_FLAG"
else
  [[ -z ${FAKE_CRYPTENROLL_FAIL:-} ]] || exit 1
  touch "$TEST_ENROLLED_FLAG"
fi
exit 0
SH
chmod +x "$tmp/bin/systemd-cryptenroll"

export TEST_ENROLLED_FLAG="$tmp/enrolled.flag"
rm -f "$TEST_ENROLLED_FLAG"

out=$(FAKE_SECURE_BOOT=1 "$drive_tpm" enroll /dev/fake)
assert_output_contains "enroll reports success" "$out" "TPM 2.0 successfully enrolled in keyslot 3"
grep -qF -e '--tpm2-device=auto --tpm2-pcrs=0+7 /dev/fake' "$TEST_CRYPTENROLL_CALLS" || fail "enroll called with expected arguments"

pass "enroll calls systemd-cryptenroll with auto device and PCRs 0+7"

# Test 6b: Enroll with --allow-unsafe and explicit drive
: >"$TEST_CRYPTENROLL_CALLS"
rm -f "$TEST_ENROLLED_FLAG"
out=$("$drive_tpm" enroll --allow-unsafe /dev/other)
assert_output_contains "enroll --allow-unsafe reports success" "$out" "TPM 2.0 successfully enrolled in keyslot 3"
grep -qF -e '--tpm2-device=auto --tpm2-pcrs=0+7 /dev/other' "$TEST_CRYPTENROLL_CALLS" || fail "enroll called with explicit drive under --allow-unsafe"
pass "enroll --allow-unsafe targets the explicitly specified drive"

# Test 6c: Enroll with --allow-unsafe and inferred root drive
: >"$TEST_CRYPTENROLL_CALLS"
rm -f "$TEST_ENROLLED_FLAG"
out=$("$drive_tpm" enroll --allow-unsafe --yes)
assert_output_contains "enroll --allow-unsafe without drive discovers root" "$out" "TPM 2.0 successfully enrolled in keyslot 3"
grep -qF -e '--tpm2-device=auto --tpm2-pcrs=0+7 /dev/nvme0n1p3' "$TEST_CRYPTENROLL_CALLS" || fail "enroll called with discovered root drive"
pass "enroll --allow-unsafe without drive discovers root LUKS drive"

# Test 7: Enroll is a no-op if already enrolled
out=$(FAKE_SECURE_BOOT=1 "$drive_tpm" enroll /dev/fake)
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

# Unattended boot of the root volume: enroll switches the initramfs to systemd,
# names the volume with rd.luks.* on the Limine command line and turns autologin
# off; wipe undoes it.
tpm_drop_in="$OMARCHY_MKINITCPIO_DIR/omarchy_tpm_unlock.conf"
cmdline_drop_in="$OMARCHY_LIMINE_DROP_INS/99-omarchy-tpm-unlock.conf"
autologin_backup="$OMARCHY_TPM_STATE_DIR/sddm-autologin.conf"
busybox_conf='HOOKS=(base udev block encrypt filesystems)'
cmdline_original=$(<"$OMARCHY_PROC_CMDLINE")

reset_root() {
  rm -f "$tpm_drop_in" "$cmdline_drop_in" "$OMARCHY_CRYPTTAB_INITRAMFS" "$TEST_ENROLLED_FLAG" "$TEST_REBUILD_FAILED"
  rm -rf "$OMARCHY_LIMINE_USR_DROP_INS" "$OMARCHY_LIMINE_ENTRY_CONF" "$(dirname "$OMARCHY_LIMINE_DEFAULT_CONF")"
  mkdir -p "$(dirname "$OMARCHY_LIMINE_DEFAULT_CONF")"
  printf 'KERNEL_CMDLINE[default]+="%s"\n' "$cmdline_original" >"$OMARCHY_LIMINE_DEFAULT_CONF"
  rm -rf "$OMARCHY_TPM_STATE_DIR"
  printf '%s\n' "$busybox_conf" >"$OMARCHY_MKINITCPIO_CONF"
  printf '%s\n' "$cmdline_original" >"$OMARCHY_PROC_CMDLINE"
  printf '%s\n' "$autologin_original" >"$OMARCHY_SDDM_AUTOLOGIN"
  : >"$TEST_CRYPTENROLL_CALLS"
  : >"$TEST_REBUILD_CALLS"
}

assert_root_untouched() {
  local desc=$1
  ! grep -q -e '--tpm2-pcrs' "$TEST_CRYPTENROLL_CALLS" || fail "$desc: no TPM key was enrolled" "$(<"$TEST_CRYPTENROLL_CALLS")"
  [[ ! -e $tpm_drop_in && ! -e $cmdline_drop_in ]] || fail "$desc: no drop-in was installed"
  [[ ! -s $TEST_REBUILD_CALLS ]] || fail "$desc: no boot image was rebuilt"
  [[ $(<"$OMARCHY_SDDM_AUTOLOGIN") == "$autologin_original" ]] || fail "$desc: autologin is unchanged"
  pass "$desc"
}

assert_refused() {
  local desc=$1 expected=$2 status=0 err
  err=$("$drive_tpm" enroll --allow-unsafe --yes 2>&1) || status=$?
  (( status != 0 )) || fail "$desc: enroll fails" "$err"
  assert_output_contains "$desc: says why" "$err" "$expected"
  assert_root_untouched "$desc: changes nothing"
}

reset_root
status=0
err=$("$drive_tpm" enroll --allow-unsafe 2>&1) || status=$?
(( status != 0 )) || fail "enroll without a terminal needs --yes" "$err"
assert_output_contains "enroll without a terminal prints the plan" "$err" "before: base udev block encrypt filesystems"
assert_root_untouched "enroll without a terminal or --yes changes nothing"

reset_root
out=$("$drive_tpm" enroll --allow-unsafe --yes)
assert_output_contains "enroll shows the HOOKS before the switch" "$out" "before: base udev block encrypt filesystems"
assert_output_contains "enroll shows the HOOKS after the switch" "$out" "after:  base systemd block sd-encrypt filesystems"
tpm_cmdline="rd.luks.name=$luks_uuid=root rd.luks.options=$luks_uuid=tpm2-device=auto"
grep -qxF "KERNEL_CMDLINE[default]+=\" $tpm_cmdline\"" "$cmdline_drop_in" ||
  fail "enroll names the root volume by LUKS UUID on the Limine command line" "$(cat "$cmdline_drop_in" 2>&1)"
pass "enroll names the root volume by LUKS UUID on the Limine command line"
cmp -s "$tpm_drop_in" "$ROOT/default/mkinitcpio/omarchy_tpm_unlock.conf" || fail "enroll installs the HOOKS drop-in"
pass "enroll installs the HOOKS drop-in"
[[ ! -e $OMARCHY_SDDM_AUTOLOGIN && $(<"$autologin_backup") == "$autologin_original" ]] ||
  fail "enroll moves SDDM autologin aside"
pass "enroll moves SDDM autologin aside"
[[ $(<"$TEST_REBUILD_CALLS") == "systemd+rd.luks" ]] || fail "enroll rebuilds the boot images once with both drop-ins" "$(<"$TEST_REBUILD_CALLS")"
pass "enroll rebuilds the boot images once with both drop-ins"

: >"$TEST_REBUILD_CALLS"
out=$("$drive_tpm" enroll --allow-unsafe --yes)
assert_output_contains "a second enroll finds the setup in place" "$out" "already set up"
[[ ! -s $TEST_REBUILD_CALLS ]] || fail "a second enroll rebuilds nothing"
pass "a second enroll rebuilds nothing"

: >"$TEST_CRYPTENROLL_CALLS"
: >"$TEST_REBUILD_CALLS"
out=$("$drive_tpm" wipe)
grep -qF -e '--wipe-slot=tpm2 /dev/nvme0n1p3' "$TEST_CRYPTENROLL_CALLS" || fail "wipe removes the root token"
[[ ! -e $tpm_drop_in && ! -e $cmdline_drop_in ]] || fail "wipe removes both drop-ins"
[[ $(<"$OMARCHY_SDDM_AUTOLOGIN") == "$autologin_original" && ! -e $autologin_backup ]] || fail "wipe restores SDDM autologin"
[[ $(<"$TEST_REBUILD_CALLS") == $'busybox+rd.luks\nbusybox' ]] || fail "wipe rebuilds busybox images, then drops rd.luks" "$(<"$TEST_REBUILD_CALLS")"
pass "wipe reverts the token, the boot images and autologin"

reset_root
out=$("$drive_tpm" enroll --allow-unsafe --keep-autologin --yes)
assert_output_contains "--keep-autologin warns about the logged-in desktop" "$out" "WARNING"
[[ $(<"$OMARCHY_SDDM_AUTOLOGIN") == "$autologin_original" && ! -e $autologin_backup ]] || fail "--keep-autologin leaves autologin on"
pass "--keep-autologin leaves autologin on"

reset_root
sed -i 's/:root /:root:allow-discards /' "$OMARCHY_PROC_CMDLINE"
"$drive_tpm" enroll --allow-unsafe --yes >/dev/null
grep -qF "rd.luks.options=$luks_uuid=tpm2-device=auto,discard\"" "$cmdline_drop_in" ||
  fail "allow-discards carries over as discard" "$(cat "$cmdline_drop_in" 2>&1)"
pass "allow-discards carries over as discard"

reset_root
printf 'HOOKS=(base udev block lvm2 encrypt filesystems)\n' >"$OMARCHY_MKINITCPIO_CONF"
assert_refused "a hook without a known systemd counterpart" "mkinitcpio hook 'lvm2'"

reset_root
printf 'HOOKS=(base systemd block filesystems)\n' >"$OMARCHY_MKINITCPIO_CONF"
assert_refused "an initramfs that does not unlock through encrypt" "busybox encrypt hook"

reset_root
printf 'HOOKS+=(resume)\n' >"$OMARCHY_MKINITCPIO_DIR/zz-late.conf"
assert_refused "a drop-in sorting after the TPM one that adds a busybox hook" "busybox hook 'resume' would remain"
rm -f "$OMARCHY_MKINITCPIO_DIR/zz-late.conf"

reset_root
rm "$OMARCHY_INITCPIO_INSTALL_DIRS/sd-btrfs-overlayfs"
printf 'HOOKS=(base udev block encrypt filesystems btrfs-overlayfs)\n' >"$OMARCHY_MKINITCPIO_CONF"
assert_refused "a systemd hook mkinitcpio cannot build" "no install script for the 'sd-btrfs-overlayfs' hook"
: >"$OMARCHY_INITCPIO_INSTALL_DIRS/sd-btrfs-overlayfs"

reset_root
FAKE_PARTUUID=00000000-0000-0000-0000-000000000000 assert_refused "a cryptdevice= naming another partition" "does not name /dev/nvme0n1p3"

reset_root
sed -i "s/^/rd.luks.name=$luks_uuid=root /" "$OMARCHY_PROC_CMDLINE"
assert_refused "an rd.luks unlock already on the command line" "rd.luks.name="

reset_root
printf 'data UUID=1234 none\n' >"$OMARCHY_CRYPTTAB_INITRAMFS"
assert_refused "a crypttab.initramfs already in use" "already sets up volumes"

# /etc/default/limine is read after the drop-ins, so a plain = there replaces
# the rd.luks.* the drop-in appends.
reset_root
printf 'KERNEL_CMDLINE[default]="%s"\n' "$cmdline_original" >"$OMARCHY_LIMINE_DEFAULT_CONF"
assert_refused "a later KERNEL_CMDLINE[default]= replacing the drop-in" "for: default"

reset_root
printf 'KERNEL_CMDLINE[fallback]+=" quiet"\n' >>"$OMARCHY_LIMINE_DEFAULT_CONF"
assert_refused "a fallback command line that never gets rd.luks.*" "for: fallback"

reset_root
mkdir -p "$OMARCHY_LIMINE_USR_DROP_INS"
printf 'KERNEL_CMDLINE[default]=" early"\n' >"$OMARCHY_LIMINE_USR_DROP_INS/00-early.conf"
"$drive_tpm" enroll --allow-unsafe --yes >/dev/null
[[ -f $cmdline_drop_in ]] || fail "a plain = read before the drop-in is fine"
pass "a plain = read before the drop-in is fine"

# The token is added after autologin is off; a failed enrollment before the
# boot switch brings autologin back, since busybox images ignore the token.
reset_root
status=0
err=$(FAKE_CRYPTENROLL_FAIL=1 "$drive_tpm" enroll --allow-unsafe --yes 2>&1) || status=$?
(( status != 0 )) || fail "a failed enrollment fails enroll" "$err"
assert_output_contains "autologin is off before the token is added" "$err" "Turned off SDDM autologin."
[[ $(<"$OMARCHY_SDDM_AUTOLOGIN") == "$autologin_original" && ! -e $autologin_backup ]] || fail "a failed enrollment restores autologin"
[[ ! -e $tpm_drop_in && ! -e $cmdline_drop_in && ! -s $TEST_REBUILD_CALLS ]] || fail "a failed enrollment switches nothing"
pass "a failed enrollment restores autologin and switches nothing"

reset_root
status=0
err=$(FAKE_REBUILD_FAIL=once "$drive_tpm" enroll --allow-unsafe --yes 2>&1) || status=$?
(( status != 0 )) || fail "a failed rebuild fails enroll" "$err"
[[ ! -e $tpm_drop_in && ! -e $cmdline_drop_in ]] || fail "a failed rebuild removes both drop-ins"
[[ $(<"$OMARCHY_SDDM_AUTOLOGIN") == "$autologin_original" ]] || fail "a failed rebuild restores autologin"
[[ $(<"$TEST_REBUILD_CALLS") == $'systemd+rd.luks\nbusybox+rd.luks\nbusybox' ]] || fail "a failed rebuild rebuilds the previous boot images" "$(<"$TEST_REBUILD_CALLS")"
pass "a failed rebuild restores the previous boot configuration"

# When the images cannot be rebuilt at all, one may still unlock from the TPM,
# so autologin must not come back.
reset_root
status=0
err=$(FAKE_REBUILD_FAIL=all "$drive_tpm" enroll --allow-unsafe --yes 2>&1) || status=$?
(( status != 0 )) || fail "a failed rollback fails enroll" "$err"
[[ ! -e $OMARCHY_SDDM_AUTOLOGIN && -f $autologin_backup ]] || fail "a failed rollback keeps autologin off"
pass "a failed rollback keeps autologin off"

# The boot configuration Omarchy ships, not a hand-written line: the platform
# baseline, omarchy_hooks.conf and hibernation's resume drop-in.
reset_root
shipped_dir="$tmp/etc/mkinitcpio.shipped.d"
mkdir -p "$shipped_dir"
cp "$ROOT"/etc/mkinitcpio.conf.d/*.conf "$shipped_dir/"
printf 'HOOKS+=(resume)\n' >"$shipped_dir/omarchy_resume.conf"
printf '#!/bin/bash\necho x86\n' >"$tmp/bin/omarchy-hw-platform"
chmod +x "$tmp/bin/omarchy-hw-platform"
mkdir -p "$tmp/no-pci"
out=$(OMARCHY_MKINITCPIO_DIR="$shipped_dir" OMARCHY_PCI_DEVICES_PATH="$tmp/no-pci" "$drive_tpm" enroll --allow-unsafe --yes)
assert_output_contains "enroll switches Omarchy's shipped hooks" "$out" \
  "after:  base systemd plymouth keyboard autodetect microcode modconf kms sd-vconsole block sd-encrypt filesystems fsck sd-btrfs-overlayfs"
[[ -f $shipped_dir/omarchy_tpm_unlock.conf ]] || fail "enroll installs the drop-in next to Omarchy's"
pass "enroll installs the drop-in next to Omarchy's"

[[ ! -e $TEST_REBUILD_BROKEN ]] || fail "no rebuild ever paired systemd hooks without rd.luks"
pass "no rebuild ever paired systemd hooks without rd.luks"
