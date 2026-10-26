echo "Give the ASUS ProArt P16 (NVIDIA N1x) speakers ASUS's amplifier tuning"

# See install/hardware/asus/fix-asus-proart-p16-speakers.sh. The amplifiers load
# the new tuning at the next boot. A speaker tuning that waits for it, as the
# P14's does, can now be switched on.
if omarchy-hw-match "H7607BA"; then
  omarchy-pkg-add asus-proart-p16-speaker-firmware

  if omarchy-audio-tuning match >/dev/null 2>&1; then
    omarchy-pkg-add lsp-plugins-lv2
    omarchy-audio-tuning on
  fi

  omarchy-state set reboot-required
fi
