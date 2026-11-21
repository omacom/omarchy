echo "Stop recording a built-in as switched off while a clone stands in for it"

# A clone listed in cloneSourceRestores is the one that put its built-in in
# disabledPlugins. The shell now works that out from the clone itself, so the
# entry it added goes, and the built-ins the user switched off stay. A clone
# that is gone or no longer parses is named <user>.<built-in name>, as
# omarchy-plugin-clone names it.
config_file="$HOME/.config/omarchy/shell.json"
[[ -s $config_file ]] || exit 0
jq -e '.cloneSourceRestores | type == "array"' "$config_file" >/dev/null || exit 0

sources=()
for clone in $(jq -r '.cloneSourceRestores[] | strings' "$config_file"); do
  manifest="$HOME/.config/omarchy/plugins/$clone/manifest.json"
  source=$(jq -r '.omarchy.clonedFrom // empty' "$manifest" 2>/dev/null || true)
  sources+=("${source:-omarchy.${clone#*.}}")
done

tmp=$(mktemp)
jq '
  ($ARGS.positional | map(select(length > 0))) as $sources
  | del(.cloneSourceRestores)
  | if (.disabledPlugins | type) == "array" then .disabledPlugins -= $sources end
  | if .disabledPlugins == [] then del(.disabledPlugins) end
' "$config_file" --args "${sources[@]}" >"$tmp"
mv "$tmp" "$config_file"
