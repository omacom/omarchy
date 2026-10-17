echo "Switch RetroArch to the glcore video driver on GPUs without Vulkan"

# The RetroArch installer used to write video_driver = "vulkan" unconditionally,
# and RetroArch won't start when no GPU provides a Vulkan device. Only configs
# still on that value are checked; vulkan-tools supplies the device check.
config="$HOME/.config/retroarch/retroarch.cfg"

if [[ -f $config ]] && grep -q '^video_driver = "vulkan"$' "$config"; then
  omarchy-pkg-add vulkan-tools

  # Match what vulkaninfo lists, not how it exits: it can list a working GPU and
  # still fail, and under pipefail a failing or SIGPIPE'd probe reads as no GPU.
  summary=$(vulkaninfo --summary 2>/dev/null || true)
  if ! grep -qE 'deviceType += PHYSICAL_DEVICE_TYPE_(INTEGRATED|DISCRETE|VIRTUAL)_GPU' <<<"$summary"; then
    sed -i 's/^video_driver = "vulkan"$/video_driver = "glcore"/' "$config"
  fi
fi
