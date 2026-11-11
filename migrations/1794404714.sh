echo "Default the ASUS Zenbook 14 UX3480QA's kernel to suspend to idle"

# See install/hardware/asus/fix-asus-zenbook-14-ux3480qa-boot.sh. Installs made
# before it set mem_sleep_default sleep in suspend to idle only through systemd,
# so anything else that suspends lands in deep sleep, which can reset the
# laptop. Rerunning the leaf rewrites its other files with the content they
# already have; the boot entries are rebuilt for the new kernel parameter.
rebuild_marker=/var/lib/omarchy/migrations/1794404714

if ! omarchy-hw-aarch64-qualcomm || ! omarchy-hw-match "UX3480QA"; then
  exit 0
fi

sudo env PATH="$PATH" OMARCHY_PATH="$OMARCHY_PATH" bash -euo pipefail -c '
  source "$OMARCHY_PATH/install/hardware/asus/fix-asus-zenbook-14-ux3480qa-boot.sh"
'

# A marker records the machine-wide rebuild: another user's run must not repeat
# it, while a missing marker still retries an interrupted rebuild.
if [[ ! -e $rebuild_marker ]]; then
  rebuild_log=$(mktemp)
  trap 'rm -f "$rebuild_log"' EXIT
  sudo limine-mkinitcpio 2>&1 | tee "$rebuild_log"

  # limine-mkinitcpio reports a kernel it could not rebuild and still exits 0.
  if grep -q 'mkinitcpio failed for kernel' "$rebuild_log"; then
    echo "A boot image was not rebuilt. Fix the error above, then run omarchy-migrate again before rebooting." >&2
    exit 1
  fi

  sudo install -Dm644 /dev/null "$rebuild_marker"
  omarchy-state set reboot-required
fi
