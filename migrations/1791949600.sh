echo "Recover Apple Broadcom Bluetooth after a warm reboot"

# The install-time quirk only reaches machines set up after it shipped, so an
# existing iMac17,1 still comes back from every update with no adapter. Setup
# no-ops without the chip, and on Apple Silicon. See
# install/hardware/apple/fix-broadcom-bluetooth.sh.

omarchy-hw-apple-bluetooth-setup
