#!/bin/bash

set -euo pipefail
source "$(dirname "$0")/base-test.sh"
export PATH="$ROOT/bin:$PATH"
source "$ROOT/install/helpers/thunderbolt-lock.sh"
source "$ROOT/install/helpers/thunderbolt-lock-setup.sh"
T=$(mktemp -d)
trap 'rm -rf "$T"' EXIT
TB_STATE=$T/state.json TB_CONFIG=$T/boltd.conf TB_MARKER=$T/enabled TB_APPROVAL=$T/approval
TB_RUNTIME=$T/runtime TB_LOCK=$T/root.lock
printf '%s\n' '{"version":1,"enabled":true,"trusted":{},"enrolled":{},"original_authmode":"enabled"}' >"$TB_STATE"
touch "$TB_MARKER"
tb_runtime_prepare
cat >"$T/inventory" <<'JSON'
{"owner":":1.5","manager":{"AuthMode":"disabled"},"domains":[{"Uid":"host","SecurityLevel":"user","IOMMU":true,"SysfsPath":"/sys/domain","path":"/domain","BootACL":["",""]}],"devices":[]}
JSON
edit() { jq "$@" "$T/inventory" >"$T/next"; mv "$T/next" "$T/inventory"; }
check() { jq -e "$1" "$2" >/dev/null || fail "$1"; }
reject() { if ("$@") >"$T/output" 2>"$T/error"; then fail "unexpected success: $*"; fi; }
add() {
  edit --arg uid "$1" '.devices += [{Uid:$uid,Name:"Dock",Vendor:"Example",Parent:"host",SysfsPath:("/sys/"+$uid),ConnectTime:1,Status:"connected",Stored:false,Secure:false,Key:"missing",Policy:"default",AuthFlags:"",path:("/devices/"+$uid),inode:$uid}]'
}
tb_inventory() { jq '. + {stored:[.devices[] | select(.Stored)]} | .devices |= map(select(.Status!="disconnected"))' "$T/inventory"; }
tb_properties() { jq -c --arg path "$2" '(.devices + .domains)[] | select(.path==$path)' "$T/inventory"; }
tb_bus() {
  local path=$3 member=$5
  printf '%s\n' "$member" >>"$T/operations"
  case $member in
    Authorize)
      [[ ! -e $T/auth-failure ]] || return 1
      edit --arg path "$path" '(.devices[] | select(.path==$path)).Status="authorized"' ;;
    EnrollDevice)
      edit --arg uid "$7" '(.devices[] | select(.Uid==$uid)) |= (.Stored=true | .Policy="manual" | .StoreTime=100)' ;;
    Policy)
      edit --arg path "$path" --arg value "$7" '(.devices[] | select(.path==$path)).Policy=$value' ;;
    *) return 1 ;;
  esac
}
systemctl() {
  [[ ! -e $T/service-failure ]] || return 1
  if [[ $1 == "show" ]]; then printf 'ActiveState=active\nUnitFileState=enabled\n'; fi
}
add initial
tb_lock_publish
check 'all(.devices[]; .Status=="authorized")' "$T/inventory"
check '.trusted=={}' "$TB_STATE"
pass 'boot/unlocked devices are allowed without permanent consent'
(
  mkdir "$T/default"
  cp "$T/inventory" "$T/default/inventory"
  cp "$TB_STATE" "$T/default/state.json"
  T=$T/default
  TB_STATE=$T/state.json TB_RUNTIME=$T/runtime TB_MARKER=$T/enabled TB_APPROVAL=$T/approval
  touch "$TB_MARKER"
  tb_runtime_prepare
  tb_lock_change lock
  add dock
  tb_lock_publish
  check '.devices[1].Status=="connected"' "$T/inventory"
  tb_lock_change unlock
  check '.devices[1].Status=="authorized"' "$T/inventory"
  check '.trusted.dock=={Uid:"dock",Name:"Dock",Vendor:"Example",Secure:false}' "$TB_RUNTIME/policy.json"
  check '.trusted=={}' "$TB_STATE"
  edit '.devices[1].Status="disconnected"'
  tb_lock_change lock
  tb_lock_change unlock
  tb_lock_change lock
  edit '.devices[1] |= (.Status="connected" | .ConnectTime=2 | .inode="reconnected")'
  tb_lock_publish
  check '.devices[1].Status=="authorized"' "$T/inventory"
  edit '.devices[1] |= (.Status="connected" | .Name="Different dock")'
  tb_lock_publish
  check '.devices[1].Status=="connected"' "$T/inventory"
  edit '.devices[1] |= (.Status="disconnected" | .Name="Dock")'
  rm "$TB_RUNTIME/policy.json"
  tb_runtime_prepare
  tb_lock_change lock
  edit '.devices[1].Status="connected"'
  tb_lock_publish
  check '.devices[1].Status=="connected"' "$T/inventory"
  pass 'default admission survives disconnected locks, keeps identity checks and expires at reboot'

  touch "$T/auth-failure"
  tb_lock_change unlock
  check '.devices[1].Status=="connected"' "$T/inventory"
  check '.trusted.dock==null' "$TB_RUNTIME/policy.json"
  add manual
  edit '.devices[2] |= (.Stored=true | .Policy="manual" | .StoreTime=200)'
  rm "$T/auth-failure"
  edit '.devices[1].inode="retry-connection"'
  tb_lock_publish
  check '.devices[1].Status=="authorized" and .devices[2].Status=="connected"' "$T/inventory"
  check '.trusted.dock!=null and .trusted.manual==null' "$TB_RUNTIME/policy.json"
  pass 'default runtime trust requires successful admission and preserves independent manual restrictions'
)
(
  mkdir "$T/secure-temporary"
  T=$T/secure-temporary
  TB_STATE=$T/state.json TB_RUNTIME=$T/runtime TB_MARKER=$T/enabled TB_APPROVAL=$T/approval
  printf '%s\n' '{"version":1,"enabled":true,"trusted":{},"enrolled":{}}' >"$TB_STATE"
  printf '%s\n' '{"owner":":1.5","manager":{"AuthMode":"disabled"},"domains":[],"devices":[]}' >"$T/inventory"
  touch "$TB_MARKER"
  tb_runtime_prepare
  add input
  mkdir "$T/device"
  printf 'input\n' >"$T/device/unique_id"
  printf '0\n' >"$T/device/authorized"
  : >"$T/device/key"
  edit --arg path "$T/device" --arg inode "$(stat -Lc '%i' "$T/device")" '.devices[0] |= (.Secure=true | .SysfsPath=$path | .inode=$inode)'
  tb_lock_publish
  [[ $(cat "$T/device/authorized") == "1" && $(cat "$T/device/key") =~ ^[0-9a-f]{64}$ ]] || fail 'temporary secure admission did not provision a key'
  key=$(cat "$T/device/key")
  edit '.devices[0].Status="authorized"'
  tb_lock_change lock
  printf '0\n' >"$T/device/authorized"
  : >"$T/device/key"
  edit '.devices[0] |= (.Status="connected" | .ConnectTime=2)'
  tb_lock_publish
  [[ $(cat "$T/device/authorized") == "2" && $(cat "$T/device/key") == $key ]] || fail 'locked temporary reconnect did not challenge with the original key'
  check '.trusted=={} and .enrolled=={}' "$TB_STATE"
  printf '0\n' >"$T/device/authorized"
  edit '.devices[0].Name="Different dock"'
  tb_lock_publish
  [[ $(cat "$T/device/authorized") == "0" ]] || fail 'temporary key admitted a changed identity'
  edit '.devices[0] |= (.Name="Dock" | .Secure=false)'
  tb_lock_publish
  [[ $(cat "$T/device/authorized") == "0" ]] || fail 'temporary key permitted a capability downgrade'
  edit '.devices[0].Secure=true'
  rm -r "$TB_RUNTIME/keys"
  tb_lock_publish
  [[ $(cat "$T/device/authorized") == "0" && ! -e $TB_RUNTIME/keys ]] || fail 'locked reconnect initialized a missing temporary key'
  pass 'temporary secure input reconnects with its boot key without permanent enrollment or key replacement'
)
tb_lock_change lock
add locked
tb_lock_publish
check '.devices[1].Status=="connected"' "$T/inventory"
tb_lock_change lock
check '.trusted.locked==null' "$TB_RUNTIME/policy.json"
pass 'lock freezes trust; repeated lock and reconciliation never learn arrivals'
touch "$TB_APPROVAL"
tb_lock_change unlock
check '.devices[1].Status=="authorized"' "$T/inventory"
check '.trusted=={}' "$TB_STATE"
add denied
tb_lock_change unlock
check '.devices[2].Status=="connected"' "$T/inventory"
tb_lock_change lock
add later
tb_lock_change unlock
check '.devices[2].Status=="connected" and .devices[3].Status=="authorized"' "$T/inventory"
pass 'optional mode admits locked arrivals temporarily and retains earlier denials'
edit '.devices[1].Status="disconnected"'
tb_lock_change lock
tb_lock_change unlock
edit '.devices[1] |= (.Status="connected" | .ConnectTime=2 | .inode="reconnected")'
tb_lock_publish
check '.devices[1].Status=="authorized"' "$T/inventory"
tb_lock_change lock
tb_lock_change unlock
check '.devices[1].Status=="authorized"' "$T/inventory"
check '.trusted=={}' "$TB_STATE"
pass 'temporary approval survives disconnecting across another lock and unlock'
edit '.devices[1] |= (.Status="connected" | .Name="Different dock")'
tb_lock_publish
check '.devices[1].Status=="connected"' "$T/inventory"
edit '.devices[1].Name="Dock"'
tb_lock_publish
check '.devices[1].Status=="authorized"' "$T/inventory"
pass 'retained temporary approval still requires the same device identity'
identity=$(tb_snapshot | jq -c '.devices[2].identity')
reject tb_lock_approve "$(jq '.inode="reconnected"' <<<"$identity")"
reject tb_lock_approve "$(jq '.owner=":1.6"' <<<"$identity")"
tb_lock_change lock
reject tb_lock_approve "$identity"
tb_lock_change unlock
tb_lock_approve "$identity" >/dev/null
check '.trusted.denied=={Uid:"denied",Name:"Dock",Vendor:"Example",Secure:false}' "$TB_STATE"
check '.enrolled.denied.StoreTime==100' "$TB_STATE"
check '.devices[2].Stored and .devices[2].Status=="authorized" and .devices[2].Policy=="manual"' "$T/inventory"
pass 'permanent approval binds connection/generation and records manual enrollment ownership'
# Secure challenges cannot initialize a replacement key implicitly.
edit '(.devices[2] | .Status="connected" | .Secure=true | .Key="missing") as $d | .devices[2]=$d'
tb_lock_publish
check '.devices[2].Status=="connected"' "$T/inventory"
jq '.trusted.denied.Secure=true' "$TB_STATE" | tb_json_write "$TB_STATE"
edit '.devices[2].Key="have"'
touch "$T/auth-failure"
tb_lock_publish
count=$(wc -l <"$T/operations")
tb_lock_publish
[[ $(wc -l <"$T/operations") == "$count" ]] || fail 'failed authorization loops on its own events'
rm "$T/auth-failure"
edit '.devices[2].inode="new-connection"'
tb_lock_publish
check '.devices[2].Status=="authorized"' "$T/inventory"
edit '.devices[2].Status="connected" | .devices[2].Secure=false'
tb_lock_publish
check '.devices[2].Status=="connected"' "$T/inventory"
edit '.devices[2].Secure=true'
tb_lock_publish
pass 'secure reconnect requires its saved key and capability; failed challenges do not spin'
saved=$(jq -c .trusted.denied "$TB_STATE")
tb_lock_forget "$saved" >/dev/null
check '.devices[2].Status=="authorized" and .devices[2].Key=="have"' "$T/inventory"
check '.trusted.denied==null' "$TB_STATE"
tb_lock_change lock
check '.trusted.denied==null' "$TB_RUNTIME/policy.json"
tb_lock_change unlock
edit '.devices[2].Status="connected" | .devices[2].inode="another-connection"'
tb_lock_publish
check '.devices[2].Status=="connected"' "$T/inventory"
tb_lock_change lock
tb_lock_change unlock
check '.devices[2].Status=="connected"' "$T/inventory"
reject tb_lock_forget "$saved"
pass 'forget retains the active PCIe connection and keys, but revokes future trust'
# Owned manual records can return to automatic policy only when consent and
# the exact store generation match. Forgotten, external and replaced stay put.
state='{"trusted":{"denied":{"Uid":"denied","Name":"Dock","Vendor":"Example"}},"enrolled":{"denied":{"Uid":"denied","Name":"Dock","Vendor":"Example","StoreTime":100}}}'
handoff=$(tb_inventory | tb_handoff_policies "$state")
jq -e '.policies.denied=="auto"' <<<"$handoff" >/dev/null || fail 'owned record handoff'
edit '.devices[2].StoreTime=101'
handoff=$(tb_inventory | tb_handoff_policies "$state")
[[ $handoff == '{"policies":{},"acls":{}}' ]] || fail 'replacement manual policy changed'
pass 'disable handoff preserves recreated and manually managed Bolt records'
add manual
edit '(.devices[] | select(.Uid=="manual")) |= (.Stored=true | .Policy="manual" | .StoreTime=200)'
rm "$TB_APPROVAL"
tb_lock_change unlock
check 'any(.devices[]; .Uid=="manual" and .Status=="connected")' "$T/inventory"
touch "$TB_APPROVAL"
tb_lock_change unlock
check '.trusted.manual==null' "$TB_RUNTIME/policy.json"
pass 'automatic admission preserves independently restricted manual devices'
tb_lock_change lock
tb_config_write "$TB_CONFIG" disabled
mkdir -p "$TB_RUNTIME/keys"
key_file=$TB_RUNTIME/keys/$(printf recovery | sha256sum)
key_file=${key_file%% *}.json
printf '{"key":"boot-secret"}\n' >"$key_file"
chmod 600 "$key_file"
tb_config_checkpoint
cp "$TB_RUNTIME/policy.json" "$T/frozen"
cp "$key_file" "$T/key-before-recovery"
rm -r "$TB_RUNTIME/keys"
jq '.mode="unlocked" | .trusted={}' "$TB_RUNTIME/policy.json" | tb_json_write "$TB_RUNTIME/policy.json"
rm "$TB_MARKER"
tb_config_restore
cmp -s "$TB_RUNTIME/policy.json" "$T/frozen" || fail 'rollback widened the frozen runtime policy'
cmp -s "$key_file" "$T/key-before-recovery" || fail 'rollback lost the boot key for trusted input'
[[ $(stat -c %a "$TB_RUNTIME/keys") == "700" ]] || fail 'recovered boot keys are not private'
[[ -e $TB_MARKER && ! -e ${TB_STATE%/*}/setup-recovery.json ]] || fail 'rollback did not restore ownership'
pass 'setup/removal recovery restores the frozen policy along with configuration'
tb_config_checkpoint
jq '.boot_id="previous-boot"' "${TB_STATE%/*}/setup-recovery.json" | tb_json_write "${TB_STATE%/*}/setup-recovery.json"
tb_config_restore
tb_runtime_prepare
check '.mode=="unlocked" and .trusted=={}' "$TB_RUNTIME/policy.json"
[[ ! -e $TB_RUNTIME/keys ]] || fail 'recovery revived keys from another boot'
pass 'recovery after reboot expires temporary consent and keys'
(
  tb_runtime_prepare() {
    if ! flock -n "$TB_LOCK" true; then touch "$T/startup-serialized"; fi
    return 1
  }
  reject tb_lock_daemon
  [[ -e $T/startup-serialized ]] || fail 'daemon startup can overwrite a concurrent lock transition'
)
pass 'daemon initialization holds the same real lock as policy transitions'
(
  export TB_TEST_DIR=$T XDG_RUNTIME_DIR=$T/session
  cat >"$T/notify-fixture" <<'BASH'
TB_MARKER=$TB_TEST_DIR/enabled
omarchy-shell() { printf '{"locked":false}\n'; }
omarchy-notification-wait() { :; }
omarchy-notification-send() { printf '%s\n' "$*" >>"$TB_TEST_DIR/sent"; }
omarchy-notification-dismiss() { :; }
tb_public_snapshot() {
  [[ -e $TB_TEST_DIR/snapshot ]] || return 1
  cat "$TB_TEST_DIR/snapshot"
}
BASH
  sed "s|source .*thunderbolt-lock.sh.*|source $T/notify-fixture|" "$ROOT/bin/omarchy-thunderbolt-lock-notify" >"$T/notify"
  reject bash "$T/notify"
  reject bash "$T/notify"
  [[ $(wc -l <"$T/sent") == 1 ]] || fail 'outage warning absent or repeated'
  printf '%s\n' '{"mode":"approval","devices":[],"warnings":[],"error":""}' >"$T/snapshot"
  bash "$T/notify"
  [[ ! -e $XDG_RUNTIME_DIR/omarchy-thunderbolt-lock-notices/warning ]] || fail 'recovery left a stale warning'
  rm "$T/snapshot"
  reject bash "$T/notify"
  [[ $(wc -l <"$T/sent") == 2 ]] || fail 'subsequent outage was hidden'
)
pass 'notification outages warn once, retry, and clear on recovery'
for entry in omarchy-thunderbolt-lock-admin omarchy-thunderbolt-lock-approve omarchy-thunderbolt-lock-daemon; do
  sed -e "s|source /usr/bin/omarchy-security-functions|source $ROOT/bin/omarchy-security-functions|" \
    -e 's|source /usr/share/omarchy/install/helpers/thunderbolt-lock.sh|exit 126|' "$ROOT/bin/$entry" >"$T/entry"
  chmod 755 "$T/entry"
  printf 'set -p\n' >"$T/decoy"
  reject env BASH_ENV="$T/decoy" /usr/bin/bash "$T/entry" -p
  printf 'touch "%s"\n' "$T/injected" >"$T/startup"
  reject env BASH_ENV="$T/startup" "$T/entry"
  [[ ! -e $T/injected ]] || fail 'privileged startup injection'
done
pass 'all Bolt root entrypoints reject unsafe Bash startup'
