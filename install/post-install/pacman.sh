# Replace the installer's offline pacman configuration with online repositories.
pacman_config=${OMARCHY_PACMAN_CONFIG:-/etc/pacman.conf}
mirrorlist=${OMARCHY_MIRRORLIST:-/etc/pacman.d/mirrorlist}
source "$OMARCHY_PATH/install/helpers/pacman.sh"

if [[ $(uname -m) == "aarch64" ]]; then
  # Install the keyring before replacing the offline package source.
  omarchy-pkg-add archlinuxarm-keyring
fi

pacman_write_repository_config "${OMARCHY_MIRROR:-stable}" "$pacman_config" "$mirrorlist" || return 1

if [[ $(uname -m) == "aarch64" ]]; then
  # Clamp unbacked ARM RTC forward so pacman-key accepts keyrings offline
  (( $(date +%Y) < 2025 )) && date -s "@$(stat -c %Y /etc/os-release 2>/dev/null || echo 1767225600)" >/dev/null 2>&1 || true

  pacman-key --init
  pacman-key --populate
fi

# Wait for CUPS to own the file, the way omarchy-settings does, so pacman does
# not turn the override into a .pacnew during ISO package installation.
if [[ -f $OMARCHY_PATH/etc-overrides/cups-cups-files.conf && -f /etc/cups/cups-files.conf ]]; then
  install -m 0640 -o root -g cups "$OMARCHY_PATH/etc-overrides/cups-cups-files.conf" /etc/cups/cups-files.conf
  rm -f /etc/cups/cups-files.conf.pacnew
fi

source "$OMARCHY_INSTALL/hardware/pacman.sh"
