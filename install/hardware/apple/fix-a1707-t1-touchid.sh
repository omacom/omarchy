# Touch ID on the 2016 15-inch MacBook Pro (A1707, MacBookPro13,3, Apple T1).
# T1Bridge hybrid: userspace + matched libfprint-t1bridge/fprintd-t1bridge pair
# + only the apple_t1_ncm module. Never install t1bridge-dkms: its appletbdrm
# and t1_cfgsel collide with the Touch Bar stack above.

source "${OMARCHY_INSTALL:-$OMARCHY_PATH/install}/hardware/apple/a1707-t1-lib.sh"
a1707_t1_applicable || return 0

echo "Detected 2016 15-inch MacBook Pro (A1707, T1); installing Touch ID (T1Bridge hybrid)"

if omarchy-pkg-present t1bridge-dkms; then
  echo "t1bridge-dkms is installed; it collides with the A1707 Touch Bar stack. Not installing Touch ID." >&2
  return 0
fi

omarchy-pkg-add dkms
a1707_t1_ensure_standardagents_repo
pacman -Sy --needed --noconfirm -- t1bridge libfprint-t1bridge fprintd-t1bridge

if omarchy-pkg-present t1bridge-dkms; then
  echo "t1bridge-dkms was pulled in; removing it so the Touch Bar stack keeps appletbdrm-t1" >&2
  omarchy-pkg-drop t1bridge-dkms
fi

# T1Bridge's Touch Bar half must not claim the iBridge; mbp-t1-touchbar owns it.
systemctl mask t1-touchbar-hw.service t1-touchbar-hw.socket 2>/dev/null || true
: >/etc/udev/rules.d/99-zz-t1bridge-touchbar.rules
udevadm control --reload-rules 2>/dev/null || true

ncm_ver=0.1.12
ncm_src=/usr/src/apple-t1-ncm-$ncm_ver
if ! dkms status -m apple-t1-ncm -v "$ncm_ver" 2>/dev/null | grep -q installed; then
  rm -rf "$ncm_src"
  cp -a "$A1707_T1_SRC/apple-t1-ncm-0.1.12" "$ncm_src"
  dkms add -m apple-t1-ncm -v "$ncm_ver"
  dkms build -m apple-t1-ncm -v "$ncm_ver"
  dkms install -m apple-t1-ncm -v "$ncm_ver"
fi

systemd-sysusers /usr/lib/sysusers.d/t1bridge.conf 2>/dev/null || true
systemd-tmpfiles --create /usr/lib/tmpfiles.d/t1bridge.conf 2>/dev/null || true

if [[ -n ${OMARCHY_INSTALL_USER:-} && $OMARCHY_INSTALL_USER != "root" ]]; then
  usermod -aG t1bridge "$OMARCHY_INSTALL_USER"
fi

systemctl daemon-reload
systemctl enable t1-touchid-auth.socket t1bridge-fingerprint.socket

install -Dm755 "$A1707_T1_SRC/xart-firewall" /usr/lib/udev/a1707-t1-xart-firewall
install -Dm644 "$A1707_T1_SRC/xart-firewall.rules" /etc/udev/rules.d/90-a1707-t1-xart.rules

# Import this Mac's FDRData when the Apple EFI partition is still present.
# Missing data is a warning, not a failed install: speakers and the Touch Bar
# still work, and Touch ID can be imported later from a backup.
a1707_t1_import_fdr() {
  local dev mnt
  command -v t1bridge >/dev/null || return 0

  while read -r dev; do
    [[ -n $dev && -b $dev ]] || continue
    mnt=$(mktemp -d /run/a1707-apple-esp.XXXXXX)
    if mount -o ro "$dev" "$mnt" 2>/dev/null; then
      if [[ -s $mnt/EFI/APPLE/EMBEDDEDOS/FDRData ]]; then
        t1bridge machine-data import --from "$mnt" ||
          systemctl start t1bridge-import.service ||
          echo "Touch ID machine-data import failed; enroll after importing EFI/APPLE/EMBEDDEDOS/FDRData"
        umount "$mnt"
        rmdir "$mnt"
        return 0
      fi
      umount "$mnt"
    fi
    rmdir "$mnt" 2>/dev/null || true
  done < <(lsblk -rno PATH,FSTYPE 2>/dev/null | awk '$2 == "vfat" { print $1 }')

  echo "No Apple EFI partition with EFI/APPLE/EMBEDDEDOS/FDRData found; Touch ID enrollment needs that file."
}

a1707_t1_import_fdr || true
