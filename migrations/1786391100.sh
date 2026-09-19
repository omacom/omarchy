echo "Run the WPA handshake in software on Macs with Broadcom Wi-Fi"

# The install-time quirk only reaches machines set up after it shipped, and it
# never covered Macs without a T2 at all, so an existing install on one still
# cannot join a WPA2/WPA3 transition-mode network. See
# install/hardware/apple/fix-brcmfmac-supplicant.sh for the failure it fixes and
# for where this list of brcmfmac PCI IDs comes from.
dmi_vendor="${OMARCHY_BRCMFMAC_DMI_VENDOR:-/sys/class/dmi/id/sys_vendor}"
conf="${OMARCHY_BRCMFMAC_CONF:-/etc/modprobe.d/brcmfmac.conf}"

source "$OMARCHY_PATH/install/helpers/pci-sysfs.sh"

sys_vendor="$(cat "$dmi_vendor" 2>/dev/null || true)"

# Detect the PCI IDs from cached sysfs fields rather than lspci, which reads
# config space and resumes runtime-suspended devices.
if ! omarchy-pci-id 0x106b 0x1801 0x1802 &&
  ! { [[ $sys_vendor == Apple* ]] &&
    omarchy-pci-id 0x14e4 0x43ba 0x43bb 0x43bc 0x43a3 0x43dc 0x4464 0x4488 0x4425 0x4433; }; then
  exit 0
fi

# T2 installs already carry this from the installer, so the common case is a
# no-op for the first user and every user after them. Only an active options
# line counts: someone who commented theirs out still needs this.
if [[ -f $conf ]] &&
  grep -Eq '^[[:space:]]*options[[:space:]]+brcmfmac[[:space:]].*feature_disable=0x82000' "$conf"; then
  exit 0
fi

sudo mkdir -p "$(dirname "$conf")"

# Append rather than overwrite, so anything else a user keeps here survives:
# modprobe reads every options line for a module, and nothing else sets
# feature_disable. The leading newline also covers a file that ends without one.
sudo tee -a "$conf" >/dev/null <<'EOF'

# Broadcom's firmware supplicant and authenticator fail the WPA four-way
# handshake on Apple hardware, which surfaces as a rejected password. Disable
# both so wpa_supplicant performs the handshake instead.
options brcmfmac feature_disable=0x82000
EOF

# modprobe only reads this when the module loads. Reloading brcmfmac here would
# drop a Wi-Fi connection that works on the network the user is on right now,
# including the one carrying this update.
omarchy-state set reboot-required
