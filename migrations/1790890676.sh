echo "Switch RetroArch to the glcore video driver on GPUs without Vulkan"

retroarch_config="$HOME/.config/retroarch/retroarch.cfg"

# RetroArch exits at startup when its Vulkan driver finds no device, so this
# only rewrites a setting that can't have been working.
if [[ -f $retroarch_config ]] && grep -q '^video_driver = "vulkan"$' "$retroarch_config" && ! omarchy-hw-vulkan; then
  sed -i 's/^video_driver = "vulkan"$/video_driver = "glcore"/' "$retroarch_config"
fi
