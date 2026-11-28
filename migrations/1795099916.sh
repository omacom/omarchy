echo "Put the camera and video settings back into the browser flags of Snapdragon laptops"

# A browser installed or refreshed since those were set up got a fresh flags
# file without them. Chrome and Chromium then list no camera and decode video
# on the CPU.
if omarchy-hw-aarch64-qualcomm; then
  omarchy-install-camera
  omarchy-install-video-decode
fi
