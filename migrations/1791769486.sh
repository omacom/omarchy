echo "Remove approval for new USB and Thunderbolt devices"

# Approval for new accessories (#11874) shipped briefly to edge and dev. The
# package update has already removed its commands, units and Polkit rules; this
# undoes what they left on the machine so devices connect as they did before.

usb_state=$HOME/.local/state/omarchy/usb-authorization
tb_dir=/var/lib/omarchy/thunderbolt-authorization
usb_boot_drop_in=/etc/limine-entry-tool.d/usb-authorization.conf
usb_boot_pending=/var/lib/omarchy/usb-authorization-boot.removing
usb_boot_parameter=usbcore.authorized_default=0
usbguard_shipped=1791573373 # when usbguard joined the default packages
# The access every Omarchy path granted with `usbguard add-user`.
usbguard_grant=$'Devices=list,modify,listen\nPolicy=list\nExceptions=listen'

# The approval watchers. Their unit files are gone, so systemctl disable can't
# find them; drop the enablement links directly.
for unit in omarchy-usb-authorization.service omarchy-thunderbolt-authorization.service; do
  systemctl --user stop "$unit" 2>/dev/null || true
  rm -f "$HOME"/.config/systemd/user/*.wants/"$unit"
done
rm -f "$HOME/.config/systemd/user/omarchy-usb-authorization.service"
systemctl --user daemon-reload

bolt_list() {
  sudo busctl --system --json=short call org.freedesktop.bolt /org/freedesktop/bolt org.freedesktop.bolt1.Manager "$1" | jq -r '.data[0][]'
}

# A device or controller missing from Bolt's inventory has nothing to restore.
# Any other failed read stops the migration, so it is retried.
bolt_has() {
  grep -qxF "/org/freedesktop/bolt/$1/${2//-/_}" <<<"$bolt_known"
}

bolt_get() {
  sudo busctl --system --json=short get-property org.freedesktop.bolt "/org/freedesktop/bolt/$1/${2//-/_}" "org.freedesktop.bolt1.$3" "$4" | jq -c .data
}

if [[ -d $tb_dir || -e /etc/omarchy/thunderbolt-authorization.enabled || -e /etc/omarchy/thunderbolt-authorization.pending ]]; then
  sudo systemctl stop omarchy-thunderbolt-authorization.service 2>/dev/null || true
  sudo rm -f /etc/systemd/system/multi-user.target.wants/omarchy-thunderbolt-authorization.service \
    /etc/omarchy/thunderbolt-authorization.enabled /etc/omarchy/thunderbolt-authorization.pending
  sudo systemctl daemon-reload

  state=$(sudo cat "$tb_dir/policy.json" 2>/dev/null || echo '{}')
  recovery=$(sudo cat "$tb_dir/boot-recovery.json" 2>/dev/null || echo '{}')

  # Thunderbolt Boot replaced device policies and emptied the firmware boot
  # allowlists. The originals were saved when it was turned on, or only in the
  # recovery journal if turning it on was interrupted.
  firmware=$(jq -c --argjson recovery "$recovery" \
    '.boot_original // (if $recovery.policies then $recovery | {policies, acls} else {} end)' <<<"$state")

  bolt_devices=$(bolt_list ListDevices)
  bolt_domains=$(bolt_list ListDomains)
  bolt_known=$bolt_devices$'\n'$bolt_domains

  while read -r uid policy; do
    if bolt_has devices "$uid"; then
      current=$(bolt_get devices "$uid" Device Policy)
      if [[ $current != "\"$policy\"" ]]; then
        sudo boltctl config device.policy "$uid" "$policy"
      fi
    fi
  done < <(jq -r '.policies // {} | to_entries[] | "\(.key) \(.value)"' <<<"$firmware")

  # Bolt rejects a BootACL write that changes nothing, so compare first.
  unrestored=0
  while read -r uid; do
    acl=$(jq -c --arg uid "$uid" '.acls[$uid]' <<<"$firmware")
    if ! bolt_has domains "$uid"; then
      echo "Thunderbolt controller $uid is not present; its firmware boot allowlist was not restored."
      unrestored=1
      continue
    fi
    current=$(bolt_get domains "$uid" Domain BootACL)
    if [[ $current != "$acl" ]]; then
      mapfile -t entries < <(jq -r '.[]' <<<"$acl")
      sudo busctl --system set-property org.freedesktop.bolt "/org/freedesktop/bolt/domains/${uid//-/_}" \
        org.freedesktop.bolt1.Domain BootACL as "${#entries[@]}" "${entries[@]}"
    fi
  done < <(jq -r '.acls // {} | keys[]' <<<"$firmware")

  # Accessories approved here were stored with Bolt's manual policy, which
  # Bolt won't authorize on its own. Hand back the ones Omarchy stored, as the
  # removal command did, never a manual policy somebody else set.
  while read -r uid store_time; do
    if bolt_has devices "$uid"; then
      current=$(bolt_get devices "$uid" Device Policy)
      stored=$(bolt_get devices "$uid" Device StoreTime)
      if [[ $current == '"manual"' && $stored == "$store_time" ]]; then
        sudo boltctl config device.policy "$uid" auto
      fi
    fi
  done < <(jq -r '(.trusted // {}) as $trusted | .enrolled // {} | to_entries[] | select($trusted[.key]) | "\(.key) \(.value.StoreTime)"' <<<"$state")

  # A first setup that failed and then failed to undo itself can lose
  # policy.json after switching Bolt off; Bolt's original config is then only
  # in the setup journal. A deferred install that never finished setup left
  # Bolt's mode untouched and has neither.
  setup=$(sudo cat "$tb_dir/setup-recovery.json" 2>/dev/null || echo '{}')
  config=$(jq -c '[.files // {} | to_entries[] | select(.key | endswith("/boltd.conf")) | .value]' <<<"$setup")
  mode=$(jq -r '.original_authmode // empty' <<<"$state")
  if [[ -z $mode && $config != "[]" ]]; then
    mode=$(jq -r '.[0].data // ""' <<<"$config" | base64 -d | awk '
      /^[[:space:]]*\[/ { section = ($0 ~ /^[[:space:]]*\[config\][[:space:]]*$/) }
      section && /^[[:space:]]*AuthMode[[:space:]]*=/ { sub(/^[^=]*=[[:space:]]*/, ""); sub(/[[:space:]]*$/, ""); mode = $0 }
      END { print mode == "" ? "enabled" : mode }
    ')
  fi
  if [[ -n $mode ]]; then
    sudo boltctl config global.auth-mode "$mode"
  fi

  if (( unrestored )) && [[ -d $tb_dir ]]; then
    sudo mv -T "$tb_dir" "$tb_dir.unrestored"
    echo "The saved Thunderbolt settings are kept in $tb_dir.unrestored."
  else
    sudo rm -rf "$tb_dir"
  fi
  sudo rm -rf /run/omarchy-thunderbolt-authorization
fi

# limine-mkinitcpio reports success even when a kernel image fails to build, so
# check every current kernel entry. Limine's command line wins, except under
# Secure Boot, where the signed image's embedded one does.
usb_boot_cleared() {
  local entries key value esp secure_boot=0 found=0
  local efivar=/sys/firmware/efi/efivars/SecureBoot-8be4df61-93ca-11d2-aa0d-00e098032b8c

  if [[ -r $efivar && $(od -An -t u1 -j 4 -N 1 "$efivar") == *1 ]]; then
    secure_boot=1
  fi
  esp=$(sed -n 's/^ESP_PATH=["'\'']\?\([^"'\'']*\).*/\1/p' /etc/default/limine | tail -1)
  esp=${esp:-/boot}
  entries=$(sudo awk '
    /^  \/\/[^\/]/ { entry = 1; next }
    /^ *\// { entry = 0 }
    entry && /^  (path|cmdline):/ { key = $1; sub(/^  [a-z]+:[[:space:]]*/, ""); print key "\t" $0 }
  ' "$esp/limine.conf") || return 1

  while IFS=$'\t' read -r key value; do
    if [[ $key == "cmdline:" ]]; then
      [[ " $value " != *" $usb_boot_parameter "* ]] || return 1
    elif [[ $key == "path:" ]]; then
      found=1
      if (( secure_boot )); then
        value=${value#'boot():'}
        value=$esp${value%%#*}
        sudo test -r "$value" || return 1
        if sudo grep -qaF "$usb_boot_parameter" "$value"; then
          return 1
        fi
      fi
    fi
  done <<<"$entries"
  (( found ))
}

# The opt-in USB at Boot setting: the parameter on the kernel command line, for
# new boot entries and new snapshots. Keep a marker until the rebuilt entries
# are verified, so an interrupted rebuild is retried rather than skipped.
if [[ -e $usb_boot_drop_in || -e $usb_boot_pending ]] || grep -Fqx '# Omarchy USB authorization begin' /etc/default/limine 2>/dev/null; then
  sudo touch "$usb_boot_pending"
  sudo rm -f "$usb_boot_drop_in"
  sudo sed -i '/^# Omarchy USB authorization begin$/,/^# Omarchy USB authorization end$/d' /etc/default/limine
  sudo limine-mkinitcpio
  if ! usb_boot_cleared; then
    echo "A boot entry still has $usb_boot_parameter, so USBGuard stays until it is rebuilt. Run omarchy-migrate to retry."
    exit 1
  fi
  sudo rm -f "$usb_boot_pending"
fi

# Leave a USBGuard the user set up before Omarchy shipped it. pacman resets the
# install date on every upgrade, so ask its log when usbguard first arrived.
usbguard_from_omarchy() {
  local first

  if [[ -f $usb_state/policy-generated-by-omarchy ]]; then
    return 0
  fi
  first=$(grep -m1 -oP '^\[\K[^]]+(?=\] \[ALPM\] installed usbguard )' /var/log/pacman.log) || return 1
  (( $(date -d "$first" +%s) >= usbguard_shipped )) || return 1
  [[ $(sudo cat "/etc/usbguard/IPCAccessControl.d/$USER" 2>/dev/null) == "$usbguard_grant" ]]
}

if omarchy-pkg-present usbguard && usbguard_from_omarchy; then
  sudo systemctl disable --now usbguard.service
  # USBGuard leaves the root hubs denying new devices when it exits, until
  # the next boot. Restore the kernel default and authorize what it blocked.
  shopt -s nullglob
  echo 1 | sudo tee /sys/bus/usb/devices/usb*/authorized_default /sys/bus/usb/devices/*/authorized >/dev/null
  shopt -u nullglob
  omarchy-pkg-drop usbguard

  # The approval access granted to each user outlives the package.
  while IFS= read -r -d '' grant; do
    if [[ $(sudo cat "$grant") == "$usbguard_grant" ]]; then
      sudo rm -f "$grant"
    fi
  done < <(sudo find /etc/usbguard/IPCAccessControl.d -maxdepth 1 -type f -print0 2>/dev/null)
  sudo rmdir /etc/usbguard/IPCAccessControl.d /etc/usbguard 2>/dev/null || true
fi

for action in /usr/share/polkit-1/actions/org.omarchy.usb.policy /usr/share/polkit-1/actions/org.omarchy.thunderbolt.policy; do
  if [[ -e $action ]] && ! pacman -Qo "$action" &>/dev/null; then
    sudo rm -f "$action"
  fi
done

rm -rf "$usb_state"
