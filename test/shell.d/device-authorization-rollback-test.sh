#!/bin/bash

set -euo pipefail
source "$(dirname "$0")/base-test.sh"
source "$ROOT/migrations/retired-device-authorization/rollback.sh"

scratch=$(mktemp -d)
trap 'rm -rf "$scratch"' EXIT
original_support=$da_support
root_runner=()
if (( EUID != 0 )) && unshare --user --map-root-user true 2>/dev/null; then
  root_runner=(unshare --user --map-root-user)
fi

# End the fixture after startup validation, before any real rollback work, even when this suite runs as root.
sed -e "s|source /usr/bin/omarchy-security-functions|source $ROOT/bin/omarchy-security-functions|" \
  -e '/^  \[\[ $(\/usr\/bin\/readlink /c\  exit 127' \
  "$original_support/rollback.sh" >"$scratch/entry"
chmod 755 "$scratch/entry"
printf 'set -p\n' >"$scratch/decoy"
if BASH_ENV="$scratch/decoy" "${root_runner[@]}" /bin/bash "$scratch/entry" -p rollback 0 >"$scratch/entrypoint-error" 2>&1; then
  fail "ordinary Bash with a decoy -p argument must not enter root rollback"
else
  [[ $? == 126 ]] || fail "unprotected startup is rejected before the fixture boundary"
fi
printf 'touch "%s"\n' "$scratch/injected" >"$scratch/startup"
BASH_ENV="$scratch/startup" "$scratch/entry" >/dev/null 2>&1 && fail "startup crossed the fixture boundary"
[[ ! -e $scratch/injected ]] || fail "privileged entrypoint ran BASH_ENV"
env 'BASH_FUNC_source%%=() { touch "$DA_INJECTED"; }' DA_INJECTED="$scratch/injected" \
  "$scratch/entry" >/dev/null 2>&1 && fail "exported function crossed the fixture boundary"
[[ ! -e $scratch/injected ]] || fail "privileged entrypoint imported an exported function"
pass "root rollback rejects unsafe Bash startup before the safe fixture boundary"

sed -e "s|source /usr/bin/omarchy-security-functions|source $ROOT/bin/omarchy-security-functions|" \
  -e '/^source .*thunderbolt-policy.sh/c\exit 127' \
  "$original_support/rollback.sh" >"$scratch/checkout-entry"
if "${root_runner[@]}" /bin/bash -p "$scratch/checkout-entry" guard >/dev/null 2>&1; then
  fail "root recovery accepted a checkout entrypoint"
else
  [[ $? == 126 ]] || fail "package-path enforcement must reject checkout code before the fixture boundary"
fi
pass "root recovery refuses a caller-selected checkout before loading controller code"

fixture() {
  rm -rf "$scratch"/*
  mkdir -p "$scratch/etc/systemd/system/bolt.service.d" "$scratch/etc/usbguard" "$scratch/run/systemd/system" \
    "$scratch/sys/bus/usb/devices/usb1" "$scratch/sys/bus/usb/devices/1-1" "$scratch/proc" "$scratch/support"
  da_support=$scratch/support
  DA_ROOT=$scratch DA_STATE=$scratch/var/lib/omarchy/retired-device-authorization
  mkdir -p "$scratch/var/lib/omarchy"
  touch "$scratch/etc/passwd"
  echo unit >"$scratch/etc/systemd/system/usbguard.service"
  TB_STATE=$scratch/policy.json TB_CONFIG=$scratch/boltd.conf TB_MARKER=$scratch/enabled
  TB_PENDING=$scratch/pending TB_LOCK=$scratch/root.lock TB_SERVICE=omarchy-thunderbolt-authorization.service
  : >"$scratch/proc/cmdline"
  : >"$scratch/units"
  printf '0\n' >"$scratch/sys/bus/usb/devices/usb1/authorized_default"
  printf '0\n' >"$scratch/sys/bus/usb/devices/1-1/authorized"
  cat >"$da_support/usb-boot.sh" <<'SH'
echo boot >>"${BASH_SOURCE[0]%/*}/../units"
[[ ! -f ${BASH_SOURCE[0]%/*}/../boot-failure ]]
SH
  echo '{"version":1,"enabled":true,"original_authmode":"enabled","trusted":{"ours":{"Uid":"ours","Name":"Dock","Vendor":"Vendor"}},"enrolled":{"ours":{"Uid":"ours","Name":"Dock","Vendor":"Vendor","StoreTime":100}}}' >"$TB_STATE"
  echo '[config]' >"$TB_CONFIG"
  echo 'AuthMode=disabled' >>"$TB_CONFIG"
  touch "$TB_MARKER"
  cat >"$scratch/inventory" <<'JSON'
{"owner":":1.5","manager":{"AuthMode":"disabled"},"domains":[{"Uid":"host","SysfsPath":"/sys/domain","path":"/domain","SecurityLevel":"user","BootACL":["ours",""]}],"stored":[{"Uid":"ours","Name":"Dock","Vendor":"Vendor","StoreTime":100,"Policy":"manual","path":"/ours","Key":"have","Status":"disconnected"},{"Uid":"other","Name":"Manual","Vendor":"Vendor","StoreTime":200,"Policy":"manual","path":"/other","Key":"have"}],"devices":[]}
JSON
}

edit_inventory() {
  jq "$@" "$scratch/inventory" >"$scratch/next"
  mv "$scratch/next" "$scratch/inventory"
}
tb_inventory() {
  if [[ -f $scratch/cold-boot && ! -f $scratch/bolt-started ]]; then return 1; fi
  cat "$scratch/inventory"
}
tb_properties() { jq -c --arg path "$2" '(.stored + .domains)[] | select(.path==$path)' "$scratch/inventory"; }
tb_bus() {
  local path=$3 member=$5 value
  [[ ! -f $scratch/policy-failure ]] || return 1
  if [[ $member == "Policy" ]]; then
    value=$(jq -cn --arg value "$7" '$value')
  else
    shift 7
    value=$(jq -cn '$ARGS.positional' --args "$@")
  fi
  edit_inventory --arg path "$path" --arg key "$member" --argjson value "$value" \
    '((.stored[], .domains[]) | select(.path==$path))[$key]=$value'
}
systemctl() {
  printf '%s\n' "$*" >>"$scratch/units"
  case $1 in
    show)
      case $* in
        *LoadState*) if [[ -f $scratch/missing-unit ]]; then echo not-found; else echo loaded; fi ;;
        *ActiveState*) echo active ;;
        *FragmentPath*)
          if [[ ! -f $scratch/missing-unit ]]; then
            printf '%s/etc/systemd/system/%s\n' "$scratch" "${!#}"
          fi ;;
        *) printf '%s\n' 'ActiveState=active' 'UnitFileState=enabled' ;;
      esac ;;
    stop) [[ ! -f $scratch/stop-failure ]] ;;
    is-active|is-enabled) [[ -f $scratch/stop-failure ]] ;;
    is-failed|reset-failed) [[ -f $scratch/failed-unit ]] ;;
    disable) [[ ! -f $scratch/stop-failure ]] ;;
    start)
      if [[ $2 == "bolt.service" ]]; then
        touch "$scratch/bolt-started"
        edit_inventory --arg mode "$(tb_config_authmode "$TB_CONFIG")" '.manager.AuthMode=$mode'
      fi ;;
  esac
}
reject() { if ("$@") >"$scratch/error" 2>&1; then fail "unexpected rollback success: $*"; fi; }

fixture
touch "$scratch/etc/limine-entry-tool.d-placeholder"
mkdir -p "$scratch/etc/limine-entry-tool.d"
touch "$scratch/etc/limine-entry-tool.d/usb-authorization.conf" "$scratch/boot-failure"
reject da_remove_usb 1
! grep -q 'disable.*usbguard' "$scratch/units" || fail "USB blocking stops only after permissive boot succeeds"
[[ $(<"$scratch/sys/bus/usb/devices/1-1/authorized") == "0" ]] || fail "failed boot rollback must not authorize devices"
rm "$scratch/boot-failure"
da_remove_usb 1
[[ $(<"$scratch/sys/bus/usb/devices/usb1/authorized_default") == "1" &&
  $(<"$scratch/sys/bus/usb/devices/1-1/authorized") == "1" ]] || fail "USB rollback restores root hubs and connected devices"
da_remove_usb 1
pass "USB rollback verifies boot before stopping protection and can retry"

fixture
touch "$scratch/stop-failure"
reject da_remove_usb 1
[[ $(<"$scratch/sys/bus/usb/devices/1-1/authorized") == "0" ]] || fail "a failed USBGuard stop retains device authorization"
pass "USB rollback fails if USBGuard is still active"

fixture
da_remove_usb 0
! grep -q 'usbguard' "$scratch/units" || fail "an unrelated USBGuard install is left alone"
echo 'allow id 1234:0001 label "omarchy-usb-authorization-v1"' >"$scratch/etc/usbguard/rules.conf"
da_remove_usb 0
grep -q 'disable.*usbguard' "$scratch/units" || fail "Omarchy policy identifies machine-wide USB setup"
pass "USB rollback targets Omarchy enrollment"

fixture
echo() {
  if [[ ${1:-} == "1" && -n ${attribute:-} ]]; then
    rm -- "$attribute"
    return 1
  fi
  builtin echo "$@"
}
da_remove_usb 1
unset -f echo
pass "USB devices disappearing during live authorization do not fail rollback"

fixture
echo usbcore.authorized_default=0 >"$scratch/proc/cmdline"
da_remove_usb 0
! grep -q 'usbguard\|boot' "$scratch/units" || fail "a manual kernel parameter must not identify Omarchy policy"
pass "manual USB boot and USBGuard policy remain untouched"

fixture
mkdir -p "$scratch/etc/limine-entry-tool.d"
touch "$scratch/etc/limine-entry-tool.d/usb-authorization.conf" "$scratch/boot-failure"
reject da_remove_usb 0
rm "$scratch/etc/limine-entry-tool.d/usb-authorization.conf" "$scratch/boot-failure"
da_remove_usb 0
grep -q '^boot$' "$scratch/units" || fail "the root checkpoint must recover an interrupted boot removal"
[[ ! -e $DA_STATE/usb-boot-pending ]] || fail "verified images clear the boot checkpoint"
pass "Omarchy boot rollback can retry after its drop-in disappears"

fixture
touch "$scratch/missing-unit"
mkdir -p "$scratch/etc/systemd/system/multi-user.target.wants"
ln -s /missing/unit "$scratch/etc/systemd/system/multi-user.target.wants/usbguard.service"
da_stop_unit usbguard.service system "$DA_ROOT"
grep -q '^stop usbguard.service$' "$scratch/units" || fail "a running not-found unit must still be stopped"
[[ ! -L $scratch/etc/systemd/system/multi-user.target.wants/usbguard.service ]] || fail "dangling enable links must be removed"
pass "retired units stop and lose enable links even after their fragments disappear"

fixture
printf '%s\n' '[Service]' 'ExecStartPre=/usr/bin/omarchy-thunderbolt-authorization-admin guard' >"$scratch/etc/systemd/system/bolt.service.d/omarchy-authorization.conf"
touch "$scratch/cold-boot"
da_remove_thunderbolt
jq -e '.enabled==false and .enrolled==null' "$TB_STATE" >/dev/null || fail "Thunderbolt state is disabled"
jq -e '.manager.AuthMode=="enabled" and .stored[0].Policy=="auto" and .stored[1].Policy=="manual" and all(.stored[]; .Key=="have")' \
  "$scratch/inventory" >/dev/null || fail "handoff preserves independent manual policies and keys, including disconnected accessories"
[[ ! -f $TB_MARKER && -f $scratch/etc/systemd/system/bolt.service.d/omarchy-authorization.conf.retired ]] || fail "obsolete Bolt guard is archived"
da_remove_thunderbolt
pass "Thunderbolt rollback hands our records to Bolt and preserves manual policies and keys"

fixture
jq '.enabled=false' "$TB_STATE" >"$scratch/next"; mv "$scratch/next" "$TB_STATE"
rm "$TB_MARKER"
da_remove_thunderbolt
! grep -q '^start bolt.service$' "$scratch/units" || fail "previous opt-out must not start an independently stopped Bolt service"
pass "already removed Thunderbolt protection preserves Bolt service state"

fixture
touch "$scratch/policy-failure"
reject da_remove_thunderbolt
jq -e .enabled "$TB_STATE" >/dev/null || fail "failed handoff preserves active protection"
[[ -f $TB_MARKER ]] || fail "failed handoff retains the marker"
rm "$scratch/policy-failure"
da_remove_thunderbolt
pass "Thunderbolt rollback failure remains recoverable and retry succeeds"

fixture
jq '.domains[0].SysfsPath=""' "$scratch/inventory" >"$scratch/next"; mv "$scratch/next" "$scratch/inventory"
reject da_remove_thunderbolt
jq -e '.enabled' "$TB_STATE" >/dev/null || fail "missing controllers must not silently discard firmware recovery"
pass "Thunderbolt rollback requires original controllers for a verified handoff"

fixture
unit=$scratch/etc/systemd/system/omarchy-thunderbolt-authorization.service
printf '[Service]\nExecStart=/usr/bin/omarchy-thunderbolt-authorization-daemon\n' >"$unit"
original_unit=$(<"$unit")
mv() { return 1; }
reject da_prepare_thunderbolt_units
[[ $(<"$unit") == "$original_unit" ]] || fail "failed unit publication must not truncate the controller"
unset -f mv
da_prepare_thunderbolt_units
grep -Fq "/usr/share/omarchy/migrations/retired-device-authorization/rollback.sh" "$unit" || fail "unit repair can retry with the original file intact"
pass "Thunderbolt unit write failures preserve the controller and permit retry"

fixture
factory=$scratch/factory
mkdir -p "$factory/usr/bin" "$factory/usr/share/omarchy/install/user/first-run" "$factory/usr/share/omarchy/migrations"
cat >"$factory/usr/bin/omarchy-provision-owner" <<'SH'
  if luks_staged_unlock_remains; then return 1; fi
  if omarchy-pkg-present usbguard; then
    log_step "enrolling the owner's USB devices"
    source "$OMARCHY_PATH/install/helpers/usb-authorization.sh"
    usb_authorization_provision_owner "$username"
  fi

  log_step "enrolling the owner's Thunderbolt accessories"
  /usr/bin/omarchy-thunderbolt-authorization-admin owner

  cleanup_oem_state
SH
cat >"$factory/usr/share/omarchy/install/user/first-run/enable-user-units.sh" <<'SH'
for unit in \
  bt-agent.service \
  omarchy-crash-watch.service \
  omarchy-usb-authorization.service \
  omarchy-thunderbolt-authorization.service; do
  systemctl --user enable --now "$unit" || failed=1
done
SH
touch "$factory/usr/share/omarchy/migrations/1789433473.sh"
original_owner=$(<"$factory/usr/bin/omarchy-provision-owner")
mv() { return 1; }
reject da_factory_enrollment "$factory"
[[ $(<"$factory/usr/bin/omarchy-provision-owner") == "$original_owner" ]] || fail "failed publication must not truncate factory provisioning"
unset -f mv
pass "factory script publication failures are reported and leave the original intact"
da_factory_enrollment "$factory"
da_factory_enrollment "$factory"
! grep -Eq 'usb_authorization|thunderbolt-authorization' "$factory/usr/bin/omarchy-provision-owner" || fail "factory reset must not reenroll accessories"
grep -q luks_staged_unlock_remains "$factory/usr/bin/omarchy-provision-owner" || fail "factory repair preserves LUKS completion guard"
bash -n "$factory/usr/share/omarchy/install/user/first-run/enable-user-units.sh"
[[ ! -e $factory/usr/share/omarchy/migrations/1789433473.sh ]] || fail "factory repair removes retired enrollment migrations"
pass "factory reset preserves provisioning guards and cannot reenroll retired protection"

cat >"$factory/usr/share/omarchy/install/user/first-run/enable-user-units.sh" <<'SH'
systemctl --user enable --now \
  bt-agent.service \
  omarchy-crash-watch.service \
  omarchy-usb-authorization.service \
  omarchy-thunderbolt-authorization.service
SH
da_factory_enrollment "$factory"
! grep -q 'authorization.service' "$factory/usr/share/omarchy/install/user/first-run/enable-user-units.sh" || fail "the released batch form must also be repaired"
bash -n "$factory/usr/share/omarchy/install/user/first-run/enable-user-units.sh"
pass "factory repair covers the original released batch startup and the later per-unit form"

fixture
da_support=$original_support
TB_STATE=/var/lib/omarchy/thunderbolt-authorization/policy.json
TB_CONFIG=/var/lib/boltd/boltd.conf TB_MARKER=/etc/omarchy/thunderbolt-authorization.enabled
TB_PENDING=/etc/omarchy/thunderbolt-authorization.pending
mkdir -p "$scratch/factory/var/lib/boltd" "$scratch/factory/var/lib/omarchy/thunderbolt-authorization" "$scratch/factory/etc/omarchy"
printf '[config]\nAuthMode=disabled\n' >"$scratch/factory/var/lib/boltd/boltd.conf"
echo '{"original_authmode":"disabled"}' >"$scratch/factory/var/lib/omarchy/thunderbolt-authorization/policy.json"
touch "$scratch/factory/etc/omarchy/thunderbolt-authorization.enabled"
echo true >"$scratch/factory-ro"
findmnt() { if [[ $* == *FSTYPE* ]]; then echo btrfs; else echo /dev/fixture; fi; }
mount() {
  cp -a "$scratch/factory" "${!#}/@factory"
  if [[ -f $scratch/ro-checkpoint ]]; then cp "$scratch/ro-checkpoint" "${!#}/.omarchy-accessory-rollback-factory-ro"; fi
}
umount() {
  rm -rf "$scratch/factory"
  cp -a "$1/@factory" "$scratch/factory"
  rm -rf "$1/@factory"
  if [[ -f $1/.omarchy-accessory-rollback-factory-ro ]]; then
    mv "$1/.omarchy-accessory-rollback-factory-ro" "$scratch/ro-checkpoint"
  else
    rm -f "$scratch/ro-checkpoint"
  fi
}
btrfs() {
  if [[ $1 == property && $2 == get ]]; then echo "ro=$(<"$scratch/factory-ro")"; fi
  if [[ $1 == property && $2 == set ]]; then
    if [[ ${!#} == "true" && -f $scratch/ro-failure ]]; then return 1; fi
    echo "${!#}" >"$scratch/factory-ro"
  fi
}
eval "$(declare -f tb_config_write | sed '1s/tb_config_write/real_tb_config_write/')"
tb_config_write() {
  if [[ $2 == "disabled" && -f $scratch/config-failure ]]; then return 1; fi
  real_tb_config_write "$@"
}
touch "$scratch/config-failure"
reject da_clean_factory
[[ -f $scratch/factory/var/lib/omarchy/thunderbolt-authorization/policy.json &&
  $(tb_config_authmode "$scratch/factory/var/lib/boltd/boltd.conf") == "disabled" ]] || fail "failed mode restoration must preserve recovery data and disabled policy"
rm "$scratch/config-failure"
pass "factory mode restoration failure retains its original policy for retry"
da_clean_factory
da_clean_factory
[[ $(tb_config_authmode "$scratch/factory/var/lib/boltd/boltd.conf") == "disabled" &&
  $(<"$scratch/factory-ro") == "true" ]] || fail "factory cleanup preserves disabled Bolt mode and read-only status on every pass"
pass "factory rollback retries without enabling an originally disabled Bolt policy or requiring Limine"

touch "$scratch/ro-failure"
reject da_clean_factory
[[ $(<"$scratch/factory-ro") == "false" ]] || fail "fixture exercises failed read-only restoration"
rm "$scratch/ro-failure"
da_clean_factory
[[ $(<"$scratch/factory-ro") == "true" ]] || fail "factory read-only repair can retry"
pass "factory read-only restoration failure blocks migration completion"

mkdir -p "$scratch/factory/usr/share/omarchy" "$scratch/outside/user/first-run"
echo 'keep outside snapshot' >"$scratch/outside/user/first-run/enable-user-units.sh"
ln -s "$scratch/outside" "$scratch/factory/usr/share/omarchy/install"
reject da_clean_factory
[[ $(<"$scratch/outside/user/first-run/enable-user-units.sh") == "keep outside snapshot" ]] || fail "factory rollback must not follow external directory links"
pass "factory rollback rejects linked directories before writing outside the snapshot"

rm "$scratch/factory/usr/share/omarchy/install"
mkdir -p "$scratch/factory/etc/default" "$scratch/factory/etc/limine-entry-tool.d"
printf '%s\n' keep '# Omarchy USB authorization begin' 'SNAPSHOT_KERNEL_PARAMETERS+=usbcore.authorized_default=0' '# Omarchy USB authorization end' >"$scratch/factory/etc/default/limine"
printf '%s\n' 'KERNEL_CMDLINE[default]+=" usbcore.authorized_default=0"' >"$scratch/factory/etc/limine-entry-tool.d/usb-authorization.conf"
da_clean_factory
[[ $(<"$scratch/factory/etc/default/limine") == "keep" && ! -e $scratch/factory/etc/limine-entry-tool.d/usb-authorization.conf ]] || fail "factory boot configuration must be repaired inside the actual snapshot root"
pass "factory cleanup reaches the snapshot's own Limine files"

fixture
(
  da_remove_thunderbolt() { echo thunderbolt >>"$scratch/order"; return 1; }
  da_remove_usb() { echo usb >>"$scratch/order"; return 1; }
  da_clean_factory() { echo factory >>"$scratch/order"; return 1; }
  reject da_main 0
  [[ $(<"$scratch/order") == $'thunderbolt\nusb\nfactory' ]] || fail "independent rollback must continue after a failure"
  [[ ! -e $DA_STATE/completed ]] || fail "partial rollback must not publish completion"
)
pass "independent live and factory repairs run despite another subsystem's failure"

fixture
mkdir -p "$scratch/home/.local/state/omarchy/usb-authorization" "$scratch/etc/usbguard/IPCAccessControl.d"
printf 'fixture:x:1000:1000::%s:/bin/bash\ncustom:x:1001:1001::%s:/bin/bash\n' "$scratch/home" "$scratch/home" >"$scratch/etc/passwd"
printf 'Devices=list,modify,listen\nPolicy=list\nExceptions=listen\n' >"$scratch/etc/usbguard/IPCAccessControl.d/fixture"
echo 'Devices=list' >"$scratch/etc/usbguard/IPCAccessControl.d/custom"
da_retire_usb_access
[[ -f $DA_STATE/ipc/fixture && ! -e $scratch/etc/usbguard/IPCAccessControl.d/fixture && -f $scratch/etc/usbguard/IPCAccessControl.d/custom ]] || fail "only identified Omarchy IPC grants are retired"
pass "retired IPC grants are archived outside USBGuard while custom permissions survive"

fixture
source "$original_support/usb-boot.sh"
printf '%s\n' 'keep existing boot settings' "$snapshot_begin" "$snapshot_setting" "$snapshot_end" >"$scratch/limine-defaults"
cp "$scratch/limine-defaults" "$scratch/original-defaults"
awk() {
  if [[ $* == *'skip = 2'* ]]; then
    echo 'partial boot settings'
    return 1
  fi
  command awk "$@"
}
reject usb_authorization_disable_snapshot_setting "$scratch/limine-defaults"
cmp "$scratch/limine-defaults" "$scratch/original-defaults" || fail "failed Limine rewrite must not replace the original with partial output"
unset -f awk
usb_authorization_disable_snapshot_setting "$scratch/limine-defaults"
[[ $(<"$scratch/limine-defaults") == "keep existing boot settings" ]] || fail "Limine rewrite preserves unrelated boot settings on retry"
pass "Limine rewrite write failures retain the original boot configuration and can retry"

fixture
mkdir -p "$scratch/bin" "$scratch/runtime/migrations" "$scratch/home/.config/systemd/user"
sed -e "s|/var/lib/omarchy/retired-device-authorization|$scratch/root-state|g" \
  -e "s|/var/lib/omarchy/thunderbolt-authorization|$scratch/system-thunderbolt|g" \
  -e "s|/etc/|$scratch/etc/|g" \
  -e "s|/usr/share/polkit-1/|$scratch/polkit/|g" \
  "$ROOT/migrations/1791673477.sh" >"$scratch/runtime/migrations/1791673477.sh"
mkdir -p "$scratch/runtime/migrations/retired-device-authorization"
cp "$ROOT/migrations/retired-device-authorization/units.sh" "$scratch/runtime/migrations/retired-device-authorization/"
cat >"$scratch/bin/omarchy-notification-dismiss" <<'SH'
exit 0
SH
cat >"$scratch/bin/sudo" <<'SH'
[[ $1 == /bin/bash && $2 == -p && $4 == rollback ]] || exit 90
echo "root rollback $5" >>"$ROLLBACK_TEST/calls"
[[ ! -f $ROLLBACK_TEST/root-failure ]]
SH
cat >"$scratch/bin/systemctl" <<'SH'
echo "$*" >>"$ROLLBACK_TEST/calls"
case $2 in
  show)
    if [[ $* == *ActiveState* && ! -f $ROLLBACK_TEST/user-stopped-${!#} ]]; then echo active; fi ;;
  stop) touch "$ROLLBACK_TEST/user-stopped-${!#}" ;;
  is-active|is-enabled) exit 1 ;;
esac
SH
sed -e "s|/var/lib/pacman/db.lck|$scratch/no-pacman-lock|" "$ROOT/bin/omarchy-migrate" >"$scratch/bin/migrator"
chmod 755 "$scratch/bin/"*
ln -s /missing/retired-unit "$scratch/home/.config/systemd/user/omarchy-usb-authorization.service"
mkdir -p "$scratch/home/.config/systemd/user/default.target.wants"
ln -s /missing/retired-unit "$scratch/home/.config/systemd/user/default.target.wants/omarchy-thunderbolt-authorization.service"
run_migration() {
  PATH="$scratch/bin:$PATH" HOME="$scratch/home" ROLLBACK_TEST=$scratch OMARCHY_PATH="$scratch/runtime" \
    "$scratch/bin/migrator"
}
touch "$scratch/root-failure"
reject run_migration
[[ $(grep '^root rollback' "$scratch/calls") == "root rollback 0" ]] || fail "a watcher alone must not identify ownership of a manual USB policy"
[[ ! -e $scratch/home/.local/state/omarchy/migrations/1791673477.sh ]] || fail "failed root rollback must stay pending"
[[ -f $scratch/home/.local/state/omarchy/device-authorization-rollback-pending &&
  -L $scratch/home/.config/systemd/user/omarchy-usb-authorization.service.retired ]] || fail "root failures must still clean watchers and retain a retry checkpoint"
rm "$scratch/root-failure"
run_migration
[[ -f $scratch/home/.local/state/omarchy/migrations/1791673477.sh &&
  -L $scratch/home/.config/systemd/user/omarchy-usb-authorization.service.retired ]] || fail "successful migration retires dangling user units"
grep -q 'root rollback 0' "$scratch/calls" || fail "a watcher alone must not identify ownership of a manual USB policy"
grep -q -- '--user stop omarchy-thunderbolt-authorization.service' "$scratch/calls" || fail "the not-found running Thunderbolt watcher must stop"
[[ ! -L $scratch/home/.config/systemd/user/default.target.wants/omarchy-thunderbolt-authorization.service ]] || fail "the user watcher must lose its dangling enable link"
before=$(wc -l <"$scratch/calls")
run_migration
[[ $(wc -l <"$scratch/calls") == "$before" ]] || fail "a completed migration is not run twice"
pass "migration retries root failures, handles dangling user units, and marks only complete rollback"

mkdir -p "$scratch/root-state"
echo 'Omarchy accessory rollback complete' >"$scratch/root-state/completed"
chmod 644 "$scratch/root-state/completed"
stat() { if [[ $* == *root-state/completed* ]]; then echo 0:644; else command stat "$@"; fi; }
export -f stat
HOME="$scratch/another-home" PATH="$scratch/bin:$PATH" OMARCHY_PATH="$scratch/runtime" ROLLBACK_TEST=$scratch \
  bash -euo pipefail "$scratch/runtime/migrations/1791673477.sh"
unset -f stat
[[ $(grep -c '^root rollback' "$scratch/calls") == 2 ]] || fail "a completed machine must not ask another user for sudo"
pass "machine completion allows later users to clean their units without sudo"

rm "$scratch/root-state/completed"
rmdir "$scratch/root-state"
HOME="$scratch/fresh-home" PATH="$scratch/bin:$PATH" OMARCHY_PATH="$scratch/runtime" ROLLBACK_TEST=$scratch \
  bash -euo pipefail "$scratch/runtime/migrations/1791673477.sh"
[[ $(grep -c '^root rollback' "$scratch/calls") == 2 ]] || fail "fresh machines with no retired state must not prompt for sudo"
pass "fresh machines with no retired state need no root action"
