echo "Remove hibernation swapfile and resume configuration to prepare for Secure Boot"

swap_subvolume=/swap
swap_file="$swap_subvolume/swapfile"
mkinitcpio_conf=/etc/mkinitcpio.conf.d/omarchy_resume.conf
resume_drop_in=/etc/limine-entry-tool.d/resume.conf
rtc_alarm_drop_in=/etc/limine-entry-tool.d/rtc-alarm.conf
resume_rebuild_pending=/var/lib/omarchy/hibernation-resume-rebuild
keyboard_backlight_hook=/usr/lib/systemd/system-sleep/keyboard-backlight
yoga_service=/etc/systemd/system/yoga-slim7x-hibernate.service
yoga_recover_hook=/usr/lib/systemd/system-sleep/yoga-slim7x-hibernate-recover
facetimehd_drop_ins=(
  /etc/systemd/system/systemd-hibernate.service.d/omarchy-facetimehd.conf
  /etc/systemd/system/systemd-hybrid-sleep.service.d/omarchy-facetimehd.conf
  /etc/systemd/system/systemd-suspend-then-hibernate.service.d/omarchy-facetimehd.conf
)

has_swapfile_active() {
  awk '$1 == "/swap/swapfile" { found=1 } END { exit !found }' /proc/swaps 2>/dev/null
}

has_fstab_swapfile() {
  grep -Eq '^[[:space:]]*/swap/swapfile([[:space:]]|$)' /etc/fstab 2>/dev/null
}

artifacts=(
  "$swap_file"
  "$mkinitcpio_conf"
  "$resume_drop_in"
  "$rtc_alarm_drop_in"
  "$resume_rebuild_pending"
  "$keyboard_backlight_hook"
  "$yoga_service"
  "$yoga_recover_hook"
  "${facetimehd_drop_ins[@]}"
)

needs_cleanup=false
if has_swapfile_active || has_fstab_swapfile; then
  needs_cleanup=true
else
  for path in "${artifacts[@]}"; do
    if [[ -e $path || -L $path ]]; then
      needs_cleanup=true
      break
    fi
  done
fi

$needs_cleanup || exit 0

# Disable the swapfile before touching fstab or boot config so an out-of-memory
# swapoff fails early without leaving a half-migrated system.
if has_swapfile_active; then
  echo "Disabling swap on $swap_file"
  if ! sudo swapoff "$swap_file"; then
    echo "Could not disable $swap_file (free memory first, then rerun omarchy-migrate)" >&2
    exit 1
  fi
fi

if [[ -e $swap_file || -L $swap_file ]]; then
  echo "Removing $swap_file"
  sudo rm -f "$swap_file"
fi

if [[ -d $swap_subvolume ]] && sudo btrfs subvolume show "$swap_subvolume" &>/dev/null; then
  if [[ -z $(sudo find "$swap_subvolume" -mindepth 1 -maxdepth 1 -print -quit) ]]; then
    echo "Removing Btrfs subvolume $swap_subvolume"
    sudo btrfs subvolume delete "$swap_subvolume" >/dev/null
  fi
fi

if has_fstab_swapfile; then
  echo "Removing $swap_file from /etc/fstab"
  sudo cp -a /etc/fstab "/etc/fstab.$(date +%Y%m%d%H%M%S).back"
  sudo sed -i -E '/^[[:space:]]*\/swap\/swapfile([[:space:]]|$)/d; /^# Btrfs swapfile for system hibernation$/d' /etc/fstab
fi

systemd_changed=false

if [[ -e $keyboard_backlight_hook || -L $keyboard_backlight_hook ]]; then
  sudo rm -f "$keyboard_backlight_hook"
fi

if [[ -e $yoga_service || -L $yoga_service ]]; then
  sudo systemctl disable yoga-slim7x-hibernate.service 2>/dev/null || true
  sudo rm -f "$yoga_service"
  systemd_changed=true
fi

if [[ -e $yoga_recover_hook || -L $yoga_recover_hook ]]; then
  sudo rm -f "$yoga_recover_hook"
fi

for drop_in in "${facetimehd_drop_ins[@]}"; do
  if [[ -e $drop_in || -L $drop_in ]]; then
    sudo rm -f "$drop_in"
    sudo rmdir "${drop_in%/*}" 2>/dev/null || true
    systemd_changed=true
  fi
done

if $systemd_changed; then
  sudo systemctl daemon-reload
fi

rebuild_needed=false
if [[ -e $mkinitcpio_conf || -L $mkinitcpio_conf ||
  -e $resume_drop_in || -L $resume_drop_in ||
  -e $rtc_alarm_drop_in || -L $rtc_alarm_drop_in ||
  -e $resume_rebuild_pending || -L $resume_rebuild_pending ]]; then
  rebuild_needed=true
fi

if $rebuild_needed; then
  # Record the pending rebuild before removing the drop-ins so a failed or
  # interrupted rebuild is retried on the next omarchy-migrate.
  sudo install -Dm644 /dev/null "$resume_rebuild_pending"
  sudo rm -f "$mkinitcpio_conf" "$resume_drop_in" "$rtc_alarm_drop_in"

  if omarchy-cmd-present limine-mkinitcpio; then
    echo "Rebuilding boot image without hibernation resume..."
    rebuild_log=$(mktemp)
    trap 'rm -f "$rebuild_log"' EXIT
    # limine-mkinitcpio reports a failed kernel and still exits 0.
    set +e
    sudo limine-mkinitcpio 2>&1 | tee "$rebuild_log"
    rebuild_status=("${PIPESTATUS[@]}")
    set -e
    if (( rebuild_status[0] != 0 || rebuild_status[1] != 0 )) || grep -q 'mkinitcpio failed for kernel' "$rebuild_log"; then
      echo "Could not rebuild the boot image; rerun omarchy-migrate once fixed" >&2
      exit 1
    fi
    rm -f "$rebuild_log"
    trap - EXIT
  elif omarchy-cmd-present mkinitcpio; then
    echo "Rebuilding initramfs without hibernation resume..."
    sudo mkinitcpio -P
  fi

  sudo rm -f "$resume_rebuild_pending"
  omarchy-state set reboot-required
fi
