source "$OMARCHY_PATH/install/helpers/pacman.sh"
omarchy_pacman_finalize "${OMARCHY_MIRROR:-stable}"

# Wait for CUPS to own the file, the way omarchy-settings does, so pacman does
# not turn the override into a .pacnew during ISO package installation.
if [[ -f $OMARCHY_PATH/etc-overrides/cups-cups-files.conf && -f /etc/cups/cups-files.conf ]]; then
  install -m 0640 -o root -g cups "$OMARCHY_PATH/etc-overrides/cups-cups-files.conf" /etc/cups/cups-files.conf
  rm -f /etc/cups/cups-files.conf.pacnew
fi

source "$OMARCHY_INSTALL/hardware/pacman.sh"
