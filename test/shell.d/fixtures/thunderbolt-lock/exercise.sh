#!/bin/bash

# Real busctl/boltd calls on a private test bus. Python only supplies UMockdev
# hardware; policy behavior and assertions are Bash.
set -euo pipefail
source "$ROOT/install/helpers/thunderbolt-lock.sh"
source "$ROOT/install/helpers/thunderbolt-lock-setup.sh"
TB_STATE=$TB_TEST_DIR/policy.json TB_RUNTIME=$TB_TEST_DIR/runtime
TB_MARKER=$TB_TEST_DIR/enabled TB_APPROVAL=$TB_TEST_DIR/approval TB_LOCK=$TB_TEST_DIR/lock
# The private fixture has no systemd unit; all device and policy operations are real.
systemctl() { [[ $1 == "is-active" || ( $1 == "start" && $2 == "bolt.service" ) ]]; }
[[ $1 != "daemon" ]] || { tb_lock_daemon; exit; }
exec 9>"$TB_LOCK"
flock 9
case $1 in
  initial)
    printf '%s\n' '{"version":1,"enabled":true,"trusted":{},"enrolled":{},"original_authmode":"enabled"}' >"$TB_STATE"
    touch "$TB_MARKER"
    tb_runtime_prepare
    tb_lock_publish
    tb_inventory | jq -e 'all(.devices[]; .Status | startswith("authorized"))' >/dev/null
    ;;
  lock|unlock) tb_lock_change "$1" ;;
  optional) touch "$TB_APPROVAL"; tb_lock_change unlock ;;
  approve)
    identity=$(tb_snapshot | jq -ce --arg uid "$TB_TEST_UID" '.devices[] | select(.identity.Uid==$uid) | .identity')
    tb_lock_approve "$identity" >/dev/null
    tb_inventory | jq -e --arg uid "$TB_TEST_UID" '.devices[] | select(.Uid==$uid) | .Stored and .Policy=="manual" and (.Status | startswith("authorized"))' >/dev/null
    if [[ $TB_TEST_SECURITY == "secure" ]]; then
      tb_inventory | jq -e --arg uid "$TB_TEST_UID" '.devices[] | select(.Uid==$uid) | .Key=="have"' >/dev/null
      if [[ -e $TB_TEST_DIR/temporary-key-checksum ]]; then
        jq -Rr . "$TB_TEST_KEYS/$TB_TEST_UID" | sha256sum >"$TB_TEST_DIR/promoted-key"
        cmp "$TB_TEST_DIR/promoted-key" "$TB_TEST_DIR/temporary-key-checksum"
      fi
      if [[ ! -e $TB_TEST_DIR/key-checksum ]]; then sha256sum "$TB_TEST_KEYS/$TB_TEST_UID" >"$TB_TEST_DIR/key-checksum"; fi
    fi
    ;;
  secure)
    tb_inventory | jq -e --arg uid "$TB_TEST_UID" '.devices[] | select(.Uid==$uid) | (.AuthFlags | contains("secure"))' >/dev/null
    sha256sum --status -c "$TB_TEST_DIR/key-checksum"
    ;;
  forget)
    identity=$(jq -ce --arg uid "$TB_TEST_UID" '.trusted[$uid]' "$TB_STATE")
    tb_lock_forget "$identity" >/dev/null
    ;;
  allowed|blocked)
    inventory=$(tb_inventory)
    jq -e --arg uid "$TB_TEST_UID" --arg desired "$1" '
      .devices[] | select(.Uid==$uid) | if $desired=="allowed" then (.Status | startswith("authorized")) else .Status=="connected" end' <<<"$inventory" >/dev/null
    ;;
  temporary)
    jq -e --arg uid "$TB_TEST_UID" '.trusted[$uid]==null' "$TB_STATE" >/dev/null
    ;;
  temporary-key)
    device=$(tb_inventory | jq -ce --arg uid "$TB_TEST_UID" '.devices[] | select(.Uid==$uid)')
    jq -e '.Secure and (.Stored | not)' <<<"$device" >/dev/null
    binding=$(jq -cS '{Uid,Name,Vendor,Secure}' <<<"$device")
    digest=$(printf '%s' "$binding" | sha256sum)
    key_file=$TB_RUNTIME/keys/${digest%% *}.json
    jq -e --argjson identity "$binding" '.identity==$identity and .ready and (.key | test("^[0-9a-f]{64}$"))' "$key_file" >/dev/null
    [[ $(stat -c %a "$TB_RUNTIME/keys") == "700" && $(stat -c %a "$key_file") == "600" ]]
    jq -r .key "$key_file" | sha256sum >"$TB_TEST_DIR/current-temporary-key"
    if [[ ! -e $TB_TEST_DIR/temporary-key-checksum ]]; then cp "$TB_TEST_DIR/current-temporary-key" "$TB_TEST_DIR/temporary-key-checksum"; fi
    cmp "$TB_TEST_DIR/current-temporary-key" "$TB_TEST_DIR/temporary-key-checksum"
    jq -e --arg uid "$TB_TEST_UID" '.trusted[$uid]==null and .enrolled[$uid]==null' "$TB_STATE" >/dev/null
    ;;
  temporary-secure)
    tb_inventory | jq -e --arg uid "$TB_TEST_UID" '.devices[] | select(.Uid==$uid) | (.Stored | not) and (.AuthFlags | contains("secure"))' >/dev/null
    ;;
  runtime-trusted)
    tb_inventory | jq -e --arg uid "$TB_TEST_UID" --argjson runtime "$(tb_runtime)" '
      .devices[] | select(.Uid==$uid) | $runtime.trusted[$uid]=={Uid,Name,Vendor,Secure}' >/dev/null
    ;;
  snapshot)
    snapshot=$(tb_public_snapshot)
    jq -e --arg owner "$(tb_owner)" '.owner==$owner' <<<"$snapshot" >/dev/null
    ;;
  restart-policy)
    rm -rf "$TB_RUNTIME/policy.json" "$TB_RUNTIME/keys"
    rm -f "$TB_TEST_DIR/temporary-key-checksum"
    tb_runtime_prepare
    tb_lock_change unlock
    ;;
  *) exit 64 ;;
esac
