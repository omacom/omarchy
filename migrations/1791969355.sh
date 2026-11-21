echo "Split the bar's center section at its anchor into centerBegin, center and centerEnd"

# The center section is now a box whose widgets are centered as one group, with
# centerBegin and centerEnd hanging off its two edges. centerAnchor named the
# one center widget pinned to the middle of the bar, with the rest flanking it:
# it stays in the box, and what flanked it moves to the sections either side,
# so the bar looks as it did. A center list without its anchor was centered as
# one group already, and stays whole in the box.
#
# An anchor the center does not list was left behind when its widget was
# swapped for a clone, and the bar was centering that list as a group. Follow
# it to what stands in its place: the one center widget cloned from it (the
# clone's manifest records its source), else the one of the same kind, the id
# after the last dot, when nothing was cloned from it. Two candidates is a
# guess, so the center stays whole.
#
# A replacement bar (a clone of the built-in one, or a third party's) reads the
# layout the way it was written for, so its config is left as it is.
config_file="$HOME/.config/omarchy/shell.json"
if [[ -s $config_file ]] && jq -e '
  (.bar | type) == "object" and (.bar | has("centerAnchor")) and ((.bar.id // "" | tostring) | IN("", "omarchy.bar"))
' "$config_file" >/dev/null; then
  clones="[]"
  shopt -s nullglob
  for manifest in "$HOME"/.config/omarchy/plugins/*/manifest.json; do
    if next=$(jq -sc --argjson clones "$clones" '
      if length == 1 then .[0] else error end
      | $clones + [{id: (.id // "" | tostring), from: (.omarchy | objects | .clonedFrom // "" | tostring)} | select(.id != "" and .from != "")]
    ' "$manifest" 2>/dev/null); then
      clones=$next
    fi
  done
  shopt -u nullglob

  tmp=$(mktemp)
  jq --argjson clones "$clones" '
    def entry_id: if type == "object" then (.id // "" | tostring) else tostring end;
    def list: if type == "array" then . else [] end;
    def kind: split(".") | last;
    def only: unique | if length == 1 then .[0] else "" end;

    (.bar.centerAnchor | if type == "string" then . else "" end) as $named
    | (if (.bar.layout | type) == "object" then .bar.layout.center | list else [] end) as $center
    | ($center | map(entry_id)) as $ids
    | (if $named == "" or ($ids | index($named)) != null then $named
       else
         ([$ids[] | select(. as $id | any($clones[]; .id == $id and .from == $named))] | unique) as $cloned
         | if ($cloned | length) == 1 then $cloned[0]
           elif ($cloned | length) > 1 then ""
           else ([$ids[] | select(kind == ($named | kind))] | only) end
       end) as $resolved
    | (if $resolved != "" then $resolved else $named end) as $anchor
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
