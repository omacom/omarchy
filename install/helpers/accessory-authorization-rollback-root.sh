# Root-side rollback. The fixed entrypoint sources the installed USB and Bolt
# helpers and serializes the complete machine-wide change before calling here.
# Factory repair follows the migration in omacom/omarchy#14938.

ACCESSORY_USB_REVERTED=/etc/omarchy/usb-authorization.reverted
ACCESSORY_USB_RULES=/etc/usbguard/rules.conf

accessory_root_usb_owned() {
  local result
  [[ $1 == "1" || -e $drop_in ]] && return 0
  if [[ -f $limine_defaults ]]; then
    if grep -Fqx "$snapshot_begin" "$limine_defaults"; then
      return 0
    else
      result=$?
      (( result == 1 )) || return 2
    fi
  fi
  [[ -f $ACCESSORY_USB_RULES ]] || return 1
  grep -Eq ' label "omarchy-usb-authorization-v1"$|^# No USB devices were present during enrollment\.$' "$ACCESSORY_USB_RULES"
}

accessory_remove_usb() {
  local load_state link
  [[ ! -e $ACCESSORY_USB_REVERTED ]] || return 0
  if accessory_root_usb_owned "$1"; then
    # Boot rollback must finish before the daemon and its approval UI stop.
    /usr/bin/omarchy-usb-authorization-boot disable || return 1
    load_state=$(systemctl show --property=LoadState --value usbguard.service) || return 1
    if [[ $load_state == "not-found" ]]; then
      # An uninstalled unit can still have dangling enablement links. systemd
      # removes those but returns nonzero for the absent fragment; verify below.
      systemctl disable usbguard.service >/dev/null 2>&1 || true
    else
      systemctl disable --now usbguard.service || return 1
    fi
    if systemctl is-active --quiet usbguard.service || systemctl is-enabled --quiet usbguard.service; then return 1; fi
    for link in /etc/systemd/system/*.wants/usbguard.service /etc/systemd/system/*.requires/usbguard.service; do
      [[ ! -e $link && ! -L $link ]] || return 1
    done
    /usr/bin/omarchy-usb-authorization-restore-default || return 1
    install -Dm644 /dev/null "$ACCESSORY_USB_REVERTED"
  else
    (( $? == 1 ))
  fi
}

accessory_remove_thunderbolt() {
  local state recovery_dir=${TB_STATE%/*}
  # These root-only files are authoritative even if removal deleted the marker
  # before failing. Recover first; an unfinished recovery can never be a no-op.
  if [[ -f $recovery_dir/setup-recovery.json ]]; then
    tb_admin recover || return 1
  fi
  if [[ -f $recovery_dir/boot-recovery.json ]]; then
    systemctl start bolt.service || return 1
    tb_admin boot-recover || return 1
  fi
  if [[ -f $TB_PENDING && ! -f $TB_MARKER ]]; then
    tb_admin disable || return 1
  elif [[ -f $TB_STATE ]]; then
    state=$(tb_state) || return 1
    if jq -e .enabled <<<"$state" >/dev/null; then
      # Bolt's IPC deliberately does not auto-start the daemon. Start it before
      # checkpointing policies or reading firmware state on a cold boot.
      systemctl start bolt.service || return 1
      tb_admin disable || return 1
    elif [[ -e $TB_MARKER ]]; then
      echo "Thunderbolt policy and enable marker disagree; restore recovery data before retrying." >&2
      return 1
    fi
  elif [[ -e $TB_MARKER ]]; then
    echo "Thunderbolt protection has no saved policy; restore recovery data before retrying." >&2
    return 1
  fi
  [[ ! -e $recovery_dir/setup-recovery.json && ! -e $recovery_dir/boot-recovery.json ]]
}

accessory_rollback_root() {
  [[ $1 == "0" || $1 == "1" ]] || return 2
  accessory_clean_factory || return 1
  accessory_remove_usb "$1" || return 1
  accessory_remove_thunderbolt
}

accessory_publish_file() {
  local path=$1 content=$2 mode=${3:-644} temporary
  temporary=$(mktemp "$path.omarchy-rollback.XXXXXXXXXX") || return 1
  if [[ -e $path || -L $path ]]; then
    if ! cp --preserve=mode,ownership -- "$path" "$temporary"; then
      rm -f -- "$temporary"
      return 1
    fi
  elif ! chmod "$mode" "$temporary"; then
    rm -f -- "$temporary"
    return 1
  fi
  if printf '%s\n' "$content" >"$temporary" && sync "$temporary" &&
    mv -fT -- "$temporary" "$path" && sync "${path%/*}"; then
    return 0
  else
    rm -f -- "$temporary"
    return 1
  fi
}

accessory_factory_enrollment() {
  local root=$1 path content enrollment original
  path=$root/usr/bin/omarchy-provision-owner
  if [[ -f $path && ! -L $path ]]; then
    content=$(<"$path") || return 1
    original=$content
    enrollment='  if omarchy-pkg-present usbguard; then
    log_step "enrolling the owner'"'"'s USB devices"
    source "$OMARCHY_PATH/install/helpers/usb-authorization.sh"
    usb_authorization_provision_owner "$username"
  fi

  log_step "enrolling the owner'"'"'s Thunderbolt accessories"
  /usr/bin/omarchy-thunderbolt-authorization-admin owner
'
    content=${content//"$enrollment"/}
    if [[ $content == *"usb_authorization_provision_owner"* || $content == *"omarchy-thunderbolt-authorization-admin owner"* ]]; then
      echo "Factory provisioning has modified accessory enrollment; repair it before retrying." >&2
      return 1
    fi
    if [[ $content != "$original" ]]; then
      accessory_publish_file "$path" "$content" || return 1
    fi
  fi
  path=$root/usr/share/omarchy/install/user/first-run/enable-user-units.sh
  if [[ -f $path && ! -L $path ]]; then
    content=$(<"$path") || return 1
    original=$content
    enrollment=$'omarchy-crash-watch.service \\\n  omarchy-usb-authorization.service \\\n  omarchy-thunderbolt-authorization.service'
    content=${content//"$enrollment"/omarchy-crash-watch.service}
    if [[ $content == *"omarchy-usb-authorization.service"* || $content == *"omarchy-thunderbolt-authorization.service"* ]]; then
      echo "Factory first-run has modified accessory units; repair it before retrying." >&2
      return 1
    fi
    if [[ $content != "$original" ]]; then
      accessory_publish_file "$path" "$content" || return 1
    fi
  fi
  rm -f -- "$root/usr/share/omarchy/migrations/1789433473.sh" \
    "$root/usr/share/omarchy/migrations/1790344599.sh" "$root/usr/share/omarchy/migrations/1790608617.sh"
}

accessory_reset_factory_thunderbolt() {
  local root=$1 mode=$2 directory
  [[ -e $root$TB_MARKER || -e $root$TB_PENDING || -d $root${TB_STATE%/*} ]] || return 0
  tb_config_write "$root$TB_CONFIG" "$mode" || return 1
  systemctl --root="$root" disable "$TB_SERVICE" || return 1
  for directory in devices keys domains; do
    rm -rf -- "$root/var/lib/boltd/$directory" || return 1
  done
  rm -f -- "$root$TB_MARKER" "$root$TB_PENDING" || return 1
  rm -rf -- "$root${TB_STATE%/*}"
}

accessory_clean_factory() (
  local top factory device read_only path mode checkpoint filesystem
  filesystem=$(findmnt -no FSTYPE /) || return 1
  [[ $filesystem == "btrfs" ]] || return 0
  device=$(findmnt -no SOURCE /) || return 1
  device=${device%%\[*}
  top=$(mktemp -d /run/omarchy-accessory-rollback.XXXXXXXXXX) || return 1
  trap 'umount "$top" && rmdir "$top"' EXIT
  mount -o subvolid=5 "$device" "$top" || return 1
  factory=$top/@factory
  [[ -d $factory && ! -L $factory ]] || return 0
  btrfs subvolume show "$factory" >/dev/null || return 1
  checkpoint=$top/.omarchy-accessory-rollback-factory-ro
  if [[ -e $checkpoint || -L $checkpoint ]]; then
    [[ -f $checkpoint && ! -L $checkpoint ]] || return 1
    read_only=$(<"$checkpoint")
  else
    read_only=$(btrfs property get -ts "$factory" ro) || return 1
    accessory_publish_file "$checkpoint" "$read_only" 600 || return 1
  fi
  [[ $read_only == "ro=true" || $read_only == "ro=false" ]] || return 1
  trap 'status=$?; if [[ $read_only == "ro=true" ]]; then btrfs property set -ts "$factory" ro true || status=1; fi; if (( status == 0 )); then rm -- "$checkpoint" || status=1; fi; umount "$top" || status=1; rmdir "$top" || status=1; exit "$status"' EXIT
  for path in etc etc/omarchy etc/limine-entry-tool.d etc/default etc/systemd etc/systemd/system \
    var var/lib var/lib/omarchy var/lib/omarchy/thunderbolt-authorization var/lib/boltd \
    usr usr/bin usr/lib usr/lib/systemd usr/lib/systemd/system usr/share usr/share/omarchy \
    usr/share/omarchy/install usr/share/omarchy/install/user usr/share/omarchy/install/user/first-run usr/share/omarchy/migrations \
    usr/bin/omarchy-provision-owner usr/share/omarchy/install/user/first-run/enable-user-units.sh \
    etc/default/limine etc/limine-entry-tool.d/usb-authorization.conf var/lib/boltd/boltd.conf \
    var/lib/omarchy/thunderbolt-authorization/policy.json; do
    [[ ! -L $factory/$path ]] || { echo "Refusing a linked factory policy directory: $path" >&2; return 1; }
  done
  btrfs property set -ts "$factory" ro false || return 1
  mode=$(tb_config_authmode "$factory/var/lib/boltd/boltd.conf") || return 1
  if [[ -f $factory/var/lib/omarchy/thunderbolt-authorization/policy.json ]]; then
    mode=$(jq -er .original_authmode "$factory/var/lib/omarchy/thunderbolt-authorization/policy.json") || return 1
  fi
  accessory_reset_factory_thunderbolt "$factory" "$mode" || return 1
  if [[ -f $factory/usr/lib/systemd/system/usbguard.service ]]; then
    systemctl --root="$factory" disable usbguard.service || return 1
  fi
  path=$factory/etc/limine-entry-tool.d/usb-authorization.conf
  if [[ -e $path ]]; then
    [[ $(<"$path") == "$setting" ]] || return 1
    rm -- "$path" || return 1
  fi
  if [[ -f $factory/etc/default/limine ]]; then
    usb_authorization_disable_snapshot_setting "$factory/etc/default/limine" || return 1
  fi
  accessory_factory_enrollment "$factory"
)
