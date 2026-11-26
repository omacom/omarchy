# Front camera relay, tuning and picker cleanup for the ASUS Zenbook A16
# UX3607OA (Snapdragon X2 Elite).
#
# The OV02C10 RGB camera runs through libcamera's simple pipeline and software
# ISP, so apps that read V4L2 cameras only (Monologue, Qt Multimedia) need the
# v4l2-relayd loopback relay that asus-zenbook-a16-support sets up, along with
# sensor black-level tuning and WirePlumber rules to hide raw CAMSS and IR nodes.

if omarchy-hw-aarch64-qualcomm && omarchy-hw-match "UX3607OA"; then
  OMARCHY_PKG_DEFER=1 omarchy-pkg-add asus-zenbook-a16-support
fi
