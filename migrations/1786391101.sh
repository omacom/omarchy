echo "Fix weak WiFi signal on MacBook Pro 2015-2017 with BCM43602"

# The install-time NVRAM fix only reaches machines set up after it shipped, so
# an existing install on one still gets -90 dBm signal. See
# install/hardware/apple/fix-brcmfmac-nvram.sh for the failure it fixes.

dmi_vendor="${OMARCHY_BRCMFMAC_DMI_VENDOR:-/sys/class/dmi/id/sys_vendor}"
sys_vendor="$(cat "$dmi_vendor" 2>/dev/null || true)"

if [[ $sys_vendor != Apple* ]] || ! lspci -nn | grep -q "14e4:43ba"; then
  exit 0
fi

firmware_dir="/usr/lib/firmware/brcm"
nvram_file="$firmware_dir/brcmfmac43602-pcie.txt"

# Skip if already installed (file exists with the cristianmiranda signature)
if [[ -f $nvram_file ]] && grep -q "pa5ga0=" "$nvram_file" 2>/dev/null; then
  exit 0
fi

echo "Installing improved NVRAM config for BCM43602..."

# Use the NVRAM config from the repo
nvram_source="$OMARCHY_PATH/install/hardware/apple/brcmfmac43602-pcie.txt"
if [[ ! -f $nvram_source ]]; then
  echo "NVRAM config not found at $nvram_source, skipping"
  exit 0
fi

# Find the wireless interface and get its MAC address
iface="$(iw dev 2>/dev/null | awk '$1=="Interface"{print $2}' | head -1)"
if [[ -z "$iface" ]]; then
  iface="$(ls /sys/class/net/ 2>/dev/null | grep -E '^wl' | head -1)"
fi

tmpfile="$(mktemp)"
cp "$nvram_source" "$tmpfile"

if [[ -n "$iface" ]]; then
  mac="$(cat "/sys/class/net/$iface/address" 2>/dev/null)"
  if [[ -n "$mac" ]]; then
    sed -i "s/^macaddr=.*/macaddr=$mac/" "$tmpfile"
    echo "Set MAC address to $mac"
  fi
fi

# Install the NVRAM config (needs sudo)
if [[ -f $nvram_file ]]; then
  sudo cp "$nvram_file" "${nvram_file}.bak.$(date +%s)"
fi
sudo install -Dm644 "$tmpfile" "$nvram_file"
rm -f "$tmpfile"

echo "NVRAM config installed. WiFi signal should improve after reboot."

# Rebuild initramfs and request reboot
if command -v limine-mkinitcpio &>/dev/null; then
  sudo limine-mkinitcpio 2>&1 || sudo mkinitcpio -P 2>&1
elif command -v mkinitcpio &>/dev/null; then
  sudo mkinitcpio -P 2>&1
fi

omarchy-state set reboot-required
