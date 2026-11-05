echo "Repair the Copy URL shortcut for Brave Origin profiles"

# The repair in 1786643346 walked every Chromium-family profile root except
# Brave Origin's, which Omarchy has installed since before the extension id
# was pinned. Those profiles still bind Alt+Shift+L to a ghost id.
#
# Rerun it on Brave Origin's roots alone: every profile it already repaired
# kept a backup it reads as a repair still to verify, and would ask for that
# browser to be closed again.
profile_roots=(
  "$HOME/.config/BraveSoftware/Brave-Origin"
  "$HOME/.config/BraveSoftware/Brave-Origin-Beta"
  "$HOME/.config/BraveSoftware/Brave-Origin-Nightly"
)
source "$OMARCHY_PATH/migrations/1786643346.sh"
