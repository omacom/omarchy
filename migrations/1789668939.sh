echo "Rebind Apple BCM4350/BCM43602 Wi-Fi across suspend"

# The install-time hook only reaches machines set up after it shipped, so an
# existing install on one still loses Wi-Fi after a long suspend. See
# install/hardware/apple/fix-brcmfmac-suspend.sh for the failure it fixes and
# for the pre-T2 chip boundary retained from omacom/omarchy#7333.
dmi_vendor="${OMARCHY_BRCMFMAC_DMI_VENDOR:-/sys/class/dmi/id/sys_vendor}"
hook="${OMARCHY_BRCMFMAC_SLEEP_HOOK:-/usr/lib/systemd/system-sleep/rebind-brcmfmac}"

sys_vendor="$(cat "$dmi_vendor" 2>/dev/null || true)"

if [[ $sys_vendor != Apple* ]] ||
  ! lspci -nn | grep -E "14e4:(43a3|43ba|43bb|43bc)" >/dev/null; then
  exit 0
fi

# Idempotent: a hook identical to the source is already the fix.
if [[ -f $hook && ! -L $hook ]] && /usr/bin/cmp -s "$OMARCHY_PATH/default/systemd/system-sleep/rebind-brcmfmac" "$hook"; then
  exit 0
fi

# Replace only the previously shipped hook, never administrator changes.
if [[ -e $hook || -L $hook ]]; then
  if [[ -L $hook || ! -f $hook ]] ||
    [[ ! $(sha256sum "$hook" | cut -d ' ' -f1) =~ ^(0e16be9962c708bfe9fe20829fbd54af4d792388f2baeaa868e16351e12148a1|9b03e6f8480a8f504ba89ed89fcfe10d47a615d6d64517bbb8d4adfb0f6953f9)$ ]]; then
    echo "Preserving customized Broadcom sleep hook: $hook. Reconcile it with $OMARCHY_PATH/default/systemd/system-sleep/rebind-brcmfmac, then retry." >&2
    exit 1
  fi
fi

sudo /usr/bin/mkdir -p "$(dirname "$hook")"
sudo /usr/bin/install -m 0755 -o root -g root \
  "$OMARCHY_PATH/default/systemd/system-sleep/rebind-brcmfmac" \
  "$hook"

# No reboot needed: systemd-sleep picks up every executable in system-sleep
# the next time the machine suspends.
