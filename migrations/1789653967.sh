echo "Fix silent internal speakers on 12-inch MacBook (CS4208)"

# The install-time audio driver fix only reaches machines set up after it
# shipped, so an existing 12-inch MacBook install still has no speaker output.
# See install/hardware/apple/fix-macbook12-audio.sh for the failure it fixes.

product_name="$(cat /sys/class/dmi/id/product_name 2>/dev/null)"
[[ $product_name =~ MacBook9,1|MacBook10,1 ]] || exit 0

# Skip if the driver is already installed via DKMS (another user applied this).
if dkms status 2>/dev/null | grep -q macbook12-audio; then
  echo "macbook12-audio driver already installed via DKMS"
else
  omarchy-pkg-add dkms gcc make git wget

  driver_dir="/usr/src/macbook12-audio-driver"
  if [[ ! -d $driver_dir/.git ]]; then
    sudo git clone https://github.com/leifliddy/macbook12-audio-driver.git "$driver_dir"
  else
    sudo git -C "$driver_dir" pull
  fi

  (
    cd "$driver_dir"
    sudo ./install.cirrus.driver.sh -i
  )
fi

# Force software volume for this card (speaker path has no hardware amp volume).
softvol_conf="/etc/wireplumber/wireplumber.conf.d/51-macbook-cs4208-softvol.conf"
if [[ ! -f $softvol_conf ]]; then
  sudo mkdir -p /etc/wireplumber/wireplumber.conf.d
  sudo tee "$softvol_conf" >/dev/null <<'EOF'
# MacBook9,1 / MacBook10,1 CS4208 - force software volume (WirePlumber 0.5+)

monitor.alsa.rules = [
  {
    matches = [ { device.name = "alsa_card.pci-0000_00_1f.3" } ]
    actions = { update-props = { api.alsa.soft-mixer = true } }
  }
]
EOF
fi

# Un-mute the EFI startup chime so the firmware powers the speaker amp at boot.
chime_var="/sys/firmware/efi/efivars/SystemAudioVolume-7c436110-ab2a-4bbb-a880-fe41995c9f82"
if [[ -f $chime_var ]]; then
  payload="$(od -An -tx1 -j4 -N1 "$chime_var" 2>/dev/null | tr -d ' \n')"
  if [[ $payload =~ ^[0-9a-fA-F]{2}$ ]] && (( (16#$payload & 0x80) != 0 )); then
    sudo chattr -i "$chime_var" 2>/dev/null || true
    sudo python3 -c "
import os
p = '$chime_var'
data = open(p, 'rb').read()
fd = os.open(p, os.O_WRONLY)
os.write(fd, bytes([0x07, 0x00, 0x00, 0x00, data[4] & 0x7f]))
os.close(fd)
"
    sudo chattr +i "$chime_var" 2>/dev/null || true
  fi
fi

# Keep the codec out of D3cold during suspend, or the speaker amp loses power
# and audio is dead until reboot. Mirror fix-suspend-nvme.sh's systemd service.
audio_d3cold="/sys/bus/pci/devices/0000:00:1f.3/d3cold_allowed"
suspend_service="/etc/systemd/system/omarchy-macbook12-audio-suspend.service"
if [[ -f $audio_d3cold && ! -f $suspend_service ]]; then
  sudo tee "$suspend_service" >/dev/null <<'EOF'
[Unit]
Description=Omarchy MacBook12 Audio Suspend Fix

[Service]
ExecStart=/bin/bash -c 'echo 0 > /sys/bus/pci/devices/0000\:00\:1f.3/d3cold_allowed'

[Install]
WantedBy=multi-user.target
EOF
  sudo systemctl enable omarchy-macbook12-audio-suspend.service
fi

# The driver binds at boot and the amp is energised by the startup chime.
omarchy-state set reboot-required
