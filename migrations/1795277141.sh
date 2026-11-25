echo "Remove the launchers of local image, video and music models"

# Image, video and music models no longer get a launcher of their own: Fantasi
# lists them itself. The sync takes away the ones made before that, and leaves
# the coding models' alone. Without omarchy-local-ai no model can be read.
if omarchy-cmd-present omarchy-local-ai; then
  omarchy-models-launchers
fi
