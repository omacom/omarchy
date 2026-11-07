echo "Remove the Apple Silicon Vulkan driver from Intel Macs whose T2 chip was taken for a GPU"

# Vulkan detection matched "Non-VGA unclassified device: Apple Inc." (the T2 chip)
# as an Apple GPU. vulkan-asahi only drives Apple Silicon GPUs, so it never works on x86_64.
[[ $(uname -m) == "x86_64" ]] || exit 0
omarchy-pkg-present vulkan-asahi || exit 0

# Keep it if removing it would break a package that relies on it as its only Vulkan driver.
if pacman -Rs --print vulkan-asahi >/dev/null 2>&1; then
  omarchy-pkg-drop vulkan-asahi
fi
