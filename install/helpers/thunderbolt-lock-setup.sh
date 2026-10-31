# shellcheck shell=bash
# Administrative Bolt setup; thunderbolt-lock.sh is sourced first.
TB_CONFIG=/var/lib/boltd/boltd.conf

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

tb_boot_saved() {
  jq -c '{policies:(.stored | map({key:.Uid,value:.Policy}) | from_entries),
    acls:(.domains | map({key:.Uid,value:.BootACL}) | from_entries)}'
}

tb_unit_state() {
  local properties
  properties=$(systemctl show -p ActiveState -p UnitFileState "$1") || return 1
  jq -Rn '[inputs | split("=") | {key:.[0],value:.[1]}] | from_entries |
    {active:(.ActiveState == "active"),enabled:(.UnitFileState == "enabled")}' <<< "$properties"
}

tb_handoff_policies() {
  local state=$1
  # StoreTime distinguishes a record recreated outside Omarchy. A completed
  # enrollment and matching consent are both required, including offline
  # accessories. Never promote somebody else's manual policy.
  jq -c --argjson state "$state" '{policies:([.stored[] |
    select(.Policy == "manual" and .StoreTime > 0 and
      $state.enrolled[.Uid] == {Uid,Name,Vendor,StoreTime} and
      ($state.trusted[.Uid] | {Uid,Name,Vendor}) == {Uid,Name,Vendor}) |
    {key:.Uid,value:"auto"}] | from_entries),acls:{}}'
}

tb_config_checkpoint() {
  local backup="${TB_STATE%/*}/setup-recovery.json" path original files='{}' units='{}' unit value saved inventory data mode state
  local -a paths=("$TB_STATE" "$TB_CONFIG" "$TB_MARKER" "$TB_RUNTIME/policy.json" "$TB_RUNTIME/generation" "$TB_RUNTIME/snapshot.json")
  [[ ! -e $backup && ! -e ${TB_STATE%/*}/boot-recovery.json ]] || {
    tb_fail 'A previous setup change needs recovery before continuing'; return 1;
  }
  for path in "$TB_RUNTIME"/keys/*.json; do
    if [[ -f $path ]]; then paths+=("$path"); fi
  done
  for path in "${paths[@]}"; do
    original=null
    if [[ -e $path ]]; then
      data=$(base64 -w0 -- "$path") || return 1
      mode=$(stat -c '%a' -- "$path") || return 1
      original=$(printf '%s' "$data" | jq -Rsc --arg mode "$mode" '{data:.,mode:$mode}') || return 1
    fi
    files=$(printf '%s\n%s\n' "$files" "$original" | jq -sc --arg path "$path" '.[0] + {($path):.[1]}') || return 1
  done
  for unit in bolt.service "$TB_SERVICE"; do
    value=$(tb_unit_state "$unit") || return 1
    units=$(jq -c --arg unit "$unit" --argjson value "$value" '.[$unit]=$value' <<< "$units") || return 1
  done
  saved=$(printf '%s\n%s\n' "$files" "$units" | jq -sc --arg boot "$(cat /proc/sys/kernel/random/boot_id)" '{files:.[0],units:.[1],boot_id:$boot}') || return 1
  state='{}'
  if [[ -f $TB_STATE ]]; then state=$(tb_state) || return 1; fi
  # A handoff to auto also changes Bolt's firmware allowlists. Checkpoint the
  # policies and ACLs even when the optional boot protection was never used.
  if jq -e '.enabled and (.boot_protection or ((.enrolled // {}) | length > 0))' <<< "$state" >/dev/null; then
    inventory=$(tb_read_inventory) || return 1
    jq -e 'all(.domains[]; .SysfsPath != "")' <<< "$inventory" >/dev/null || {
      tb_fail 'Reconnect every Thunderbolt controller before changing device policies'; return 1;
    }
    saved=$(jq -c --argjson firmware "$(tb_boot_saved <<< "$inventory")" '.firmware=$firmware' <<< "$saved") || return 1
  fi
  install -d -m 700 "${TB_STATE%/*}" || return 1
  tb_json_write "$backup" <<< "$saved"
}

tb_config_restore() {
  local backup="${TB_STATE%/*}/setup-recovery.json" saved path original temporary unit boot
  local -a paths=("$TB_STATE" "$TB_CONFIG" "$TB_MARKER" "$TB_RUNTIME/policy.json" "$TB_RUNTIME/generation" "$TB_RUNTIME/snapshot.json")
  saved=$(jq -ce . "$backup") || return 1
  systemctl stop "$TB_SERVICE" bolt.service || return 1
  boot=$(jq -r '.boot_id // empty' <<<"$saved") || return 1
  while IFS= read -r path; do paths+=("$path"); done < <(jq -r --arg prefix "$TB_RUNTIME/keys/" '
    .files | keys[] | select(startswith($prefix) and (ltrimstr($prefix) | test("^[0-9a-f]{64}\\.json$")))' <<<"$saved")
  rm -rf "$TB_RUNTIME/keys" || return 1
  for path in "${paths[@]}"; do
    original=$(jq -c --arg path "$path" '.files[$path]' <<< "$saved") || return 1
    # Recovery can be retried after reboot. Restore durable configuration,
    # but never revive another boot's temporary consent or challenge keys.
    if [[ -n $boot && $boot != $(cat /proc/sys/kernel/random/boot_id) ]]; then
      case $path in "$TB_RUNTIME"/*) original=null ;; esac
    fi
    if [[ $original == "null" ]]; then
      rm -f -- "$path" || return 1
    else
      case $path in "$TB_RUNTIME"/keys/*) install -d -m 700 "$TB_RUNTIME/keys" || return 1 ;; esac
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

# Installation stages services only; current hardware is learned at runtime,
# never from the installer or copied into permanent consent.
tb_lock_prepare() {
  local state mode
  if [[ -f $TB_STATE ]]; then
    state=$(tb_state) || return 1
  else
    mode=$(tb_config_authmode "$TB_CONFIG") || return 1
    [[ $mode == "enabled" || $mode == "disabled" ]] || return 1
    state=$(jq -cn --arg mode "$mode" '{version:1,enabled:false,trusted:{},enrolled:{},original_authmode:$mode}') || return 1
  fi
  install -d -m 700 "${TB_STATE%/*}" || return 1
  jq '.enabled=true' <<<"$state" | tb_json_write "$TB_STATE" || return 1
  install -Dm644 /dev/null "$TB_MARKER" || return 1
}

tb_lock_enable() {
  tb_lock_prepare || return 1
  tb_guard || return 1
  systemctl daemon-reload || return 1
  systemctl restart bolt.service || return 1
  tb_read_inventory >/dev/null || return 1
  systemctl enable --now "$TB_SERVICE" || return 1
}

tb_lock_defaults() {
  local start=${1:-now}
  [[ -e /etc/omarchy/usb-lock.enabled && ! -e /etc/omarchy/usb-lock.disabled ]] || return 0
  [[ ! -f $TB_MARKER ]] || return 0
  if [[ -e /etc/omarchy/thunderbolt-authorization.enabled ||
        -e /var/lib/omarchy/thunderbolt-authorization/setup-recovery.json ||
        -e /var/lib/omarchy/thunderbolt-authorization/boot-recovery.json ]]; then
    tb_fail 'Finish the previous Thunderbolt removal before enabling device protection'; return 1
  fi
  if [[ $(tb_config_authmode "$TB_CONFIG") == "disabled" && ! -e $TB_STATE ]]; then
    echo 'An independently managed Bolt policy was preserved; Thunderbolt lock protection was not enabled.' >&2
    return 0
  fi
  [[ -f /etc/systemd/system/omarchy-thunderbolt-lock.service &&
     -f /etc/systemd/system/bolt.service.d/omarchy-lock.conf &&
     -f /etc/polkit-1/rules.d/40-omarchy-thunderbolt-lock.rules &&
     -f /etc/systemd/user/omarchy-thunderbolt-lock-notify.service &&
     -f /etc/systemd/user/omarchy-thunderbolt-lock-watch.path ]] || {
    tb_fail 'Thunderbolt lock support is incomplete. Update Omarchy before enabling it.'; return 1;
  }
  if [[ $start == "later" ]]; then
    tb_lock_prepare || return 1
    systemctl enable "$TB_SERVICE"
  else
    systemctl start bolt.service || return 1
    tb_transaction tb_lock_enable
  fi
}

tb_lock_disable_apply() {
  local state mode policies
  state=$(tb_state) || return 1
  mode=$(jq -er .original_authmode <<<"$state") || return 1
  systemctl stop "$TB_SERVICE" || return 1
  systemctl start bolt.service || return 1
  policies=$(tb_read_inventory | tb_handoff_policies "$state") || return 1
  tb_boot_apply "$policies" || return 1
  # Keep the marker until configuration and the owned records are restored.
  # No active PCIe device is deauthorized as part of removal.
  systemctl stop bolt.service || return 1
  tb_config_write "$TB_CONFIG" "$mode" || return 1
  rm -f "$TB_MARKER" || return 1
  jq '.enabled=false | del(.enrolled)' <<<"$state" | tb_json_write "$TB_STATE" || return 1
  systemctl disable "$TB_SERVICE" || return 1
  systemctl start bolt.service || return 1
  tb_inventory | jq -e --arg mode "$mode" --argjson policies "$policies" '
    .manager.AuthMode==$mode and (([.stored[] | {key:.Uid,value:.Policy}] | from_entries) as $actual |
      all($policies.policies | to_entries[]; $actual[.key]==.value))' >/dev/null || return 1
  rm -f "$TB_RUNTIME/policy.json" "$TB_RUNTIME/snapshot.json" "$TB_RUNTIME/generation"
  rm -rf "$TB_RUNTIME/keys"
}

tb_lock_disable() {
  [[ -f $TB_MARKER ]] || return 0
  systemctl start bolt.service || return 1
  tb_transaction tb_lock_disable_apply
}

tb_lock_reset_root() {
  local root=$1 directory
  # Both the staged factory and the retained root are new-owner environments.
  # The caller controls when they become active; do not touch live services.
  for directory in etc etc/omarchy var var/lib var/lib/omarchy var/lib/boltd; do
    [[ ! -L $root/$directory ]] || { tb_fail 'Refusing a linked factory policy directory'; return 1; }
  done
  rm -rf "$root${TB_STATE%/*}" || return 1
  for directory in devices keys domains; do
    rm -rf "$root/var/lib/boltd/$directory" || return 1
  done
  tb_config_write "$root$TB_CONFIG" enabled || return 1
  # No old consent or pending controller changes may survive into the new owner.
  rm -f "$root$TB_MARKER" || return 1
  if [[ -f $root/etc/systemd/system/omarchy-thunderbolt-lock.service ]]; then
    # The session dispatches both policies through USB's enable marker. Match
    # its decision when an independent USBGuard service owns the reset root.
    if [[ -f $root/etc/omarchy/usb-lock.enabled ]]; then
      install -d -m700 "$root${TB_STATE%/*}" || return 1
      printf '%s\n' '{"version":1,"enabled":true,"trusted":{},"enrolled":{},"original_authmode":"enabled"}' |
        tb_json_write "$root$TB_STATE" || return 1
      install -Dm644 /dev/null "$root$TB_MARKER" || return 1
      systemctl --root "$root" enable "$TB_SERVICE" || return 1
    else
      systemctl --root "$root" disable "$TB_SERVICE" || return 1
    fi
  fi
}
