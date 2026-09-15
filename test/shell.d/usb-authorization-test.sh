#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

scratch=$(mktemp -d)
trap 'rm -rf "$scratch"' EXIT

stub_bin="$scratch/bin"
home="$scratch/home"
rules="$scratch/etc/usbguard/rules.conf"
daemon_config="$scratch/etc/usbguard/usbguard-daemon.conf"
calls="$scratch/calls"

mkdir -p "$stub_bin" "$home" "${rules%/*}"
: >"$rules"
: >"$calls"

cat >"$daemon_config" <<'CONF'
ImplicitPolicyTarget=block
PresentDevicePolicy=apply-policy
InsertedDevicePolicy=apply-policy
AuthorizedDefault=none
RestoreControllerDeviceState=false
CONF

cat >"$stub_bin/omarchy-pkg-missing" <<'STUB'
#!/bin/bash
exit 0
STUB
cat >"$stub_bin/omarchy-pkg-present" <<'STUB'
#!/bin/bash
exit 0
STUB
cat >"$stub_bin/omarchy-pkg-add" <<'STUB'
#!/bin/bash
printf 'pkg-add <%s>\n' "$*" >>"$CALLS"
STUB
cat >"$stub_bin/omarchy-pkg-drop" <<'STUB'
#!/bin/bash
printf 'pkg-drop <%s>\n' "$*" >>"$CALLS"
STUB
cat >"$stub_bin/install" <<'STUB'
#!/bin/bash
if [[ $1 == -Dm600 && $2 == -o && $3 == root && $4 == -g && $5 == root ]]; then
  exec /usr/bin/install -Dm600 "$6" "$7"
fi
exec /usr/bin/install "$@"
STUB
cat >"$stub_bin/systemctl" <<'STUB'
#!/bin/bash
printf 'systemctl <%s>\n' "$*" >>"$CALLS"
if [[ $* == "is-enabled --quiet usbguard.service" ]]; then
  exit 1
fi
STUB
cat >"$stub_bin/usbguard" <<'STUB'
#!/bin/bash
case "$1" in
generate-policy)
  echo 'usbguard <generate-policy>' >>"$CALLS"
  [[ ${GENERATE_FAIL:-0} == 0 ]] || exit 1
  if [[ ${GENERATE_EMPTY:-0} == 0 ]]; then
    echo 'allow id 1d6b:0002 name "Linux Foundation root hub" hash "root"'
  fi
  ;;
list-devices)
  if [[ ${2:-} == "--blocked" ]]; then
    if [[ -n ${BLOCKED_DEVICES_FILE:-} ]]; then cat "$BLOCKED_DEVICES_FILE"; exit 0; fi
    if [[ ${BLOCKED_DEVICE_PRESENT:-1} == 1 ]]; then
      rule="${BLOCKED_DEVICE_RULE:?}"
      if [[ -n ${BLOCKED_DEVICE_RULE_FILE:-} && -f $BLOCKED_DEVICE_RULE_FILE ]]; then
        rule=$(<"$BLOCKED_DEVICE_RULE_FILE")
      fi
      printf '17: %s\n' "$rule"
    fi
  else
    echo '4: allow id 1d6b:0002 name "Linux Foundation root hub" hash "root"'
    echo '5: allow id 0627:0001 name "QEMU USB Tablet" hash "tablet"'
  fi
  ;;
*)
  printf 'usbguard' >>"$CALLS"
  printf ' <%s>' "$@" >>"$CALLS"
  printf '\n' >>"$CALLS"
  ;;
esac
STUB
cat >"$stub_bin/sudo" <<'STUB'
#!/bin/bash
printf 'sudo' >>"$CALLS"
printf ' <%s>' "$@" >>"$CALLS"
printf '\n' >>"$CALLS"
if [[ $1 == awk && ${!#} == /etc/usbguard/usbguard-daemon.conf ]]; then
  args=("$@")
  args[-1]="$TEST_DAEMON_CONFIG"
  exec "${args[@]}"
elif [[ $1 == test && $2 == -s && $3 == /etc/usbguard/rules.conf ]]; then
  exec /usr/bin/test -s "$TEST_RULES"
elif [[ $1 == install && $2 == -Dm600 && $3 == -o && $4 == root && $5 == -g && $6 == root && $8 == /etc/usbguard/rules.conf ]]; then
  exec /usr/bin/install -Dm600 "$7" "$TEST_RULES"
elif [[ $1 == omarchy-usb-authorization-restore-default ]]; then
  echo 1 >"$TEST_SYSFS/usb1/authorized_default"
  echo 1 >"$TEST_SYSFS/1-2/authorized"
  exit 0
elif [[ $1 == omarchy-usb-authorization-boot ]]; then
  exit 0
fi
exec "$@"
STUB
cat >"$stub_bin/gum" <<'STUB'
#!/bin/bash
case "$1" in
style) exit 0 ;;
choose)
  if [[ -n ${GUM_REASSIGN_RULE:-} ]]; then
    printf '%s\n' "$GUM_REASSIGN_RULE" >"$BLOCKED_DEVICE_RULE_FILE"
  fi
  printf '%s\n' "${GUM_CHOICE:-Keep blocked}"
  ;;
confirm) exit 0 ;;
esac
STUB
cat >"$stub_bin/omarchy-notification-send" <<'STUB'
#!/bin/bash
printf 'notification' >>"$CALLS"
printf ' <%s>' "$@" >>"$CALLS"
printf '\n' >>"$CALLS"
if [[ -n ${NOTIFICATION_FAILURE_MARKER:-} && ! -e $NOTIFICATION_FAILURE_MARKER ]]; then
  touch "$NOTIFICATION_FAILURE_MARKER"
  exit 1
fi
STUB
cat >"$stub_bin/omarchy-notification-wait" <<'STUB'
#!/bin/bash
if [[ -n ${NOTIFICATION_READY_FILE:-} ]]; then
  touch "$NOTIFICATION_READY_FILE.waited"
  [[ -e $NOTIFICATION_READY_FILE ]]
fi
STUB
chmod +x "$stub_bin"/*

export HOME="$home"
export USER=tester
export OMARCHY_PATH="$ROOT"
export CALLS="$calls"
export PATH="$stub_bin:$ROOT/bin:$PATH"
export TEST_DAEMON_CONFIG="$daemon_config"
export TEST_RULES="$rules"

if "$ROOT/bin/omarchy-usb-authorization-restore-default" >/dev/null 2>&1; then
  fail "the fixed-path USB authorization restore helper requires root"
fi
if "$ROOT/bin/omarchy-usb-authorization-boot" enable >/dev/null 2>&1; then
  fail "the fixed-path boot authorization helper requires root"
fi
! grep -q 'OMARCHY_USB_AUTHORIZATION_.*ROOT\|OMARCHY_USB_AUTHORIZATION_.*FILE\|OMARCHY_USB_AUTHORIZATION_.*CONFIG' \
  "$ROOT/bin/omarchy-setup-security-usb-authorization" \
  "$ROOT/bin/omarchy-remove-security-usb-authorization" \
  "$ROOT/bin/omarchy-usb-authorization-boot" ||
  fail "user-facing USB authorization commands do not elevate caller-selected paths"
pass "USB authorization keeps privileged paths fixed"

"$ROOT/bin/omarchy-setup-security-usb-authorization" --yes >"$scratch/setup-output"

grep -qx 'allow id 1d6b:0002 name "Linux Foundation root hub" hash "root"' "$rules" ||
  fail "USB authorization setup trusts devices present during enrollment"
[[ $(stat -c %a "$rules") == 600 ]] || fail "USB authorization policy is root-private"
grep -Fqx 'usbguard <add-user> <tester> <--devices=list,listen,modify> <--policy=list> <--exceptions=listen>' "$calls" ||
  fail "USB authorization grants only the IPC access needed by the approval flow"
grep -Fqx 'systemctl <restart usbguard.service>' "$calls" ||
  fail "USB authorization reloads its user ACL before the watcher starts"
[[ -L $home/.config/systemd/user/omarchy-usb-authorization.service ]] ||
  fail "USB authorization installs the graphical-session watcher"
grep -Fqx 'pkg-add <usbguard>' "$calls" || fail "USB authorization ensures USBGuard is installed"
pass "USB authorization enrolls present devices before enabling default-deny"

generate_count=$(grep -c '^usbguard <generate-policy>$' "$calls")
"$ROOT/bin/omarchy-setup-security-usb-authorization" --yes >"$scratch/setup-existing-output"
generate_count_after=$(grep -c '^usbguard <generate-policy>$' "$calls")
(( generate_count_after == generate_count )) || fail "re-enabling preserves the existing trusted-device policy"
pass "USB authorization setup preserves an existing policy"

: >"$rules"
GENERATE_EMPTY=1 "$ROOT/bin/omarchy-setup-security-usb-authorization" --yes >"$scratch/setup-empty-output"
[[ -s $rules ]] || fail "empty USB inventory must persist an initialized policy"
! grep -q '^allow ' "$rules" || fail "empty inventory must not add permissive rules"
generate_count=$(grep -c '^usbguard <generate-policy>$' "$calls")
"$ROOT/bin/omarchy-setup-security-usb-authorization" --yes >"$scratch/setup-empty-again-output"
[[ $(grep -c '^usbguard <generate-policy>$' "$calls") == "$generate_count" ]] ||
  fail "re-enabling an empty policy must not enroll newly attached devices"
: >"$rules"
if GENERATE_FAIL=1 "$ROOT/bin/omarchy-setup-security-usb-authorization" --yes >"$scratch/setup-failed-output" 2>&1; then
  fail "enumeration failure must not be accepted as an empty USB inventory"
fi
[[ ! -s $rules ]] || fail "failed enumeration must not install a policy"
pass "USB setup accepts an empty inventory while rejecting enumeration failure"

: >"$calls"
"$ROOT/bin/omarchy-setup-security-usb-authorization" --boot --yes >"$scratch/setup-boot-output"
grep -Fqx 'usbguard <allow-device> <--permanent> <4>' "$calls" ||
  fail "boot authorization trusts the connected root controller"
grep -Fqx 'usbguard <allow-device> <--permanent> <5>' "$calls" ||
  fail "boot authorization trusts the connected USB devices"
grep -Fqx 'sudo <omarchy-usb-authorization-boot> <enable>' "$calls" ||
  fail "boot authorization uses the fixed-path boot-image helper"
grep -Fq 'takes effect after reboot' "$scratch/setup-boot-output" ||
  fail "boot authorization explains when the change becomes active"
pass "USB authorization can snapshot connected devices for early-boot denial"

boot_conf="$scratch/limine.conf"
machine_id=$(</etc/machine-id)
touch "$scratch/vmlinuz-linux"
boot_hash=$(b2sum "$scratch/vmlinuz-linux")
boot_hash=${boot_hash%% *}
printf 'quiet splash\0' >"$scratch/embedded-cmdline"
historical_uki="$scratch/embedded.efi_sha256_fixture"
objcopy -I binary -O pei-x86-64 -B i386:x86-64 "$scratch/embedded-cmdline" "$historical_uki"
objcopy --rename-section .data=.cmdline,alloc,load,readonly,data,contents "$historical_uki"
embedded_hash=$(b2sum "$historical_uki")
embedded_hash=${embedded_hash%% *}
cat >"$boot_conf" <<CONF
/+Omarchy
comment: machine-id=$machine_id
  //linux
  comment: kernel-id=linux
  path: boot():/vmlinuz-linux#$boot_hash
  cmdline: quiet splash
  //linux-embedded
  comment: kernel-id=linux-embedded
  path: boot():/embedded.efi_sha256_fixture#$embedded_hash
  cmdline: quiet splash
    ///Snapshots
      ////linux
      comment: kernel-id=linux
      path: boot():/vmlinuz-linux#$boot_hash
      cmdline: rootflags=subvol=/snapshot quiet splash
/Other Linux
comment: machine-id=ffffffffffffffffffffffffffffffff
  //linux
  comment: kernel-id=linux
  path: boot():/other-linux
  cmdline: quiet splash
CONF

source "$ROOT/bin/omarchy-usb-authorization-boot"
limine-mkinitcpio() { return 0; }
limine-enroll-config() { return 0; }

if usb_authorization_rebuild_and_verify enabled "$boot_conf" "$scratch" "$machine_id" enabled 2>/dev/null; then
  fail "boot authorization rejects Limine's false-success status when entries were not rebuilt"
fi
usb_authorization_rewrite_boot_cmdlines enabled "$boot_conf" "$machine_id"
usb_authorization_rebuild_and_verify enabled "$boot_conf" "$scratch" "$machine_id" disabled ||
  fail "a non-Secure-Boot snapshot uses its updated external command line"
if usb_authorization_rebuild_and_verify enabled "$boot_conf" "$scratch" "$machine_id" enabled 2>/dev/null; then
  fail "an external allow parameter cannot hide a stale embedded UKI command line"
fi
printf 'quiet splash usbcore.authorized_default=0\0' >"$scratch/embedded-cmdline"
objcopy -I binary -O pei-x86-64 -B i386:x86-64 "$scratch/embedded-cmdline" "$historical_uki"
objcopy --rename-section .data=.cmdline,alloc,load,readonly,data,contents "$historical_uki"
updated_embedded_hash=$(b2sum "$historical_uki")
updated_embedded_hash=${updated_embedded_hash%% *}
sed -i "s/embedded.efi_sha256_fixture#$embedded_hash/embedded.efi_sha256_fixture#$updated_embedded_hash/" "$boot_conf"
usb_authorization_rebuild_and_verify enabled "$boot_conf" "$scratch" "$machine_id" enabled ||
  fail "boot authorization updates current and snapshot entries for this machine"
[[ $(grep -c 'usbcore.authorized_default=0' "$boot_conf") == 3 ]] ||
  fail "boot authorization leaves another operating system's kernel entries unchanged"
printf 'stale image' >"$scratch/vmlinuz-linux"
if usb_authorization_rebuild_and_verify enabled "$boot_conf" "$scratch" "$machine_id" enabled 2>/dev/null; then
  fail "boot authorization rejects a stale Limine verification hash"
fi
: >"$scratch/vmlinuz-linux"
if usb_authorization_rebuild_and_verify disabled "$boot_conf" "$scratch" "$machine_id" enabled 2>/dev/null; then
  fail "boot authorization detects a stale deny-by-default boot entry during removal"
fi
usb_authorization_rewrite_boot_cmdlines disabled "$boot_conf" "$machine_id"
printf 'quiet splash\0' >"$scratch/embedded-cmdline"
objcopy -I binary -O pei-x86-64 -B i386:x86-64 "$scratch/embedded-cmdline" "$historical_uki"
objcopy --rename-section .data=.cmdline,alloc,load,readonly,data,contents "$historical_uki"
disabled_embedded_hash=$(b2sum "$historical_uki")
disabled_embedded_hash=${disabled_embedded_hash%% *}
sed -i "s/embedded.efi_sha256_fixture#$updated_embedded_hash/embedded.efi_sha256_fixture#$disabled_embedded_hash/" "$boot_conf"
usb_authorization_rebuild_and_verify disabled "$boot_conf" "$scratch" "$machine_id" enabled ||
  fail "boot authorization removes the parameter from current and snapshot entries"

snapshot_config="$scratch/limine-defaults"
printf 'TARGET_OS_NAME="Omarchy"\n' >"$snapshot_config"
usb_authorization_enable_snapshot_setting "$snapshot_config"
grep -Fqx 'SNAPSHOT_KERNEL_PARAMETERS+=usbcore.authorized_default=0' "$snapshot_config" ||
  fail "future Limine snapshots inherit boot-time USB authorization"
usb_authorization_enable_snapshot_setting "$snapshot_config"
[[ $(grep -Fxc '# Omarchy USB authorization begin' "$snapshot_config") == 1 ]] ||
  fail "the snapshot setting remains idempotent"
usb_authorization_disable_snapshot_setting "$snapshot_config"
! grep -Fq 'usbcore.authorized_default=0' "$snapshot_config" ||
  fail "removing boot authorization restores future snapshot defaults"
pass "boot authorization verifies generated entries despite Limine false-success exits"

manifest="$scratch/snapshots.json"
jq -n --arg hash "$boot_hash" '
  def kernel:
    {cmdlineDetails: [{limineKey: "CMDLINE", cmdline: "quiet rootflags=subvol=@", snapshotCmdline: "quiet rootflags=subvol=/snapshot"}],
     allInConfig: ["  cmdline: quiet rootflags=subvol=@"],
     allInSnapshotConfig: ["comment: kernel-id=linux", "path: boot():/vmlinuz-linux#" + $hash, "cmdline: quiet rootflags=subvol=/snapshot"],
     subKernels: [], properties: {untouched: "usbcore.authorized_default=0"}};
  {jsonFormatVersion: "1.3.0", snapshotEntries: [{kernelEntries: [kernel | .subKernels = [kernel | .allInSnapshotConfig = []]]}], uuid: "preserve-me"}
' >"$manifest"
cp "$manifest" "$scratch/manifest-original.json"
for expected in enabled disabled; do
  usb_authorization_rewrite_snapshot_manifest "$expected" "$manifest"
  cp "$manifest" "$scratch/manifest-once.json"
  usb_authorization_rewrite_snapshot_manifest "$expected" "$manifest"
  cmp -s "$manifest" "$scratch/manifest-once.json" || fail "manifest updates are idempotent"
  # Model both Limine render paths: cached lines and structured details.
  for representation in cached structured; do
    {
      printf '/Omarchy\ncomment: machine-id=%s\n  //linux\n' "$machine_id"
      if [[ $representation == "cached" ]]; then
        jq -r '.snapshotEntries[0].kernelEntries[0].allInSnapshotConfig[]' "$manifest"
      else
        printf 'comment: kernel-id=linux\npath: boot():/vmlinuz-linux#%s\n' "$boot_hash"
        jq -r '"cmdline: " + .snapshotEntries[0].kernelEntries[0].subKernels[0].cmdlineDetails[0].snapshotCmdline' "$manifest"
      fi
    } >"$scratch/regenerated.conf"
    usb_authorization_verify_boot_entries "$expected" "$scratch/regenerated.conf" "$scratch" "$machine_id" disabled ||
      fail "snapshot synchronization preserves $expected policy from $representation entries"
  done
  jq -e '.snapshotEntries[0].kernelEntries[0].properties.untouched == "usbcore.authorized_default=0"' "$manifest" >/dev/null ||
    fail "manifest changes preserve unrelated metadata"
done
jq -S . "$manifest" >"$scratch/manifest-after.json"
jq -S . "$scratch/manifest-original.json" >"$scratch/manifest-before.json"
cmp -s "$scratch/manifest-before.json" "$scratch/manifest-after.json" ||
  fail "disable restores all stored command lines without changing other snapshot data"
printf '{bad json' >"$scratch/bad-manifest.json"
if usb_authorization_rewrite_snapshot_manifest enabled "$scratch/bad-manifest.json" 2>/dev/null; then
  fail "invalid manifests must fail closed"
fi
[[ $(<"$scratch/bad-manifest.json") == '{bad json' ]] || fail "failed manifest updates preserve the original"
pass "USB boot policy survives snapshot regeneration from cached and structured manifests"


: >"$calls"
"$ROOT/bin/omarchy-remove-security-usb-authorization" --boot-only --yes >"$scratch/remove-boot-output"
grep -Fqx 'sudo <omarchy-usb-authorization-boot> <disable>' "$calls" ||
  fail "boot-only removal rebuilds the permissive boot policy"
! grep -Fq 'systemctl <--user disable --now omarchy-usb-authorization.service>' "$calls" ||
  fail "boot-only removal leaves the userspace approval watcher enabled"
grep -Fq 'takes effect after reboot' "$scratch/remove-boot-output" ||
  fail "boot-only removal explains when the change becomes active"
pass "early-boot denial can be removed without disabling USBGuard"

grep -qx 'usbguard' "$ROOT/install/omarchy-base.packages" || fail "USBGuard is installed by default"
grep -Fq 'config/usb-authorization.sh' "$ROOT/install/config/all.sh" ||
  fail "fresh installs configure the USB authorization policy"
grep -Fq 'omarchy-usb-authorization.service' "$ROOT/install/user/first-run/enable-user-units.sh" ||
  fail "fresh installs enable the USB approval watcher"
grep -Fq 'usb_authorization_add_user "$username"' "$ROOT/bin/omarchy-provision-owner" ||
  fail "deferred provisioning grants the new owner approval access"
grep -Fq 'systemctl try-restart usbguard.service' "$ROOT/bin/omarchy-provision-owner" ||
  fail "deferred provisioning reloads the new owner ACL"
grep -Fqx 'omarchy-setup-security-usb-authorization --yes' "$ROOT/migrations/1789433473.sh" ||
  fail "existing installs enable USB authorization during migration"

: >"$rules"
: >"$calls"
export OMARCHY_INSTALL="$ROOT/install"
export OMARCHY_INSTALL_USER=tester
export OMARCHY_USB_AUTHORIZATION_RULES_FILE="$rules"
export OMARCHY_USB_AUTHORIZATION_DAEMON_CONFIG="$daemon_config"
bash -euo pipefail -c 'source "$OMARCHY_INSTALL/config/usb-authorization.sh"' >"$scratch/install-output"
grep -qx 'allow id 1d6b:0002 name "Linux Foundation root hub" hash "root"' "$rules" ||
  fail "fresh installation enrolls devices present during installation"
grep -Fqx 'usbguard <add-user> <tester> <--devices=list,listen,modify> <--policy=list> <--exceptions=listen>' "$calls" ||
  fail "fresh installation grants the owner narrowly scoped approval access"
grep -Fqx 'systemctl <enable usbguard.service>' "$calls" ||
  fail "fresh installation enables USBGuard for the first boot"
pass "USB authorization is the default for fresh and existing installations"

: >"$rules"
GENERATE_EMPTY=1 bash -euo pipefail -c 'source "$OMARCHY_INSTALL/config/usb-authorization.sh"' >"$scratch/install-empty-output"
[[ -s $rules ]] || fail "fresh install accepts a successful empty USB inventory"
! grep -q '^allow ' "$rules" || fail "empty fresh-install inventory stays default-deny"
: >"$rules"
: >"$calls"
if GENERATE_FAIL=1 bash -euo pipefail -c 'source "$OMARCHY_INSTALL/config/usb-authorization.sh"' >"$scratch/install-enumeration-failed" 2>&1; then
  fail "fresh install must reject a generator failure"
fi
! grep -Fq 'systemctl <enable usbguard.service>' "$calls" || fail "failed enumeration must not enable USBGuard"
pass "fresh installation distinguishes no USB hardware from enumeration failure"

malicious_rule='block id 07a6:8513 name "$(touch '"$scratch"'/injected)" hash "attacker" with-interface 02:06:00'
export BLOCKED_DEVICE_RULE="$malicious_rule"
notification_count=$(grep -c '^notification' "$calls" || true)
for presence in Insert Present; do
  USBGUARD_IPC_SIGNAL=Device.PresenceChanged \
    USBGUARD_DEVICE_EVENT="$presence" \
    USBGUARD_DEVICE_TARGET=block \
    USBGUARD_DEVICE_ID=17 \
    USBGUARD_DEVICE_RULE="$malicious_rule" \
    "$ROOT/bin/omarchy-usb-authorization-event"
done
USBGUARD_IPC_SIGNAL=Device.PolicyApplied \
  USBGUARD_DEVICE_TARGET_NEW=allow \
  USBGUARD_DEVICE_ID=17 \
  USBGUARD_DEVICE_RULE="${malicious_rule/#block/allow}" \
  "$ROOT/bin/omarchy-usb-authorization-event"
[[ $(grep -c '^notification' "$calls" || true) == "$notification_count" ]] ||
  fail "a trusted device's transient blocked presence must not prompt"
BLOCKED_DEVICE_PRESENT=0 \
  USBGUARD_IPC_SIGNAL=Device.PolicyApplied \
  USBGUARD_DEVICE_TARGET_NEW=block \
  USBGUARD_DEVICE_ID=17 \
  USBGUARD_DEVICE_RULE="$malicious_rule" \
  "$ROOT/bin/omarchy-usb-authorization-event"
[[ $(grep -c '^notification' "$calls" || true) == "$notification_count" ]] ||
  fail "a stale blocked event must not prompt after authorization or removal"
pass "USB alerts use the final policy and discard stale events"
USBGUARD_IPC_SIGNAL=Device.PolicyApplied \
  USBGUARD_DEVICE_ID=17 \
  USBGUARD_DEVICE_EVENT=Insert \
  USBGUARD_DEVICE_TARGET_NEW=block \
  USBGUARD_DEVICE_RULE="$malicious_rule" \
  "$ROOT/bin/omarchy-usb-authorization-event"

request=$(find "$home/.local/state/omarchy/usb-authorization/requests" -maxdepth 1 -name 'request-*.json' -print -quit)
[[ -n $request ]] || fail "a blocked USB device creates a review request"
[[ $(stat -c %a "$request") == 600 ]] || fail "device-controlled request data stays private"
[[ $(jq -r .id "$request") == 17 ]] || fail "the request records the USBGuard device id"
[[ $(jq -r .rule "$request") == "$malicious_rule" ]] || fail "the request preserves the identity snapshot"
! grep -Fq "$malicious_rule" "$calls" || fail "device text never enters the notification's launch command"
[[ ! -e $scratch/injected ]] || fail "device text cannot execute during notification"
token=$(basename "${request%.json}")
grep -Eq "notification .*<omarchy-usb-authorization-review> <$token>$" "$calls" ||
  fail "the notification action carries only an opaque request token"
pass "blocked device metadata remains data across the desktop notification boundary"

notification_count=$(grep -c '^notification' "$calls")
USBGUARD_IPC_SIGNAL=IPC.Connected "$ROOT/bin/omarchy-usb-authorization-event" &
scan_pid=$!
USBGUARD_IPC_SIGNAL=Device.PolicyApplied \
  USBGUARD_DEVICE_ID=17 \
  USBGUARD_DEVICE_TARGET_NEW=block \
  USBGUARD_DEVICE_RULE="$malicious_rule" \
  "$ROOT/bin/omarchy-usb-authorization-event"
wait "$scan_pid"
[[ $(grep -c '^notification' "$calls") == "$notification_count" ]] ||
  fail "overlapping scan and policy events must not duplicate pending prompts"
pass "USB reconnect scans and policy events deduplicate pending requests"

GUM_CHOICE='Allow once' "$ROOT/bin/omarchy-usb-authorization-review" "$token" >"$scratch/review-once-output"
grep -Fqx "usbguard <allow-device> <$malicious_rule>" "$calls" || fail "review can allow the exact device once"
[[ ! -e $request ]] || fail "a completed review consumes its request"
pass "USB review allows a still-matching device once"

# A daemon restart discards the temporary approval. The IPC reconnect must
# recover the blocked device even when its startup policy events were missed.
notification_count=$(grep -c '^notification' "$calls")
USBGUARD_IPC_SIGNAL=IPC.Connected "$ROOT/bin/omarchy-usb-authorization-event"
[[ -f $request ]] || fail "reconnection recreates a consumed Allow once request"
[[ $(grep -c '^notification' "$calls") == $((notification_count + 1)) ]] ||
  fail "reconnection prompts again for a temporary approval lost on restart"
GUM_CHOICE='Keep blocked' "$ROOT/bin/omarchy-usb-authorization-review" "$token" >/dev/null
USBGUARD_IPC_SIGNAL=Device.PolicyApplied \
  USBGUARD_DEVICE_ID=17 \
  USBGUARD_DEVICE_TARGET_OLD=allow \
  USBGUARD_DEVICE_TARGET_NEW=block \
  USBGUARD_DEVICE_RULE="$malicious_rule" \
  "$ROOT/bin/omarchy-usb-authorization-event"
[[ -f $request ]] || fail "a later allow-to-block policy transition creates a request"
GUM_CHOICE='Keep blocked' "$ROOT/bin/omarchy-usb-authorization-review" "$token" >/dev/null
pass "USB approval recovers after IPC reconnects and policy transitions"

USBGUARD_IPC_SIGNAL=Device.PolicyApplied \
  USBGUARD_DEVICE_ID=17 \
  USBGUARD_DEVICE_EVENT=Insert \
  USBGUARD_DEVICE_TARGET_NEW=block \
  USBGUARD_DEVICE_RULE="$malicious_rule" \
  "$ROOT/bin/omarchy-usb-authorization-event"
request=$(find "$home/.local/state/omarchy/usb-authorization/requests" -maxdepth 1 -name 'request-*.json' -print -quit)
token=$(basename "${request%.json}")
GUM_CHOICE='Always allow this device' "$ROOT/bin/omarchy-usb-authorization-review" "$token" >"$scratch/review-always-output"
grep -Fqx "usbguard <allow-device> <--permanent> <$malicious_rule>" "$calls" || fail "review can persist an exact-device rule"
pass "USB review supports explicit persistent trust"

USBGUARD_IPC_SIGNAL=Device.PolicyApplied \
  USBGUARD_DEVICE_ID=17 \
  USBGUARD_DEVICE_EVENT=Insert \
  USBGUARD_DEVICE_TARGET_NEW=block \
  USBGUARD_DEVICE_RULE="$malicious_rule" \
  "$ROOT/bin/omarchy-usb-authorization-event"
request=$(find "$home/.local/state/omarchy/usb-authorization/requests" -maxdepth 1 -name 'request-*.json' -print -quit)
token=$(basename "${request%.json}")
device_rule_file="$scratch/blocked-device-rule"
printf '%s\n' "$malicious_rule" >"$device_rule_file"
replacement_rule='block id 1d50:60c7 name "Replacement gadget" hash "replacement"'
allow_count=$(grep -c '^usbguard <allow-device>' "$calls")
if BLOCKED_DEVICE_RULE_FILE="$device_rule_file" \
  GUM_REASSIGN_RULE="$replacement_rule" \
  GUM_CHOICE='Always allow this device' \
  "$ROOT/bin/omarchy-usb-authorization-review" "$token" >"$scratch/review-reassigned-output" 2>&1; then
  fail "review rejects a USBGuard ID reassigned while the approval dialog is open"
fi
[[ $(grep -c '^usbguard <allow-device>' "$calls") == "$allow_count" ]] ||
  fail "an ID reassigned during review cannot authorize a different device"
[[ ! -e $request ]] || fail "a reassigned-ID review request is discarded"
pass "USB review revalidates identity after the approval dialog"

USBGUARD_IPC_SIGNAL=Device.PolicyApplied \
  USBGUARD_DEVICE_ID=17 \
  USBGUARD_DEVICE_EVENT=Insert \
  USBGUARD_DEVICE_TARGET_NEW=block \
  USBGUARD_DEVICE_RULE="$malicious_rule" \
  "$ROOT/bin/omarchy-usb-authorization-event"
request=$(find "$home/.local/state/omarchy/usb-authorization/requests" -maxdepth 1 -name 'request-*.json' -print -quit)
token=$(basename "${request%.json}")
allow_count=$(grep -c '^usbguard <allow-device>' "$calls")
if BLOCKED_DEVICE_PRESENT=0 "$ROOT/bin/omarchy-usb-authorization-review" "$token" >"$scratch/review-stale-output" 2>&1; then
  fail "review rejects a request after its device disappears"
fi
[[ $(grep -c '^usbguard <allow-device>' "$calls") == "$allow_count" ]] ||
  fail "a reused USBGuard id cannot authorize a different device"
[[ ! -e $request ]] || fail "a stale review request is discarded"
pass "USB review binds approval to the device snapshot"

notification_count=$(grep -c '^notification' "$calls")
printf '17: %s\n18: %s\n' "$malicious_rule" 'block id 1234:5678 name "Second blocked device" hash "second"' >"$scratch/two-blocked"
NOTIFICATION_READY_FILE="$scratch/notification-ready" \
  NOTIFICATION_FAILURE_MARKER="$scratch/first-send-failed" \
  BLOCKED_DEVICES_FILE="$scratch/two-blocked" \
  USBGUARD_IPC_SIGNAL=IPC.Connected \
  timeout 10 "$ROOT/bin/omarchy-usb-authorization-event" &
scan_pid=$!
for ((attempt=0; attempt<50; attempt++)); do
  [[ -e $scratch/notification-ready.waited ]] && break
  sleep 0.02
done
[[ -e $scratch/notification-ready.waited ]] || fail "startup waits for notification readiness"
[[ $(grep -c '^notification' "$calls") == "$notification_count" ]] ||
  fail "startup does not send before the notification server is ready"
touch "$scratch/notification-ready"
wait "$scan_pid" || fail "startup scan must retry and finish without another USB event"
[[ $(grep -c '^notification' "$calls") == $((notification_count + 3)) ]] ||
  fail "two blocked devices must be notified despite a failed first send"
[[ -f $request ]] || fail "successful retry leaves a reviewable request"
pass "USB startup waits for notifications and automatically retries delivery for all devices"

sysfs="$scratch/sys/bus/usb/devices"
mkdir -p "$sysfs/usb1" "$sysfs/1-2"
echo 0 >"$sysfs/usb1/authorized_default"
echo 0 >"$sysfs/1-2/authorized"
export TEST_SYSFS="$sysfs"

"$ROOT/bin/omarchy-remove-security-usb-authorization" --yes >"$scratch/remove-output"

[[ $(<"$sysfs/usb1/authorized_default") == 1 ]] || fail "removal restores root-hub default authorization"
[[ $(<"$sysfs/1-2/authorized") == 1 ]] || fail "removal reauthorizes devices left connected"
grep -Fqx 'systemctl <disable --now usbguard.service>' "$calls" || fail "removal stops a service Omarchy enabled"
grep -Fqx 'usbguard <remove-user> <tester>' "$calls" || fail "removal drops the user's USBGuard IPC access"
grep -Fqx 'sudo <omarchy-usb-authorization-restore-default>' "$calls" ||
  fail "removal restores USB authorization only through the fixed-path root helper"
grep -Fqx 'sudo <omarchy-usb-authorization-boot> <disable>' "$calls" ||
  fail "removing USB authorization also removes early-boot denial"
! grep -Fqx 'pkg-drop <usbguard>' "$calls" || fail "disabling keeps the default USBGuard package installed"
[[ ! -e $home/.config/systemd/user/omarchy-usb-authorization.service ]] ||
  fail "removal deletes the graphical-session watcher"
pass "USB authorization removal restores the original default-allow behavior"
