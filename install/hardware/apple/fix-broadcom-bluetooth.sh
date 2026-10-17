# Apple Broadcom Bluetooth (USB 05ac:8294) stays powered across a warm reboot.
# Omarchy updates reboot that way, btusb's first HCI commands time out, and
# BlueZ reports no adapter until the chip is power-cycled. The kernel should
# retry the reset; this installs that recovery for the machines that have the
# chip. See bin/omarchy-hw-apple-bluetooth-reset.

omarchy-hw-apple-bluetooth-setup
