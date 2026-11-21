echo "Rebind Broadcom Wi-Fi across suspend on Macs with brcmfmac"

# The install-time hook only reaches machines set up after it shipped, so an
# existing install on one still loses Wi-Fi after a long suspend. See
# install/hardware/apple/fix-brcmfmac-suspend.sh for the failure it fixes and
# for where this list of brcmfmac PCI IDs comes from.
dmi_vendor="${OMARCHY_BRCMFMAC_DMI_VENDOR:-/sys/class/dmi/id/sys_vendor}"
hook="${OMARCHY_BRCMFMAC_SLEEP_HOOK:-/usr/lib/systemd/system-sleep/rebind-brcmfmac}"

sys_vendor="$(cat "$dmi_vendor" 2>/dev/null || true)"

if ! lspci -nn | grep "106b:180[12]" >/dev/null &&
  ! { [[ $sys_vendor == Apple* ]] &&
    lspci -nn | grep -E "14e4:(43ba|43bb|43bc|43a3|43dc|4464|4488|4425|4433)" >/dev/null; }; then
  exit 0
fi

# Idempotent: a hook identical to the source is already the fix.
if [[ -f $hook ]] && /usr/bin/cmp -s "$OMARCHY_PATH/default/systemd/system-sleep/rebind-brcmfmac" "$hook"; then
  exit 0
fi

sudo /usr/bin/mkdir -p "$(dirname "$hook")"
sudo /usr/bin/install -m 0755 -o root -g root \
  "$OMARCHY_PATH/default/systemd/system-sleep/rebind-brcmfmac" \
  "$hook"

# No reboot needed: systemd-sleep picks up every executable in system-sleep
# the next time the machine suspends.
