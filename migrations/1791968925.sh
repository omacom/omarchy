echo "Write the bar's tray where the bar drew it"

# The bar used to draw the tray at the inner end of its section, whatever the
# layout said: first in the right section, last in the left and center ones,
# and only the last tray a section listed. It now draws every widget in the
# order the layout lists them, so the tray moves there in the layout, any
# other trays in the section go, and the bar looks as it did. This runs
# before the center section is split around its anchor (1791969355), as the
# bar pinned the tray before splitting it.
#
# A replacement bar (a clone of the built-in one, or a third party's) reads the
# layout the way it was written for, so its config is left as it is.
config_file="$HOME/.config/omarchy/shell.json"
if [[ -s $config_file ]] && jq -e '
  (.bar | type) == "object" and ((.bar.id // "" | tostring) | IN("", "omarchy.bar")) and (.bar.layout | type) == "object"
' "$config_file" >/dev/null; then
  tmp=$(mktemp)
  jq '
    def entry_id: if type == "object" then (.id // "" | tostring) else tostring end;
    def pin($first):
      if type == "array" then
        map(select(entry_id == "omarchy.tray"))[-1:] as $tray
        | map(select(entry_id != "omarchy.tray")) as $rest
        | if $first then $tray + $rest else $rest + $tray end
      end;

    .bar.layout |= with_entries(
      if .key == "right" then .value |= pin(true)
      elif .key == "left" or .key == "center" then .value |= pin(false)
      end
    )
  ' "$config_file" >"$tmp"
  if [[ $(jq -cS . "$tmp") != "$(jq -cS . "$config_file")" ]]; then
    mv "$tmp" "$config_file"
  else
    rm -f "$tmp"
  fi
fi
