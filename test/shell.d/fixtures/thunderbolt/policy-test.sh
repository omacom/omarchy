#!/bin/bash

# These behavior cases were first run as the existing Python assertions against
# the Bash implementation. Fixtures replace only Bolt, systemd and desktop I/O.
set -euo pipefail
source "$ROOT/test/shell.d/base-test.sh"
source "$ROOT/install/helpers/thunderbolt-policy.sh"
source "$ROOT/install/helpers/thunderbolt-setup.sh"
source "$ROOT/install/helpers/thunderbolt-review.sh"

fixture() {
  T=$(mktemp -d)
  trap 'rm -rf -- "$T"' EXIT
  export HOME="$T/home"
  TB_STATE="$T/policy.json" TB_CONFIG="$T/boltd.conf" TB_MARKER="$T/enabled"
  TB_PENDING="$T/pending" TB_SYSFS="$T/sysfs" TB_KEYS="$T/keys"
  TB_RUNTIME="$T/runtime" TB_LOCK="$T/root.lock"
  mkdir -p "$TB_RUNTIME" "$HOME" "$TB_SYSFS" "$TB_KEYS"
  echo generation-a > "$TB_RUNTIME/generation"
  echo '{"version":1,"enabled":true,"trusted":{},"original_authmode":"enabled"}' > "$TB_STATE"
  cat > "$T/inventory" <<'JSON'
{"owner":":1.5","manager":{"AuthMode":"disabled"},"domains":[{"Uid":"host","SecurityLevel":"user","IOMMU":true,"SysfsPath":"/sys/domain","path":"/domain","BootACL":["device-1",""]}],"devices":[{"Uid":"device-1","Name":"Dock","Vendor":"Vendor","Parent":"host","SysfsPath":"/sys/devices/test/0-1","ConnectTime":1,"Status":"connected","Stored":false,"Policy":"default","AuthFlags":"","path":"/devices/1","inode":"1"}]}
JSON
  : > "$T/operations"; : > "$T/units"; : > "$T/notifications"
  echo '{}' > "$T/capture"
  tb_requests
}

edit_inventory() { jq "$@" "$T/inventory" > "$T/next"; mv "$T/next" "$T/inventory"; }
edit_state() { jq "$@" "$TB_STATE" | tb_json_write "$TB_STATE"; }
check() { jq -e "$1" "$2" >/dev/null || fail "$1" "$(cat "$2")"; }
reject() { if ("$@") > "$T/output" 2> "$T/error"; then fail "unexpected success: $*"; fi; }
identity() { tb_snapshot | jq -c '.devices[0].identity'; }

tb_inventory() {
  [[ ! -f $T/inventory-failure ]] || { tb_fail 'inventory unavailable'; return 1; }
  jq '. + {stored:[.devices[] | select(.Stored)]}' "$T/inventory"
}
tb_properties() { jq -c --arg path "$2" '(.devices + .domains)[] | select(.path==$path)' "$T/inventory"; }
tb_bus() {
  local command=$1 path=$3 member=$5 value
  printf '%s\n' "$member" >> "$T/operations"
  case "$member" in
    Authorize)
      [[ ! -f $T/authorize-failure ]] || return 1
      if [[ ! -f $T/authorize-noop ]]; then edit_inventory --arg path "$path" '(.devices[] | select(.path==$path)).Status="authorized"'; fi ;;
    EnrollDevice)
      if [[ ! -f $T/enroll-noop ]]; then
        edit_inventory '(.devices[0] | .Stored=true | .Policy="manual") as $d | .devices[0]=$d'
        if [[ -f $TB_SYSFS/0-1/key && $(cat "$TB_SYSFS/0-1/key") =~ ^[0-9a-f]{64}$ && ! -f $T/key-store-failure ]]; then
          edit_inventory '.devices[0].Key="have"'
        fi
      fi ;;
    Policy|BootACL)
      if [[ $member == "BootACL" && -f $T/boot-failure ]] || [[ $member == "Policy" && ${7:-} == "auto" && -f $T/restore-failure ]]; then
        tb_fail 'firmware rejected write'; return 1
      fi
      if [[ $member == "BootACL" ]]; then
        shift 7
        value=$(jq -cn '$ARGS.positional' --args "$@")
      else
        value=$(jq -cn --arg value "$7" '$value')
      fi
      edit_inventory --arg path "$path" --arg key "$member" --argjson value "$value" \
        '((.devices[],.domains[]) | select(.path==$path))[$key]=$value' ;;
    *) tb_fail "Unexpected Bolt call: $*"; return 1 ;;
  esac
}
tb_capture() { [[ ! -f $T/capture-failure ]] && cat "$T/capture"; }
tb_unit_state() { jq -cn --arg unit "$1" '{active:($unit=="bolt.service"),enabled:false}'; }
systemctl() {
  if [[ $1 == --root=* ]]; then command systemctl "$@"; return; fi
  printf '%s\n' "$*" >> "$T/units"
  if [[ -f $T/unit-failure && $* == "$(cat "$T/unit-failure")" ]]; then
    [[ -f $T/repeat-failure ]] || rm "$T/unit-failure"
    tb_fail 'systemd failed'; return 1
  fi
}
tb_public_snapshot() { cat "$T/public"; }
tb_notify() {
  echo "$1" >> "$T/notifications"
  if [[ -f $T/notify-failure ]]; then rm "$T/notify-failure"; return 1; fi
}
tb_attention() { echo attention >> "$T/notifications"; }
gum() { if [[ $1 == "choose" ]]; then cat "$T/choice"; fi; }
tb_request_apply() {
  jq --argjson identity "$2" --argjson permanent "$1" \
    '(.devices[] | select(.identity==$identity)) |= (.status="authorized" | .trusted=$permanent | .stored=$permanent)' "$T/public" > "$T/next"
  mv "$T/next" "$T/public"
  [[ ! -f $T/lost-reply ]] || { tb_fail 'reply lost'; return 1; }
  cat "$T/public"
}
request() { local paths=("$TB_REQUESTS"/request-*.json); printf '%s\n' "${paths[0]}"; }
request_count() { local paths; shopt -s nullglob; paths=("$TB_REQUESTS"/request-*.json); echo "${#paths[@]}"; }
public_fixture() { tb_snapshot > "$T/public"; }
boot_fixture() { edit_inventory '.devices[0] |= (.Stored=true | .Policy="auto")'; }
review_tick() {
  local path watch
  path=$(request); watch=$(jq -r .watch "$path")
  tb_scan "$watch" >/dev/null
}

test_iommu_is_not_consent() {
  edit_inventory '.devices[0] |= (.Stored=true | .Policy="iommu")'
  tb_reconcile > "$T/result"
  [[ ! -s $T/operations ]]; check '.devices[0].trusted==false' "$T/result"
}
test_once_is_not_saved() {
  tb_approve "$(identity)" false > "$T/result"
  check '.warnings==[]' "$T/result"; check '.trusted=={}' "$TB_STATE"
  edit_inventory '.devices[0].Status="connected"'
  tb_reconcile >/dev/null
  [[ $(cat "$T/operations") == "Authorize" ]]
}
test_always_survives_restart() {
  tb_approve "$(identity)" true >/dev/null
  edit_inventory '.owner=":1.9" | .devices[0] |= (.Status="connected" | .inode="2")'
  echo generation-b > "$TB_RUNTIME/generation"
  tb_reconcile > "$T/result"
  check '.devices[0].status=="authorized" and .devices[0].trusted' "$T/result"
  check '.manager.AuthMode=="disabled"' "$T/inventory"
}
secure_fixture() {
  mkdir -p "$TB_SYSFS/0-1"
  echo 11111111-2222-3333-4444-555555555555 > "$TB_SYSFS/0-1/unique_id"
  echo 0 > "$TB_SYSFS/0-1/authorized"
  : > "$TB_SYSFS/0-1/key"
  edit_inventory --arg path "$TB_SYSFS/0-1" --arg inode "$(stat -Lc %i "$TB_SYSFS/0-1")" \
    '.domains[0].SecurityLevel="secure" | .devices[0] |= (.Secure=true | .Key="missing" |
      .Uid="11111111-2222-3333-4444-555555555555" | .SysfsPath=$path | .inode=$inode)'
}
test_secure_approval_initializes_before_trust() {
  secure_fixture
  tb_approve "$(identity)" true true > "$T/result"
  [[ $(cat "$TB_SYSFS/0-1/key") =~ ^[0-9a-f]{64}$ ]]
  check '.devices[0].trusted and .devices[0].stored' "$T/result"
  cp "$TB_SYSFS/0-1/key" "$T/original-key"
  tb_approve "$(identity)" true true >/dev/null
  cmp "$TB_SYSFS/0-1/key" "$T/original-key"
}
test_secure_automatic_restore_cannot_initialize_keys() {
  secure_fixture
  jq '.devices[0] | {(.Uid):{Uid,Name,Vendor}}' "$T/inventory" > "$T/trusted"
  edit_state --slurpfile trusted "$T/trusted" '.trusted=$trusted[0]'
  tb_reconcile > "$T/result"
  check '.devices[0].trusted==false' "$T/result"
  [[ ! -s $T/operations && ! -s $TB_SYSFS/0-1/key ]]
  reject tb_approve "$(identity)" true
  [[ ! -s $T/operations ]]
}
test_secure_missing_saved_key_cannot_claim_success() {
  secure_fixture
  touch "$T/key-store-failure"
  reject tb_approve "$(identity)" true true
  check '.trusted=={}' "$TB_STATE"
  tb_snapshot > "$T/result"; check '.devices[0].trusted==false' "$T/result"
}
test_secure_key_failure_does_not_authorize() {
  secure_fixture
  openssl() { return 1; }
  reject tb_approve "$(identity)" true true
  [[ ! -s $T/operations && ! -s $TB_SYSFS/0-1/key ]]
  unset -f openssl
  echo invalid > "$TB_SYSFS/0-1/key"
  reject tb_approve "$(identity)" true true
  [[ ! -s $T/operations ]]
}
test_authorized_keyless_device_requires_explicit_reconnect() {
  secure_fixture
  edit_inventory '.devices[0].Status="authorized"'
  echo 1 > "$TB_SYSFS/0-1/authorized"
  reject tb_approve "$(identity)" true true
  rg -q 'disconnect, reconnect' "$T/error"
  [[ ! -s $TB_SYSFS/0-1/key ]]; check '.trusted=={}' "$TB_STATE"
  edit_inventory '.devices[0].Status="connected"'
  tb_reconcile >/dev/null
  [[ $(cat "$T/operations") == "EnrollDevice" ]]
}
test_stale_identity_rejected() {
  local id field
  id=$(identity)
  for field in inode Name ConnectTime; do
    cp "$T/inventory" "$T/original"
    edit_inventory --arg field "$field" '.devices[0][$field]="replacement"'
    reject tb_approve "$id" true
    mv "$T/original" "$T/inventory"
  done
  edit_inventory '.owner=":1.9"'; reject tb_approve "$id" true
  [[ ! -s $T/operations ]]
}
test_false_success_rejected() {
  local id; id=$(identity)
  touch "$T/authorize-noop"; reject tb_approve "$id" true; check '.trusted=={}' "$TB_STATE"
  rm "$T/authorize-noop"; touch "$T/enroll-noop"
  reject tb_approve "$id" true; check '.trusted=={}' "$TB_STATE"
  rm "$T/enroll-noop"; tb_approve "$id" true > "$T/result"
  check '.devices[0].trusted' "$T/result"
  [[ $(rg -c '^Authorize$' "$T/operations") == 2 ]]
}
test_write_failure_retains_retry() {
  local id; id=$(identity)
  eval "$(declare -f tb_json_write | sed '1s/tb_json_write/disk_write/')"
  tb_json_write() { [[ ! -f $T/disk-full ]] && disk_write "$@"; }
  touch "$T/disk-full"; reject tb_approve "$id" true; check '.trusted=={}' "$TB_STATE"
  rm "$T/disk-full"; tb_approve "$id" true > "$T/result"
  check '.devices[0].trusted' "$T/result"
  [[ $(rg -c '^Authorize$' "$T/operations") == 1 ]]
}
test_firmware_bypass_warns() {
  edit_inventory '.domains[0].SecurityLevel="none" | .devices[0] |= (.Status="authorized" | .AuthFlags="boot")'
  tb_snapshot > "$T/result"; check '.warnings|length==2' "$T/result"; [[ ! -s $T/operations ]]
}
test_global_enable_not_protected() {
  edit_inventory '.manager.AuthMode="enabled"'
  reject tb_snapshot; rg -q 'not active' "$T/error"
  reject tb_reconcile
}
test_display_only_needs_no_approval() {
  edit_state '.trusted["device-1"]={Uid:"device-1",Name:"Dock",Vendor:"Vendor"}'
  edit_inventory '.devices[0].AuthFlags="nopcie"'
  tb_reconcile > "$T/result"; check '.error==""' "$T/result"; [[ ! -s $T/operations ]]
}
test_empty_capture_preserved() {
  rm "$TB_STATE"; tb_prepare
  touch "$T/capture-failure"; tb_prepare
  check '.trusted=={}' "$TB_STATE"; [[ $(tb_config_authmode "$TB_CONFIG") == "disabled" ]]
}
test_capture_failure_does_not_publish() {
  rm "$TB_STATE"; touch "$T/capture-failure"; reject tb_prepare
  [[ ! -e $TB_STATE && ! -e $TB_MARKER ]]
}
test_capture_optional_names_match_numeric_identity() {
  source "$ROOT/install/helpers/thunderbolt-setup.sh"
  mkdir -p "$TB_SYSFS/0-1"
  echo device-1 > "$TB_SYSFS/0-1/unique_id"
  echo 0x1234 > "$TB_SYSFS/0-1/device"
  echo 0xab > "$TB_SYSFS/0-1/vendor"
  tb_capture > "$T/result"
  check '.["device-1"]=={Uid:"device-1",Name:"0x1234",Vendor:"0xab"}' "$T/result"
  echo Dock > "$TB_SYSFS/0-1/device_name"
  tb_capture > "$T/result"; check '.["device-1"].Name=="Dock" and .["device-1"].Vendor=="0xab"' "$T/result"
  rm "$TB_SYSFS/0-1/device_name"; echo Vendor > "$TB_SYSFS/0-1/vendor_name"
  tb_capture > "$T/result"; check '.["device-1"].Name=="0x1234" and .["device-1"].Vendor=="Vendor"' "$T/result"
  mkdir "$TB_SYSFS/0-1/device_name"
  reject tb_capture
}
test_first_activation_defers_without_touching_bolt() {
  secure_fixture; rm "$TB_STATE"
  printf '[config]\nAuthMode=enabled\n' > "$TB_CONFIG"; cp "$TB_CONFIG" "$T/original"
  tb_admin owner
  [[ -f $TB_PENDING && ! -f $TB_STATE && ! -f $TB_MARKER && ! -s $T/units ]]
  cmp "$TB_CONFIG" "$T/original"
  rm -rf "$TB_SYSFS/0-1"
  tb_admin migrate
  [[ -f $TB_PENDING && ! -f $TB_MARKER && ! -s $T/units ]]
  tb_admin enable
  [[ ! -f $TB_PENDING && -f $TB_MARKER ]]
}
test_saved_secure_binding_allows_initial_capture() {
  secure_fixture; rm "$TB_STATE"
  edit_inventory '.devices[0] |= (.Stored=true | .Key="have")'
  tb_admin owner
  [[ ! -f $TB_PENDING && -f $TB_MARKER ]]
}
test_key_without_record_defers_initial_capture() {
  secure_fixture; rm "$TB_STATE"
  edit_inventory '.devices[0].Key="have"'
  tb_admin owner
  [[ -f $TB_PENDING && ! -f $TB_MARKER && ! -s $T/units ]]
}
test_offline_prepare_cannot_trust_installers_bolt() {
  secure_fixture; rm "$TB_STATE"
  edit_inventory '.devices[0] |= (.Stored=true | .Key="have")'
  tb_admin prepare
  [[ -f $TB_PENDING && ! -f $TB_MARKER && ! -s $T/units ]]
}
test_deferred_opt_out_retains_initial_enrollment() {
  secure_fixture; rm "$TB_STATE"
  tb_admin owner
  tb_admin disable
  [[ ! -f $TB_PENDING && ! -f $TB_MARKER && ! -s $T/units ]]
  check '.enabled==false and .enrollment_pending==true' "$TB_STATE"
  tb_admin migrate
  [[ ! -f $TB_PENDING && ! -s $T/units ]]
  tb_admin enable
  [[ -f $TB_PENDING && ! -f $TB_MARKER && ! -s $T/units ]]
  rm -rf "$TB_SYSFS/0-1"
  echo '{"new-device":{}}' > "$T/capture"
  tb_admin enable
  check '.enabled and .enrollment_pending==null and .trusted=={"new-device":{}}' "$TB_STATE"
  [[ ! -f $TB_PENDING && -f $TB_MARKER ]]
}
test_pending_notice_retries_without_claiming_protection() {
  touch "$TB_PENDING"
  local count=0 notices=0
  sleep() { count=$((count + 1)); (( count < 3 )) || exit 99; }
  tb_setup_notice() { notices=$((notices + 1)); (( notices > 1 )) && echo pending >> "$T/notifications"; }
  reject tb_watch
  [[ $(cat "$T/notifications") == "pending" ]]
  tb_status > "$T/result"; rg -q 'protection is deferred' "$T/result"
}
test_active_policy_is_not_deferred() {
  secure_fixture; touch "$TB_MARKER"
  tb_admin owner
  [[ ! -f $TB_PENDING && -f $TB_MARKER ]]
}
test_pending_only_factory_reset_reaches_both_roots() {
  local function_name root="$T/top/@factory"
  local TOP_MNT="$T/top" NEXT_NAME=@next PROVISIONING_DIR=/var/lib/omarchy/provisioning LOG_FILE="$T/reset.log" swap_done=0
  mkdir -p "$root/etc/omarchy" "$root/etc/systemd/system" "$root/usr/bin" \
    "$root/usr/share/omarchy/install/provisioning" "$T/top/@"
  touch "$root/etc/omarchy/thunderbolt-authorization.pending" "$root/usr/bin/omarchy-provision-owner"
  chmod +x "$root/usr/bin/omarchy-provision-owner"
  echo 'root:x:0:0:root:/root:/bin/bash' > "$root/etc/passwd"
  cp "$ROOT/install/provisioning/omarchy-provision-owner.service" \
    "$ROOT/install/provisioning/omarchy-system-factory-reset-finish.service" "$root/usr/share/omarchy/install/provisioning/"
  cp "$ROOT/etc/systemd/system/omarchy-thunderbolt-authorization.service" "$root/etc/systemd/system/"
  for function_name in install_provisioning_units scrub_factory_accounts sanitize_factory_baseline stage_full_reset; do
    eval "$(sed -n "/^$function_name() {$/,/^}/p" "$ROOT/bin/omarchy-system-factory-reset")"
  done
  log() { :; }
  btrfs() {
    if [[ $1 == "subvolume" && $2 == "snapshot" ]]; then cp -a "$3" "$4"
    elif [[ $1 == "property" ]]; then :
    else return 1; fi
  }
  usermod() { [[ $1 == "--root" && $2 == "$TOP_MNT/"* && $3 == "--password" && $4 == "!" && $5 == "root" ]]; }
  systemd-id128() { echo new-machine-id; }
  encrypted_install() { return 1; }
  rebuild_next_boot() { :; }
  sync() { :; }
  systemctl() {
    [[ ( $1 == "--root=$TOP_MNT/@next" || $1 == "--root=$TOP_MNT/@factory" ) && $2 == "disable" && $3 == "$TB_SERVICE" ]] || return 1
    command systemctl "$@"
  }
  function /usr/bin/omarchy-thunderbolt-authorization-admin() {
    [[ $1 == "reset-root" ]] || return 1
    printf '%s\n' "$2" >> "$T/reset-roots"
    (
      source "$ROOT/install/helpers/thunderbolt-policy.sh"
      source "$ROOT/install/helpers/thunderbolt-setup.sh"
      tb_reset_root "$2"
    )
  }
  stage_full_reset
  [[ $(wc -l < "$T/reset-roots") == 2 && $swap_done == 1 ]]
  [[ ! -f $TOP_MNT/@/etc/omarchy/thunderbolt-authorization.pending &&
    ! -f $TOP_MNT/@factory/etc/omarchy/thunderbolt-authorization.pending ]]
  [[ -f $TOP_MNT/@/var/lib/omarchy/provisioning/pending ]]
}
test_config_preserves_settings() {
  rm "$TB_STATE"; printf '[config]\nAuthMode=enabled\nDefaultPolicy=manual\n' > "$TB_CONFIG"
  tb_prepare; rg -q '^DefaultPolicy=manual$' "$TB_CONFIG"
  check '.original_authmode=="enabled"' "$TB_STATE"
}
test_fresh_owner_replaces_trust() {
  rm "$TB_STATE"; echo '{"old":{}}' > "$T/capture"; tb_prepare
  echo '{"new":{}}' > "$T/capture"; tb_prepare true
  check '.trusted=={"new":{}} and .original_authmode=="enabled"' "$TB_STATE"
}
test_enable_rollback() {
  rm "$TB_STATE"; printf '[config]\nAuthMode=enabled\nDefaultPolicy=manual\n' > "$TB_CONFIG"
  cp "$TB_CONFIG" "$T/original"; echo 'start bolt.service' > "$T/unit-failure"
  reject tb_transaction tb_enable
  cmp "$TB_CONFIG" "$T/original"; [[ ! -e $TB_STATE && ! -e $TB_MARKER && ! -e $T/setup-recovery.json ]]
  [[ $(tail -2 "$T/units") == $'start bolt.service\nstop omarchy-thunderbolt-authorization.service' ]]
}
test_failed_restore_keeps_checkpoint() {
  rm "$TB_STATE"; echo '[config]' > "$TB_CONFIG"; cp "$TB_CONFIG" "$T/original"
  echo 'stop omarchy-thunderbolt-authorization.service bolt.service' > "$T/unit-failure"; touch "$T/repeat-failure"
  reject tb_transaction tb_enable; rg -q 'restoration is incomplete' "$T/error"
  [[ -f $T/setup-recovery.json ]]; reject tb_transaction tb_enable; rg -q 'needs recovery' "$T/error"
  echo partial > "$TB_CONFIG"; rm "$T/unit-failure"
  tb_config_restore; cmp "$TB_CONFIG" "$T/original"
}
test_disable_restores_matching_boot_state() {
  boot_fixture; tb_prepare; tb_boot_change true; cp "$TB_STATE" "$T/original"
  echo 'disable omarchy-thunderbolt-authorization.service' > "$T/unit-failure"
  reject tb_transaction tb_disable
  cmp "$TB_STATE" "$T/original"; [[ -f $TB_MARKER && ! -f $T/setup-recovery.json ]]
  check '.devices[0].Policy=="manual" and .domains[0].BootACL==["",""]' "$T/inventory"
}
test_boot_policy_reconnection_and_restore() {
  boot_fixture; tb_boot_change true
  check '.devices[0].Policy=="manual" and .domains[0].BootACL==["",""]' "$T/inventory"
  check '.boot_protection and .trusted["device-1"]!=null' "$TB_STATE"
  edit_inventory '.devices[0].Policy="auto" | .domains[0].BootACL=["device-1",""]'
  tb_snapshot > "$T/result"; check '.warnings|length>0' "$T/result"
  tb_reconcile > "$T/result"; check '.error==""' "$T/result"
  check '.domains[0].BootACL==["",""]' "$T/inventory"
  tb_boot_change false
  check '.devices[0].Policy=="auto" and .domains[0].BootACL==["device-1",""]' "$T/inventory"
}
test_boot_change_rollback() {
  boot_fixture; cp "$TB_STATE" "$T/original"; touch "$T/boot-failure"
  reject tb_boot_change true
  check '.devices[0].Policy=="auto" and .domains[0].BootACL==["device-1",""]' "$T/inventory"
  cmp <(jq -cS . "$TB_STATE") <(jq -cS . "$T/original"); [[ ! -e $T/boot-recovery.json ]]
}
test_boot_recovery_retained() {
  boot_fixture; cp "$TB_STATE" "$T/original"; touch "$T/boot-failure" "$T/restore-failure"
  reject tb_boot_change true; rg -q 'recovery is incomplete' "$T/error"; [[ -f $T/boot-recovery.json ]]
  rm "$T/boot-failure" "$T/restore-failure"; tb_boot_recover
  cmp <(jq -cS . "$TB_STATE") <(jq -cS . "$T/original"); [[ ! -e $T/boot-recovery.json ]]
}
test_unsupported_boot_cannot_succeed() {
  boot_fixture; cp "$T/inventory" "$T/original"
  local expression
  for expression in '.SysfsPath=""' '.SecurityLevel="none"' '.BootACL=[]'; do
    cp "$T/original" "$T/inventory"; edit_inventory ".domains[0] |= ($expression)"
    reject tb_boot_change true
  done
  [[ ! -s $T/operations ]]
}
test_install_defers_owner() {
  install() { :; }
  function /usr/bin/omarchy-thunderbolt-authorization-admin() { echo "helper $*"; }
  export OMARCHY_PATH=$ROOT OMARCHY_INSTALL_USER=''
  source "$ROOT/install/config/thunderbolt-authorization.sh" > "$T/output"
  ! rg -q helper "$T/output"; [[ ! -s $T/units ]]
  OMARCHY_INSTALL_USER=lab
  source "$ROOT/install/config/thunderbolt-authorization.sh" > "$T/output"
  rg -q 'helper prepare' "$T/output"; rg -q '^enable omarchy-thunderbolt-authorization.service$' "$T/units"
}
test_offline_reset_scrubs_private_state() {
  source "$ROOT/install/helpers/thunderbolt-policy.sh"
  local root="$T/clone" unit="$TB_SERVICE"
  mkdir -p "$root/etc/systemd/system" "$root${TB_STATE%/*}" "$root${TB_MARKER%/*}"
  cp "$ROOT/etc/systemd/system/$unit" "$root/etc/systemd/system/"
  command systemctl --root="$root" enable "$unit" >/dev/null 2>&1
  touch "$root$TB_MARKER" "$root$TB_STATE" "$root${TB_STATE%/*}/setup-recovery.json"
  local kind
  for kind in devices keys domains; do mkdir -p "$root/var/lib/boltd/$kind"; touch "$root/var/lib/boltd/$kind/old"; done
  tb_reset_root "$root"
  [[ ! -e $root$TB_MARKER && ! -e $root${TB_STATE%/*} && ! -e $root/etc/systemd/system/multi-user.target.wants/$unit ]]
  [[ $(ls "$root/var/lib/boltd") == "boltd.conf" && $(tb_config_authmode "$root/var/lib/boltd/boltd.conf") == "enabled" ]]
}
test_live_reset_refused() { reject tb_reset_root /; }
test_trusted_reconnect_no_alert() {
  edit_state '.trusted["device-1"]={Uid:"device-1",Name:"Dock",Vendor:"Vendor"}'
  public_fixture; tb_scan watch1 >/dev/null; [[ ! -s $T/notifications ]]
}
test_unavailable_warns_once() {
  tb_scan() { return 1; }
  sleep() { count=$((count+1)); ((count<4)) || exit 99; }
  local count=0
  reject tb_watch
  [[ $(cat "$T/notifications") == "attention" ]]
}
test_failed_delivery_retries_other_devices() {
  edit_inventory '.devices += [(.devices[0] | .Uid="device-2")]'; public_fixture; touch "$T/notify-failure"
  tb_scan watch1 >/dev/null; [[ $(request_count) == 1 ]]
  tb_scan watch1 >/dev/null; [[ $(request_count) == 2 && $(wc -l < "$T/notifications") == 3 ]]
}
test_restarts_restore_requests() {
  public_fixture; tb_scan watch1 >/dev/null; local old; old=$(request)
  tb_scan watch1 >/dev/null; [[ $(wc -l < "$T/notifications") == 1 ]]
  edit_inventory '.owner=":1.9"'; public_fixture
  tb_scan watch1 >/dev/null; [[ $(request) != "$old" ]]
  tb_scan watch2 >/dev/null; [[ $(request_count) == 1 && $(wc -l < "$T/notifications") == 3 ]]
}
test_inventory_failure_preserves_request() {
  public_fixture; tb_scan watch1 >/dev/null; local path; path=$(request)
  rm "$T/public"; reject tb_scan watch1; [[ -f $path ]]
}
test_replacement_during_dialog_rejected() {
  public_fixture; tb_scan watch1 >/dev/null; local path; path=$(request)
  gum() {
    if [[ $1 == "choose" ]]; then
      jq '.devices[0].identity.Uid="replacement"' "$T/public" > "$T/next"; mv "$T/next" "$T/public"
      echo 'Always allow this device'
    fi
  }
  reject tb_review "${path##*/}" # A filename is not a valid token.
  reject tb_review "$(basename "$path" .json)"
  check '.devices[0].status=="connected"' "$T/public"
}
test_lost_reply_keeps_approval_intent() {
  public_fixture; tb_scan watch1 >/dev/null; local path; path=$(request)
  echo 'Always allow this device' > "$T/choice"; touch "$T/lost-reply"
  sleep() { review_tick; }
  reject tb_review "$(basename "$path" .json)"
  check '.approval=="Always allow this device"' "$path"
  tb_scan watch1 >/dev/null; [[ -f $path && $(wc -l < "$T/notifications") == 2 ]]
  tb_scan watch2 >/dev/null; [[ ! -f $path && $(wc -l < "$T/notifications") == 3 ]]; path=$(request)
  rm "$T/lost-reply"; gum() { fail 'Saved approval must not ask again'; }
  tb_review "$(basename "$path" .json)" >/dev/null
  [[ ! -f $path ]]
}
test_disconnect_and_untrusted_text() {
  edit_inventory '.devices[0].Name="$(touch /tmp/untrusted)\u001b[2J"'
  public_fixture; tb_scan watch1 >/dev/null
  [[ $(basename "$(request)") =~ ^request-[0-9a-f]{64}.json$ ]]
  [[ $(jq '.devices[0].Name' "$T/inventory" | tb_safe_text) != *$'\e'* ]]
  edit_inventory '.devices=[]'; public_fixture; tb_scan watch1 >/dev/null; [[ $(request_count) == 0 ]]
}
test_snapshot_freshness_and_disabled_state() {
  # Exercise the real public reader, including freshness after daemon failure.
  source "$ROOT/install/helpers/thunderbolt-policy.sh"
  TB_RUNTIME="$T/runtime"
  jq -cn --argjson now "$(date +%s)" '{available:true,time:$now,generation:"generation-a"}' > "$TB_RUNTIME/snapshot.json"
  tb_public_snapshot >/dev/null
  jq '.time-=30' "$TB_RUNTIME/snapshot.json" > "$T/next"; mv "$T/next" "$TB_RUNTIME/snapshot.json"
  reject tb_public_snapshot
  echo generation-b > "$TB_RUNTIME/generation"; reject tb_public_snapshot
}
test_invalid_state_not_skipped_by_migration() {
  echo '{"enabled":false}' > "$TB_STATE"; reject tb_admin migrate
  [[ ! -s $T/units ]]
}

for case in $(declare -F | awk '$3 ~ /^test_/ {print $3}'); do
  (fixture; "$case")
  pass "Thunderbolt ${case#test_}"
done
