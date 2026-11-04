echo "Drop the second agents widget from bars that ended up with two"

# A bar that still carried omarchy.model-usage when it updated past both
# 1785344985 and 1786099804 got the widget twice: the first added omarchy.agents
# because it only looked for the new id, and the second renamed the old entry
# to it. The widget allows one instance, so keep one at the first one's spot,
# taking the copy that carries the user's settings.
config_file="$HOME/.config/omarchy/shell.json"

agents='
  def entry_id: if type == "object" then (.id // "" | tostring) else tostring end;
  def agents: [.bar.layout[] | select(type == "array") | .[] | select(entry_id == "omarchy.agents")];
'

if [[ -s $config_file ]] && jq -e "$agents"' (.bar.layout | type) == "object" and (agents | length) > 1' "$config_file" >/dev/null; then
  tmp=$(mktemp)
  jq "$agents"'
    (agents | max_by(if type == "object" then length else 0 end)) as $keep
    | reduce (.bar.layout | to_entries[] | select(.value | type == "array") | .key) as $section
        ({kept: false, config: .};
          reduce .config.bar.layout[$section][] as $entry (.config.bar.layout[$section] = [];
            if ($entry | entry_id) != "omarchy.agents" then
              .config.bar.layout[$section] += [$entry]
            elif .kept | not then
              .config.bar.layout[$section] += [$keep] | .kept = true
            end
          )
        )
    | .config
  ' "$config_file" >"$tmp" && mv "$tmp" "$config_file" || rm -f "$tmp"
fi
