echo "Force software cursors on nouveau when install-time detection missed them"

# Older fix-nouveau-cursor.sh required `lspci -k` ("Kernel driver in use: nouveau")
# and an existing ~/.config/hypr/looknfeel.lua. Install/chroot often cannot load
# libkmod, so first boot kept an invisible pointer on outdated NVIDIA GPUs.
source "$OMARCHY_PATH/install/user/hardware/fix-nouveau-cursor.sh"
