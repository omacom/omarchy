# Original 2023 ASUS ROG Ally (RC71L). The Ally X (RC72LA) is a different
# machine and is not handled here.
#
# asusctl stays uninstalled. It is the laptop ROG daemon: versions 6.0.0
# through 6.0.11 unsynced this handheld's RGB zones by sending a laptop LED
# command at boot, and Handheld Daemon conflicts with asusctl (and with
# rog-control-center / supergfxctl) because both claim the ASUS WMI device.
# The Ally has one AMD GPU, so the laptop hybrid-GPU tools do not apply.
# install/hardware/asus-rog.sh is what skips the package, and only when
# omarchy-hw-rog-ally matches. A product_family that contains "ROG" would
# otherwise take the laptop path; that family string is not assumed here.
#
# Nothing else is installed. As of late 2026 the handheld userspace is split,
# and the two stacks conflict with each other. Handheld Daemon still supports
# the RC71L (controller emulation, gyro, back buttons, TDP, fans, RGB) but
# upstream discourages the AUR package, and this leaf can run offline on an
# image's first boot before any user exists, so it cannot enable hhd@<user>.
# Bazzite Deck 44 and CachyOS Handheld moved the Ally to InputPlumber and
# OpenGamepadUI instead. Gamescope gaming mode is DeckShift, not this repo.
# manual/49-omarchy-on.md is the note for the person using the machine.

if omarchy-hw-rog-ally; then
  echo "ROG Ally (2023, RC71L): not installing asusctl. Handheld controls and gaming mode are in the Omarchy manual under Omarchy on, ROG Ally."
fi
