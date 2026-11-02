# HP ProDesk 600 G5 Desktop Mini advertises disconnected HDMI/DP pins,
# so snd-hda-intel creates no HDMI PCM devices. Do not override working systems.
if omarchy-hw-match "^HP ProDesk 600 G5 Desktop Mini$" &&
  grep -q "Vendor Id: 0x14f15098" /proc/asound/card*/codec* 2>/dev/null &&
  ! grep -qE '^[0-9]+-[0-9]+: HDMI' /proc/asound/pcm 2>/dev/null &&
  [[ ! -e /etc/modprobe.d/hda-jack-retask.conf && ! -e /lib/firmware/hda-jack-retask.fw ]]; then
  for codec in /proc/asound/card*/codec*; do
    if grep -q "Vendor Id: 0x8086280b" "$codec" &&
      grep -q "Subsystem Id: 0x80860101" "$codec" &&
      grep -q "Address: 2$" "$codec" &&
      [[ $(grep -c '  Devices: 0$' "$codec") == "3" ]]; then
      echo "Fix missing HDMI/DisplayPort audio on HP ProDesk 600 G5 Desktop Mini"

      sudo mkdir -p /lib/firmware /etc/modprobe.d
      sudo tee /lib/firmware/hda-jack-retask.fw >/dev/null <<'EOF'
[codec]
0x8086280b 0x80860101 2
[pincfg]
0x05 0x18560070
0x06 0x18560070
0x07 0x18560070
EOF

      sudo tee /etc/modprobe.d/hda-jack-retask.conf >/dev/null <<'EOF'
# HP ProDesk 600 G5 Desktop Mini: enable disconnected HDMI/DisplayPort pins
options snd-hda-intel patch=hda-jack-retask.fw
EOF
      # The driver and patch load from the root filesystem; no initramfs rebuild.
      echo "HDMI/DisplayPort pin correction installed. Reboot required."
      break
    fi
  done
fi
