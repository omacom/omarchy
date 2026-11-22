echo "Shrink an AMD APU's dedicated VRAM so the GPU can map more of RAM"

# See omarchy-apply-amd-gpu-memory. Only firmware that lets Linux change the
# carveout offers fwupd's video-memory setting, and only a shrunk carveout
# needs a rebuild: the cap is resized for the RAM it frees, and both apply
# from the next boot. A machine-wide marker, written only after the rebuild,
# records that this one is done, so a second user's run does nothing. A
# failure after the carveout is written leaves it unchanged for the retry, so
# a pending marker, written before anything changes, makes that retry rebuild
# anyway.
done_marker=/var/lib/omarchy/migrations/1794924891-done
pending_marker=/var/lib/omarchy/migrations/1794924891-pending
if [[ -e $done_marker ]]; then
  exit 0
fi

# Only an AMD APU has a carveout, and fwupd can only offer it through amdgpu's
# uma/carveout or a vendor's firmware-attributes, so a machine with neither is
# done without asking for a password. Past that, a failed read (a cancelled
# password prompt, a fwupd error) must leave this pending for a retry,
# apart from a read that finds no video-memory setting.
shopt -s nullglob
apu=false
for device in /sys/bus/pci/devices/*; do
  if [[ $(< "$device/vendor") == "0x1002" && $(< "$device/class") == 0x03* && -f $device/mem_info_vram_total && ! -e $device/mem_info_vram_vendor ]]; then
    apu=true
  fi
done
backends=(/sys/bus/pci/devices/*/uma/carveout /sys/class/firmware-attributes/*/attributes)
if [[ $apu == "false" ]] || (( ${#backends[@]} == 0 )); then
  exit 0
fi

carveouts() {
  local settings

  settings=$(sudo fwupdmgr get-bios-settings --json < /dev/null 2>/dev/null) || return 1
  jq -r '.BiosSettings[]? | select(.AppstreamId == "org.fwupd.bios.video-memory") | .BiosSettingCurrentValue' <<< "$settings"
}

if ! before=$(carveouts); then
  echo "Could not read the firmware's settings. Run omarchy-migrate again to retry." >&2
  exit 1
fi
if [[ -z $before ]]; then
  exit 0
fi

retrying=false
if [[ -e $pending_marker ]]; then
  retrying=true
fi

sudo install -Dm644 /dev/null "$pending_marker"
sudo env PATH="$PATH" omarchy-apply-amd-gpu-memory || exit 1

if ! after=$(carveouts); then
  echo "Could not read the firmware's settings. Run omarchy-migrate again to retry." >&2
  exit 1
fi

if [[ $after == "$before" && $retrying == "false" ]]; then
  sudo rm -f "$pending_marker"
  exit 0
fi

rebuild_log=$(mktemp)
trap 'rm -f "$rebuild_log"' EXIT
sudo limine-mkinitcpio 2>&1 | tee "$rebuild_log"

# limine-mkinitcpio reports a kernel it could not rebuild and still exits 0.
if grep -q 'mkinitcpio failed for kernel' "$rebuild_log"; then
  echo "A boot image was not rebuilt. Fix the error above, then run omarchy-migrate again before rebooting." >&2
  exit 1
fi

sudo install -Dm644 /dev/null "$done_marker"
sudo rm -f "$pending_marker"
omarchy-state set reboot-required
