echo "Keep the MacBookPro14,1 Alpine Ridge USB-C controller awake so a plug is enumerated"

# See install/hardware/apple/fix-alpine-ridge-usb.sh, which sets up new installs
# the same way. An existing rule or hook is left alone: it may be an
# administrator's copy.
#
# The reload marker is written in the same step as the rule. A later failure
# leaves the marker behind, so the next run reloads instead of treating the
# file on disk as a rule udev has already loaded.

if ! omarchy-hw-match "MacBookPro14,1"; then
  exit 0
fi

rules="${OMARCHY_ALPINE_RIDGE_USB_RULES:-/etc/udev/rules.d/71-omarchy-macbook-alpine-ridge-usb.rules}"
hook="${OMARCHY_ALPINE_RIDGE_USB_HOOK:-/usr/lib/systemd/system-sleep/macbook-alpine-ridge-usb}"
reload_marker="${OMARCHY_ALPINE_RIDGE_USB_RELOAD_MARKER:-/var/lib/omarchy/migrations/1792055925-udev-reload-needed}"
udev_control="${OMARCHY_UDEV_CONTROL:-/run/udev/control}"
pci_devices="${OMARCHY_PCI_DEVICES_PATH:-/sys/bus/pci/devices}"
usb_devices="${OMARCHY_USB_DEVICES_PATH:-/sys/bus/usb/devices}"
rule_src="$OMARCHY_PATH/default/udev/macbook-alpine-ridge-usb.rules"
hook_src="$OMARCHY_PATH/default/systemd/system-sleep/macbook-alpine-ridge-usb"

if [[ ! -f $rules ]]; then
  sudo install -Dm644 "$rule_src" "$rules"
  sudo install -Dm644 /dev/null "$reload_marker"
fi

installed_hook=0
if [[ ! -f $hook ]]; then
  sudo install -Dm755 "$hook_src" "$hook"
  installed_hook=1
fi

if [[ -e $reload_marker ]]; then
  # No control socket means no running udevd is holding the old rules. The next
  # daemon start reads the directory from disk. A daemon that refuses the reload
  # must keep this migration pending, or the marker would be cleared while the
  # new rule stayed inactive.
  if [[ -e $udev_control ]] && ! sudo udevadm control --reload-rules; then
    echo "Could not reload udev for the Alpine Ridge USB-C rule. Run omarchy-migrate again." >&2
    exit 1
  fi
  sudo rm -f -- "$reload_marker"
fi

# The hook is idempotent. Run it when it is new, or when a controller or one
# of its root hubs is still allowed to suspend. Once everything is awake,
# another user's run does not touch sysfs again.
needs_wake=0
if (( installed_hook )); then
  needs_wake=1
else
  shopt -s nullglob
  for pci in "$pci_devices"/*; do
    [[ -f $pci/vendor && -f $pci/device && -f $pci/power/control ]] || continue
    [[ $(cat "$pci/vendor") == "0x8086" && $(cat "$pci/device") == "0x15d4" ]] || continue
    [[ $(cat "$pci/power/control") != "on" ]] || continue
    needs_wake=1
    break
  done
  if (( ! needs_wake )); then
    for usb in "$usb_devices"/*; do
      [[ -f $usb/idVendor && -f $usb/serial && -f $usb/power/control ]] || continue
      [[ $(cat "$usb/idVendor") == "1d6b" ]] || continue
      pci="$pci_devices/$(cat "$usb/serial")"
      [[ -f $pci/vendor && -f $pci/device ]] || continue
      [[ $(cat "$pci/vendor") == "0x8086" && $(cat "$pci/device") == "0x15d4" ]] || continue
      [[ $(cat "$usb/power/control") != "on" ]] || continue
      needs_wake=1
      break
    done
  fi
fi

if (( needs_wake )); then
  sudo "$hook" post
fi
