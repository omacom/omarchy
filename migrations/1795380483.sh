echo "Remove the local models icon from the bar"

# Local coding models moved into the agents panel, and the local models icon
# and panel are gone.
config_file="$HOME/.config/omarchy/shell.json"
[[ -s $config_file ]] || exit 0
grep -q '"omarchy.local-models"' "$config_file" || exit 0

tmp=$(mktemp)
jq '
  def entry_id: if type == "object" then (.id // "") elif type == "string" then . else "" end;
  .bar.layout[]? |= (if type == "array" then [.[] | select(entry_id != "omarchy.local-models")] else . end)
' "$config_file" >"$tmp" && mv "$tmp" "$config_file"
