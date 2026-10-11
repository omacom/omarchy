# Fix the headset microphone on ASUS VivoBook X415MA / A416MA
# The ALC256 codec needs a pin quirk so the combo jack exposes the headset
# microphone. Without it only the internal mic is detected, and plugging a
# headset in adds no capture device.
# The analog codec on this board is bound by snd_hda_intel rather than the SOF
# driver, so the option targets snd-hda-intel. Confirmed via
# /sys/module/snd_hda_intel/parameters/model on the X415MA.

if omarchy-hw-match "X415MA"; then
  sudo mkdir -p /etc/modprobe.d
  sudo tee /etc/modprobe.d/alsa-asus-x415ma.conf >/dev/null <<'EOF'
options snd-hda-intel model=dell-headset-multi
EOF
fi
