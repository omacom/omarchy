# Install Vulkan drivers matching detected GPU hardware
# (NVIDIA Vulkan is handled by nvidia.sh via nvidia-utils)
#
# Walk sysfs the way omarchy-hw-nvidia does. lspci reads PCI config space and
# resumes runtime-suspended GPUs; three greps used to do that once per vendor.

pci_devices_path="${OMARCHY_PCI_DEVICES_PATH:-/sys/bus/pci/devices}"

PACKAGES=()

add_vulkan_pkg() {
  local pkg=$1
  local existing
  for existing in "${PACKAGES[@]+"${PACKAGES[@]}"}"; do
    [[ $existing == "$pkg" ]] && return
  done
  PACKAGES+=("$pkg")
}

shopt -s nullglob
for device in "$pci_devices_path"/*; do
  [[ -r $device/vendor && -r $device/class ]] || continue
  [[ $(<"$device/class") == 0x03* ]] || continue
  case $(<"$device/vendor") in
    0x8086) add_vulkan_pkg vulkan-intel ;;
    0x1002) add_vulkan_pkg vulkan-radeon ;;
    0x106b) add_vulkan_pkg vulkan-asahi ;;
  esac
done

if (( ${#PACKAGES[@]} > 0 )); then
  omarchy-pkg-add "${PACKAGES[@]}"
fi
