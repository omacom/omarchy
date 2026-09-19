echo "Fix audio on MacBook Pro with Cirrus Logic CS8409"

# The install-time audio driver fix only reaches machines set up after it shipped,
# so an existing install on one still has no speaker output. See
# install/hardware/apple/fix-snd-hda-macbookpro.sh for the failure it fixes.

# Skip on non-Mac hardware
sys_vendor="$(cat /sys/class/dmi/id/sys_vendor 2>/dev/null || true)"
[[ $sys_vendor == Apple* ]] || exit 0

# Skip if no Cirrus Logic CS8409 is detected
lspci -nn | grep -q "106b:3900" || exit 0

# Skip if DKMS module is already installed
if dkms status 2>/dev/null | grep -q "snd_hda_macbookpro"; then
  echo "snd_hda_macbookpro already installed via DKMS"
  exit 0
fi

echo "Installing snd_hda_macbookpro for Cirrus Logic CS8409..."

# Install build dependencies
if (( EUID == 0 )); then
  pacman -S --noconfirm --needed linux-headers gcc make patch wget git dkms 2>&1
else
  sudo pacman -S --noconfirm --needed linux-headers gcc make patch wget git dkms 2>&1
fi

# Clone the driver source to /usr/src for DKMS
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
omarchy-state set reboot-required
