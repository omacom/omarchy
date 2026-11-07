echo "Enable the internal speakers on the Huawei MateBook D 15 M1280"

# The install-time leaf only reaches machines set up after it shipped. See
# install/hardware/huawei/fix-matebook-d15-speakers.sh for the fault.
conf="${OMARCHY_MODPROBE_DIR:-/etc/modprobe.d}/huawei-matebook-d15-speakers.conf"

if [[ ! -f $conf ]]; then
  source "$OMARCHY_PATH/install/hardware/huawei/fix-matebook-d15-speakers.sh"

  # The driver only reads the option when it loads, and reloading it would pull
  # the sound card out from under PipeWire.
  if [[ -f $conf ]]; then
    omarchy-state set reboot-required
  fi
fi
