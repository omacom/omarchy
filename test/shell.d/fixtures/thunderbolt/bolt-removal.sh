#!/bin/bash

# Real Bolt policy/approval/setup calls. Only systemd is bridged to the private
# daemon processes owned by bolt-integration.py; never contact host systemd.
set -euo pipefail
source "$ROOT/install/helpers/thunderbolt-policy.sh"
source "$ROOT/install/helpers/thunderbolt-setup.sh"
TB_STATE="$TB_TEST_DIR/policy.json" TB_CONFIG="$TB_TEST_STORE/boltd.conf"
TB_MARKER="$TB_TEST_DIR/enabled" TB_PENDING="$TB_TEST_DIR/pending"
TB_RUNTIME="$TB_TEST_DIR/runtime" TB_LOCK="$TB_TEST_DIR/root.lock"
mkdir -p "$TB_RUNTIME"

service_request() {
  printf '%s\n' "$*" > "$TB_TEST_DIR/control.tmp"
  mv "$TB_TEST_DIR/control.tmp" "$TB_TEST_DIR/control"
  for (( attempt=0; attempt<300; attempt++ )); do
    [[ -f $TB_TEST_DIR/control ]] || return 0
    sleep 0.05
  done
  echo "Private service operation timed out: $*" >&2
  return 1
}
systemctl() {
  local action=$1 unit
  shift
  printf '%s\n' "$action $*" >> "$TB_TEST_DIR/services.log"
  case "$action" in
    show)
      unit=${!#}
      if [[ -f $TB_TEST_DIR/$unit.active ]]; then echo ActiveState=active; else echo ActiveState=inactive; fi
      if [[ -f $TB_TEST_DIR/$unit.enabled ]]; then echo UnitFileState=enabled; else echo UnitFileState=disabled; fi ;;
    start|stop)
      for unit in "$@"; do service_request "$action" "$unit" || return 1; done ;;
    enable)
      unit=${!#}
      touch "$TB_TEST_DIR/$unit.enabled"
      if [[ $1 == "--now" ]]; then service_request start "$unit"; fi ;;
    disable)
      if [[ -f $TB_TEST_DIR/fail-disable ]]; then rm "$TB_TEST_DIR/fail-disable"; return 1; fi
      rm -f -- "$TB_TEST_DIR/$1.enabled" ;;
    daemon-reload) ;;
    *) echo "Unexpected systemctl action: $action $*" >&2; return 1 ;;
  esac
}
check_inventory() { tb_inventory | jq -e --arg uid "$TB_TEST_UID" --arg other "$TB_TEST_OTHER" "$1" >/dev/null; }
case "$1" in
  approve)
    jq -cn '{version:1,enabled:true,trusted:{},original_authmode:"enabled"}' > "$TB_STATE"
    echo removal-test > "$TB_RUNTIME/generation"
    touch "$TB_MARKER"
    identity=$(tb_snapshot | jq -c --arg uid "$TB_TEST_UID" '.devices[]|select(.identity.Uid==$uid)|.identity')
    tb_approve "$identity" true true >/dev/null
    # An existing manual record, even explicitly trusted through Omarchy,
    # must keep the policy its administrator chose before enrollment.
    inventory=$(tb_inventory)
    owner=$(jq -r .owner <<< "$inventory")
    path=$(jq -r --arg uid "$TB_TEST_OTHER" '.devices[]|select(.Uid==$uid)|.path' <<< "$inventory")
    tb_bus call "$owner" "$path" "$TB_DEVICE" Authorize s '' >/dev/null
    tb_bus call "$owner" "$TB_PATH" "$TB_MANAGER" EnrollDevice sss "$TB_TEST_OTHER" manual '' >/dev/null
    identity=$(tb_snapshot | jq -c --arg uid "$TB_TEST_OTHER" '.devices[]|select(.identity.Uid==$uid)|.identity')
    tb_approve "$identity" true true >/dev/null
    jq -e --arg uid "$TB_TEST_UID" --arg other "$TB_TEST_OTHER" \
      '.enrolled[$uid].StoreTime>0 and .enrolled[$other]==null and .trusted[$other]!=null' "$TB_STATE" >/dev/null
    if [[ $TB_TEST_SECURITY == "secure" ]]; then
      sha256sum "$TB_TEST_STORE/keys/$TB_TEST_UID" > "$TB_TEST_DIR/key-checksum"
    fi ;;
  boot-enable) tb_admin boot-enable ;;
  rollback)
    cp "$TB_STATE" "$TB_TEST_DIR/old-policy.json"
    tb_inventory | tb_boot_saved > "$TB_TEST_DIR/old-firmware.json"
    touch "$TB_TEST_DIR/fail-disable"
    if tb_admin disable; then echo 'Failed removal unexpectedly succeeded' >&2; exit 1; fi
    cmp "$TB_STATE" "$TB_TEST_DIR/old-policy.json"
    cmp <(tb_inventory | tb_boot_saved | jq -cS .) <(jq -cS . "$TB_TEST_DIR/old-firmware.json")
    [[ -f $TB_MARKER && -f $TB_TEST_DIR/$TB_SERVICE.active && -f $TB_TEST_DIR/$TB_SERVICE.enabled && ! -f $TB_TEST_DIR/setup-recovery.json ]]
    check_inventory '.manager.AuthMode=="disabled"'
    echo 'Removal failure restored policy, firmware ACLs and approval service' ;;
  disable)
    tb_admin disable
    [[ ! -f $TB_MARKER && ! -f $TB_TEST_DIR/$TB_SERVICE.active && ! -f $TB_TEST_DIR/$TB_SERVICE.enabled ]]
    jq -e '.enabled==false and .enrolled==null' "$TB_STATE" >/dev/null
    check_inventory '.manager.AuthMode=="enabled" and any(.stored[]; .Uid==$uid and .Policy=="auto") and any(.stored[]; .Uid==$other and .Policy=="manual")'
    if [[ $TB_TEST_SECURITY == "secure" ]]; then sha256sum --status -c "$TB_TEST_DIR/key-checksum"; fi
    echo 'Removal handed our record back to Bolt and preserved existing manual policy' ;;
  disconnected)
    check_inventory 'any(.stored[]; .Uid==$uid and .Status=="disconnected") and any(.stored[]; .Uid==$other and .Status=="disconnected")' ;;
  reconnected)
    check_inventory 'any(.devices[]; .Uid==$uid and .Policy=="auto" and (.Status|startswith("authorized"))) and any(.devices[]; .Uid==$other and .Policy=="manual" and .Status=="connected")'
    if [[ $TB_TEST_SECURITY == "secure" ]]; then
      check_inventory 'any(.devices[]; .Uid==$uid and .Key=="have" and (.AuthFlags|contains("secure")))'
      sha256sum --status -c "$TB_TEST_DIR/key-checksum"
    fi
    echo "Automatic reconnect succeeded in $TB_TEST_SECURITY mode; pre-existing manual device stayed blocked" ;;
  *) exit 64 ;;
esac
