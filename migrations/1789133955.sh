echo "Disable USB autosuspend for existing fingerprint lock-screen setups"

# omarchy-setup-security-fingerprint now writes this rule itself, but a
# machine that ran it before this migration existed never got one. Left as-is,
# the reader comes back from USB autosuspend in a state libfprint can't
# re-claim, so lock-screen fingerprint auth quietly stops working after the
# first suspend/resume until the device is replugged or fprintd restarted.
rule="${OMARCHY_FINGERPRINT_UDEV_RULE_PATH:-/etc/udev/rules.d/90-omarchy-fingerprint-no-autosuspend.rules}"
lock_pam="${OMARCHY_LOCK_FINGERPRINT_PAM_PATH:-/etc/pam.d/omarchy-lock-fingerprint}"

# Only machines that already opted into lock-screen fingerprint auth need the
# backfill; a fresh setup run writes the rule itself, and a rule already on
# disk (from either) means there is nothing left to do.
if [[ -f $lock_pam ]] && [[ ! -f $rule ]]; then
  dev=$(omarchy-hw-fingerprint --device-path) || dev=""

  if [[ -n $dev && -r "$dev/idVendor" && -r "$dev/idProduct" ]]; then
    vendor=$(<"$dev/idVendor")
    product=$(<"$dev/idProduct")

    sudo tee "$rule" >/dev/null <<EOF
ACTION=="add", SUBSYSTEM=="usb", ATTR{idVendor}=="$vendor", ATTR{idProduct}=="$product", TEST=="power/control", ATTR{power/control}="on"
EOF

    # Apply to the device already plugged in, so this machine benefits without
    # waiting for a reboot or a replug.
    if [[ -e "$dev/power/control" ]]; then
      echo on | sudo tee "$dev/power/control" >/dev/null
    fi
  fi
fi
