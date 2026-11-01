echo "Leave the ASUS ProArt P16 the ProArt P14's room for docks behind its USB4 ports"

# See install/hardware/n1x.sh: the P16 has the P14's three USB4 host routers and
# tunnel root ports and now takes the P14's bus numbers and windows. Until now it
# got the other N1x laptops' bus numbers, from n1x.sh or 1790984600.
dropin=/etc/limine-entry-tool.d/00-omarchy-n1x-usb4.conf
rebuild_marker=/var/lib/omarchy/migrations/1793143637

# Every drop-in Omarchy has written on a P16, from before and after
# linux-omarchy 7.3-3 kept the USB4 resources powered by itself.
omarchy_dropins=(
  '# N1x: keep USB4 powered for the Thunderbolt connection manager, and leave bus
# numbers for docks. See install/hardware/n1x.sh.
KERNEL_CMDLINE[default]+=" power_wrap_drv.usb4_release=0 pci=hpbussize=0x20"'
  '# N1x: leave bus numbers for docks behind the USB4 tunnel root ports; see
# install/hardware/n1x.sh.
KERNEL_CMDLINE[default]+=" pci=hpbussize=0x20"'
)
proart_dropin='# N1x: leave room for docks behind the USB4 tunnel root ports; see
# install/hardware/n1x.sh.
KERNEL_CMDLINE[default]+=" pci=hpbussize=0x80,hpmmiosize=32M,hpmmioprefsize=32G"'

if omarchy-hw-aarch64-n1x && omarchy-hw-match "H7607BA"; then
  current=""
  [[ ! -f $dropin ]] || current=$(<"$dropin")

  ours=false
  [[ -e $dropin ]] || ours=true
  for written in "${omarchy_dropins[@]}"; do
    [[ $current != "$written" ]] || ours=true
  done

  if [[ $ours == true ]]; then
    printf '%s\n' "$proart_dropin" | sudo install -Dm644 /dev/stdin "$dropin"
    current=$proart_dropin
  fi

  # Anything else is the administrator's: leave it, and the boot image, alone.
  # The bus numbers and windows are kernel parameters, so rebuild once. The
  # marker keeps another user's run from repeating it, while a missing marker
  # still retries an interrupted rebuild.
  if [[ $current != "$proart_dropin" ]]; then
    echo "Leaving your own $dropin in place; install/hardware/n1x.sh has the ProArt P16's USB4 settings"
  elif [[ ! -e $rebuild_marker ]]; then
    rebuild_log=$(mktemp)
    trap 'rm -f "$rebuild_log"' EXIT
    sudo limine-mkinitcpio 2>&1 | tee "$rebuild_log"

    # limine-mkinitcpio reports a kernel it could not rebuild and still exits 0.
    # That kernel still boots with the old bus numbers, so stay pending.
    if grep -q 'mkinitcpio failed for kernel' "$rebuild_log"; then
      echo "A boot image was not rebuilt. Fix the error above, then run omarchy-migrate again before rebooting." >&2
      exit 1
    fi

    sudo install -Dm644 /dev/null "$rebuild_marker"
  fi
fi
