echo "Give the ASUS ProArt P16 the ProArt P14's USB4 settings so a dock's PCIe devices appear"

# See install/hardware/n1x.sh: the P16 has the P14's three USB4 host routers and
# three 10de:22cf tunnel root ports. Until now it got the other N1x laptops'
# bus numbers (from n1x.sh or 1790984600) and no root-port rule.
dropin=/etc/limine-entry-tool.d/00-omarchy-n1x-usb4.conf
rules=/etc/udev/rules.d/71-omarchy-n1x-usb4-root-ports.rules
rebuild_marker=/var/lib/omarchy/migrations/1792977280

# The whole drop-in n1x.sh and 1790984600 wrote on a P16 until now, and the one
# n1x.sh writes for it from now on.
generic_dropin='# N1x: keep USB4 powered for the Thunderbolt connection manager, and leave bus
# numbers for docks. See install/hardware/n1x.sh.
KERNEL_CMDLINE[default]+=" power_wrap_drv.usb4_release=0 pci=hpbussize=0x20"'
proart_dropin='# N1x: keep the USB4 host routers powered and leave room for docks behind them;
# see install/hardware/n1x.sh.
KERNEL_CMDLINE[default]+=" power_wrap_drv.usb4_release=0 pci=hpbussize=0x80,hpmmiosize=32M,hpmmioprefsize=32G"'

if ! omarchy-hw-aarch64-n1x || ! omarchy-hw-match "H7607BA"; then
  exit 0
fi

if [[ ! -f $rules ]]; then
  sudo install -Dm644 /dev/stdin "$rules" <<'EOF'
# N1x: the USB4 tunnel root ports cannot wake for a hotplug, so keep them out of
# runtime suspend; see install/hardware/n1x.sh.
ACTION=="add|bind", SUBSYSTEM=="pci", ATTR{vendor}=="0x10de", ATTR{device}=="0x22cf", ATTR{power/control}="on"
EOF
fi

# udev only applies the rule to new events, so replay one for any port that is
# still allowed to suspend. Once they are all on, another user's run is a no-op.
for port in /sys/bus/pci/devices/*; do
  [[ $(cat "$port/vendor" 2>/dev/null) == "0x10de" && $(cat "$port/device" 2>/dev/null) == "0x22cf" ]] || continue
  [[ $(cat "$port/power/control" 2>/dev/null) != "on" ]] || continue
  sudo udevadm control --reload
  sudo udevadm trigger --action=add --subsystem-match=pci --attr-match=vendor=0x10de --attr-match=device=0x22cf
  break
done

# Replace the drop-in only while it is exactly the one Omarchy wrote, or when
# there is none. Anything else is the administrator's: leave it, and the boot
# image, alone.
current=""
[[ ! -f $dropin ]] || current=$(<"$dropin")
if [[ ! -f $dropin || $current == "$generic_dropin" ]]; then
  printf '%s\n' "$proart_dropin" | sudo install -Dm644 /dev/stdin "$dropin"
elif [[ $current != "$proart_dropin" ]]; then
  echo "Leaving your own $dropin in place; install/hardware/n1x.sh has the ProArt P16's USB4 settings"
  exit 0
fi

# The bus numbers and windows are kernel parameters, so rebuild once. A marker
# records it: another user's run must not repeat it, while a missing marker
# still retries an interrupted rebuild.
[[ ! -e $rebuild_marker ]] || exit 0

rebuild_log=$(mktemp)
trap 'rm -f "$rebuild_log"' EXIT
sudo limine-mkinitcpio 2>&1 | tee "$rebuild_log"

# limine-mkinitcpio reports a kernel it could not rebuild and still exits 0.
# That kernel still boots with the old settings, so the migration stays pending.
if grep -q 'mkinitcpio failed for kernel' "$rebuild_log"; then
  echo "A boot image was not rebuilt. Fix the error above, then run omarchy-migrate again before rebooting." >&2
  exit 1
fi

sudo install -Dm644 /dev/null "$rebuild_marker"
