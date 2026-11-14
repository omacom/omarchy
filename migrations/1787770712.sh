echo "Check HP ProDesk 600 G5 Desktop Mini HDMI/DisplayPort audio correction"

if [[ ! -e /etc/modprobe.d/hda-jack-retask.conf ]]; then
  source "$OMARCHY_PATH/install/hardware/intel/fix-hdmi-audio-kabylake.sh"
  if [[ -e /etc/modprobe.d/hda-jack-retask.conf ]]; then
    omarchy-state set reboot-required
  fi
fi
