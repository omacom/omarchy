# Fix audio on MacBook Pro with Cirrus Logic CS8409 (snd_hda_macbookpro)
#
# The CS8409 codec on MacBook Pro 2015-2017 needs the community snd_hda_macbookpro
# driver to enable speakers, headphone jack, and microphone. The in-tree driver
# (snd_hda_codec_cs8409) only provides basic functionality.
#
# Source: https://github.com/davidjo/snd_hda_macbookpro

# Detect Cirrus Logic CS8409 audio codec (Apple subsystem 106b:3900)
if lspci -nn | grep -q "106b:3900" || grep -rq "CS8409" /proc/asound/card*/codec* 2>/dev/null; then
  echo "Cirrus Logic CS8409 detected, installing snd_hda_macbookpro driver"

  # Install build dependencies
  omarchy-pkg-add linux-headers gcc make patch wget git dkms

  # Clone the driver source for DKMS
  driver_dir="/usr/src/snd_hda_macbookpro"
  if [[ ! -d $driver_dir/.git ]]; then
    echo "Cloning snd_hda_macbookpro from GitHub..."
    sudo git clone https://github.com/davidjo/snd_hda_macbookpro.git "$driver_dir" 2>&1
  else
    echo "Driver source already exists, pulling latest..."
    sudo git -C "$driver_dir" pull 2>&1
  fi

  # Install via DKMS (auto-rebuilds on kernel updates)
  echo "Installing DKMS driver..."
  (
    cd "$driver_dir"
    sudo ./install.cirrus.driver.sh -i 2>&1
  )

  # Rebuild initramfs
  echo "Rebuilding initramfs..."
  if command -v limine-mkinitcpio &>/dev/null; then
    sudo limine-mkinitcpio 2>&1 || sudo mkinitcpio -P 2>&1
  elif command -v mkinitcpio &>/dev/null; then
    sudo mkinitcpio -P 2>&1
  fi

  echo "snd_hda_macbookpro driver installed. Reboot to apply."
fi
