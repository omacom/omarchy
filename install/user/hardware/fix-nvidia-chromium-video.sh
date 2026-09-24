# Chromium-family browsers render video black on NVIDIA GPUs with GSP firmware,
# because the VA-API driver Omarchy points them at only supports Firefox. Force
# software decode in the flags files this user already has.
source "$OMARCHY_INSTALL/helpers/chromium-video-decode.sh"

if chromium_needs_software_video_decode; then
  echo "Detected NVIDIA GPU with GSP firmware. Forcing software video decode in Chromium-family browsers."
  chromium_force_software_video_decode
fi
