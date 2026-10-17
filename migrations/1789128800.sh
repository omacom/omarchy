echo "Force software cursors on nouveau when install-time detection missed them"

# The install-time check needed nouveau bound and looknfeel.lua present, so some
# unsupported NVIDIA GPUs kept an invisible pointer.
source "$OMARCHY_PATH/install/user/hardware/fix-nouveau-cursor.sh"
