#!/bin/bash -p

# Privileged Bash suppresses BASH_ENV and exported functions before root rollback or a Bolt guard runs.
if [[ ${BASH_SOURCE[0]} == "$0" ]]; then
  [[ $- == *p* ]] && (( EUID == 0 )) || exit 126
fi

da_support=$(cd -- "${BASH_SOURCE[0]%/*}" && pwd) || exit 126
source "$da_support/thunderbolt-policy.sh" || exit 126
source "$da_support/thunderbolt-setup.sh" || exit 126

da_stop_unit() {
  local unit=$1 state
  state=$(systemctl show -p LoadState --value "$unit") || return 1
  if [[ $state != "not-found" ]]; then
    systemctl disable --now "$unit" || return 1
  fi
  if systemctl is-active --quiet "$unit" || systemctl is-enabled --quiet "$unit"; then
    echo "$unit is still active or enabled; rollback is incomplete." >&2
    return 1
  fi
}

da_archive() {
  local path=$1
  [[ -e $path || -L $path ]] || return 0
  if [[ -e $path.retired || -L $path.retired ]]; then
    cmp -s -- "$path" "$path.retired" || return 1
    rm -- "$path"
  else
    mv -- "$path" "$path.retired"
  fi
}

# Recovery may restart the retired controller. Keep its two root entrypoints
# available until the original transactional removal has verified success.
da_prepare_thunderbolt_units() {
  local unit=/etc/systemd/system/omarchy-thunderbolt-authorization.service
  local guard=/etc/systemd/system/bolt.service.d/omarchy-authorization.conf
  local content
  if [[ -f $unit ]]; then
    content=$(<"$unit") || return 1
    if [[ $content == *"ExecStart=/usr/bin/omarchy-thunderbolt-authorization-daemon"* ]]; then
      content=${content//ExecStart=\/usr\/bin\/omarchy-thunderbolt-authorization-daemon/ExecStart=\"$da_support\/rollback.sh\" daemon}
      da_publish_file "$unit" "$content" || return 1
    fi
  else
    install -d -m755 /run/systemd/system || return 1
    printf -v content '%s\n' '[Unit]' 'After=bolt.service' 'ConditionPathExists=/etc/omarchy/thunderbolt-authorization.enabled' '[Service]' \
      "ExecStart=\"$da_support/rollback.sh\" daemon" '[Install]' 'WantedBy=multi-user.target' \
      || return 1
    da_publish_file /run/systemd/system/omarchy-thunderbolt-authorization.service "$content" || return 1
  fi
  if [[ -f $guard ]]; then
    content=$(<"$guard") || return 1
    content=${content//ExecStartPre=\/usr\/bin\/omarchy-thunderbolt-authorization-admin guard/ExecStartPre=\"$da_support\/rollback.sh\" guard}
    da_publish_file "$guard" "$content" || return 1
  fi
  systemctl daemon-reload || return 1
  for unit in bolt.service "$TB_SERVICE"; do
    if systemctl is-failed --quiet "$unit"; then
      systemctl reset-failed "$unit" || return 1
    fi
  done
}

da_remove_thunderbolt() {
  local state
  if [[ -f $TB_STATE || -f $TB_MARKER || -f $TB_PENDING || -f ${TB_STATE%/*}/setup-recovery.json || -f ${TB_STATE%/*}/boot-recovery.json ]]; then
    if [[ -f ${TB_STATE%/*}/setup-recovery.json || -f ${TB_STATE%/*}/boot-recovery.json ]]; then
      da_prepare_thunderbolt_units || return 1
      if [[ -f ${TB_STATE%/*}/setup-recovery.json ]]; then
        tb_admin recover || return 1
      fi
      systemctl start bolt.service || return 1
      if [[ -f ${TB_STATE%/*}/boot-recovery.json ]]; then
        tb_admin boot-recover || return 1
      fi
    fi
    if [[ -f $TB_PENDING && ! -f $TB_MARKER ]]; then
      tb_admin disable || return 1
    elif [[ -f $TB_STATE ]]; then
      state=$(tb_state) || return 1
      if jq -e .enabled <<<"$state" >/dev/null; then
        da_prepare_thunderbolt_units || return 1
        systemctl start bolt.service || return 1
        tb_admin disable || return 1
      elif [[ -f $TB_MARKER ]]; then
        echo "Thunderbolt policy and enable marker disagree; restore recovery data before retrying." >&2
        return 1
      fi
    else
      echo "Thunderbolt protection has no saved policy; restore its recovery data before retrying." >&2
      return 1
    fi
    da_stop_unit "$TB_SERVICE" || return 1
    rm -f -- "$TB_MARKER" "$TB_PENDING"
  fi
  da_archive /etc/systemd/system/bolt.service.d/omarchy-authorization.conf || return 1
  da_archive /etc/systemd/system/omarchy-thunderbolt-authorization.service || return 1
  rm -f /run/systemd/system/omarchy-thunderbolt-authorization.service
  systemctl daemon-reload || return 1
}

da_remove_usb() {
  local requested=$1 attribute
  if [[ -e /etc/limine-entry-tool.d/usb-authorization.conf ]] ||
    grep -Fq '# Omarchy USB authorization begin' /etc/default/limine 2>/dev/null ||
    grep -qw usbcore.authorized_default=0 /proc/cmdline; then
    /bin/bash -p "$da_support/usb-boot.sh" disable || return 1
    echo "USB boot protection removed; reboot to use the restored boot images."
    requested=1
  fi
  if (( requested )) || grep -Fq 'label "omarchy-usb-authorization-v1"' /etc/usbguard/rules.conf 2>/dev/null ||
    grep -Fqx '# No USB devices were present during enrollment.' /etc/usbguard/rules.conf 2>/dev/null; then
    da_stop_unit usbguard.service || return 1
    shopt -s nullglob
    for attribute in /sys/bus/usb/devices/usb*/authorized_default /sys/bus/usb/devices/*/authorized; do
      echo 1 >"$attribute" || return 1
    done
    shopt -u nullglob
  fi
}

da_factory_enrollment() {
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
      da_publish_file "$path" "$content" || return 1
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
      da_publish_file "$path" "$content" || return 1
    fi
  fi
  rm -f -- "$root/usr/share/omarchy/migrations/1789433473.sh" \
    "$root/usr/share/omarchy/migrations/1790344599.sh" "$root/usr/share/omarchy/migrations/1790608617.sh"
}

da_publish_file() {
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

# Keep the saved mode until it is durably restored. Clearing identity last
# makes interruption or disk failure retryable without defaulting to enabled.
da_reset_factory_thunderbolt() {
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

da_clean_factory() (
  local top factory device read_only path mode checkpoint
  [[ $(findmnt -no FSTYPE /) == "btrfs" ]] || return 0
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
    da_publish_file "$checkpoint" "$read_only" 600 || return 1
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
  da_reset_factory_thunderbolt "$factory" "$mode" || return 1
  if [[ -f $factory/usr/lib/systemd/system/usbguard.service ]]; then
    systemctl --root="$factory" disable usbguard.service || return 1
  fi
  source "$da_support/usb-boot.sh" || return 1
  path=$factory/etc/limine-entry-tool.d/usb-authorization.conf
  if [[ -e $path ]]; then
    [[ $(<"$path") == "$setting" ]] || return 1
    rm -- "$path" || return 1
  fi
  if [[ -f $factory/etc/default/limine ]]; then
    usb_authorization_disable_snapshot_setting "$factory/etc/default/limine" || return 1
  fi
  da_factory_enrollment "$factory"
)

da_main() {
  local usb=${1:-0} path
  [[ $usb == "0" || $usb == "1" ]] || return 2
  da_clean_factory || return 1
  da_remove_usb "$usb" || return 1
  da_remove_thunderbolt || return 1
  for path in /etc/polkit-1/rules.d/40-omarchy-usb.rules /etc/polkit-1/rules.d/40-omarchy-thunderbolt.rules \
    /usr/share/polkit-1/actions/org.omarchy.usb.policy /usr/share/polkit-1/actions/org.omarchy.thunderbolt.policy; do
    da_archive "$path" || return 1
  done
}

if [[ ${BASH_SOURCE[0]} == "$0" ]]; then
  [[ $- == *p* ]] && (( EUID == 0 )) || exit 126
  source "$da_support/../../bin/omarchy-security-functions" || exit 126
  omarchy_security_require_privileged_bash_startup || exit 126
  omarchy_security_sanitize_bash_environment "$0" "$@"
  set -euo pipefail
  export PATH="$da_support/../../bin:/usr/bin:/bin" LC_ALL=C
  unset DBUS_SYSTEM_BUS_ADDRESS DBUS_SESSION_BUS_ADDRESS
  case ${1:-rollback} in
    guard) tb_guard ;;
    daemon) tb_daemon ;;
    rollback)
      omarchy_security_prepare_private_root_directory /run/omarchy-device-authorization-rollback /run || exit 1
      exec 8>/run/omarchy-device-authorization-rollback/lock
      flock -x 8
      da_main "${2:-0}"
      ;;
    *) exit 2 ;;
  esac
fi
