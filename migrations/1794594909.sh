echo "Copy the USB4 router firmware for the Surface Laptop 8's second USB-C port"

# linux-omarchy now runs USB4 on the laptop's second USB-C port. That port's
# router takes a firmware image of its own, which
# microsoft-surface-laptop-8-support copies out of the Windows USB4 driver from
# 1-7; installs set up before that have only the first port's image. The router
# driver reads its image from the boot image, so that is rebuilt.
rebuild_marker=/var/lib/omarchy/migrations/1794594909
firmware=/usr/lib/firmware/updates/qcom/glymur/surface-laptop8

if ! omarchy-hw-aarch64-qualcomm ||
  ! omarchy-hw-match-device-tree microsoft,surface-laptop-8-13p8 microsoft,surface-laptop-8-15; then
  exit 0
fi

# A marker records the machine-wide work: another user's run must not repeat
# it, while a missing marker still retries an interrupted rebuild.
[[ ! -e $rebuild_marker ]] || exit 0

# An older package's tool copies only the first port's image.
if ! grep -qs usb4-router-v2.bin /usr/bin/surface-laptop8-usb4-firmware; then
  echo "microsoft-surface-laptop-8-support 1-7 or newer is needed. Update the system, then run omarchy-migrate again." >&2
  exit 1
fi

# The tool says which port stays without USB4 when Windows or its USB4 driver
# is gone or cannot be read. That is no reason to stop the other migrations.
if ! sudo surface-laptop8-usb4-firmware --no-rebuild; then
  echo "To copy the missing firmware later: sudo surface-laptop8-usb4-firmware" >&2
fi

# Either image can be new here, and a rebuild that failed last time left no
# marker, so the boot image is rebuilt whenever there is an image to put in it.
if [[ -e $firmware/usb4-router-legacy.bin || -e $firmware/usb4-router-v2.bin ]]; then
  rebuild_log=$(mktemp)
  trap 'rm -f "$rebuild_log"' EXIT
  sudo limine-mkinitcpio 2>&1 | tee "$rebuild_log"

  # limine-mkinitcpio reports a kernel it could not rebuild and still exits 0.
  # That image lacks the firmware, so the migration stays pending.
  if grep -q 'mkinitcpio failed for kernel' "$rebuild_log"; then
    echo "A boot image was not rebuilt. Fix the error above, then run omarchy-migrate again before rebooting." >&2
    exit 1
  fi

  omarchy-state set reboot-required
fi

sudo install -Dm644 /dev/null "$rebuild_marker"
