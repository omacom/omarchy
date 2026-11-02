echo "Install the FaceTime HD camera driver on Intel Macs that have one"

# Fresh installs get this from install/hardware/apple/fix-facetimehd.sh. Existing
# Macs only pick it up on omarchy update via this migration.
if omarchy-hw-facetimehd; then
  source "$OMARCHY_PATH/install/hardware/apple/fix-facetimehd.sh"
fi
