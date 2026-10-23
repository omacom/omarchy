# Hardware-specific pacman repository extensions that must survive the final
# pacman.conf restore.
source "$OMARCHY_PATH/install/helpers/pci-sysfs.sh"

if omarchy-pci-id 0x106b 0x1801 0x1802; then
  if ! grep -q '^\[arch-mact2\]' /etc/pacman.conf; then
    cat >> /etc/pacman.conf <<'EOF'

[arch-mact2]
Server = https://github.com/NoaHimesaka1873/arch-mact2-mirror/releases/download/release
SigLevel = Never
EOF
  fi
fi
