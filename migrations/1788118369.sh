echo "Avoid idle audio pops on ASUS GU605CX laptops with Realtek ALC285"

if omarchy-hw-asus-gu605cx-alc285; then
  audio_config="/etc/modprobe.d/omarchy-asus-gu605cx-audio.conf"

  if [[ ! -e $audio_config && ! -L $audio_config ]]; then
    source "$OMARCHY_PATH/install/hardware/asus/fix-gu605cx-audio-pop.sh"
    # Apply on the next boot: changing live power states can itself cause a pop.
    omarchy-state set reboot-required
  fi
fi
