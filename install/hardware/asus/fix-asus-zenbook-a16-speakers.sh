# Speakers and microphones for the ASUS Zenbook A16 UX3607OA (Snapdragon X2
# Elite).
#
# The sound card asks for a board-named topology and UCM profile that
# linux-firmware and alsa-ucm-conf don't carry, so without the package it never
# registers and there is no speaker or microphone. The package also keeps the
# speakers attached across idle and gives them a working volume range. It runs
# before speaker-tuning.sh, whose tuning for this laptop needs the speaker sink.

if omarchy-hw-aarch64-qualcomm && omarchy-hw-match "UX3607OA"; then
  omarchy-pkg-add asus-zenbook-a16-audio
fi
