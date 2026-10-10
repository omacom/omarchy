echo "Disable Chromium accelerated video decode on NVIDIA GSP GPUs"

# Session-wide LIBVA_DRIVER_NAME=nvidia is correct for Firefox but makes
# Chromium paint black video (issue #13188). The helper is a no-op off GSP.
omarchy-chromium-nvidia-video-flags || true
