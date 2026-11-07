echo "Install the pre-T2 FaceTime HD camera driver and firmware"

# Pre-T2 Macs' built-in camera (Broadcom 1570) has no in-tree driver, so it
# sits driverless with no /dev/video. See
# install/hardware/apple/fix-facetimehd.sh.
source "$OMARCHY_PATH/install/hardware/apple/fix-facetimehd.sh"
