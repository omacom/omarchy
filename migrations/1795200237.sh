echo "Put the local models icon beside the agents icon"

# Local models have a bar icon of their own, which only shows on a machine that
# can run a model. It goes right before the agents icon, and only where that
# one is.
config_file="$HOME/.config/omarchy/shell.json"
[[ -s $config_file ]] || exit 0

tmp=$(mktemp)
jq '
  def entry_id: if type == "object" then (.id // "") elif type == "string" then . else "" end;

  if [.bar.layout[]?[]? | entry_id] | (index("omarchy.local-models") != null or index("omarchy.agents") == null) then
    .
  else
    .bar.layout[] |= (if type == "array" then [.[] | if entry_id == "omarchy.agents" then { id: "omarchy.local-models" }, . else . end] else . end)
  end
' "$config_file" >"$tmp" && mv "$tmp" "$config_file"
