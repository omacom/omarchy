# SDDM is the desktop edition's login manager. A server boots to a getty, and
# the package is not installed to configure.
if omarchy-edition-desktop; then
  run_logged "$OMARCHY_INSTALL/login/sddm.sh"
fi
