#!/bin/bash

set -euo pipefail
source "$(dirname "$0")/base-test.sh"
source "$ROOT/install/helpers/thunderbolt-policy.sh"
source "$ROOT/install/helpers/thunderbolt-setup.sh"
source "$ROOT/bin/omarchy-usb-authorization-boot"
source "$ROOT/install/helpers/accessory-authorization-rollback-root.sh"
source "$ROOT/install/helpers/accessory-authorization-rollback.sh"

scratch=$(mktemp -d)
trap 'rm -rf "$scratch"' EXIT

# Relocate the temporary factory mount; no host mount or sysfs write runs.
body=$(declare -f accessory_clean_factory)
body=${body//\/run\//$scratch\/run\/}
eval "$body"
body=$(declare -f accessory_remove_usb)
body=${body//\/etc\//$scratch\/etc\/}
eval "$body"

fixture() {
  rm -rf "$scratch"/*
  mkdir -p "$scratch/etc/systemd/system/bolt.service.d" "$scratch/etc/usbguard" "$scratch/run/systemd/system" \
    "$scratch/sys/bus/usb/devices/usb1" "$scratch/sys/bus/usb/devices/1-1" "$scratch/proc" "$scratch/support"
  ACCESSORY_USB_REVERTED=$scratch/etc/usb-reverted
  ACCESSORY_USB_RULES=$scratch/etc/usbguard/rules.conf
  ACCESSORY_USER_HOME=$scratch/user
  mkdir -p "$ACCESSORY_USER_HOME/.config/systemd/user/graphical-session.target.wants" \
    "$ACCESSORY_USER_HOME/.local/state/omarchy/migrations"
  drop_in=$scratch/etc/usb-boot
  limine_defaults=$scratch/etc/limine-defaults
  TB_STATE=$scratch/policy.json TB_CONFIG=$scratch/boltd.conf TB_MARKER=$scratch/enabled
  TB_PENDING=$scratch/pending TB_LOCK=$scratch/root.lock TB_SERVICE=omarchy-thunderbolt-authorization.service
  : >"$scratch/proc/cmdline"
  : >"$scratch/units"
  printf '0\n' >"$scratch/sys/bus/usb/devices/usb1/authorized_default"
  printf '0\n' >"$scratch/sys/bus/usb/devices/1-1/authorized"
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
    --user)
      case $2 in
        show) if [[ -e $ACCESSORY_USER_HOME/.config/systemd/user/$3 ]]; then echo loaded; else echo not-found; fi ;;
        disable) rm -f "$ACCESSORY_USER_HOME/.config/systemd/user/graphical-session.target.wants/${!#}" ;;
        is-active) return 3 ;;
        daemon-reload) return 0 ;;
        *) return 91 ;;
      esac ;;
    show)
      if [[ $* == *LoadState* ]]; then
        if [[ -f $scratch/missing-unit ]]; then echo not-found; else echo loaded; fi
      else
        printf '%s\n' 'ActiveState=active' 'UnitFileState=enabled'
      fi ;;
    is-active|is-enabled)
      [[ -f $scratch/stop-failure || ( ${!#} == "usbguard.service" && -f $scratch/manual-usbguard-active ) ]] ;;
    is-failed|reset-failed) [[ -f $scratch/failed-unit ]] ;;
    disable)
      [[ ! -f $scratch/stop-failure ]] || return 1
      if [[ ${!#} == "usbguard.service" ]]; then rm -f "$scratch/manual-usbguard-active"; fi ;;
    start)
      if [[ $2 == "bolt.service" ]]; then
        touch "$scratch/bolt-started"
        edit_inventory --arg mode "$(tb_config_authmode "$TB_CONFIG")" '.manager.AuthMode=$mode'
      fi ;;
  esac
}
sudo() {
  if [[ $1 == "$ACCESSORY_ROOT_ADMIN" ]]; then
    echo "root $2" >>"$scratch/units"
    accessory_rollback_root "$2"
  else
    case $1 in
      systemctl) shift; systemctl "$@" ;;
      omarchy-usb-authorization-boot) shift; /usr/bin/omarchy-usb-authorization-boot "$@" ;;
      omarchy-usb-authorization-restore-default) /usr/bin/omarchy-usb-authorization-restore-default ;;
      test) return 1 ;;
      *) return 91 ;;
    esac
  fi
}
omarchy-pkg-present() { [[ $1 == "usbguard" ]]; }
# The full root dispatcher sees a non-Btrfs fixture until the factory cases.
findmnt() { [[ $* == *FSTYPE* ]] || return 91; echo ext4; }
reject() { if ("$@") >"$scratch/error" 2>&1; then fail "unexpected rollback success: $*"; fi; }

function /usr/bin/omarchy-usb-authorization-boot() {
  [[ $* == disable ]] || return 90
  echo boot >>"$scratch/units"
  [[ ! -f $scratch/boot-failure ]]
}
function /usr/bin/omarchy-usb-authorization-restore-default() {
  echo 1 >"$scratch/sys/bus/usb/devices/usb1/authorized_default"
  echo 1 >"$scratch/sys/bus/usb/devices/1-1/authorized"
}

for history in first-install removed; do
  fixture
  rm "$TB_STATE" "$TB_MARKER"
  migration_marker=$ACCESSORY_USER_HOME/.local/state/omarchy/migrations/1789433473.sh
  touch "$migration_marker"
  if [[ $history == "removed" ]]; then
    state_dir=$ACCESSORY_USER_HOME/.local/state/omarchy/usb-authorization
    unit_dir=$ACCESSORY_USER_HOME/.config/systemd/user
    mkdir -p "$state_dir/requests"
    touch "$state_dir/package-installed-by-omarchy" "$state_dir/policy-generated-by-omarchy" \
      "$state_dir/service-enabled-by-omarchy" "$state_dir/requests/.lock" "$unit_dir/omarchy-usb-authorization.service"
    ln -s ../omarchy-usb-authorization.service "$unit_dir/graphical-session.target.wants/omarchy-usb-authorization.service"
    # Relocate only HOME references; execute the actual removal's file cleanup.
    sed 's/\$HOME/\$ACCESSORY_USER_HOME/g' "$ROOT/bin/omarchy-remove-security-usb-authorization" >"$scratch/remove"
    (source "$scratch/remove" --yes) >"$scratch/remove-output"
    [[ -f $migration_marker && ! -e $state_dir && ! -e $unit_dir/omarchy-usb-authorization.service &&
      ! -L $unit_dir/graphical-session.target.wants/omarchy-usb-authorization.service ]] || fail "removal fixture must retain only migration history"
  fi
  printf '%s\n' 'allow id 1234:0001 serial "independent"' 'block' >"$ACCESSORY_USB_RULES"
  cp "$ACCESSORY_USB_RULES" "$scratch/manual-rules"
  touch "$scratch/manual-usbguard-active"
  echo 0 >"$scratch/sys/bus/usb/devices/usb1/authorized_default"
  echo 0 >"$scratch/sys/bus/usb/devices/1-1/authorized"
  : >"$scratch/units"
  accessory_authorization_rollback
  accessory_authorization_rollback
  [[ -f $scratch/manual-usbguard-active && ! -e $ACCESSORY_USB_REVERTED &&
    $(<"$scratch/sys/bus/usb/devices/usb1/authorized_default") == "0" &&
    $(<"$scratch/sys/bus/usb/devices/1-1/authorized") == "0" ]] || fail "$history migration history must not disable independent USB protection"
  cmp "$ACCESSORY_USB_RULES" "$scratch/manual-rules" || fail "manual rules must remain unchanged"
  grep -qx 'root 0' "$scratch/units" || fail "root recovery must still run without current USB enrollment"
  [[ -f $migration_marker ]] || fail "rollback must preserve migration history"
  pass "$history migration history preserves independent USB protection on repeated rollback"
done

for evidence in watcher wants state rules empty-rules boot snapshot; do
  fixture
  rm "$TB_STATE" "$TB_MARKER"
  unit_dir=$ACCESSORY_USER_HOME/.config/systemd/user
  case $evidence in
    watcher) touch "$unit_dir/omarchy-usb-authorization.service" ;;
    wants) ln -s ../omarchy-usb-authorization.service "$unit_dir/graphical-session.target.wants/omarchy-usb-authorization.service" ;;
    state) mkdir -p "$ACCESSORY_USER_HOME/.local/state/omarchy/usb-authorization" ;;
    rules) echo 'allow id 1234:0001 label "omarchy-usb-authorization-v1"' >"$ACCESSORY_USB_RULES" ;;
    empty-rules) echo '# No USB devices were present during enrollment.' >"$ACCESSORY_USB_RULES" ;;
    boot) touch "$drop_in" ;;
    snapshot) printf '%s\n' "$snapshot_begin" "$snapshot_setting" "$snapshot_end" >"$limine_defaults" ;;
  esac
  accessory_authorization_rollback
  [[ -e $ACCESSORY_USB_REVERTED && $(<"$scratch/sys/bus/usb/devices/usb1/authorized_default") == "1" &&
    $(<"$scratch/sys/bus/usb/devices/1-1/authorized") == "1" ]] || fail "$evidence enrollment must still restore USB access"
  grep -qx 'disable --now usbguard.service' "$scratch/units" || fail "$evidence enrollment must still disable USBGuard"
  pass "current $evidence evidence still rolls back Omarchy USB protection without migration history"
done

fixture
touch "$scratch/etc/limine-entry-tool.d-placeholder"
mkdir -p "$scratch/etc/limine-entry-tool.d"
touch "$drop_in" "$scratch/boot-failure"
reject accessory_remove_usb 1
! grep -q 'disable.*usbguard' "$scratch/units" || fail "USB blocking stops only after permissive boot succeeds"
[[ $(<"$scratch/sys/bus/usb/devices/1-1/authorized") == "0" ]] || fail "failed boot rollback must not authorize devices"
rm "$scratch/boot-failure"
accessory_remove_usb 1
[[ $(<"$scratch/sys/bus/usb/devices/usb1/authorized_default") == "1" &&
  $(<"$scratch/sys/bus/usb/devices/1-1/authorized") == "1" ]] || fail "USB rollback restores root hubs and connected devices"
accessory_remove_usb 1
pass "USB rollback verifies boot before stopping protection and can retry"

fixture
touch "$scratch/stop-failure"
reject accessory_remove_usb 1
[[ $(<"$scratch/sys/bus/usb/devices/1-1/authorized") == "0" ]] || fail "a failed USBGuard stop retains device authorization"
pass "USB rollback fails if USBGuard is still active"

fixture
accessory_remove_usb 0
! grep -q 'usbguard' "$scratch/units" || fail "an unrelated USBGuard install is left alone"
echo 'allow id 1234:0001 label "omarchy-usb-authorization-v1"' >"$scratch/etc/usbguard/rules.conf"
accessory_remove_usb 0
grep -q 'disable.*usbguard' "$scratch/units" || fail "Omarchy policy identifies machine-wide USB setup"
pass "USB rollback targets Omarchy enrollment"

fixture
printf '%s\n' '[Service]' 'ExecStartPre=/usr/bin/omarchy-thunderbolt-authorization-admin guard' >"$scratch/etc/systemd/system/bolt.service.d/omarchy-authorization.conf"
touch "$scratch/cold-boot"
accessory_remove_thunderbolt
jq -e '.enabled==false and .enrolled==null' "$TB_STATE" >/dev/null || fail "Thunderbolt state is disabled"
jq -e '.manager.AuthMode=="enabled" and .stored[0].Policy=="auto" and .stored[1].Policy=="manual" and all(.stored[]; .Key=="have")' \
  "$scratch/inventory" >/dev/null || fail "handoff preserves independent manual policies and keys, including disconnected accessories"
[[ ! -f $TB_MARKER ]] || fail "enrollment marker is removed"
accessory_remove_thunderbolt
pass "Thunderbolt rollback hands our records to Bolt and preserves manual policies and keys"

fixture
jq '.enabled=false' "$TB_STATE" >"$scratch/next"; mv "$scratch/next" "$TB_STATE"
rm "$TB_MARKER"
accessory_remove_thunderbolt
! grep -q '^start bolt.service$' "$scratch/units" || fail "previous opt-out must not start an independently stopped Bolt service"
pass "already removed Thunderbolt protection preserves Bolt service state"

fixture
touch "$scratch/policy-failure"
reject accessory_remove_thunderbolt
jq -e .enabled "$TB_STATE" >/dev/null || fail "failed handoff preserves active protection"
[[ -f $TB_MARKER ]] || fail "failed handoff retains the marker"
rm "$scratch/policy-failure"
accessory_remove_thunderbolt
pass "Thunderbolt rollback failure remains recoverable and retry succeeds"

fixture
jq '.domains[0].SysfsPath=""' "$scratch/inventory" >"$scratch/next"; mv "$scratch/next" "$scratch/inventory"
reject accessory_remove_thunderbolt
jq -e '.enabled' "$TB_STATE" >/dev/null || fail "missing controllers must not silently discard firmware recovery"
pass "Thunderbolt rollback requires original controllers for a verified handoff"


fixture
# Reproduce marker deletion followed by a failed state write and failed restore.
eval "$(declare -f tb_json_write | sed '1s/tb_json_write/real_tb_json_write/')"
tb_json_write() {
  if [[ $1 == "$TB_STATE" && -f $scratch/state-write-failure ]]; then return 1; fi
  real_tb_json_write "$@"
}
mv() {
  if [[ ${!#} == "$TB_STATE" && -f $scratch/state-write-failure ]]; then return 1; fi
  command mv "$@"
}
touch "$scratch/state-write-failure"
reject accessory_remove_thunderbolt
[[ ! -e $TB_MARKER && -f $scratch/setup-recovery.json ]] || fail "fixture must reach missing-marker recovery state"
reject accessory_authorization_rollback
[[ -f $scratch/setup-recovery.json ]] || fail "repeated failure must retain recovery data"
rm "$scratch/state-write-failure"
accessory_authorization_rollback
grep -qx 'root 0' "$scratch/units" || fail "missing USB evidence must not skip Thunderbolt recovery"
[[ ! -e $scratch/setup-recovery.json && ! -e $TB_MARKER ]] || fail "successful retry must complete recovery and removal"
jq -e '.enabled==false' "$TB_STATE" >/dev/null || fail "recovered policy must finish disabled"
jq -e '.manager.AuthMode=="enabled" and .stored[0].Policy=="auto" and .stored[1].Policy=="manual"' "$scratch/inventory" >/dev/null || fail "recovery must complete the verified policy handoff"
unset -f mv tb_json_write
# Restore the production writer for subsequent cases.
eval "$(declare -f real_tb_json_write | sed '1s/real_tb_json_write/tb_json_write/')"
pass "markerless interrupted removal remains pending until saved recovery and handoff succeed"

fixture
saved=$(tb_boot_saved <"$scratch/inventory" | jq -c --argjson state "$(cat "$TB_STATE")" '. + {state:$state}')
printf '%s\n' "$saved" >"$scratch/boot-recovery.json"
rm "$TB_MARKER"
touch "$scratch/cold-boot"
accessory_authorization_rollback
grep -qx 'root 0' "$scratch/units" || fail "missing USB evidence must not skip boot recovery"
[[ ! -e $scratch/boot-recovery.json && ! -e $TB_MARKER ]] || fail "boot-only recovery without a marker must complete"
jq -e '.enabled==false' "$TB_STATE" >/dev/null || fail "boot recovery must finish removal"
pass "boot recovery without enrollment markers starts Bolt and completes removal"

fixture
rm "$TB_STATE" "$TB_MARKER"
touch "$TB_PENDING"
accessory_remove_thunderbolt
[[ ! -f $TB_PENDING ]] || fail "pending enrollment must be canceled"
! grep -q '^start bolt.service$' "$scratch/units" || fail "canceling deferred enrollment must not start Bolt"
pass "pending enrollment is canceled without enabling or starting Bolt"

fixture
rm "$TB_STATE"
reject accessory_remove_thunderbolt
[[ -f $TB_MARKER ]] || fail "inconsistent enrollment is preserved for recovery"
pass "missing policy with an enrollment marker cannot report completion"

fixture
echo '# No USB devices were present during enrollment.' >"$ACCESSORY_USB_RULES"
accessory_remove_usb 0
[[ -e $ACCESSORY_USB_REVERTED ]] || fail "empty initial enrollment is still Omarchy-owned"
: >"$scratch/units"
accessory_remove_usb 1
[[ ! -s $scratch/units ]] || fail "machine-wide completion must make another user's retry a no-op"
pass "empty initial enrollment is removed once across users"

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
reject accessory_factory_enrollment "$factory"
[[ $(<"$factory/usr/bin/omarchy-provision-owner") == "$original_owner" ]] || fail "failed publication must not truncate factory provisioning"
unset -f mv
pass "factory script publication failures are reported and leave the original intact"
accessory_factory_enrollment "$factory"
accessory_factory_enrollment "$factory"
! grep -Eq 'usb_authorization|thunderbolt-authorization' "$factory/usr/bin/omarchy-provision-owner" || fail "factory reset must not reenroll accessories"
grep -q luks_staged_unlock_remains "$factory/usr/bin/omarchy-provision-owner" || fail "factory repair preserves LUKS completion guard"
bash -n "$factory/usr/share/omarchy/install/user/first-run/enable-user-units.sh"
[[ ! -e $factory/usr/share/omarchy/migrations/1789433473.sh ]] || fail "factory repair removes retired enrollment migrations"
pass "factory reset preserves provisioning guards and cannot reenroll retired protection"

fixture
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
reject accessory_clean_factory
[[ -f $scratch/factory/var/lib/omarchy/thunderbolt-authorization/policy.json &&
  $(tb_config_authmode "$scratch/factory/var/lib/boltd/boltd.conf") == "disabled" ]] || fail "failed mode restoration must preserve recovery data and disabled policy"
rm "$scratch/config-failure"
pass "factory mode restoration failure retains its original policy for retry"
accessory_clean_factory
accessory_clean_factory
[[ $(tb_config_authmode "$scratch/factory/var/lib/boltd/boltd.conf") == "disabled" &&
  $(<"$scratch/factory-ro") == "true" ]] || fail "factory cleanup preserves disabled Bolt mode and read-only status on every pass"
pass "factory rollback retries without enabling an originally disabled Bolt policy or requiring Limine"

touch "$scratch/ro-failure"
reject accessory_clean_factory
[[ $(<"$scratch/factory-ro") == "false" ]] || fail "fixture exercises failed read-only restoration"
rm "$scratch/ro-failure"
accessory_clean_factory
[[ $(<"$scratch/factory-ro") == "true" ]] || fail "factory read-only repair can retry"
pass "factory read-only restoration failure blocks migration completion"

mkdir -p "$scratch/factory/usr/share/omarchy" "$scratch/outside/user/first-run"
echo 'keep outside snapshot' >"$scratch/outside/user/first-run/enable-user-units.sh"
ln -s "$scratch/outside" "$scratch/factory/usr/share/omarchy/install"
reject accessory_clean_factory
[[ $(<"$scratch/outside/user/first-run/enable-user-units.sh") == "keep outside snapshot" ]] || fail "factory rollback must not follow external directory links"
pass "factory rollback rejects linked directories before writing outside the snapshot"

fixture
source "$ROOT/bin/omarchy-usb-authorization-boot"
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
mkdir -p "$scratch/etc/systemd/system/basic.target.wants"
ln -s /missing/package/usbguard.service "$scratch/etc/systemd/system/usbguard.service"
ln -s ../usbguard.service "$scratch/etc/systemd/system/basic.target.wants/usbguard.service"
eval "$(declare -f systemctl | sed '1s/systemctl/fixture_systemctl/')"
systemctl() {
  if [[ ${!#} == usbguard.service ]]; then
    case "$1" in
      show) echo not-found ;;
      disable) /usr/bin/systemctl --root="$scratch" disable usbguard.service ;;
      is-active) return 3 ;;
      is-enabled) /usr/bin/systemctl --root="$scratch" is-enabled usbguard.service ;;
      *) return 91 ;;
    esac
  else
    fixture_systemctl "$@"
  fi
}
accessory_remove_usb 1
[[ -f $ACCESSORY_USB_REVERTED && ! -L $scratch/etc/systemd/system/basic.target.wants/usbguard.service ]] || fail "uninstalled USBGuard must retire its links before recording completion"
pass "uninstalled USBGuard removes dangling enablement links with native systemctl"
unset -f systemctl
eval "$(declare -f fixture_systemctl | sed '1s/fixture_systemctl/systemctl/')"

findmnt() { return 1; }
reject accessory_clean_factory
pass "a failed filesystem query cannot silently skip factory repair"
