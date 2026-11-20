echo "Give local models their own bar icon beside the agents"

# Local models moved out of the agents panel into omarchy.local-models. Its icon
# goes right after the agents icon, and only where that one is: a bar without
# the agents widget had nowhere to show local models before either. The lines
# hidden from the agents panel (an offer, a cabled Spark, a tailnet model) stay
# hidden, by carrying their ids over to the new widget.
config_file="$HOME/.config/omarchy/shell.json"
[[ -s $config_file ]] || exit 0

tmp=$(mktemp)
jq '
  def entry_id: if type == "object" then (.id // "") elif type == "string" then . else "" end;
  def local_id: startswith("local:") or startswith("net:");

  if [.bar.layout[]?[]? | entry_id] | (index("omarchy.local-models") != null or index("omarchy.agents") == null) then
    .
  else
    .bar.layout |= with_entries(
      if (.value | type) == "array" then
        .value |= (map(
          if entry_id == "omarchy.agents" and type == "object" then
            ((.providers // {}) | with_entries(select(.key | local_id))) as $hidden
            | [
                (if .providers then .providers |= with_entries(select(.key | local_id | not)) else . end),
                ({ id: "omarchy.local-models" } + (if ($hidden | length) > 0 then { providers: $hidden } else {} end))
              ]
          elif entry_id == "omarchy.agents" then
            [., { id: "omarchy.local-models" }]
          else
            [.]
          end
        ) | add // [])
      else
        .
      end
    )
  end
' "$config_file" >"$tmp" && mv "$tmp" "$config_file"
