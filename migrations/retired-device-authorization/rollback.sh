#!/bin/bash -p

# Privileged Bash suppresses BASH_ENV and exported functions before root rollback or a Bolt guard runs.
if [[ ${BASH_SOURCE[0]} == "$0" ]]; then
  [[ $- == *p* ]] && (( EUID == 0 )) || exit 126
  source /usr/bin/omarchy-security-functions || exit 126
  omarchy_security_require_privileged_bash_startup || exit 126
  omarchy_security_sanitize_bash_environment "$0" "$@"
  # Root recovery services must run package-owned code.
  [[ $(/usr/bin/readlink -e -- "$0") == "/usr/share/omarchy/migrations/retired-device-authorization/rollback.sh" ]] || exit 126
  da_support=/usr/share/omarchy/migrations/retired-device-authorization
else
  da_support=$(cd -- "${BASH_SOURCE[0]%/*}" && pwd) || exit 126
fi

source "$da_support/thunderbolt-policy.sh" || exit 126
source "$da_support/thunderbolt-setup.sh" || exit 126
source "$da_support/units.sh" || exit 126
DA_ROOT=""
DA_STATE=/var/lib/omarchy/retired-device-authorization

# Recovery may restart the retired controller. Keep its two root entrypoints
# available until the original transactional removal has verified success.
da_prepare_thunderbolt_units() {
  local unit="$DA_ROOT/etc/systemd/system/omarchy-thunderbolt-authorization.service"
  local guard="$DA_ROOT/etc/systemd/system/bolt.service.d/omarchy-authorization.conf"
  local content
  if [[ -f $unit ]]; then
    content=$(<"$unit") || return 1
    if [[ $content != *"ExecStart=/usr/bin/omarchy-thunderbolt-authorization-daemon"* &&
      $content != *"ExecStart=/bin/bash -p /usr/share/omarchy/migrations/retired-device-authorization/rollback.sh daemon"* &&
      $content != *'ExecStart=/bin/bash -p "/usr/share/omarchy/migrations/retired-device-authorization/rollback.sh" daemon'* ]]; then
      echo "Unrecognized Thunderbolt controller entrypoint; repair its unit before retrying." >&2
      return 1
    fi
  else
    install -d -m755 "$DA_ROOT/etc/systemd/system" || return 1
    content='[Unit]
Description=Recover installed Thunderbolt authorization during removal
Wants=bolt.service
After=bolt.service polkit.service
ConditionPathExists=/etc/omarchy/thunderbolt-authorization.enabled

[Service]
Type=simple
ExecStart=/bin/bash -p /usr/share/omarchy/migrations/retired-device-authorization/rollback.sh daemon
RuntimeDirectory=omarchy-thunderbolt-authorization
RuntimeDirectoryMode=0755
Restart=on-failure
RestartSec=2
UMask=0077
NoNewPrivileges=yes
ProtectSystem=strict
ReadWritePaths=/var/lib/omarchy/thunderbolt-authorization /run/lock
ProtectHome=yes
PrivateTmp=yes
ProtectKernelTunables=yes
ProtectKernelModules=yes
ProtectControlGroups=yes
RestrictAddressFamilies=AF_UNIX

[Install]
WantedBy=multi-user.target'
    da_publish_file "$unit" "$content" || return 1
  fi
  if [[ -f $guard ]]; then
    content=$(<"$guard") || return 1
    if [[ $content != *"ExecStartPre=/usr/bin/omarchy-thunderbolt-authorization-admin guard"* &&
      $content != *'ExecStartPre=/bin/bash -p "/usr/share/omarchy/migrations/retired-device-authorization/rollback.sh" guard'* ]]; then
      echo "Unrecognized Bolt guard entrypoint; repair its unit before retrying." >&2
      return 1
    fi
  fi
  systemctl daemon-reload || return 1
  for unit in bolt.service "$TB_SERVICE"; do
    if systemctl is-failed --quiet "$unit"; then
      systemctl reset-failed "$unit" || return 1
    fi
  done
  if [[ -f $TB_MARKER ]]; then
    systemctl enable --force "$TB_SERVICE" || return 1
    systemctl start "$TB_SERVICE" || return 1
  fi
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
    da_stop_unit "$TB_SERVICE" system "$DA_ROOT" || return 1
    rm -f -- "$TB_MARKER" "$TB_PENDING"
  fi
  systemctl daemon-reload || return 1
}

da_remove_usb() {
  local requested=$1 attribute boot_pending="$DA_STATE/usb-boot-pending" boot_removed="$DA_STATE/usb-boot-removed"
  if [[ -e "$DA_ROOT/etc/limine-entry-tool.d/usb-authorization.conf" || -f $boot_pending ]] ||
    grep -Fq '# Omarchy USB authorization begin' "$DA_ROOT/etc/default/limine" 2>/dev/null; then
    install -d -m755 "$DA_STATE" || return 1
    da_publish_file "$boot_pending" 'Omarchy USB boot rollback pending' || return 1
    /bin/bash -p "$da_support/usb-boot.sh" disable || return 1
    da_publish_file "$boot_removed" "$(<"$DA_ROOT/proc/sys/kernel/random/boot_id")" || return 1
    rm -- "$boot_pending" || return 1
    echo "USB boot protection removed; reboot to use the restored boot images."
    requested=1
  fi
  if (( requested )) || grep -Fq 'label "omarchy-usb-authorization-v1"' "$DA_ROOT/etc/usbguard/rules.conf" 2>/dev/null ||
    grep -Fqx '# No USB devices were present during enrollment.' "$DA_ROOT/etc/usbguard/rules.conf" 2>/dev/null; then
    if grep -Eq '(^|[[:space:]])usbcore\.authorized_default=0([[:space:]]|$)' "$DA_ROOT/proc/cmdline" &&
      [[ ! -f $boot_removed || $(<"$boot_removed") != $(<"$DA_ROOT/proc/sys/kernel/random/boot_id") ]]; then
      echo "Remove your USB default-deny boot parameter, rebuild the boot images, reboot, then rerun the migration. USBGuard is retained to keep boot input working." >&2
      return 1
    fi
    da_stop_unit usbguard.service system "$DA_ROOT" || return 1
    attribute=$DA_ROOT/sys/module/usbcore/parameters/authorized_default
    if [[ -e $attribute && $(<"$attribute") == "0" ]]; then
      echo 1 >"$attribute" || return 1
    fi
    for attribute in "$DA_ROOT/sys/bus/usb/devices/usb"*/authorized_default "$DA_ROOT/sys/bus/usb/devices/"*/authorized; do
      [[ -e $attribute ]] || continue
      if ! echo 1 >"$attribute"; then
        [[ ! -e $attribute ]] || return 1
      fi
    done
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

da_repair_root() {
  local root=$1 path mode
  [[ $root == /* && $root != "/" && -d $root && ! -L $root ]] || return 1
  for path in etc etc/omarchy etc/limine-entry-tool.d etc/default etc/systemd etc/systemd/system \
    var var/lib var/lib/omarchy var/lib/omarchy/thunderbolt-authorization var/lib/boltd \
    usr usr/bin usr/lib usr/lib/systemd usr/lib/systemd/system usr/share usr/share/omarchy \
    usr/share/omarchy/install usr/share/omarchy/install/user usr/share/omarchy/install/user/first-run usr/share/omarchy/migrations \
    usr/bin/omarchy-provision-owner usr/share/omarchy/install/user/first-run/enable-user-units.sh \
    etc/default/limine etc/limine-entry-tool.d/usb-authorization.conf var/lib/boltd/boltd.conf \
    var/lib/omarchy/thunderbolt-authorization/policy.json; do
    [[ ! -L $root/$path ]] || { echo "Refusing a linked factory policy directory: $path" >&2; return 1; }
  done
  mode=$(tb_config_authmode "$root/var/lib/boltd/boltd.conf") || return 1
  if [[ -f $root/var/lib/omarchy/thunderbolt-authorization/policy.json ]]; then
    mode=$(jq -er .original_authmode "$root/var/lib/omarchy/thunderbolt-authorization/policy.json") || return 1
  fi
  da_reset_factory_thunderbolt "$root" "$mode" || return 1
  if [[ -f $root/usr/lib/systemd/system/usbguard.service ]]; then
    systemctl --root="$root" disable usbguard.service || return 1
  fi
  source "$da_support/usb-boot.sh" || return 1
  path=$root/etc/limine-entry-tool.d/usb-authorization.conf
  if [[ -e $path ]]; then
    [[ $(<"$path") == "$setting" ]] || return 1
    rm -- "$path" || return 1
  fi
  if [[ -f $root/etc/default/limine ]]; then
    usb_authorization_disable_snapshot_setting "$root/etc/default/limine" || return 1
  fi
  da_factory_enrollment "$root"
}

da_clean_factory() (
  local top factory device read_only path mode checkpoint
  [[ $(findmnt -no FSTYPE /) == "btrfs" ]] || return 0
  device=$(findmnt -no SOURCE /) || return 1
  device=${device%%\[*}
  top=$(mktemp -d "$DA_ROOT/run/omarchy-accessory-rollback.XXXXXXXXXX") || return 1
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
  btrfs property set -ts "$factory" ro false || return 1
  da_repair_root "$factory"
)

da_retire_usb_access() {
  local path user home rest content expected
  expected=$'Devices=list,modify,listen\nPolicy=list\nExceptions=listen'
  while IFS=: read -r user rest rest rest rest home rest; do
    [[ $home == /* ]] || continue
    if [[ -e $home/.config/systemd/user/omarchy-usb-authorization.service ||
      -L $home/.config/systemd/user/omarchy-usb-authorization.service ||
      -d $home/.local/state/omarchy/usb-authorization ]]; then
      path="$DA_ROOT/etc/usbguard/IPCAccessControl.d/$user"
      [[ -f $path && ! -L $path ]] || continue
      content=$(<"$path") || return 1
      if [[ $content == "$expected" ]]; then
        install -d -m700 "$DA_STATE/ipc" || return 1
        mv -- "$path" "$DA_STATE/ipc/$user" || return 1
      fi
    fi
  done <"$DA_ROOT/etc/passwd"
}

da_main() {
  local usb=${1:-0} path status=0 unit
  [[ $usb == "0" || $usb == "1" ]] || return 2
  da_remove_thunderbolt || status=1
  da_remove_usb "$usb" || status=1
  da_clean_factory || status=1
  (( status == 0 )) || return 1
  da_retire_usb_access || return 1
  for unit in omarchy-usb-authorization.service omarchy-thunderbolt-authorization.service; do
    da_remove_unit_links "$DA_ROOT/etc/systemd/user" "$unit" || return 1
    da_remove_unit_links "$DA_ROOT/run/systemd/user" "$unit" || return 1
  done
  for path in "$DA_ROOT/etc/polkit-1/rules.d/40-omarchy-usb.rules" "$DA_ROOT/etc/polkit-1/rules.d/40-omarchy-thunderbolt.rules" \
    "$DA_ROOT/usr/share/polkit-1/actions/org.omarchy.usb.policy" "$DA_ROOT/usr/share/polkit-1/actions/org.omarchy.thunderbolt.policy"; do
    da_archive "$path" || return 1
  done
  install -d -m755 "$DA_STATE" || return 1
  da_publish_file "$DA_STATE/completed" 'Omarchy accessory rollback complete'
}

if [[ ${BASH_SOURCE[0]} == "$0" ]]; then
  [[ $- == *p* ]] && (( EUID == 0 )) || exit 126
  set -euo pipefail
  export PATH="/usr/bin:/bin" LC_ALL=C
  unset DBUS_SYSTEM_BUS_ADDRESS DBUS_SESSION_BUS_ADDRESS
  case ${1:-rollback} in
    guard) tb_guard ;;
    daemon) exec 9>"$TB_LOCK"; tb_daemon ;;
    reset-root) [[ $# == 2 ]] && da_repair_root "$2" ;;
    rollback)
      omarchy_security_prepare_private_root_directory /run/omarchy-device-authorization-rollback /run || exit 1
      exec 8>/run/omarchy-device-authorization-rollback/lock
      flock -x 8
      da_main "${2:-0}"
      ;;
    *) exit 2 ;;
  esac
fi
