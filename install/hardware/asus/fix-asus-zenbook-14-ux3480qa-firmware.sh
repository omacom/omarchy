# DSP, GPU and video firmware for the ASUS Zenbook 14 UX3480QA (Snapdragon X
# X1-26-100).
#
# The audio DSP, which also reports the battery and charger, the compute DSP,
# the GPU zap shader and the video firmware only run images ASUS signed for
# this model. The package installs them. It runs before qualcomm/firmware.sh,
# which keeps the DSP driver off unless that image is already there.

if omarchy-hw-aarch64-qualcomm && omarchy-hw-match "UX3480QA"; then
  omarchy-pkg-add asus-zenbook-14-ux3480qa-firmware
fi
