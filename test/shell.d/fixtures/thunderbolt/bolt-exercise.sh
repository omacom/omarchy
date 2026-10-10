#!/bin/bash

# Runs against the private real boltd created by bolt-integration.py. No policy,
# busctl, firmware reads, or writes are mocked here.
set -euo pipefail
source "$ROOT/install/helpers/thunderbolt-policy.sh"
source "$ROOT/install/helpers/thunderbolt-setup.sh"
TB_STATE="$TB_TEST_DIR/policy.json"
TB_RUNTIME="$TB_TEST_DIR/runtime"
mkdir -p "$TB_RUNTIME"
check() { jq -e "$1" "$2" >/dev/null; }
reject() { if "$@"; then echo 'Unexpected approval success' >&2; exit 1; fi; }
case "$1" in
  approve)
    echo '{"version":1,"enabled":true,"trusted":{}}' | tb_json_write "$TB_STATE"
    cat /proc/sys/kernel/random/uuid > "$TB_RUNTIME/generation"
    tb_snapshot > "$TB_TEST_DIR/before.json"
    capture=$(tb_capture)
    tb_inventory | jq -e --arg uid "$TB_TEST_UID" --argjson capture "$capture" \
      '.devices[] | select(.Uid==$uid) | $capture[$uid]=={Uid,Name,Vendor}' >/dev/null
    check 'all(.devices[]; .status=="connected" and (.stored|not))' "$TB_TEST_DIR/before.json"
    id=$(jq -c --arg uid "$TB_TEST_UID" '.devices[] | select(.identity.Uid==$uid) | .identity' "$TB_TEST_DIR/before.json")
    printf '%s\n' "$id" > "$TB_TEST_DIR/identity.json"
    tb_approve "$id" true true > "$TB_TEST_DIR/after.json"
    jq -e --arg uid "$TB_TEST_UID" '.devices[] | select(.identity.Uid==$uid) | .trusted and .status=="authorized" and .policy=="manual"' "$TB_TEST_DIR/after.json" >/dev/null
    jq -e --arg uid "$TB_TEST_OTHER" '.devices[] | select(.identity.Uid==$uid) | .status=="connected"' "$TB_TEST_DIR/after.json" >/dev/null
    check 'all(.domains[0].BootACL[]; .=="")' "$TB_TEST_DIR/after.json"
    inventory=$(tb_inventory)
    if [[ $TB_TEST_SECURITY == "secure" ]]; then
      jq -e --arg uid "$TB_TEST_UID" '.devices[] | select(.Uid==$uid) | .Stored and .Key=="have"' <<< "$inventory" >/dev/null
      [[ -s $TB_TEST_KEYS/$TB_TEST_UID ]]
      sha256sum "$TB_TEST_KEYS/$TB_TEST_UID" > "$TB_TEST_DIR/key-checksum"
    fi
    owner=$(jq -r .owner <<< "$inventory")
    device=$(jq -c --arg uid "$TB_TEST_UID" '.stored[] | select(.Uid==$uid)' <<< "$inventory")
    domain=$(jq -c '.domains[0]' <<< "$inventory")
    device_path=$(jq -r .path <<< "$device"); domain_path=$(jq -r .path <<< "$domain")
    tb_set "$owner" "$device_path" "$TB_DEVICE" Policy '"auto"'
    acl=$(jq -c --arg uid "$TB_TEST_UID" '.BootACL | map("") | .[0]=$uid' <<< "$domain")
    tb_set "$owner" "$domain_path" "$TB_DOMAIN" BootACL "$acl" as
    tb_boot_change true
    check .boot_protection "$TB_STATE"
    tb_inventory > "$TB_TEST_DIR/inventory.json"
    check 'all(.domains[0].BootACL[]; .=="") and .stored[0].Policy=="manual"' "$TB_TEST_DIR/inventory.json"
    tb_boot_change false
    check '.boot_protection==false' "$TB_STATE"
    tb_inventory > "$TB_TEST_DIR/inventory.json"
    jq -e --argjson acl "$acl" '.domains[0].BootACL==$acl and .stored[0].Policy=="auto"' "$TB_TEST_DIR/inventory.json" >/dev/null
    jq --arg other "$TB_TEST_OTHER" 'del(.trusted[$other])' "$TB_STATE" | tb_json_write "$TB_STATE"
    tb_set "$owner" "$device_path" "$TB_DEVICE" Policy '"manual"'
    tb_set "$owner" "$domain_path" "$TB_DOMAIN" BootACL "$(jq -c 'map("")' <<< "$acl")" as
    ;;
  restart)
    cat /proc/sys/kernel/random/uuid > "$TB_RUNTIME/generation"
    reject tb_approve "$(cat "$TB_TEST_DIR/identity.json")" true
    tb_reconcile > "$TB_TEST_DIR/after.json"
    jq -e --arg uid "$TB_TEST_UID" '.devices[] | select(.identity.Uid==$uid) | .trusted and .status=="authorized"' "$TB_TEST_DIR/after.json" >/dev/null
    jq -e --arg uid "$TB_TEST_OTHER" '.devices[] | select(.identity.Uid==$uid) | .status=="connected"' "$TB_TEST_DIR/after.json" >/dev/null
    tb_inventory | jq -e '.manager.AuthMode=="disabled"' >/dev/null
    if [[ $TB_TEST_SECURITY == "secure" ]]; then
      # Bolt must challenge with the originally saved key, not provision a new
      # key merely because a reconnecting device advertises the same identity.
      tb_inventory | jq -e --arg uid "$TB_TEST_UID" \
        '.devices[] | select(.Uid==$uid) | .Key=="have" and (.AuthFlags | contains("secure"))' >/dev/null
      sha256sum --status -c "$TB_TEST_DIR/key-checksum"
    fi
    ;;
  daemon)
    TB_MARKER="$TB_TEST_DIR/enabled" TB_LOCK="$TB_TEST_DIR/root.lock"
    touch "$TB_MARKER"
    tb_daemon
    ;;
  status)
    snapshot=$(tb_public_snapshot)
    jq -e --arg owner "$(tb_owner)" '.owner==$owner' <<< "$snapshot" >/dev/null
    printf '%s\n' "$snapshot"
    ;;
  once)
    snapshot=$(tb_public_snapshot)
    id=$(jq -c --arg uid "$TB_TEST_OTHER" '.devices[] | select(.identity.Uid==$uid) | .identity' <<< "$snapshot")
    exec 9> "$TB_TEST_DIR/root.lock"
    flock -x 9
    tb_approve "$id" false > "$TB_TEST_DIR/once.json"
    jq -e --arg uid "$TB_TEST_OTHER" '.devices[] | select(.identity.Uid==$uid) | .status=="authorized" and (.trusted|not)' "$TB_TEST_DIR/once.json" >/dev/null
    ;;
  *) exit 64 ;;
esac
