# Root setup functions. The caller sources thunderbolt-policy.sh first.

tb_config_authmode() {
  local path=$1
  if [[ -f $path ]]; then
    awk '
      /^[[:space:]]*\[/ { section = ($0 ~ /^[[:space:]]*\[config\][[:space:]]*$/) }
      section && /^[[:space:]]*AuthMode[[:space:]]*=/ {
        sub(/^[^=]*=[[:space:]]*/, ""); sub(/[[:space:]]*$/, ""); mode=$0
      }
      END { print mode == "" ? "enabled" : mode }
    ' "$path"
  else
    printf 'enabled\n'
  fi
}

tb_config_write() {
  local path=$1 mode=$2 temporary
  [[ $mode == "enabled" || $mode == "disabled" ]] || return 1
  install -d -m 700 "${path%/*}" || return 1
  temporary=$(mktemp "${path%/*}/.config.XXXXXX") || return 1
  if awk -v mode="$mode" '
    /^[[:space:]]*\[/ {
      section = ($0 ~ /^[[:space:]]*\[config\][[:space:]]*$/)
      if (section) { found=1; print; print "AuthMode = " mode; next }
    }
    section && /^[[:space:]]*AuthMode[[:space:]]*=/ { next }
    { print }
    END { if (!found) print "\n[config]\nAuthMode = " mode }
  ' "$(if [[ -e $path ]]; then printf '%s' "$path"; else printf /dev/null; fi)" > "$temporary" &&
    sync "$temporary" && mv -fT -- "$temporary" "$path" && sync "${path%/*}"; then
    return 0
  else
    rm -f -- "$temporary"
    return 1
  fi
}

tb_guard() {
  if [[ -f $TB_MARKER ]]; then
    tb_state | jq -e .enabled >/dev/null || { tb_fail 'Thunderbolt policy and enable marker disagree'; return 1; }
    tb_config_write "$TB_CONFIG" disabled
  fi
}

tb_capture() {
  local path uid name vendor trusted='{}'
  for path in "$TB_SYSFS"/*; do
    [[ -f $path/unique_id && $path != *-0 ]] || continue
    uid=$(cat "$path/unique_id") || return 1
    # Bolt uses the numeric attribute when a descriptive name is absent.
    if [[ -e $path/device_name ]]; then
      name=$(cat "$path/device_name") || return 1
    else
      name=$(cat "$path/device") || return 1
    fi
    if [[ -e $path/vendor_name ]]; then
      vendor=$(cat "$path/vendor_name") || return 1
    else
      vendor=$(cat "$path/vendor") || return 1
    fi
    [[ -n $uid ]] || { tb_fail 'A connected Thunderbolt device has no identity'; return 1; }
    trusted=$(jq -c --arg uid "$uid" --arg name "$name" --arg vendor "$vendor" \
      '.[$uid] = {Uid:$uid,Name:$name,Vendor:$vendor}' <<< "$trusted") || return 1
  done
  printf '%s\n' "$trusted"
}

tb_capture_ready() {
  local fresh=${1:-false} offline=${2:-false} path uid inode inventory=''
  # Do not relax an active policy, or capture new devices when re-enabling an
  # existing policy. This preflight only guards the initial trust inventory.
  [[ ! -f $TB_MARKER ]] || return 0
  if [[ -f $TB_STATE && ! -f $TB_PENDING && $fresh != "true" ]]; then
    tb_state | jq -e '.enrollment_pending // false' >/dev/null || return 0
  fi
  for path in "$TB_SYSFS"/*; do
    [[ -f $path/unique_id && $path != *-0 && -e $path/key ]] || continue
    uid=$(cat "$path/unique_id") || return 1
    [[ $uid =~ ^[0-9a-fA-F-]{36}$ ]] || { tb_fail 'A connected Thunderbolt device has an invalid identity'; return 1; }
    path=$(realpath -e -- "$path") || return 1
    inode=$(stat -Lc '%i' -- "$path") || return 1
    # A key file alone can be orphaned after a failed Bolt record write. Ask
    # Bolt whether this exact connection has a stored record and key. Offline
    # prepare must not accept the live installer's daemon as the target store.
    if [[ $offline != "true" && -z $inventory ]]; then
      inventory=$(tb_inventory) || inventory='{}'
    fi
    if [[ $offline == "true" ]] || ! jq -e --arg uid "$uid" --arg path "$path" --arg inode "$inode" \
      'any(.devices[]?; .Uid==$uid and .SysfsPath==$path and .inode==$inode and .Stored and (.Key | IN("have","new")))' <<< "$inventory" >/dev/null; then
      # An active keyless dock cannot receive a key without disconnecting it.
      # Preserve input/storage and finish installation with setup deferred.
      install -d -m 755 "${TB_PENDING%/*}" || return 1
      install -m 644 /dev/null "$TB_PENDING" || return 1
      printf 'Thunderbolt protection is deferred: safely disconnect accessories without saved secure keys, keep independent input available, then run Setup > Security > Thunderbolt.\n' >&2
      return 2
    fi
  done
}

tb_prepare() {
  local fresh=${1:-false} state='{}' trusted mode
  if [[ -f $TB_STATE ]]; then
    state=$(tb_state) || return 1
  fi
  if [[ ! -f $TB_STATE || -f $TB_PENDING || $fresh == "true" ]] || jq -e '.enrollment_pending // false' <<< "$state" >/dev/null; then
    trusted=$(tb_capture) || return 1
    mode=$(jq -r '.original_authmode // empty' <<< "$state") || return 1
    [[ -n $mode ]] || mode=$(tb_config_authmode "$TB_CONFIG") || return 1
    [[ $mode == "enabled" || $mode == "disabled" ]] || { tb_fail 'Unsupported existing Bolt authorization mode'; return 1; }
    state=$(jq -c --arg mode "$mode" --argjson trusted "$trusted" \
      'del(.enrollment_pending) | . + {version:1,enabled:true,trusted:$trusted,original_authmode:$mode}' <<< "$state") || return 1
  else
    mode=$(jq -r .original_authmode <<< "$state") || return 1
    [[ $mode == "enabled" || $mode == "disabled" ]] || { tb_fail 'Unsupported existing Bolt authorization mode'; return 1; }
    state=$(jq -c '.enabled=true' <<< "$state") || return 1
  fi
  install -d -m 700 "${TB_STATE%/*}" || return 1
  tb_json_write "$TB_STATE" <<< "$state" || return 1
  tb_config_write "$TB_CONFIG" disabled || return 1
  install -d -m 755 "${TB_MARKER%/*}" || return 1
  install -m 644 /dev/null "$TB_MARKER"
}

tb_boot_saved() {
  jq -c '{policies:(.stored | map({key:.Uid,value:.Policy}) | from_entries),
    acls:(.domains | map({key:.Uid,value:.BootACL}) | from_entries)}'
}

tb_boot_change() {
  local enabled=$1 state inventory saved after desired backup="${TB_STATE%/*}/boot-recovery.json"
  state=$(tb_state) || return 1
  jq -e .enabled <<< "$state" >/dev/null || { tb_fail 'Enable Thunderbolt device authorization first'; return 1; }
  if [[ $enabled == "false" ]] && ! jq -e .boot_protection <<< "$state" >/dev/null; then
    return 0
  fi
  [[ ! -e $backup ]] || { tb_fail 'Recover the previous firmware boot-access change before retrying'; return 1; }
  inventory=$(tb_read_inventory) || return 1
  jq -e '.domains | length > 0 and all(.[]; .SysfsPath != "")' <<< "$inventory" >/dev/null || {
    tb_fail 'Connect every Thunderbolt controller before changing firmware boot access'; return 1;
  }
  saved=$(tb_boot_saved <<< "$inventory" | jq -c --argjson state "$state" '. + {state:$state}') || return 1
  if [[ $enabled == "true" ]]; then
    jq -e 'all(.domains[]; (.SecurityLevel == "user" or .SecurityLevel == "secure") and (.BootACL|length > 0))' <<< "$inventory" >/dev/null || {
      tb_fail 'This controller has no supported firmware boot allowlist. Disable Thunderbolt pre-boot/PCIe boot support in firmware settings; Omarchy cannot verify that setting.'; return 1;
    }
    desired=$(jq -c '{policies:(.stored | map({key:.Uid,value:"manual"}) | from_entries),
      acls:(.domains | map({key:.Uid,value:(.BootACL | map(""))}) | from_entries)}' <<< "$inventory") || return 1
    after=$(jq -c --argjson saved "$saved" --argjson devices "$(jq -c .devices <<< "$inventory")" '
      if .boot_protection then . else .boot_original=($saved | {policies,acls}) end |
      .boot_protection=true | .trusted += ($devices | map({key:.Uid,value:{Uid,Name,Vendor}}) | from_entries)' <<< "$state") || return 1
  else
    desired=$(jq -ce .boot_original <<< "$state") || return 1
    after=$(jq -c 'del(.boot_original) | .boot_protection=false' <<< "$state") || return 1
  fi
  tb_json_write "$backup" <<< "$saved" || return 1
  if tb_boot_apply "$desired" && tb_json_write "$TB_STATE" <<< "$after"; then
    rm -- "$backup"
  else
    if tb_boot_apply "$saved" && tb_json_write "$TB_STATE" <<< "$state"; then
      rm -- "$backup" || return 1
      tb_fail 'Firmware change failed; previous state restored'
    else
      tb_fail "Firmware change failed; recovery is incomplete. Recovery data retained at $backup"
    fi
    return 1
  fi
}

tb_boot_recover() {
  local backup="${TB_STATE%/*}/boot-recovery.json" saved
  saved=$(jq -ce . "$backup") || return 1
  tb_boot_apply "$saved" || return 1
  jq .state <<< "$saved" | tb_json_write "$TB_STATE" || return 1
  rm -- "$backup"
}

tb_unit_state() {
  local properties
  properties=$(systemctl show -p ActiveState -p UnitFileState "$1") || return 1
  jq -Rn '[inputs | split("=") | {key:.[0],value:.[1]}] | from_entries |
    {active:(.ActiveState == "active"),enabled:(.UnitFileState == "enabled")}' <<< "$properties"
}

tb_config_checkpoint() {
  local backup="${TB_STATE%/*}/setup-recovery.json" path original files='{}' units='{}' unit value saved inventory data mode state
  [[ ! -e $backup && ! -e ${TB_STATE%/*}/boot-recovery.json ]] || {
    tb_fail 'A previous setup change needs recovery before continuing'; return 1;
  }
  for path in "$TB_STATE" "$TB_CONFIG" "$TB_MARKER"; do
    original=null
    if [[ -e $path ]]; then
      data=$(base64 -w0 -- "$path") || return 1
      mode=$(stat -c '%a' -- "$path") || return 1
      original=$(jq -cn --arg data "$data" --arg mode "$mode" '{data:$data,mode:$mode}') || return 1
    fi
    files=$(jq -c --arg path "$path" --argjson original "$original" '.[$path]=$original' <<< "$files") || return 1
  done
  for unit in bolt.service "$TB_SERVICE"; do
    value=$(tb_unit_state "$unit") || return 1
    units=$(jq -c --arg unit "$unit" --argjson value "$value" '.[$unit]=$value' <<< "$units") || return 1
  done
  saved=$(jq -cn --argjson files "$files" --argjson units "$units" '{files:$files,units:$units}') || return 1
  state='{}'
  if [[ -f $TB_STATE ]]; then state=$(tb_state) || return 1; fi
  if jq -e .boot_protection <<< "$state" >/dev/null; then
    inventory=$(tb_read_inventory) || return 1
    jq -e 'all(.domains[]; .SysfsPath != "")' <<< "$inventory" >/dev/null || return 1
    saved=$(jq -c --argjson firmware "$(tb_boot_saved <<< "$inventory")" '.firmware=$firmware' <<< "$saved") || return 1
  fi
  install -d -m 700 "${TB_STATE%/*}" || return 1
  tb_json_write "$backup" <<< "$saved"
}

tb_config_restore() {
  local backup="${TB_STATE%/*}/setup-recovery.json" saved path original temporary unit
  saved=$(jq -ce . "$backup") || return 1
  systemctl stop "$TB_SERVICE" bolt.service || return 1
  for path in "$TB_STATE" "$TB_CONFIG" "$TB_MARKER"; do
    original=$(jq -c --arg path "$path" '.files[$path]' <<< "$saved") || return 1
    if [[ $original == "null" ]]; then
      rm -f -- "$path" || return 1
    else
      mkdir -p -- "${path%/*}" || return 1
      temporary=$(mktemp "${path%/*}/.restore.XXXXXX") || return 1
      if jq -r .data <<< "$original" | base64 -d > "$temporary" &&
        chmod "$(jq -r .mode <<< "$original")" "$temporary" && sync "$temporary" &&
        mv -fT -- "$temporary" "$path" && sync "${path%/*}"; then
        :
      else
        rm -f -- "$temporary"
        return 1
      fi
    fi
  done
  if jq -e .firmware <<< "$saved" >/dev/null; then
    systemctl start bolt.service || return 1
    tb_boot_apply "$(jq -c .firmware <<< "$saved")" || return 1
  fi
  rm -f -- "${TB_STATE%/*}/boot-recovery.json" || return 1
  if jq -e --arg unit "$TB_SERVICE" '.units[$unit].enabled' <<< "$saved" >/dev/null; then
    systemctl enable "$TB_SERVICE" || return 1
  else
    systemctl disable "$TB_SERVICE" || return 1
  fi
  for unit in bolt.service "$TB_SERVICE"; do
    if jq -e --arg unit "$unit" '.units[$unit].active' <<< "$saved" >/dev/null; then
      systemctl start "$unit" || return 1
    else
      systemctl stop "$unit" || return 1
    fi
  done
  rm -- "$backup"
}

tb_transaction() {
  tb_config_checkpoint || return 1
  if "$@"; then
    rm -- "${TB_STATE%/*}/setup-recovery.json"
  else
    if tb_config_restore; then
      tb_fail 'Thunderbolt setup failed; previous configuration restored'
    else
      tb_fail 'Thunderbolt setup failed; restoration is incomplete. Run the setup recovery command.'
    fi
    return 1
  fi
}

tb_enable() {
  systemctl stop "$TB_SERVICE" bolt.service || return 1
  tb_prepare "${1:-false}" || return 1
  systemctl daemon-reload || return 1
  systemctl start bolt.service || return 1
  tb_read_inventory >/dev/null || return 1
  systemctl enable --now "$TB_SERVICE"
}

tb_disable() {
  local state mode
  systemctl stop "$TB_SERVICE" || return 1
  tb_boot_change false || return 1
  state=$(tb_state) || return 1
  mode=$(jq -er .original_authmode <<< "$state") || return 1
  systemctl stop bolt.service || return 1
  tb_config_write "$TB_CONFIG" "$mode" || return 1
  rm -f -- "$TB_MARKER" || return 1
  jq '.enabled=false' <<< "$state" | tb_json_write "$TB_STATE" || return 1
  systemctl disable "$TB_SERVICE" || return 1
  systemctl start bolt.service || return 1
  tb_inventory | jq -e --arg mode "$mode" '.manager.AuthMode==$mode' >/dev/null
}

tb_cancel_pending() {
  local state
  if [[ -f $TB_STATE ]]; then
    state=$(tb_state) || return 1
  else
    state=$(jq -cn --arg mode "$(tb_config_authmode "$TB_CONFIG")" \
      '{version:1,enabled:false,trusted:{},enrollment_pending:true,original_authmode:$mode}') || return 1
  fi
  install -d -m 700 "${TB_STATE%/*}" || return 1
  jq '.enabled=false | .enrollment_pending=true' <<< "$state" | tb_json_write "$TB_STATE" || return 1
  rm -- "$TB_PENDING"
}

tb_reset_root() {
  local root directory
  root=$(realpath -e -- "$1") || return 1
  [[ $root != "/" && -d $root ]] || { tb_fail 'Refusing to reset the running system'; return 1; }
  [[ -e $root$TB_MARKER || -e $root$TB_PENDING || -d $root${TB_STATE%/*} ]] || return 0
  # Resolve fixed paths inside the cloned root, never through an outside link.
  for directory in etc etc/omarchy var var/lib var/lib/omarchy var/lib/boltd; do
    [[ ! -L $root/$directory ]] || { tb_fail 'Refusing a linked factory policy directory'; return 1; }
  done
  systemctl --root="$root" disable "$TB_SERVICE" || return 1
  rm -f -- "$root$TB_MARKER" || return 1
  rm -f -- "$root$TB_PENDING" || return 1
  rm -rf -- "$root${TB_STATE%/*}" || return 1
  for directory in devices keys domains; do
    rm -rf -- "$root/var/lib/boltd/$directory" || return 1
  done
  tb_config_write "$root/var/lib/boltd/boltd.conf" enabled
}

tb_admin() {
  local action=${1:-} status=0 state
  if [[ $action != "guard" ]]; then
    exec 9> "$TB_LOCK"
    flock -x 9 || return 1
  fi
  case "$action" in
    prepare|enable|owner|migrate)
      # A deferred setup needs explicit consent after the accessories have
      # been disconnected; a later migration must not silently finish it.
      if [[ -f $TB_PENDING && $action != "enable" ]]; then return 0; fi
      if [[ $action == "migrate" && -f $TB_STATE ]] && tb_state | jq -e '.enabled == false' >/dev/null; then return 0; fi
      if tb_capture_ready "$(if [[ $action == "owner" ]]; then echo true; else echo false; fi)" \
        "$(if [[ $action == "prepare" ]]; then echo true; else echo false; fi)"; then
        :
      else
        status=$?
        if (( status == 2 )); then return 0; else return "$status"; fi
      fi ;;
  esac
  case "$action" in
    guard) tb_guard ;;
    prepare) tb_prepare && rm -f -- "$TB_PENDING" ;;
    enable) tb_transaction tb_enable && rm -f -- "$TB_PENDING" ;;
    owner) tb_transaction tb_enable true && rm -f -- "$TB_PENDING" ;;
    migrate)
      state='{"enabled":true}'
      if [[ -f $TB_STATE ]]; then state=$(tb_state) || return 1; fi
      if jq -e .enabled <<< "$state" >/dev/null; then
        tb_transaction tb_enable
      fi ;;
    disable)
      if [[ -f $TB_PENDING && ! -f $TB_MARKER ]]; then
        tb_cancel_pending
      else
        tb_transaction tb_disable
      fi ;;
    recover) tb_config_restore ;;
    boot-enable|boot-disable|boot-recover)
      systemctl stop "$TB_SERVICE" || return 1
      case "$action" in
        boot-enable) tb_boot_change true || status=$? ;;
        boot-disable) tb_boot_change false || status=$? ;;
        boot-recover) tb_boot_recover || status=$? ;;
      esac
      systemctl start "$TB_SERVICE" || return 1
      return "$status" ;;
    reset-root) [[ $# == 2 ]] && tb_reset_root "$2" ;;
    *) tb_fail 'Unknown Thunderbolt setup action' ;;
  esac
}
