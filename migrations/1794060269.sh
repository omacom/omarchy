echo "Quiet the efivarfs mount error Snapdragon laptops print at boot"

# See install/hardware/qualcomm/initramfs.sh. The boot image picks the hook up
# the next time it is rebuilt, which every kernel update does; the message is
# harmless until then, so this does not rebuild it now.
if ! omarchy-hw-aarch64-qualcomm; then
  exit 0
fi

# Another user's run already wrote it.
if [[ -f /etc/initcpio/install/omarchy-quiet-efivars ]] &&
  grep -Fqx "HOOKS+=(omarchy-quiet-efivars)" /etc/mkinitcpio.conf.d/qualcomm-platform.conf 2>/dev/null; then
  exit 0
fi

sudo env PATH="$PATH" OMARCHY_PATH="$OMARCHY_PATH" bash -euo pipefail -c '
  source "$OMARCHY_PATH/install/hardware/qualcomm/initramfs.sh"
'
