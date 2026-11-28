echo "Remove the local models icon from the bar"

# Local coding models moved into the agents panel, and the local models icon
# and panel are gone.
config_file="$HOME/.config/omarchy/shell.json"
[[ -s $config_file ]] || exit 0
grep -q '"omarchy.local-models"' "$config_file" || exit 0

# Written through, so a shell.json linked from dotfiles stays a link.
tmp=$(mktemp)
if jq '
  def entry_id: if type == "object" then (.id // "") elif type == "string" then . else "" end;
  .bar.layout[]? |= (if type == "array" then [.[] | select(entry_id != "omarchy.local-models")] else . end)
' "$config_file" >"$tmp"; then
  cat "$tmp" >"$config_file"
else
  # A shell.json jq can't read stays as it is, and the migration pending.
  status=$?
  rm -f "$tmp"
  exit "$status"
fi
rm -f "$tmp"
