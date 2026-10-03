# nvidia-vaapi-driver targets Firefox; Chromium needs an explicit opt-in to use
# it. On NVIDIA GPUs with GSP firmware that drive the display, Omarchy points
# LIBVA_DRIVER_NAME at it for the whole session (default/hypr/nvidia.lua), so
# Chromium-family browsers can end up decoding through it anyway: the decoded
# frames fail dmabuf import (eglCreateImage, EGL_BAD_MATCH) and video renders
# black while the audio track plays on. Software decode gives up nothing that
# was working there. Machines where an iGPU drives the display keep
# LIBVA_DRIVER_NAME unset and their iGPU hardware decode, so they are left alone.

CHROMIUM_SOFTWARE_VIDEO_DECODE_FLAG="--disable-accelerated-video-decode"

CHROMIUM_FLAGS_FILES=(
  "$HOME/.config/chromium-flags.conf"
  "$HOME/.config/chrome-flags.conf"
  "$HOME/.config/microsoft-edge-stable-flags.conf"
  "$HOME/.config/brave-flags.conf"
  "$HOME/.config/brave-origin-flags.conf"
)

# Must match the condition default/hypr/nvidia.lua exports LIBVA_DRIVER_NAME on.
chromium_needs_software_video_decode() {
  omarchy-hw-nvidia-gsp && omarchy-hw-nvidia-display
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
    [[ -n $(tail -c1 "$conf") ]] && echo >>"$conf"
    echo "$CHROMIUM_SOFTWARE_VIDEO_DECODE_FLAG" >>"$conf"
  done
}
