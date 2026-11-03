echo "Finish Superwhisper setup for installs that came up with it unconfigured"

# Superwhisper became the default dictation backend before first run set it up
# (#17286), and aarch64 images before omacom/omarchy-iso#377 left the package
# out entirely. Both left dictation selected but unusable. setup-user creates
# the app/current link, so its presence means setup already ran.
if [[ $(omarchy-default-dictation 2>/dev/null) == "superwhisper" ]] &&
  [[ ! -e ${XDG_DATA_HOME:-$HOME/.local/share}/superwhisper/app/current ]]; then
  omarchy-install-dictation-superwhisper --background
fi
