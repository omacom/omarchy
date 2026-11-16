echo "Install Gliff on aarch64, now that Omarchy's repositories build it there"

if omarchy-hw-aarch64; then
  omarchy-pkg-add gliff
fi
