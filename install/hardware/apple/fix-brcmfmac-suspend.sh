# Apple Macs with Broadcom Wi-Fi driven by brcmfmac lose Wi-Fi after a long
# suspend: the firmware stops answering commands on wake and the interface
# never recovers without a reboot. A system-sleep hook that rebinds the device
# across sleep reloads the firmware cleanly.
#
# Use the BCM4350/BCM43602 boundary from omacom/omarchy#7333. The supplicant
# workaround's wider chip list does not establish a shared sleep lifecycle:
# T2 radios have separate recovery/ordering proposals (#11536 and #5140).
sys_vendor="$(cat /sys/class/dmi/id/sys_vendor 2>/dev/null || true)"

if [[ $sys_vendor == Apple* ]] &&
  lspci -nn | grep -E "14e4:(43a3|43ba|43bb|43bc)" >/dev/null; then
  echo "Detected Apple BCM4350/BCM43602 Wi-Fi; rebinding brcmfmac across suspend"

  hook=/usr/lib/systemd/system-sleep/rebind-brcmfmac
  if [[ -f $hook && ! -L $hook ]] && cmp -s "$OMARCHY_PATH/default/systemd/system-sleep/rebind-brcmfmac" "$hook"; then
    return 0
  fi
  # Replace only the previously shipped hook, never administrator changes.
  if [[ -e $hook || -L $hook ]]; then
    if [[ -L $hook || ! -f $hook ]] ||
    [[ ! $(sha256sum "$hook" | cut -d ' ' -f1) =~ ^(0e16be9962c708bfe9fe20829fbd54af4d792388f2baeaa868e16351e12148a1|9b03e6f8480a8f504ba89ed89fcfe10d47a615d6d64517bbb8d4adfb0f6953f9)$ ]]; then
      echo "Preserving customized Broadcom sleep hook: $hook. Reconcile it with $OMARCHY_PATH/default/systemd/system-sleep/rebind-brcmfmac, then retry." >&2
      return 1
    fi
  fi
  sudo install -Dm 0755 -o root -g root \
    "$OMARCHY_PATH/default/systemd/system-sleep/rebind-brcmfmac" \
    "$hook"
fi
