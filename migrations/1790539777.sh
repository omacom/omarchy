echo "Teach older foot configs the Ctrl+Shift clipboard chords that Super+C and Super+V now send"

# Universal copy and paste send Ctrl+Shift+C and Ctrl+Shift+V to terminals. A foot
# config from before those chords were added binds copy and paste to the Insert
# keys alone, which replaces foot's own defaults, so Super+C reaches the program
# as an interrupt. Only the exact lines Omarchy shipped are rewritten; a binding
# the user changed is left alone.

foot_config="$HOME/.config/foot/foot.ini"

if [[ -f $foot_config ]] && grep -qx 'clipboard-copy=Control+Insert\|clipboard-paste=Shift+Insert' "$foot_config"; then
  tmp=$(mktemp)
  awk '
    /^\[/ { section = $0 }
    section == "[key-bindings]" && $0 == "clipboard-copy=Control+Insert" { $0 = $0 " Control+Shift+c XF86Copy" }
    section == "[key-bindings]" && $0 == "clipboard-paste=Shift+Insert" { $0 = $0 " Control+Shift+v XF86Paste" }
    { print }
  ' "$foot_config" >"$tmp"
  cat "$tmp" >"$foot_config"
  rm -f "$tmp"
fi
