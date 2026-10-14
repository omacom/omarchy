# Run the Synaptics touchpad in the ThinkPad T14 Gen 2a / P14s Gen 2 AMD over
# RMI4/SMBus (InterTouch) instead of the PS/2 fallback the stock kernel leaves
# it on. RMI4 multitouch reports two fingers at the one-finger rate (14.9 ms
# rather than about 25 ms), so scrolls glide and fast flicks no longer whiff
# into pointer motion.
#
# The stock kernel cannot use the SMBus path on this machine because the AMD
# FCH SMBus driver offers no SMBus Host Notify. The DKMS package rebuilds
# i2c-piix4, rmi_smbus and psmouse from pristine kernel sources plus four
# patches meant for upstream but not yet posted, and goes away once a shipped
# kernel contains them: https://github.com/orospakr/thinkpad-t14-amd-touchpad

if omarchy-hw-thinkpad-t14-gen2-amd; then
  omarchy-pkg-add thinkpad-t14-amd-touchpad-dkms
fi
