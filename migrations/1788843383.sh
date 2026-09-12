echo "Restrict clipboard history file modes"

state="${XDG_STATE_HOME:-$HOME/.local/state}/omarchy"
json="$state/clipboard-history.json"
images="$state/clipboard-images"

if [[ -f $json ]]; then
  chmod 600 "$json"
fi

if [[ -d $images ]]; then
  chmod 700 "$images"
fi
