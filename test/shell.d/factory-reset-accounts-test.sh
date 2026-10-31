#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"
export OMARCHY_PATH=$ROOT

if (( EUID != 0 )); then
  if unshare --user --map-root-user true 2>/dev/null; then
    exec unshare --user --map-root-user bash "$0"
  fi
  skip "no unprivileged user namespace; skipping factory account cleanup"
  exit 0
fi

test_tmp=$(mktemp -d)
trap 'rm -rf "$test_tmp"' EXIT

# Load the production functions without self-elevation or the reset entrypoint.
awk '
  /^[a-z_]+\(\) \{/ { copying = 1 }
  copying { print }
  /^}/ { copying = 0 }
' "$ROOT/bin/omarchy-system-factory-reset" >"$test_tmp/functions"

cat >"$test_tmp/reset" <<'SH'
#!/bin/bash
set -euo pipefail
source "$1/functions"
TOP_MNT="$2"
ESP_MNT="$2/esp-mount"
NEXT_NAME=@omarchy-reset-next
PROVISIONING_DIR=/var/lib/omarchy/provisioning
LOG_FILE="$TOP_MNT/reset.log"

log() { printf '%s\n' "$1" >>"$LOG_FILE"; }
fail() { log "$1"; exit 1; }

# Account tools are real. Only snapshots, boot rebuilding, and system services
# are replaced: all writes stay inside this test's disposable directory.
btrfs() {
  if [[ $1 == "subvolume" && $2 == "snapshot" ]]; then
    mkdir -p "$4"
    cp -a "$3/." "$4/"
  elif [[ $1 == "property" ]]; then
    printf '%s\n' "$6" >"$4/read-only"
  elif [[ $1 == "subvolume" && $2 == "delete" ]]; then
    command rm -rf "${@: -1}"
  else
    return 1
  fi
}
systemd-id128() { printf '%032d\n' 1; }
install_provisioning_units() { :; }
encrypted_install() { return 1; }
rebuild_next_boot() { touch "$TOP_MNT/rebuilt"; }
commit_next_boot() { :; }
sync() { :; }

userdel() {
  [[ ${FAIL_COMMAND:-} == "userdel" && $2 == "$FAIL_ROOT" ]] && return 42
  command userdel "$@"
}
usermod() {
  [[ ${FAIL_COMMAND:-} == "usermod" && $2 == "$FAIL_ROOT" ]] && return 42
  command usermod "$@"
}
rm() {
  [[ ${FAIL_COMMAND:-} == "rm" && $* == *"$FAIL_ROOT/etc/shadow-"* ]] && return 42
  command rm "$@"
}
# FAIL_MV is a pattern for the source of the renames that should fail.
mv() {
  [[ -n ${FAIL_MV:-} && $1 == $FAIL_MV ]] && return 42
  command mv "$@"
}

# The production cleanup trap runs as it would on the real top-level mount.
mountpoint() { [[ ${*: -1} == "$TOP_MNT" ]]; }
umount() { :; }
trap cleanup EXIT

stage_full_reset
SH

make_fixture() {
  local top="$1" root_hash="${2:-original-root-hash}"
  local factory="$top/@factory"
  mkdir -p "$top/@" "$factory/etc" "$factory/home/seller" \
    "$factory/usr/bin" "$factory/usr/share/omarchy/install/provisioning"
  touch "$top/@/old-system" "$factory/home/seller/private-file" \
    "$factory/usr/share/omarchy/install/provisioning/omarchy-provision-owner.service"
  printf '#!/bin/bash\n' >"$factory/usr/bin/omarchy-provision-owner"
  chmod +x "$factory/usr/bin/omarchy-provision-owner"
  mkdir -p "$factory/etc/omarchy" "$factory/etc/systemd/system" "$factory/var/lib/omarchy/usb-lock"
  cp "$ROOT/etc/systemd/system/omarchy-usb-lock.service" "$factory/etc/systemd/system/"
  cp "$ROOT/etc/systemd/system/omarchy-thunderbolt-lock.service" "$factory/etc/systemd/system/"
  mkdir -p "$factory/var/lib/omarchy/thunderbolt-lock" "$factory/var/lib/boltd/keys" "$factory/var/lib/boltd/devices"
  echo old-owner >"$factory/var/lib/omarchy/thunderbolt-lock/policy.json"
  touch "$factory/var/lib/boltd/keys/old-device" "$factory/var/lib/boltd/devices/old-device"
  touch "$factory/etc/omarchy/usb-lock.approval" "$factory/etc/omarchy/usb-lock.disabled"
  echo 'allow id 1234:5678' >"$factory/var/lib/omarchy/usb-lock/approved.conf"
  printf 'true\n' >"$factory/read-only"
  cat >"$factory/etc/passwd" <<'EOF'
root:x:0:0:root:/root:/bin/bash
daemon:x:1:1:daemon:/:/usr/bin/nologin
seller:x:1000:1000:Seller:/home/seller:/bin/bash
EOF
  printf 'root:%s:20000:0:99999:7:::\ndaemon:*:20000:0:99999:7:::\nseller:original-user-hash:20000:0:99999:7:::\n' \
    "$root_hash" >"$factory/etc/shadow"
  printf 'root:x:0:\ndaemon:x:1:\nseller:x:1000:\nwheel:x:998:seller\n' >"$factory/etc/group"
  printf 'root:!::\ndaemon:!::\nseller:!::\nwheel:!::seller\n' >"$factory/etc/gshadow"
  printf 'USERGROUPS_ENAB yes\n' >"$factory/etc/login.defs"
  printf 'seller:100000:65536\n' >"$factory/etc/subuid"
  printf 'seller:100000:65536\n' >"$factory/etc/subgid"
  chmod 600 "$factory/etc/"{shadow,gshadow}
  for file in passwd shadow group gshadow subuid subgid; do
    cp "$factory/etc/$file" "$factory/etc/$file-"
  done
}

assert_scrubbed() {
  local root="$1" vendor=${2:-} file
  assert_device_policy "$root" "$vendor"
  [[ $(awk -F: '$1 == "root" { print $2 }' "$root/etc/shadow") == "!" ]] ||
    fail "reset erases the root hash while keeping the account locked"
  ! grep -q 'original-.*-hash\|seller' "$root/etc/"{passwd,shadow,group,gshadow} ||
    fail "reset removes seller account credentials and group membership"
  [[ ! -e $root/home/seller ]] || fail "reset removes the seller's baseline home"
  grep -q '^daemon:\*:' "$root/etc/shadow" || fail "reset preserves service accounts"
  [[ $(stat -c '%a' "$root/etc/shadow") == "600" ]] || fail "shadow stays private"
  for file in passwd shadow group gshadow subuid subgid; do
    [[ ! -e $root/etc/$file- ]] || fail "reset removes the $file backup"
  done
}

assert_device_policy() {
  local root=$1 vendor=${2:-}
  [[ ! -e $root/var/lib/omarchy/usb-lock && ! -e $root/etc/omarchy/usb-lock.approval && ! -e $root/etc/omarchy/usb-lock.disabled ]] ||
    fail "reset retained previous-owner USB consent"
  [[ ! -e $root/var/lib/boltd/keys && ! -e $root/var/lib/boltd/devices ]] || fail "reset retained previous-owner Bolt keys"
  if [[ -n $vendor ]]; then
    systemctl --root "$root" is-enabled --quiet "$vendor" || fail "reset disabled independent USBGuard"
    [[ $(cat "$root/etc/usbguard/rules.conf") == 'block id 1234:5678' ]] || fail "reset changed manual USB rules"
    for name in usb thunderbolt; do
      [[ ! -e $root/etc/omarchy/$name-lock.enabled ]] || fail "reset published conflicting $name enable marker"
      if systemctl --root "$root" is-enabled --quiet "omarchy-$name-lock.service"; then
        fail "reset enabled conflicting $name service"
      fi
    done
    [[ ! -e $root/var/lib/omarchy/thunderbolt-lock/policy.json ]] || fail "reset retained Thunderbolt consent"
  else
    for name in usb thunderbolt; do
      [[ -e $root/etc/omarchy/$name-lock.enabled ]] || fail "reset lost default $name protection"
      systemctl --root "$root" is-enabled --quiet "omarchy-$name-lock.service" || fail "reset did not enable $name protection"
    done
    jq -e '.enabled and .trusted=={} and .enrolled=={}' "$root/var/lib/omarchy/thunderbolt-lock/policy.json" >/dev/null || fail "reset retained Thunderbolt consent"
  fi
}

enable_vendor() {
  local root=$1 vendor=$2
  mkdir -p "$root/etc/usbguard"
  printf 'block id 1234:5678\n' >"$root/etc/usbguard/rules.conf"
  printf '[Service]\nExecStart=/usr/bin/true\n[Install]\nWantedBy=multi-user.target\n' >"$root/etc/systemd/system/$vendor"
  systemctl --root "$root" enable "$vendor" omarchy-usb-lock.service omarchy-thunderbolt-lock.service
  touch "$root/etc/omarchy/usb-lock.enabled" "$root/etc/omarchy/thunderbolt-lock.enabled"
}

for scenario in normal locked usbguard.service usbguard-dbus.service; do
  top="$test_tmp/$scenario"
  vendor=""
  if [[ $scenario == "locked" ]]; then
    make_fixture "$top" '!'
  else
    make_fixture "$top"
  fi
  if [[ $scenario == *.service ]]; then
    vendor=$scenario
    enable_vendor "$top/@factory" "$vendor"
  fi
  bash "$test_tmp/reset" "$test_tmp" "$top" || fail "$scenario reset stages successfully"
  assert_scrubbed "$top/@factory" "$vendor"
  assert_scrubbed "$top/@" "$vendor"
  [[ $(cat "$top/@factory/read-only") == "true" ]] || fail "baseline returns to read-only"
  [[ -f $top/@/var/lib/omarchy/provisioning/pending && -f $top/rebuilt ]] ||
    fail "reset reaches provisioning after cleanup"

  bash "$test_tmp/reset" "$test_tmp" "$top" || fail "$scenario reset can be repeated"
  assert_scrubbed "$top/@factory" "$vendor"
  assert_scrubbed "$top/@" "$vendor"
  pass "$scenario reset scrubs both roots, preserves service accounts, and can be repeated"
done

# Run the actual degraded-reset worker function with filesystem paths redirected
# into a retained-root fixture. Real systemctl operates only on that root.
# The early boot service has no desktop OMARCHY_PATH environment.
for vendor in "" usbguard.service usbguard-dbus.service; do
  (
    unset OMARCHY_PATH
    top="$test_tmp/degraded-${vendor:-default}"
    make_fixture "$top"
    retained="$top/@factory"
    [[ -z $vendor ]] || enable_vendor "$retained" "$vendor"
    awk '/^scrub_legacy_degraded_state\(\)/ { copying=1 } copying { print } /^}/ { copying=0 }' \
      "$ROOT/bin/omarchy-system-factory-reset-finish" |
      sed -e "s|/etc/|$retained/etc/|g" -e "s|/var/|$retained/var/|g" \
        -e "s|/usr/share/omarchy/install/helpers/|$ROOT/install/helpers/|g" \
        -e "s|/\.snapshots/|$retained/.snapshots/|g" -e "s|reset_root / |reset_root \"$retained\" |g" >"$top/finish-functions"
    log() { :; }
    abort() { fail "$1"; }
    userdel() { command userdel --root "$retained" "$@"; }
    systemctl() {
      if [[ $1 == "--root" ]]; then command systemctl "$@"; else command systemctl --root "$retained" "$@"; fi
    }
    source "$top/finish-functions"
    scrub_legacy_degraded_state
    assert_device_policy "$retained" "$vendor"
    OMARCHY_PATH="$top/absent-checkout"
    scrub_legacy_degraded_state
    assert_device_policy "$retained" "$vendor"
    pass "degraded reset preserves ${vendor:-default protection} without a desktop environment or checkout"
  )
done

# Reset must not follow a snapshot's linked policy parent out of its root.
source "$ROOT/install/helpers/usb-lock.sh"
mkdir -p "$test_tmp/linked-root" "$test_tmp/outside/omarchy"
touch "$test_tmp/outside/omarchy/usb-lock.enabled"
ln -s "$test_tmp/outside" "$test_tmp/linked-root/etc"
if usb_lock_reset_root "$test_tmp/linked-root"; then fail "reset accepted a linked policy parent"; fi
[[ -e $test_tmp/outside/omarchy/usb-lock.enabled ]] || fail "reset changed files outside its root"
pass "device reset refuses linked policy parents before changing files"

for target in @omarchy-reset-next @factory; do
  for command in userdel usermod rm; do
    top="$test_tmp/fail-$target-$command"
    make_fixture "$top"
    if FAIL_COMMAND="$command" FAIL_ROOT="$top/$target" bash "$test_tmp/reset" "$test_tmp" "$top"; then
      fail "reset accepted failed $command in $target"
    fi
    [[ -f $top/@/old-system && ! -e $top/rebuilt ]] ||
      fail "failed cleanup must not activate or rebuild the reset system"
    [[ $(cat "$top/@factory/read-only") == "true" ]] ||
      fail "failed cleanup must leave the baseline read-only"
    pass "failed $command in $target aborts reset before activation"
  done
done

top="$test_tmp/fail-activate"
make_fixture "$top"
if FAIL_MV="$top/@omarchy-reset-next" bash "$test_tmp/reset" "$test_tmp" "$top"; then
  fail "reset accepted a failed activation"
fi
[[ -f $top/@/old-system ]] && ! compgen -G "$top/@omarchy-old-*" >/dev/null ||
  fail "a failed activation puts the running root back as @"
[[ ! -e $top/@omarchy-reset-next ]] || fail "a failed activation discards the staged root"
pass "a failed activation puts the running root back"

top="$test_tmp/fail-activate-and-restore"
make_fixture "$top"
if FAIL_MV="$top/@omarchy-*" bash "$test_tmp/reset" "$test_tmp" "$top"; then
  fail "reset accepted a failed activation"
fi
[[ ! -e $top/@ && -d $top/@omarchy-reset-next ]] && compgen -G "$top/@omarchy-old-*/old-system" >/dev/null ||
  fail "with no @ left, cleanup keeps both the running and the staged root"
pass "a root switch that cannot be undone keeps both roots for recovery"
