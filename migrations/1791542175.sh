echo "Install Gliff, the Hyprland remote desktop over SSH"

# Gliff has no aarch64 build (install/omarchy-x86_64-only.packages).
if omarchy-hw-x86; then
  omarchy-pkg-add gliff
fi
