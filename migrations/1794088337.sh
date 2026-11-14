echo "Turn off suspend on the ASUS Zenbook A16 (UX3607OA) until it sleeps reliably"

# See install/hardware/asus/fix-asus-zenbook-a16-boot.sh. Rerunning the leaf
# rewrites its initramfs and command line files with the same content they
# already have, so no boot image rebuild is needed.
if ! omarchy-hw-aarch64-qualcomm || ! omarchy-hw-match "UX3607OA"; then
  exit 0
fi

# Another user on this machine may already have applied it.
if [[ -f /etc/systemd/sleep.conf.d/omarchy-sleep-disabled.conf && ! -e /etc/systemd/sleep.conf.d/zenbook-a16.conf ]]; then
  exit 0
fi

sudo env PATH="$PATH" OMARCHY_PATH="$OMARCHY_PATH" bash -euo pipefail -c '
  source "$OMARCHY_PATH/install/hardware/asus/fix-asus-zenbook-a16-boot.sh"
'
