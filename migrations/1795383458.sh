echo "Put the system icon between the display and battery icons"

# The system panel shows memory by what holds it, CPU load and disk space. Its
# icon goes right before the battery icon, and only where that one is.
config_file="$HOME/.config/omarchy/shell.json"
[[ -s $config_file ]] || exit 0

# Written through, so a shell.json linked from dotfiles stays a link.
tmp=$(mktemp)
if jq '
  def entry_id: if type == "object" then (.id // "") elif type == "string" then . else "" end;

  if [.bar.layout[]?[]? | entry_id] | (index("omarchy.system") != null or index("omarchy.power") == null) then
    .
  else
    .bar.layout[] |= (if type == "array" then [.[] | if entry_id == "omarchy.power" then { id: "omarchy.system" }, . else . end] else . end)
  end
' "$config_file" >"$tmp"; then
  cat "$tmp" >"$config_file"
else
  # A shell.json jq can't read stays as it is, and the migration pending.
  status=$?
  rm -f "$tmp"
  exit "$status"
fi
rm -f "$tmp"
