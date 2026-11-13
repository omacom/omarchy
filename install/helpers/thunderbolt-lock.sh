# shellcheck shell=bash
# Shared by the root controller and session commands. These paths are fixed at
# privileged entrypoints; tests may source the functions in an isolated fixture.
TB_STATE=/var/lib/omarchy/thunderbolt-lock/policy.json
TB_MARKER=/etc/omarchy/thunderbolt-lock.enabled
TB_RUNTIME=/run/omarchy-thunderbolt-lock
TB_LOCK=/run/lock/omarchy-usb-lock.lock
TB_SERVICE=omarchy-thunderbolt-lock.service
TB_BOLT=org.freedesktop.bolt
TB_MANAGER=org.freedesktop.bolt1.Manager
TB_DEVICE=org.freedesktop.bolt1.Device
TB_DOMAIN=org.freedesktop.bolt1.Domain
TB_PATH=/org/freedesktop/bolt
TB_APPROVAL=/etc/omarchy/usb-lock.approval
TB_TRUST_JQ='def trusted($state): $state.trusted[.Uid] == {Uid,Name,Vendor,Secure} and
  ((.Secure | not) or (.Stored and (.Key | IN("have","new"))));'

tb_fail() { printf '%s\n' "$*" >&2; return 1; }

tb_json_write() {
  local target=$1 mode=${2:-600} temporary
  temporary=$(mktemp "${target%/*}/.thunderbolt.XXXXXX") || return 1
  if jq -cS . > "$temporary" && chmod "$mode" "$temporary" && sync "$temporary" &&
    mv -fT -- "$temporary" "$target" && sync "${target%/*}"; then
    return 0
  else
    rm -f -- "$temporary"
    return 1
  fi
}

tb_state() {
  jq -ce 'select(.version == 1 and (.trusted | type == "object") and (.enabled | type == "boolean"))' "$TB_STATE"
}

tb_bus() {
  busctl --system --auto-start=no --timeout=10 --json=short "$@"
}

tb_owner() {
  tb_bus call org.freedesktop.DBus /org/freedesktop/DBus org.freedesktop.DBus GetNameOwner s "$TB_BOLT" | jq -er '.data[0]'
}

tb_properties() {
  tb_bus call "$1" "$2" org.freedesktop.DBus.Properties GetAll s "$3" | jq -ce '.data[0] | map_values(.data)'
}

tb_set() {
  local owner=$1 path=$2 interface=$3 key=$4 value=$5 signature=${6:-s} current
  local -a values=()
  current=$(tb_properties "$owner" "$path" "$interface") || return 1
  if ! jq -e --arg key "$key" --argjson value "$value" '.[$key] == $value' <<< "$current" >/dev/null; then
    if [[ $signature == "as" ]]; then
      mapfile -t values < <(jq -r '.[]' <<< "$value")
      tb_bus set-property "$owner" "$path" "$interface" "$key" as "${#values[@]}" "${values[@]}" >/dev/null || return 1
    else
      tb_bus set-property "$owner" "$path" "$interface" "$key" s "$(jq -r . <<< "$value")" >/dev/null || return 1
    fi
  fi
  # Bolt rejects no-op BootACL writes; even skipped writes are read back.
  current=$(tb_properties "$owner" "$path" "$interface") || return 1
  jq -e --arg key "$key" --argjson value "$value" '.[$key] == $value' <<< "$current" >/dev/null ||
    tb_fail "Bolt did not retain the requested $key"
}

tb_inventory() {
  local owner manager paths path item inode domains='[]' devices='[]' stored='[]'
  owner=$(tb_owner) || return 1
  manager=$(tb_properties "$owner" "$TB_PATH" "$TB_MANAGER") || return 1
  paths=$(tb_bus call "$owner" "$TB_PATH" "$TB_MANAGER" ListDomains | jq -cer '.data[0]') || return 1
  while IFS= read -r path; do
    item=$(tb_properties "$owner" "$path" "$TB_DOMAIN" | jq -c --arg path "$path" '. + {path:$path}') || return 1
    domains=$(jq -c --argjson item "$item" '. + [$item]' <<< "$domains") || return 1
  done < <(jq -r '.[]' <<< "$paths")
  paths=$(tb_bus call "$owner" "$TB_PATH" "$TB_MANAGER" ListDevices | jq -cer '.data[0]') || return 1
  while IFS= read -r path; do
    item=$(tb_properties "$owner" "$path" "$TB_DEVICE" | jq -c --arg path "$path" '. + {path:$path}') || return 1
    [[ $(jq -r .Type <<< "$item") == "peripheral" ]] || continue
    if jq -e .Stored <<< "$item" >/dev/null; then
      stored=$(jq -c --argjson item "$item" '. + [$item]' <<< "$stored") || return 1
    fi
    [[ $(jq -r .Status <<< "$item") != "disconnected" ]] || continue
    inode=$(stat -Lc '%i' -- "$(jq -r .SysfsPath <<< "$item")") || return 1
    item=$(jq -c --arg inode "$inode" '. + {inode:$inode}' <<< "$item") || return 1
    devices=$(jq -c --argjson item "$item" '. + [$item]' <<< "$devices") || return 1
  done < <(jq -r '.[]' <<< "$paths")
  [[ $(tb_owner) == $owner ]] || { tb_fail "Bolt restarted while reading its inventory"; return 1; }
  jq -cn --arg owner "$owner" --argjson manager "$manager" --argjson domains "$domains" \
    --argjson devices "$devices" --argjson stored "$stored" '
    {owner:$owner,manager:$manager,domains:$domains,stored:$stored,devices:[$devices[] |
      . + {Secure:((.Domain as $domain | any($domains[]; .Uid == $domain and .SecurityLevel == "secure"))
        and (.AuthFlags | contains("nokey") | not))}]}'
}

tb_read_inventory() {
  local inventory
  inventory=$(tb_inventory) || return 1
  jq -e '.manager.AuthMode == "disabled"' <<< "$inventory" >/dev/null || {
    tb_fail "Bolt automatic authorization is enabled; protection is not active"
    return 1
  }
  printf '%s\n' "$inventory"
}

tb_identity() {
  jq -c --arg owner "$1" --arg generation "$2" \
    '{owner:$owner,generation:$generation,path,inode,Uid,Name,Vendor,Parent,SysfsPath,ConnectTime,Secure}'
}

tb_current() {
  local expected=$1 inventory owner generation device identity
  inventory=$(tb_read_inventory) || return 1
  owner=$(jq -r .owner <<< "$inventory")
  generation=$(< "$TB_RUNTIME/generation") || return 1
  while IFS= read -r device; do
    identity=$(tb_identity "$owner" "$generation" <<< "$device") || return 1
    if jq -e --argjson expected "$expected" '. == $expected' <<< "$identity" >/dev/null; then
      jq -cn --arg owner "$owner" --argjson device "$device" '{owner:$owner,device:$device}'
      return 0
    fi
  done < <(jq -c '.devices[]' <<< "$inventory")
  tb_fail "That Thunderbolt device was removed or changed. Open its latest notification."
}

tb_prepare_key() (
  local identity=$1 current key key_fd
  current=$(tb_current "$identity") || return 1
  # Bolt creates keys for stored devices itself. For a new device, disabled
  # AuthMode prevents enrollment before authorization. Seed the kernel key so
  # Authorize provisions it and the subsequent enrollment imports it into Bolt.
  jq -e '.device.Secure and (.device.Stored | not)' <<< "$current" >/dev/null || return 0
  cd -- "$(jq -r .device.SysfsPath <<< "$current")" || return 1
  [[ $(stat -Lc '%i' .) == $(jq -r .device.inode <<< "$current") &&
    $(cat unique_id) == "$(jq -r .device.Uid <<< "$current")" ]] || {
    tb_fail 'The Thunderbolt connection changed before key setup'; return 1;
  }
  # Pin the attribute in the original directory; do not follow a replacement
  # connection at the same path, or truncate an existing key on a retry.
  exec {key_fd}<>key || return 1
  key=$(cat key) || return 1
  if [[ -z $key ]]; then
    [[ $(cat authorized) == "0" ]] || { tb_fail 'Reconnect the device before saving secure approval'; return 1; }
    key=$(openssl rand -hex 32) || return 1
    [[ $key =~ ^[0-9a-f]{64}$ ]] || return 1
    tb_current "$identity" >/dev/null || return 1
    printf '%s' "$key" >&"$key_fd" || return 1
    [[ $(cat key) == $key ]] || { tb_fail 'Could not verify the Thunderbolt key'; return 1; }
  else
    [[ $key =~ ^[0-9a-fA-F]{64}$ ]] || { tb_fail 'The Thunderbolt key is invalid'; return 1; }
  fi
)

# Bolt cannot keep a key for an unstored device. Keep temporary keys in /run
# and use the same kernel provisioning (1) and secure challenge (2) interface.
# Never enroll these devices or replace a failed challenge with a new key.
tb_temporary_authorize() (
  local identity=$1 initialize=$2 current binding digest path record key level key_fd auth_fd
  current=$(tb_current "$identity") || return 1
  jq -e '.device.Secure and (.device.Stored | not)' <<<"$current" >/dev/null || return 1
  binding=$(jq -cS '{Uid,Name,Vendor,Secure}' <<<"$identity") || return 1
  digest=$(printf '%s' "$binding" | sha256sum) || return 1
  path=$TB_RUNTIME/keys/${digest%% *}.json
  if [[ -e $path ]]; then
    record=$(jq -ce --argjson identity "$binding" 'select(.identity==$identity and (.ready | type=="boolean"))' "$path") || return 1
    key=$(jq -er .key <<<"$record") || return 1
    if jq -e .ready <<<"$record" >/dev/null; then
      level=2
    else
      [[ $initialize == "true" ]] || return 1
      level=1
    fi
  else
    [[ $initialize == "true" ]] || return 1
    key=$(openssl rand -hex 32) || return 1
    record=$(printf '%s' "$key" | jq -Rsc --argjson identity "$binding" '{identity:$identity,key:.,ready:false}') || return 1
    install -d -m 700 "$TB_RUNTIME/keys" || return 1
    tb_json_write "$path" <<<"$record" || return 1
    level=1
  fi
  [[ $key =~ ^[0-9a-f]{64}$ ]] || return 1
  cd -- "$(jq -r .device.SysfsPath <<<"$current")" || return 1
  [[ $(stat -Lc '%i' .) == $(jq -r .device.inode <<<"$current") &&
    $(cat unique_id) == "$(jq -r .device.Uid <<<"$current")" ]] || return 1
  # Pin both attributes to this connection before writing either one. A
  # disconnect cannot redirect the challenge to a replacement directory.
  exec {key_fd}<>key {auth_fd}<>authorized || return 1
  [[ $(cat authorized) == "0" ]] || return 1
  tb_current "$identity" >/dev/null || return 1
  printf '%s' "$key" >&"$key_fd" || return 1
  [[ $(cat key) == $key ]] || return 1
  tb_current "$identity" >/dev/null || return 1
  printf '%s' "$level" >&"$auth_fd" || return 1
  [[ $(cat authorized) == "1" || $(cat authorized) == "2" ]] || return 1
  # A pending provision may be retried only with unlocked admission. Once
  # confirmed, every later connection must challenge the original boot key.
  jq '.ready=true' <<<"$record" | tb_json_write "$path"
)

tb_approve() {
  local identity=$1 permanent=$2 initialize=${3:-false} current owner path status state
  state=$(tb_state) || return 1
  jq -e .enabled <<< "$state" >/dev/null || { tb_fail "Thunderbolt protection is disabled"; return 1; }
  current=$(tb_current "$identity") || return 1
  owner=$(jq -r .owner <<< "$current")
  path=$(jq -r .device.path <<< "$current")
  status=$(jq -r .device.Status <<< "$current")
  case "$status" in
    connected|auth-error)
      if [[ $permanent == "true" ]]; then
        if [[ $initialize == "true" ]]; then
          tb_prepare_key "$identity" || return 1
        else
          jq -e '(.device.Secure | not) or (.device.Stored and (.device.Key | IN("have","new")))' <<< "$current" >/dev/null || {
            tb_fail 'A secure key requires explicit device approval'; return 1;
          }
        fi
      fi
      current=$(tb_current "$identity") || return 1
      tb_bus call "$owner" "$path" "$TB_DEVICE" Authorize s '' >/dev/null || return 1 ;;
    authorized|authorized-newkey|authorized-secure) ;;
    *) tb_fail "Device authorization is still in progress; try again"; return 1 ;;
  esac
  current=$(tb_current "$identity") || return 1
  jq -e '.device.Status | IN("authorized","authorized-newkey","authorized-secure")' <<< "$current" >/dev/null || {
    tb_fail "Could not confirm device authorization; try again"; return 1;
  }
  if [[ $permanent == "true" ]]; then
    if ! jq -e .device.Stored <<< "$current" >/dev/null; then
      # Save enrollment intent before Bolt writes its record, so a lost reply
      # can be retried without confusing our record with a pre-existing one.
      state=$(jq --argjson device "$(jq -c .device <<< "$current")" \
        '.enrolled[$device.Uid] = ($device | {Uid,Name,Vendor})' <<< "$state") || return 1
      tb_json_write "$TB_STATE" <<< "$state" || return 1
      tb_bus call "$owner" "$TB_PATH" "$TB_MANAGER" EnrollDevice sss "$(jq -r .device.Uid <<< "$current")" manual '' >/dev/null || return 1
    fi
    current=$(tb_current "$identity") || return 1
    jq -e .device.Stored <<< "$current" >/dev/null || { tb_fail "Could not confirm saved device information; try again"; return 1; }
    jq -e '(.device.Secure | not) or (.device.Key | IN("have","new"))' <<< "$current" >/dev/null || {
      tb_fail 'Secure approval has no saved key. Safely disconnect, reconnect, and approve the device again.'; return 1;
    }
    jq --argjson device "$(jq -c .device <<< "$current")" '
      if .enrolled[$device.Uid] == ($device | {Uid,Name,Vendor}) then
        .enrolled[$device.Uid] = ($device | {Uid,Name,Vendor,StoreTime})
      else . end |
      .trusted[$device.Uid] = ($device | {Uid,Name,Vendor,Secure})' <<< "$state" |
      tb_json_write "$TB_STATE" || return 1
  fi
  tb_snapshot
}

tb_boot_apply() {
  local saved=$1 inventory owner item uid value path
  inventory=$(tb_inventory) || return 1
  owner=$(jq -r .owner <<< "$inventory")
  jq -e --argjson saved "$saved" '
    (($saved.policies | keys) - [.stored[].Uid] | length == 0) and
    (($saved.acls | keys) - [.domains[] | select(.SysfsPath != "") | .Uid] | length == 0)' <<< "$inventory" >/dev/null || {
    tb_fail "Reconnect the original controllers and restore missing Bolt records before recovery"; return 1;
  }
  while IFS= read -r item; do
    uid=$(jq -r .Uid <<< "$item")
    value=$(jq -c --arg uid "$uid" '.policies[$uid] // empty' <<< "$saved") || return 1
    [[ -n $value ]] || continue
    tb_set "$owner" "$(jq -r .path <<< "$item")" "$TB_DEVICE" Policy "$value" || return 1
  done < <(jq -c '.stored[]' <<< "$inventory")
  # Changing a device policy can update firmware ACLs, so restore ACLs last.
  while IFS= read -r item; do
    uid=$(jq -r .Uid <<< "$item")
    value=$(jq -c --arg uid "$uid" '.acls[$uid] // empty' <<< "$saved") || return 1
    [[ -n $value ]] || continue
    [[ $(jq length <<< "$value") == $(jq '.BootACL | length' <<< "$item") ]] || {
      tb_fail "Firmware boot allowlist capacity changed"; return 1;
    }
    tb_set "$owner" "$(jq -r .path <<< "$item")" "$TB_DOMAIN" BootACL "$value" as || return 1
  done < <(jq -c '.domains[]' <<< "$inventory")
}

# Runtime consent is separate from permanent approvals and survives daemon
# restarts, but not reboot. Never infer consent from Bolt's stored-device list.
tb_runtime() {
  jq -ce 'select(.mode | IN("unlocked","locked","approval"))' "$TB_RUNTIME/policy.json"
}

tb_runtime_prepare() {
  install -d -m 755 "$TB_RUNTIME" || return 1
  if [[ ! -e $TB_RUNTIME/policy.json ]]; then
    printf '%s\n' '{"mode":"unlocked","trusted":{},"denied":{},"admit":[],"revoked":{}}' | tb_json_write "$TB_RUNTIME/policy.json" || return 1
  fi
  if [[ ! -e $TB_RUNTIME/generation ]]; then
    cat /proc/sys/kernel/random/uuid >"$TB_RUNTIME/generation" || return 1
    chmod 644 "$TB_RUNTIME/generation" || return 1
  fi
}

tb_snapshot() {
  local state runtime inventory generation
  state=$(tb_state) || return 1
  runtime=$(tb_runtime) || return 1
  inventory=$(tb_read_inventory) || return 1
  generation=$(<"$TB_RUNTIME/generation") || return 1
  jq -c --argjson state "$state" --argjson runtime "$runtime" --arg generation "$generation" --arg error "${1:-}" "$TB_TRUST_JQ"'
    .owner as $owner |
    {available:true,owner:$owner,generation:$generation,mode:$runtime.mode,error:$error,
     devices:[.devices[] | . as $d | {
       identity:({owner:$owner,generation:$generation}+{path,inode,Uid,Name,Vendor,Parent,SysfsPath,ConnectTime,Secure}),
       trusted:($d | trusted($state)),status:.Status,flags:.AuthFlags}],
     warnings:([.domains[] | if .SecurityLevel=="none" then
       "Firmware permits PCIe connections without authorization. Lock protection cannot block them."
       elif (.SecurityLevel | IN("user","secure","dponly","usbonly","nopcie") | not) then
       "The Thunderbolt controller authorization mode could not be verified."
       else empty end] + [.devices[] | select((.Status | startswith("authorized")) and (.AuthFlags | contains("boot"))) |
       "Firmware authorized a Thunderbolt device before Linux started. This policy does not provide boot protection."] | unique)}' <<<"$inventory"
}

tb_lock_reconcile() {
  local state runtime inventory owner generation device identity authorize initialize error=""
  state=$(tb_state) || return 1
  jq -e .enabled <<<"$state" >/dev/null || return 1
  inventory=$(tb_read_inventory) || return 1
  runtime=$(tb_runtime) || return 1
  owner=$(jq -r .owner <<<"$inventory")
  generation=$(<"$TB_RUNTIME/generation") || return 1
  runtime=$(jq -c --argjson inventory "$inventory" --arg owner "$owner" --arg generation "$generation" '
    .failed = [(.failed // [])[] | . as $failed | select(any($inventory.devices[];
      $failed == {owner:$owner,generation:$generation,path,inode,Uid,Name,Vendor,Parent,SysfsPath,ConnectTime,Secure}))]' <<<"$runtime") || return 1
  while IFS= read -r device; do
    identity=$(tb_identity "$owner" "$generation" <<<"$device") || return 1
    authorize=tb_approve initialize=false
    # Unstored secure devices authenticate with their private boot key.
    if jq -e '.Secure and (.Stored | not)' <<<"$device" >/dev/null; then
      authorize=tb_temporary_authorize
      initialize=$(jq -c --argjson identity "$identity" '.mode=="unlocked" or
        (.mode=="approval" and any(.admit[]; .==$identity))' <<<"$runtime") || return 1
    fi
    if "$authorize" "$identity" "$initialize" >/dev/null; then
      # Remember successful automatic admissions before the device disappears.
      # Later locks retain this runtime consent even while the dock is absent.
      runtime=$(jq -c --argjson device "$device" 'if .mode=="unlocked" then
        .trusted[$device.Uid]=($device | {Uid,Name,Vendor,Secure}) else . end' <<<"$runtime") || return 1
    else
      runtime=$(jq -c --argjson identity "$identity" '.failed += [$identity] | .failed |= unique' <<<"$runtime") || return 1
    fi
  done < <(jq -c --argjson state "$state" --argjson runtime "$runtime" --arg owner "$owner" --arg generation "$generation" "$TB_TRUST_JQ"'
    .devices | sort_by(.SysfsPath | length)[] |
    select((.Status | IN("connected","auth-error")) and (.AuthFlags | contains("nopcie") | not)) |
    . as $d |
    select(all(($runtime.failed // [])[];
      . != ($d | {owner:$owner,generation:$generation,path,inode,Uid,Name,Vendor,Parent,SysfsPath,ConnectTime,Secure}))) |
    select(($runtime.mode=="unlocked" and (.Policy!="manual" or
      $state.enrolled[.Uid]=={Uid,Name,Vendor,StoreTime})) or
      ($d | trusted($state)) or
      ($d | trusted({trusted:$runtime.trusted})) or
      (.Secure and (.Stored | not) and $runtime.trusted[.Uid]=={Uid,Name,Vendor,Secure}) or
      ($runtime.mode=="approval" and any($runtime.admit[];
        . == ($d | {owner:$owner,generation:$generation,path,inode,Uid,Name,Vendor,Parent,SysfsPath,ConnectTime,Secure}))))' <<<"$inventory")
  # Failed secure challenges must not spin on their own PropertiesChanged
  # events. Retry only for a new connection/generation or an explicit action.
  tb_json_write "$TB_RUNTIME/policy.json" <<<"$runtime" || return 1
  if jq -e '.failed | length > 0' <<<"$runtime" >/dev/null; then
    error="A Thunderbolt device could not be authorized. Check omarchy-thunderbolt-lock.service."
  fi
  tb_snapshot "$error"
}

tb_lock_publish() {
  local snapshot error
  if snapshot=$(tb_lock_reconcile); then
    tb_json_write "$TB_RUNTIME/snapshot.json" 644 <<<"$snapshot"
  else
    error="Thunderbolt protection could not be verified. Check omarchy-thunderbolt-lock.service."
    jq -cn --arg error "$error" '{available:false,error:$error}' | tb_json_write "$TB_RUNTIME/snapshot.json" 644
    return 1
  fi
}

tb_lock_change() {
  local action=$1 runtime inventory owner generation mode next state
  [[ -f $TB_MARKER ]] || return 0
  systemctl start bolt.service || return 1
  if ! systemctl is-active --quiet "$TB_SERVICE"; then
    systemctl reset-failed "$TB_SERVICE" || return 1
    systemctl start "$TB_SERVICE" || return 1
  fi
  tb_runtime_prepare || return 1
  runtime=$(tb_runtime) || return 1
  mode=$(jq -r .mode <<<"$runtime")
  inventory=$(tb_read_inventory) || return 1
  owner=$(jq -r .owner <<<"$inventory")
  generation=$(<"$TB_RUNTIME/generation") || return 1
  if [[ $action == "lock" && $mode != "locked" ]]; then
    state=$(tb_state) || return 1
    # Temporary consent lasts until reboot, including devices currently unplugged.
    next=$(jq -cn --argjson runtime "$runtime" --argjson inventory "$inventory" --argjson state "$state" '
      $runtime | .mode="locked" | .admit=[] |
      .trusted = (($runtime.trusted + $state.trusted + ([ $inventory.devices[] |
        select(.Status | startswith("authorized")) | select($runtime.revoked[.Uid] != {Uid,Name,Vendor,Secure}) |
        {key:.Uid,value:{Uid,Name,Vendor,Secure}} ] | from_entries)) |
        with_entries(select($runtime.revoked[.key] != .value))) |
      .denied = ([ $inventory.devices[] | select((.Status | startswith("authorized") | not) or
        $runtime.revoked[.Uid] == {Uid,Name,Vendor,Secure}) | {key:.Uid,value:{Uid,Name,Vendor,Secure}} ] | from_entries)') || return 1
    tb_json_write "$TB_RUNTIME/policy.json" <<<"$next" || return 1
  elif [[ $action == "unlock" ]]; then
    if [[ -e $TB_APPROVAL ]]; then
      if [[ $mode != "approval" ]]; then
        state=$(tb_state) || return 1
        next=$(jq -cn --argjson runtime "$runtime" --argjson inventory "$inventory" --argjson state "$state" --arg owner "$owner" --arg generation "$generation" '
          [$inventory.devices[] | select($runtime.denied[.Uid] != {Uid,Name,Vendor,Secure} and
            $runtime.revoked[.Uid] != {Uid,Name,Vendor,Secure}) | select(.Policy!="manual" or
              (.Status | startswith("authorized")) or $state.enrolled[.Uid]=={Uid,Name,Vendor,StoreTime})] as $waiting |
          $runtime | .mode="approval" | .failed=[] |
          .trusted += ($waiting | map({key:.Uid,value:{Uid,Name,Vendor,Secure}}) | from_entries) |
          .admit = [$waiting[] | {owner:$owner,generation:$generation,path,inode,Uid,Name,Vendor,Parent,SysfsPath,ConnectTime,Secure}]') || return 1
        tb_json_write "$TB_RUNTIME/policy.json" <<<"$next" || return 1
      fi
    else
      jq '.mode="unlocked" | .denied={} | .admit=[] | .revoked={} | .failed=[]' <<<"$runtime" | tb_json_write "$TB_RUNTIME/policy.json" || return 1
    fi
  fi
  tb_lock_publish || return 1
  systemctl is-active --quiet "$TB_SERVICE"
}

tb_lock_require_approval() {
  [[ -f $TB_MARKER && -f $TB_APPROVAL ]] || return 1
  systemctl is-active --quiet "$TB_SERVICE" || return 1
  tb_runtime | jq -e '.mode=="approval"' >/dev/null
}

tb_lock_approve() {
  local identity=$1 runtime uid
  tb_lock_require_approval || return 1
  tb_approve "$identity" true true >/dev/null || return 1
  uid=$(jq -er .Uid <<<"$identity") || return 1
  runtime=$(tb_runtime) || return 1
  jq --arg uid "$uid" 'del(.revoked[$uid]) | .failed = [(.failed // [])[] | select(.Uid != $uid)]' <<<"$runtime" | tb_json_write "$TB_RUNTIME/policy.json" || return 1
  tb_lock_publish
}

tb_lock_forget() {
  local identity=$1 state runtime uid
  tb_lock_require_approval || return 1
  state=$(tb_state) || return 1
  jq -e --argjson identity "$identity" '.trusted[$identity.Uid] == $identity' <<<"$state" >/dev/null || return 1
  uid=$(jq -er .Uid <<<"$identity") || return 1
  runtime=$(tb_runtime) || return 1
  # Deauthorizing PCIe storage can lose data. Remove future consent, retaining
  # this live connection and Bolt's keys/manual records until safe unplugging.
  jq --arg uid "$uid" --argjson identity "$identity" '
    del(.trusted[$uid]) | .admit |= map(select(.Uid != $uid)) | .revoked[$uid]=$identity' <<<"$runtime" |
    tb_json_write "$TB_RUNTIME/policy.json" || return 1
  jq --arg uid "$uid" 'del(.trusted[$uid])' <<<"$state" | tb_json_write "$TB_STATE" || return 1
  tb_lock_publish
}

tb_lock_daemon() {
  local events monitor line
  # Startup can race a lock transition that starts this service. Serialize the
  # initial permissive policy too, so it cannot overwrite a frozen lock policy.
  (
    flock -x 9 || exit 1
    tb_runtime_prepare || exit 1
    cat /proc/sys/kernel/random/uuid >"$TB_RUNTIME/generation" || exit 1
    chmod 644 "$TB_RUNTIME/generation"
  ) 9>"$TB_LOCK" || return 1
  # Subscribe before the initial scan. Bolt's property/device/owner signals
  # drive reconciliation, including daemon reconnects; no periodic inventory.
  coproc TB_EVENTS { exec busctl --system --json=short \
    --match="type='signal',sender='org.freedesktop.bolt'" \
    --match="type='signal',interface='org.freedesktop.DBus',member='NameLost'" \
    --match="type='signal',interface='org.freedesktop.DBus',member='NameOwnerChanged',arg0='org.freedesktop.bolt'" monitor 2>&1; }
  monitor=$TB_EVENTS_PID
  exec {events}<&"${TB_EVENTS[0]}"
  trap 'kill "$monitor" 2>/dev/null || true' EXIT
  IFS= read -r line <&"$events" || return 1
  # BecomeMonitor drops the subscriber's unique name after installing matches.
  # That NameLost signal is our subscription-ready barrier.
  jq -e '.type=="signal"' <<<"$line" >/dev/null || { tb_fail "$line"; return 1; }
  while [[ -f $TB_MARKER ]]; do
    (flock -x 9; [[ -f $TB_MARKER ]] && systemctl start bolt.service && tb_lock_publish) 9>"$TB_LOCK" || true
    while IFS= read -r line <&"$events"; do
      [[ $line != *'"interface":"org.freedesktop.DBus","member":"NameLost"'* ]] || continue
      break
    done || return 1
    [[ -n $line ]] || return 1
  done
}

tb_public_snapshot() {
  local snapshot generation owner
  systemctl is-active --quiet "$TB_SERVICE" || return 1
  snapshot=$(cat "$TB_RUNTIME/snapshot.json") || return 1
  generation=$(<"$TB_RUNTIME/generation") || return 1
  owner=$(tb_owner) || return 1
  jq -e --arg generation "$generation" --arg owner "$owner" \
    '.available and .generation==$generation and .owner==$owner' <<<"$snapshot" >/dev/null || return 1
  printf '%s\n' "$snapshot"
}
