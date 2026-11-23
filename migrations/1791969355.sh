echo "Split the bar's center section at its anchor into centerBegin, center and centerEnd"

# The center section is now a box whose widgets are centered as one group, with
# centerBegin and centerEnd hanging off its two edges. centerAnchor named the
# one center widget pinned to the middle of the bar, with the rest flanking it:
# it stays in the box, and what flanked it moves to the sections either side,
# so the bar looks as it did. A center list without its anchor was centered as
# one group already, and stays whole in the box.
#
# A replacement bar (a clone of the built-in one, or a third party's) reads the
# layout the way it was written for, so its config is left as it is.
config_file="$HOME/.config/omarchy/shell.json"
if [[ -s $config_file ]] && jq -e '
  (.bar | type) == "object" and (.bar | has("centerAnchor")) and ((.bar.id // "" | tostring) | IN("", "omarchy.bar"))
' "$config_file" >/dev/null; then
  tmp=$(mktemp)
  jq '
    def entry_id: if type == "object" then (.id // "" | tostring) else tostring end;
    def list: if type == "array" then . else [] end;

    (.bar.centerAnchor | if type == "string" then . else "" end) as $anchor
    | (if (.bar.layout | type) == "object" then .bar.layout.center | list else [] end) as $center
    | (first(range(0; $center | length) | select($anchor != "" and ($center[.] | entry_id) == $anchor)) // null) as $index
    | if $index != null then
        .bar.layout.centerBegin = (.bar.layout.centerBegin | list) + $center[0:$index]
        | .bar.layout.center = [$center[$index]]
        | .bar.layout.centerEnd = $center[$index + 1:] + (.bar.layout.centerEnd | list)
      end
    | del(.bar.centerAnchor)
  ' "$config_file" >"$tmp"
  mv "$tmp" "$config_file"
fi
