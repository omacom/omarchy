#!/bin/bash

set -euo pipefail
source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"
source "$ROOT/bin/omarchy-usb-authorization-boot"

scratch=$(mktemp -d)
trap 'rm -rf "$scratch"' EXIT
machine=12345678901234567890123456789012
export calls="$scratch/calls"
: >"$calls"

# Optional integration run uses real sbctl keys and sbattach in isolated paths.
sbctl() {
  printf '%s\n' "$1" >>"$calls"
  [[ ${SIGN_FAIL:-0} != 1 || $1 != sign ]] || return 1
  [[ ${VERIFY_FAIL:-0} != 1 || $1 != verify ]] || return 1
  if [[ -n ${USB_TEST_SBCTL_CONFIG:-} ]]; then
    /usr/bin/sbctl --config "$USB_TEST_SBCTL_CONFIG" "$@"
  elif [[ $1 == verify ]]; then
    jq -n --arg file "${!#}" --argjson signed "${TEST_SIGNED:-1}" '[{file_name: $file, is_signed: $signed}]'
  fi
}
sbattach() {
  if [[ -n ${USB_TEST_SBATTACH:-} ]]; then
    "$USB_TEST_SBATTACH" "$@"
  fi
}
omarchy-cmd-missing() { return 1; }
limine-enroll-config() { [[ ${ENROLL_FAIL:-0} != 1 ]]; }
usb_authorization_secure_boot_enabled() { [[ ${SECURE_BOOT:-1} == 1 ]]; }
# Bootloader enrollment/rollback is exercised with real EFI binaries in its own suite.
usb_authorization_verify_bootloader() { return 0; }

fixture() {
  local embedded="$1" hash digest image_base
  esp="$scratch/case-$RANDOM"
  history="$esp/$machine/limine_history"
  manifest="$history/snapshots.json"
  cache="$esp/cache.json"
  config="$esp/limine.conf"
  mkdir -p "$history"
  printf '%s\0' "$embedded" >"$esp/cmdline"
  cp /usr/lib/systemd/boot/efi/linuxx64.efi.stub "$esp/image.efi"
  image_base=$(objdump -p "$esp/image.efi" | awk '$1 == "ImageBase" {print "0x" $2}')
  objcopy --add-section .cmdline="$esp/cmdline" --change-section-vma .cmdline="$((image_base + 0x100000))" "$esp/image.efi"
  if [[ -n ${USB_TEST_SBCTL_CONFIG:-} ]]; then
    sbctl sign "$esp/image.efi" >/dev/null
  fi
  digest=$(sha256sum "$esp/image.efi"); digest=${digest%% *}
  old_name="test.efi_sha256_$digest"
  cp "$esp/image.efi" "$history/$old_name"
  hash=$(b2sum "$esp/image.efi"); hash=${hash%% *}
  printf '/Omarchy\ncomment: machine-id=%s\n  //snapshot\n  comment: kernel-id=linux\n  path: boot():/%s/limine_history/%s#%s\n  cmdline: %s rootflags=subvol=/snapshot\n' \
    "$machine" "$machine" "$old_name" "$hash" "$embedded" >"$config"
  jq -n --arg name "$old_name" --arg hash "$hash" --arg machine "$machine" --arg cmdline "$embedded" '
    def kernel:
      {imageDetails: [{fileHashName: $name, fileName: "test.efi",
        snapshotFilePathLine: "/" + $machine + "/limine_history/" + $name + "#" + $hash,
        filePathLine: "/EFI/Linux/test.efi#" + $hash, properties: {HASH: "#" + $hash}}],
       cmdlineDetails: [{cmdline: $cmdline, snapshotCmdline: $cmdline + " rootflags=subvol=/snapshot"}],
       allInConfig: ["path: boot():/EFI/Linux/test.efi#" + $hash, "cmdline: " + $cmdline],
       allInSnapshotConfig: ["comment: kernel-id=linux", "path: boot():/" + $machine + "/limine_history/" + $name + "#" + $hash, "cmdline: " + $cmdline + " rootflags=subvol=/snapshot"], subKernels: []};
    {jsonFormatVersion: "1.3.0", snapshotEntries: [{kernelEntries: [kernel | .subKernels = [kernel]]}]}
  ' >"$manifest"
  cp "$manifest" "$manifest.old"
  cp "$manifest" "$cache"
  cp "$manifest" "$esp/before.json"
  cp "$config" "$esp/before.conf"
  : >"$calls"
}

for expected in enabled disabled; do
  old='quiet'
  [[ $expected != disabled ]] || old+=' usbcore.authorized_default=0'
  fixture "$old"
  usb_authorization_reconcile_archived_images "$expected" "$config" "$esp" "$machine" "$cache"
  new_name=$(jq -r '.snapshotEntries[0].kernelEntries[0].imageDetails[0].fileHashName' "$manifest")
  [[ $new_name != "$old_name" && -f $history/$new_name ]] || fail "conflicting archives get new content-addressed copies"
  cmp "$history/$old_name" "$esp/image.efi" || fail "original archived image remains unchanged"
  digest=$(sha256sum "$history/$new_name")
  [[ $new_name == *"${digest%% *}" ]] || fail "replacement name matches its content hash"
  objcopy -O binary --only-section=.cmdline "$history/$new_name" "$esp/section"
  embedded=$(tr '\0' '\n' <"$esp/section")
  wanted=quiet
  [[ $expected != enabled ]] || wanted+=' usbcore.authorized_default=0'
  [[ $embedded == "$wanted" ]] || fail "replacement must preserve embedded boot arguments and change only USB policy"
  objcopy -O binary --only-section=.text "$history/$old_name" "$esp/text.before"
  objcopy -O binary --only-section=.text "$history/$new_name" "$esp/text.after"
  cmp "$esp/text.before" "$esp/text.after" || fail "archive conversion must not alter executable code"
  [[ $(grep -c '^sign$' "$calls") == 1 && $(grep -c '^verify$' "$calls") == 2 ]] || fail "deduplicated image must be verified before and after signing"
  for file in "$manifest" "$manifest.old" "$cache"; do
    ! grep -Fq "$old_name" "$file" || fail "no old image references may survive in manifests"
    usb_authorization_rewrite_snapshot_manifest "$expected" "$file"
    # Both cached and structured restore representations must regenerate valid entries.
    for format in cached structured; do
      {
        printf '/Omarchy\ncomment: machine-id=%s\n  //snapshot\n' "$machine"
        if [[ $format == cached ]]; then
          jq -r '.snapshotEntries[0].kernelEntries[0].allInSnapshotConfig[]' "$file"
        else
          printf 'comment: kernel-id=linux\n'
          jq -r '.snapshotEntries[0].kernelEntries[0].subKernels[0] | "path: boot():" + .imageDetails[0].snapshotFilePathLine, "cmdline: " + .cmdlineDetails[0].snapshotCmdline' "$file"
        fi
      } >"$esp/regenerated.conf"
      usb_authorization_verify_boot_entries "$expected" "$esp/regenerated.conf" "$esp" "$machine" enabled || fail "regenerated $format $expected snapshot must verify"
    done
  done
  usb_authorization_rewrite_boot_cmdlines "$expected" "$config" "$machine"
  usb_authorization_verify_boot_entries "$expected" "$config" "$esp" "$machine" enabled || fail "$expected archive transition must verify under Secure Boot"
  usb_authorization_reconcile_archived_images "$expected" "$config" "$esp" "$machine" "$cache"
  [[ $(grep -c '^sign$' "$calls") == 1 ]] || fail "retry must not resign an already-compatible archive"
  if [[ -n ${USB_TEST_SBCTL_CONFIG:-} ]]; then
    usb_authorization_verify_signature "$history/$new_name"
  fi
  pass "USB $expected transition updates signed history and all cached/structured references"
done

fixture quiet
old_hash=$(b2sum "$esp/image.efi"); old_hash=${old_hash%% *}
printf '  //current\n  comment: kernel-id=current\n  path: boot():/image.efi#%s\n  cmdline: quiet\n' "$old_hash" >>"$config"
usb_authorization_reconcile_archived_images enabled "$config" "$esp" "$machine" "$cache"
grep -Fq "path: boot():/image.efi#$old_hash" "$config" || fail "preflight must not rewrite hashes of unchanged current images sharing archive content"
pass "USB archive preflight preserves unchanged current-image hashes"

fixture 'quiet rd.test="two  spaces"'
usb_authorization_reconcile_archived_images enabled "$config" "$esp" "$machine" "$cache"
new_name=$(jq -r '.snapshotEntries[0].kernelEntries[0].imageDetails[0].fileHashName' "$manifest")
objcopy -O binary --only-section=.cmdline "$history/$new_name" "$esp/section"
[[ $(tr '\0' '\n' <"$esp/section") == 'quiet rd.test="two  spaces" usbcore.authorized_default=0' ]] || fail "unrelated quoted arguments must retain their whitespace"
pass "USB archive policy changes preserve unrelated embedded arguments and executable code"

for failure in SIGN_FAIL VERIFY_FAIL ENROLL_FAIL; do
  fixture quiet
  if (export "$failure=1"; usb_authorization_reconcile_archived_images enabled "$config" "$esp" "$machine" "$cache") >"$esp/failure.log" 2>&1; then
    fail "$failure must prevent publication"
  fi
  cmp "$config" "$esp/before.conf" || fail "$failure must preserve the original boot menu"
  for file in "$manifest" "$manifest.old" "$cache"; do
    cmp "$file" "$esp/before.json" || fail "$failure must preserve every manifest"
  done
  cmp "$history/$old_name" "$esp/image.efi" || fail "$failure must preserve the archived image"
done
pass "USB archive signing, verification and enrollment failures preserve original references"

fixture quiet
printf corrupt >>"$history/$old_name"
if usb_authorization_reconcile_archived_images enabled "$config" "$esp" "$machine" "$cache" >"$esp/hash-failure" 2>&1; then
  fail "corrupt original archive must never be signed"
fi
[[ ! -s $calls ]] || fail "hash failure must occur before signing"
cmp "$config" "$esp/before.conf"
SECURE_BOOT=0 usb_authorization_reconcile_archived_images enabled "$config" "$esp" "$machine" "$cache"
[[ ! -s $calls ]] || fail "non-Secure-Boot transitions must not rewrite archive images"
pass "USB archive conversion rejects corruption and skips non-Secure-Boot systems"

if [[ -z ${USB_TEST_SBCTL_CONFIG:-} ]]; then
  fixture quiet
  if TEST_SIGNED=0 usb_authorization_reconcile_archived_images enabled "$config" "$esp" "$machine" "$cache" >"$esp/unsigned" 2>&1; then
    fail "a false-success sbctl result cannot authorize signing"
  fi
  ! grep -qx sign "$calls" || fail "an unsigned original must not be resigned"
fi
for missing in menu manifest; do
  fixture quiet
  if [[ $missing == menu ]]; then
    sed -i '/cmdline:/d' "$config"
  else
    jq '.snapshotEntries[0].kernelEntries[0].cmdlineDetails = []' "$manifest" >"$esp/modified"
    mv "$esp/modified" "$manifest"
  fi
  usb_authorization_reconcile_archived_images enabled "$config" "$esp" "$machine" "$cache" || fail "embedded-only $missing must support policy changes"
  usb_authorization_rewrite_boot_cmdlines enabled "$config" "$machine"
  usb_authorization_verify_boot_entries enabled "$config" "$esp" "$machine" enabled || fail "embedded-only $missing must retain a valid command line"
done
for section in .profile .pcrsig; do
  fixture quiet
  printf protected >"$esp/protected"
  objcopy --add-section "$section=$esp/protected" "$history/$old_name" 2>/dev/null
  if usb_authorization_reconcile_archived_images enabled "$config" "$esp" "$machine" "$cache" >"$esp/protected-failure" 2>&1; then
    fail "a $section image must require its original builder"
  fi
  grep -Fq "($section)" "$esp/protected-failure" || fail "unsupported signing policies need an actionable error"
  [[ ! -s $calls ]] || fail "unsupported signing policies must not be resigned"
done
pass "USB archive conversion requires authentic signatures and preserves boot/unlock requirements"

# Package hooks use this same lock. Installing the optional signature tool
# must finish before preparation takes the lock, while sync must run under it.
fixture quiet
prepare=$(declare -f usb_authorization_prepare_archived_images)
prepare=${prepare//\/run\/lock\/boot-partition.lock/$scratch\/preflight.lock}
eval "$prepare"
omarchy-cmd-missing() { return 0; }
omarchy-pkg-add() {
  flock --nonblock "$scratch/preflight.lock" true || fail "package installation must precede the boot lock"
  printf 'package\n' >>"$calls"
}
limine-snapper-sync() {
  [[ $* == '--no-mutex --no-hooks' ]] || fail "preparation must use the already-held lock"
  if flock --nonblock "$scratch/preflight.lock" true; then
    fail "snapshot synchronization must hold the boot lock"
  fi
}
usb_authorization_prepare_archived_images enabled "$config" "$esp" "$machine"
grep -qx package "$calls" || fail "missing signature tooling must be installed before preparing archives"
pass "USB archive preparation installs optional tools before taking Limine's lock"

# The disposable Lab runs the actual root-only main function with only boot paths
# and external build/sync commands redirected into this fixture.
if [[ ${USB_TEST_MAIN:-0} == 1 ]]; then
  (( EUID == 0 )) || fail "main-path fixtures require the disposable guest's root"
  usb_authorization_prepare_archived_images() {
    usb_authorization_reconcile_archived_images "$1" "$2" "$3" "$machine" "$cache"
  }
  limine-mkinitcpio() { return 0; }
  usb_authorization_sync_and_verify() {
    local file
    for file in "$manifest" "$manifest.old" "$cache"; do
      usb_authorization_rewrite_snapshot_manifest "$1" "$file" || return 1
    done
    usb_authorization_rewrite_boot_cmdlines "$1" "$2" "$machine" || return 1
    usb_authorization_verify_boot_entries "$1" "$2" "$3" "$machine" enabled
  }
  for action in enable disable; do
    old=quiet
    [[ $action != disable ]] || old+=' usbcore.authorized_default=0'
    fixture "$old"
    drop_in="$esp/entry-tool/usb-authorization.conf"
    limine_defaults="$esp/defaults"
    limine_conf="$config"
    boot_path="$esp"
    printf '# fixture defaults\n' >"$limine_defaults"
    if [[ $action == disable ]]; then
      mkdir -p "${drop_in%/*}"
      printf '%s\n' "$setting" >"$drop_in"
      usb_authorization_enable_snapshot_setting "$limine_defaults"
    fi
    cp "$limine_defaults" "$esp/defaults.before"
    if (export SIGN_FAIL=1; usb_authorization_main "$action") >"$esp/main-failed" 2>&1; then
      fail "$action must stop if archive preparation fails"
    fi
    cmp "$limine_defaults" "$esp/defaults.before" || fail "$action failure must precede snapshot-setting changes"
    if [[ $action == enable ]]; then
      [[ ! -e $drop_in ]] || fail "enable preflight failure must not create the boot setting"
    else
      [[ $(<"$drop_in") == "$setting" ]] || fail "disable preflight failure must preserve the boot setting"
    fi
    (usb_authorization_main "$action")
    if [[ $action == enable ]]; then
      [[ $(<"$drop_in") == "$setting" ]] || fail "successful enable sets the boot policy"
    else
      [[ ! -e $drop_in ]] || fail "successful disable clears the boot policy"
    fi
    pass "USB $action main path prepares archives before changing boot policy"
  done
fi
