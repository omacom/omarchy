echo "Keep the kernel's default free-memory watermark on GB10 machines"

# See install/hardware/gb10/memory-watermark.sh, which sets up new installs the same way.
omarchy-hw-aarch64-gb10 || exit 0

sudo env PATH="$PATH" bash "$OMARCHY_PATH/install/hardware/gb10/memory-watermark.sh"
sudo sysctl -p /etc/sysctl.d/zz-omarchy-gb10-memory.conf >/dev/null || omarchy-state set reboot-required
