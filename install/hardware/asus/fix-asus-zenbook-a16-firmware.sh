# DSP firmware and Wi-Fi board data for the ASUS Zenbook A16 UX3607OA
# (Snapdragon X2 Elite).
#
# The audio DSP, which also reports the battery and charger, only runs an image
# signed for this board, and linux-firmware has no Wi-Fi board data for it. The
# package installs both. It runs before qualcomm/firmware.sh, which keeps the DSP
# driver off unless that image is already there.

if omarchy-hw-aarch64-qualcomm && omarchy-hw-match "UX3607OA"; then
  omarchy-pkg-add asus-zenbook-a16-firmware
fi
