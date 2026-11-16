# Hardware-specific pacman repository extensions that must survive the final
# pacman.conf restore.
if lspci -nn | grep "106b:180[12]" >/dev/null; then
  if ! grep -q '^\[arch-mact2\]' /etc/pacman.conf; then
    cat >> /etc/pacman.conf <<'EOF'

[arch-mact2]
Server = https://github.com/NoaHimesaka1873/arch-mact2-mirror/releases/download/release
SigLevel = Never
EOF
  fi
fi

# 2016 15-inch MacBook Pro (A1707, MacBookPro13,3): T1Bridge userspace repo.
# DMI-only so the repo remains if the T1 is in recovery.
if omarchy-hw-match "MacBookPro13,3"; then
  source "${OMARCHY_INSTALL:-$OMARCHY_PATH/install}/hardware/apple/a1707-t1-lib.sh"
  a1707_t1_ensure_standardagents_repo
fi
