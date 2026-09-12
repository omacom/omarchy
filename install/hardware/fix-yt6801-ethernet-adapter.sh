# Install drivers for Motorcomm YT6801 ethernet adapter used by the Slimbook Executive
source "$OMARCHY_PATH/install/helpers/pci-sysfs.sh"

if omarchy-pci-id 0x1f0a 0x6801; then
  omarchy-pkg-add linux-headers yt6801-dkms
fi
