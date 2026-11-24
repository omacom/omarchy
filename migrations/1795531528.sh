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

# Match files installed by Omarchy's retired hibernation helpers so custom
# administrator-authored files at those paths are left alone.
is_omarchy_file() {
  local path="$1" marker="$2"
  [[ -f $path && ! -L $path ]] && grep -Fq "$marker" "$path" 2>/dev/null
}

omarchy_files_to_remove=()
if is_omarchy_file "$keyboard_backlight_hook" "Turn off keyboard backlight before hibernate"; then
  omarchy_files_to_remove+=("$keyboard_backlight_hook")
fi
if is_omarchy_file "$yoga_service" "/usr/share/omarchy/install/hardware/lenovo/yoga-slim7x-hibernate.sh"; then
  omarchy_files_to_remove+=("$yoga_service")
fi
if is_omarchy_file "$yoga_recover_hook" "yoga-slim7x-hibernate.service"; then
  omarchy_files_to_remove+=("$yoga_recover_hook")
fi
for drop_in in "${facetimehd_drop_ins[@]}"; do
  if is_omarchy_file "$drop_in" "omarchy-system-sleep-facetimehd"; then
    omarchy_files_to_remove+=("$drop_in")
  fi
done

rebuild_needed=false
if [[ -e $mkinitcpio_conf || -L $mkinitcpio_conf ||
  -e $resume_drop_in || -L $resume_drop_in ||
  -e $rtc_alarm_drop_in || -L $rtc_alarm_drop_in ||
  -e $resume_rebuild_pending || -L $resume_rebuild_pending ]]; then
  rebuild_needed=true
fi

if ! has_swapfile_active && ! has_fstab_swapfile &&
  [[ ! -e $swap_file && ! -L $swap_file ]] &&
  ! $rebuild_needed && (( ${#omarchy_files_to_remove[@]} == 0 )); then
  exit 0
fi

# Disable the swapfile before touching fstab or boot config so an out-of-memory
# swapoff fails early without leaving a half-migrated system.
if has_swapfile_active; then
  echo "Disabling swap on $swap_file"
  if ! sudo swapoff "$swap_file"; then
    echo "Could not disable $swap_file (free memory first, then rerun omarchy-migrate)" >&2
    exit 1
  fi
fi

# Remove the fstab entry before deleting the swapfile so an interruption in
# between cannot leave a failing swap unit on the next boot.
if has_fstab_swapfile; then
  echo "Removing $swap_file from /etc/fstab"
  sudo cp -a /etc/fstab "/etc/fstab.$(date +%Y%m%d%H%M%S).back"
  sudo sed -i -E '/^[[:space:]]*\/swap\/swapfile([[:space:]]|$)/d; /^# Btrfs swapfile for system hibernation$/d' /etc/fstab
fi

if [[ -e $swap_file || -L $swap_file ]]; then
  echo "Removing $swap_file"
  sudo rm -f "$swap_file"
fi

if [[ -d $swap_subvolume ]] && ! mountpoint -q "$swap_subvolume" && sudo btrfs subvolume show "$swap_subvolume" &>/dev/null; then
  if [[ -z $(sudo find "$swap_subvolume" -mindepth 1 -maxdepth 1 -print -quit) ]]; then
    echo "Removing Btrfs subvolume $swap_subvolume"
    sudo btrfs subvolume delete "$swap_subvolume" >/dev/null
  fi
fi

if (( ${#omarchy_files_to_remove[@]} > 0 )); then
  if is_omarchy_file "$yoga_service" "/usr/share/omarchy/install/hardware/lenovo/yoga-slim7x-hibernate.sh"; then
    sudo systemctl disable yoga-slim7x-hibernate.service 2>/dev/null || true
  fi
  sudo rm -f "${omarchy_files_to_remove[@]}"
  for drop_in in "${facetimehd_drop_ins[@]}"; do
    sudo rmdir "${drop_in%/*}" 2>/dev/null || true
  done
  sudo systemctl daemon-reload
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
  fi

  sudo rm -f "$resume_rebuild_pending"
  omarchy-state set reboot-required
fi
