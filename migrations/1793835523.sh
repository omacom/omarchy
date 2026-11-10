echo "Install iptsd for the Surface Laptop 7 15\" touchpad"

# See install/hardware/microsoft/surface-laptop-7.sh. iptsd starts from its udev
# rule, so this needs no reboot. A second user finds the package installed and
# has nothing to do.
if omarchy-pkg-missing iptsd; then
  bash -euo pipefail -c 'source "$OMARCHY_PATH/install/hardware/microsoft/surface-laptop-7.sh"'
fi
