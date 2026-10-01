echo "Use CPU dictation on Intel Haswell GPUs"

if omarchy-pkg-present voxtype-bin && omarchy-hw-intel-haswell-gpu; then
  sudo voxtype setup gpu --disable
  if systemctl --user is-active --quiet voxtype.service; then
    systemctl --user restart voxtype.service
  fi
fi
