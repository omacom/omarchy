# Speakers, headset and microphones for the HP OmniBook 3 (Snapdragon X
# X1-26-100).
#
# The sound card asks for a board-named topology that linux-firmware doesn't
# carry, so without the package it never registers and there is no speaker or
# microphone. alsa-ucm-conf's ThinkPad T14s profile already matches it.

if omarchy-hw-aarch64-qualcomm && omarchy-hw-match "OmniBook 3 Laptop"; then
  omarchy-pkg-add hp-omnibook-3-audio
fi
