echo "Start Pi straight at the editor, without its header"

# The previous Pi migration set quietStartup to "header" for the Omarchy header,
# which is gone again, so that value becomes true. A value the user chose stays.
settings=~/.pi/agent/settings.json
if jq -e '.quietStartup == "header"' "$settings" &>/dev/null; then
  target=$(realpath "$settings")
  tmp=$(mktemp "$target.XXXXXX")
  jq '.quietStartup = true' "$target" >"$tmp" && mv "$tmp" "$target"
fi
