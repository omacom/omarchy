echo "Switch RetroArch to the glcore video driver on GPUs without Vulkan"

# The RetroArch installer used to write video_driver = "vulkan" unconditionally,
# and RetroArch won't start when no GPU provides a Vulkan device. Only configs
# still on that value are checked; vulkan-tools supplies the device check.
config="$HOME/.config/retroarch/retroarch.cfg"

if [[ -f $config ]] && grep -q '^video_driver = "vulkan"$' "$config"; then
  omarchy-pkg-add vulkan-tools

  # grep reads the whole summary rather than quitting at the first match (-q):
  # under pipefail, vulkaninfo dying of SIGPIPE would read as no GPU.
  if ! vulkaninfo --summary 2>/dev/null | grep -E 'deviceType += PHYSICAL_DEVICE_TYPE_(INTEGRATED|DISCRETE|VIRTUAL)_GPU' >/dev/null; then
    sed -i 's/^video_driver = "vulkan"$/video_driver = "glcore"/' "$config"
  fi
fi
