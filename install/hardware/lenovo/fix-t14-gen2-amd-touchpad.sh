# Run the Synaptics touchpad in the ThinkPad T14 Gen 2a / P14s Gen 2 AMD over
# RMI4/SMBus (InterTouch) instead of the PS/2 fallback the stock kernel leaves
# it on: 80 Hz single-finger, about 40 Hz two-finger, flicks that whiff.
#
# The stock kernel cannot use the SMBus path on this machine because the AMD
# FCH SMBus driver offers no SMBus Host Notify. The DKMS package rebuilds
# i2c-piix4, rmi_smbus and psmouse from pristine kernel sources plus four
# patches that are on their way upstream, and goes away once the shipped
# kernel contains them: https://github.com/orospakr/thinkpad-t14-amd-touchpad

if omarchy-hw-thinkpad-t14-gen2-amd; then
  omarchy-pkg-add thinkpad-t14-amd-touchpad-dkms
fi
