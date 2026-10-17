echo "Restrict clipboard history file modes"

# Clipboard.qml writes the history under HOME whatever XDG_STATE_HOME says; capture.sh honours it for images.
json="$HOME/.local/state/omarchy/clipboard-history.json"
images="${XDG_STATE_HOME:-$HOME/.local/state}/omarchy/clipboard-images"

if [[ -f $json ]]; then
  chmod 600 "$json"
fi

if [[ -d $images ]]; then
  chmod 700 "$images"
fi
