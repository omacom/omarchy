echo "Mark the T2 Mac t2bce_vhci initramfs module optional so other kernels build"

# Only linux-t2 ships t2bce, so a bare t2bce_vhci in MODULES fails the initramfs
# build for linux-omarchy installed next to it and leaves that kernel's UKI stale.

conf=/etc/mkinitcpio.conf.d/apple-t2.conf

if [[ -f $conf ]] && grep -q 't2bce_vhci ' "$conf"; then
  sudo sed -i 's/t2bce_vhci /t2bce_vhci? /' "$conf"
  sudo limine-update
fi
