# nvidia-vaapi-driver supports Firefox only. On NVIDIA GPUs with GSP firmware
# Omarchy points LIBVA_DRIVER_NAME at it for the whole session
# (default/hypr/nvidia.lua), so Chromium-family browsers try to decode video
# through a driver that does not support them: the decoded frames fail dmabuf
# import (eglCreateImage, EGL_BAD_MATCH) and video renders black while the audio
# track plays on. NVIDIA has no other hardware decode path in Chromium on Linux,
# so software decode gives up nothing that was working.

CHROMIUM_SOFTWARE_VIDEO_DECODE_FLAG="--disable-accelerated-video-decode"

CHROMIUM_FLAGS_FILES=(
  "$HOME/.config/chromium-flags.conf"
  "$HOME/.config/chrome-flags.conf"
  "$HOME/.config/microsoft-edge-stable-flags.conf"
  "$HOME/.config/brave-flags.conf"
  "$HOME/.config/brave-origin-flags.conf"
)

chromium_needs_software_video_decode() {
  omarchy-hw-nvidia-gsp
}

# Appends the flag to the flags files given, or to every Chromium-family flags
# file Omarchy seeds. Idempotent, and silent on machines that decode fine.
chromium_force_software_video_decode() {
  local conf
  local -a confs=("$@")

  (( ${#confs[@]} )) || confs=("${CHROMIUM_FLAGS_FILES[@]}")

  chromium_needs_software_video_decode || return 0

  for conf in "${confs[@]}"; do
    [[ -f $conf ]] || continue
    grep -qxF -- "$CHROMIUM_SOFTWARE_VIDEO_DECODE_FLAG" "$conf" && continue
    echo "$CHROMIUM_SOFTWARE_VIDEO_DECODE_FLAG" >>"$conf"
  done
}
