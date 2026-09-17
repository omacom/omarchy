# Fix silent internal speakers on the 12-inch MacBook (MacBook9,1 / MacBook10,1)
#
# These machines use a Cirrus Logic CS4208 codec whose speaker amplifier is never
# enabled by the in-tree driver: the PCI subsystem ID is generic (8086:7270), so
# snd_hda_codec_cs420x applies no Apple fixup and exposes speaker_outs=0. The
# out-of-tree macbook12-audio-driver replays the codec init that powers the amp.
#
# Two independent things are required for sound to actually come out:
#   1. The driver above (cloned and built against the running kernel via DKMS).
#   2. The EFI startup chime un-muted in NVRAM. The firmware only powers the
#      class-D speaker amp when it plays the boot chime; if the chime is muted
#      the amp is never energised and no software fix can work.
#
# The internal speaker also has no usable hardware volume, so a WirePlumber
# soft-mixer rule is installed for software volume control.
#
# Reference: https://github.com/leifliddy/macbook12-audio-driver
# Verified on Omarchy 4.x / kernel 7.2.5, PipeWire + WirePlumber.

product_name="$(cat /sys/class/dmi/id/product_name 2>/dev/null)"
if [[ $product_name =~ MacBook9,1|MacBook10,1 ]]; then
  echo "Detected 12-inch MacBook (CS4208) - installing speaker audio fix"

  # Build prerequisites. Kernel headers for the running kernel are provided by
  # the base install; dkms, gcc, make, git and wget (to fetch the matching
  # kernel source tarball from kernel.org) are the build chain.
  omarchy-pkg-add dkms gcc make git wget

  # Skip the driver build if it is already installed via DKMS.
  if dkms status 2>/dev/null | grep -q macbook12-audio; then
    echo "macbook12-audio driver already installed via DKMS"
  else
    driver_dir="/usr/src/macbook12-audio-driver"
    if [[ ! -d $driver_dir/.git ]]; then
      echo "Cloning macbook12-audio-driver..."
      git clone https://github.com/leifliddy/macbook12-audio-driver.git "$driver_dir"
    else
      echo "Driver source already exists, pulling latest..."
      git -C "$driver_dir" pull
    fi

    # Install via DKMS so the module auto-rebuilds on kernel updates.
    echo "Installing DKMS driver..."
    (
      cd "$driver_dir"
      ./install.cirrus.driver.sh -i
    )
  fi

  # Force software volume for this card: the speaker path has no hardware amp
  # volume (the codec's only analog amp is on the headphone path), so without
  # this the volume slider does nothing on the speakers.
  mkdir -p /etc/wireplumber/wireplumber.conf.d
  tee /etc/wireplumber/wireplumber.conf.d/51-macbook-cs4208-softvol.conf >/dev/null <<'EOF'
# MacBook9,1 / MacBook10,1 CS4208 - force software volume (WirePlumber 0.5+)
#
# The internal speaker has no usable hardware volume control (the codec's only
# analog amp is wired to the headphone path), so PipeWire must apply volume in
# software for this card. Without this the volume slider does nothing on the
# speakers. Applied at the device level so it takes effect before the card
# profile's mixer paths are set up.

monitor.alsa.rules = [
  {
    matches = [ { device.name = "alsa_card.pci-0000_00_1f.3" } ]
    actions = { update-props = { api.alsa.soft-mixer = true } }
  }
]
EOF

  # Un-mute the EFI startup chime. The firmware energises the speaker amp only
  # when it plays the boot chime; bit 7 of the SystemAudioVolume payload byte is
  # the mute flag. Keep the low 7 volume bits, just clear bit 7. This must be a
  # single write() on an O_WRONLY fd - piping through tee fails with
  # "Invalid argument" (tee uses O_TRUNC and the firmware attribute word is
  # rejected).
  chime_var="/sys/firmware/efi/efivars/SystemAudioVolume-7c436110-ab2a-4bbb-a880-fe41995c9f82"
  if [[ -f $chime_var ]]; then
    payload="$(od -An -tx1 -j4 -N1 "$chime_var" 2>/dev/null | tr -d ' \n')"
    if [[ $payload =~ ^[0-9a-fA-F]{2}$ ]] && (( (16#$payload & 0x80) != 0 )); then
      echo "Un-muting EFI startup chime so the speaker amp is powered at boot"
      chattr -i "$chime_var" 2>/dev/null || true
      python3 -c "
import os
p = '$chime_var'
data = open(p, 'rb').read()
fd = os.open(p, os.O_WRONLY)
os.write(fd, bytes([0x07, 0x00, 0x00, 0x00, data[4] & 0x7f]))
os.close(fd)
"
      chattr +i "$chime_var" 2>/dev/null || true
    fi
  fi

  # s2idle suspend kills the speaker amp (audio dead until reboot), and the
  # codec's d3cold_allowed pin does NOT prevent it - verified empirically.
  # Freezing to idle (/sys/power/state = freeze) keeps the amp alive across
  # suspend. These machines have no S3 (mem_sleep rejects "freeze"), so force
  # systemd onto the plain-freeze path with an empty MemorySleepMode.
  mkdir -p /etc/systemd/sleep.conf.d
  tee /etc/systemd/sleep.conf.d/99-macbook12-audio.conf >/dev/null <<'EOF'
[Sleep]
SuspendState=freeze
MemorySleepMode=
EOF

  echo "Speaker audio fix installed. A reboot is required (the driver binds at"
  echo "boot and the amp is energised by the startup chime). You will hear the"
  echo "Apple startup chime - that is the mechanism, not a side effect."
fi
