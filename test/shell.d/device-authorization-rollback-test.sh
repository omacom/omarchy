#!/bin/bash

set -euo pipefail
source "$(dirname "$0")/base-test.sh"
source "$ROOT/migrations/retired-device-authorization/rollback.sh"

scratch=$(mktemp -d)
trap 'rm -rf "$scratch"' EXIT
original_support=$da_support

if bash "$original_support/rollback.sh" -p rollback 0 >"$scratch/entrypoint-error" 2>&1; then
  fail "ordinary Bash with a decoy -p argument must not enter root rollback"
else
  [[ $? == 126 ]] || fail "unprotected startup is rejected before dispatch"
fi
pass "root rollback rejects an ordinary Bash launch with a decoy privileged flag"

# Relocate fixed system paths; the production functions and Bolt readback run.
for function in da_remove_usb da_remove_thunderbolt da_prepare_thunderbolt_units da_main da_clean_factory; do
  body=$(declare -f "$function")
  body=${body//\/etc\//$scratch\/etc\/}
  body=${body//\/run\//$scratch\/run\/}
  body=${body//\/sys\//$scratch\/sys\/}
  body=${body//\/proc\//$scratch\/proc\/}
  eval "$body"
done

fixture() {
  rm -rf "$scratch"/*
  mkdir -p "$scratch/etc/systemd/system/bolt.service.d" "$scratch/etc/usbguard" "$scratch/run/systemd/system" \
    "$scratch/sys/bus/usb/devices/usb1" "$scratch/sys/bus/usb/devices/1-1" "$scratch/proc" "$scratch/support"
  da_support=$scratch/support
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
      if [[ $* == *LoadState* ]]; then
        if [[ -f $scratch/missing-unit ]]; then echo not-found; else echo loaded; fi
      else
        printf '%s\n' 'ActiveState=active' 'UnitFileState=enabled'
      fi ;;
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
grep -Fq "$da_support/rollback.sh" "$unit" || fail "unit repair can retry with the original file intact"
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
cp "$ROOT/migrations/1791673477.sh" "$scratch/runtime/migrations/1791673477.sh"
cat >"$scratch/bin/sudo" <<'SH'
[[ $1 == /bin/bash && $2 == -p && $4 == rollback ]] || exit 90
echo "root rollback $5" >>"$ROLLBACK_TEST/calls"
[[ ! -f $ROLLBACK_TEST/root-failure ]]
SH
cat >"$scratch/bin/systemctl" <<'SH'
echo "$*" >>"$ROLLBACK_TEST/calls"
case $2 in
  show) echo not-found ;;
  is-active|is-enabled) exit 1 ;;
esac
SH
chmod 755 "$scratch/bin/sudo" "$scratch/bin/systemctl"
ln -s /missing/retired-unit "$scratch/home/.config/systemd/user/omarchy-usb-authorization.service"
run_migration() {
  PATH="$scratch/bin:$PATH" HOME="$scratch/home" ROLLBACK_TEST=$scratch OMARCHY_PATH="$scratch/runtime" \
    "$ROOT/bin/omarchy-migrate"
}
touch "$scratch/root-failure"
reject run_migration
[[ ! -e $scratch/home/.local/state/omarchy/migrations/1791673477.sh ]] || fail "failed root rollback must stay pending"
rm "$scratch/root-failure"
run_migration
[[ -f $scratch/home/.local/state/omarchy/migrations/1791673477.sh &&
  -L $scratch/home/.config/systemd/user/omarchy-usb-authorization.service.retired ]] || fail "successful migration retires dangling user units"
grep -q 'root rollback 1' "$scratch/calls" || fail "a dangling old watcher identifies USB enrollment"
before=$(wc -l <"$scratch/calls")
run_migration
[[ $(wc -l <"$scratch/calls") == "$before" ]] || fail "a completed migration is not run twice"
pass "migration retries root failures, handles dangling user units, and marks only complete rollback"
