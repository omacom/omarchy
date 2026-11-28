# TI TAS2783 SoundWire speaker amp firmware on the HP OmniBook X Flip 16-cc0xxx (board 8EA2).
#
# Kernel snd_soc_tas2783_sdw (<= 7.2) requests 3-field firmware filenames
# (8EA2-0-0x9.bin, 8EA2-0-0xC.bin), while linux-firmware-ti ships 4-field blobs
# under ti/audio/tas2783/8EA2-0-0-0x{9,C}.bin.zst. Without bridging symlinks,
# the speaker amps fail to load DSP protection firmware (-ENOENT). Drop this
# once the kernel driver reads 4-field spkid filenames or linux-firmware-ti
# ships the 3-field symlinks.

if omarchy-hw-x86 && omarchy-hw-match "OmniBook X Flip Laptop 16-cc0"; then
  fw_dir=${OMARCHY_HP_OMNIBOOK_FW_DIR:-/usr/lib/firmware}
  for uid in 0x9 0xC; do
    rel_target="ti/audio/tas2783/8EA2-0-0-${uid}.bin.zst"
    link_path="$fw_dir/8EA2-0-${uid}.bin.zst"
    if [[ -e $fw_dir/$rel_target && ! -e $link_path && ! -e $fw_dir/8EA2-0-${uid}.bin ]]; then
      if (( EUID == 0 )); then
        ln -sfn "$rel_target" "$link_path"
      else
        sudo ln -sfn "$rel_target" "$link_path"
      fi
    fi
  done
fi
