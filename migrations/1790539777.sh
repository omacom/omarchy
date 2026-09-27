echo "Teach older foot configs the Ctrl+Shift clipboard chords that Super+C and Super+V now send"

# Universal copy and paste send Ctrl+Shift+C and Ctrl+Shift+V to terminals. A foot
# config from before those chords were added binds copy and paste to the Insert
# keys alone, which replaces foot's own defaults, so Super+C reaches the program
# as an interrupt. Only the exact lines Omarchy shipped are rewritten; a binding
# the user changed is left alone.

foot_config="$HOME/.config/foot/foot.ini"

if [[ -f $foot_config ]] && grep -qx 'clipboard-copy=Control+Insert\|clipboard-paste=Shift+Insert' "$foot_config"; then
  tmp=$(mktemp)
  # Two passes: the first notes every key already bound in [key-bindings], so a
  # chord the user gave to another action is not bound a second time.
  awk '
    function add(line, keys,    n, i, list, extra) {
      n = split(keys, list, " ")
      for (i = 1; i <= n; i++) if (!(tolower(list[i]) in bound)) extra = extra " " list[i]
      return line extra
    }
    FNR == 1 { section = "" }
    /^\[/ { section = $0 }
    NR == FNR {
      if (section == "[key-bindings]" && index($0, "=")) {
        n = split(substr($0, index($0, "=") + 1), keys, /[[:space:]]+/)
        for (i = 1; i <= n; i++) if (keys[i] != "") bound[tolower(keys[i])] = 1
      }
      next
    }
    section == "[key-bindings]" && $0 == "clipboard-copy=Control+Insert" { $0 = add($0, "Control+Shift+c XF86Copy") }
    section == "[key-bindings]" && $0 == "clipboard-paste=Shift+Insert" { $0 = add($0, "Control+Shift+v XF86Paste") }
    { print }
  ' "$foot_config" "$foot_config" >"$tmp"
  cat "$tmp" >"$foot_config"
  rm -f "$tmp"
fi
