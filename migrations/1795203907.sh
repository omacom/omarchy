echo "Install the Whisper CLI backend for existing Voxtype setups"

if omarchy-cmd-present voxtype; then
  omarchy-pkg-add whisper-cpp
fi
