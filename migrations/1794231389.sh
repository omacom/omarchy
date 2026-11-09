echo "Bind Ctrl+Shift+C/V to copy and paste in foot so universal copy and paste reach it"

# Universal copy/paste sends Ctrl+Shift+C/V to terminals. A foot.ini copied
# before those keys were added to clipboard-copy/clipboard-paste replaces
# foot's defaults with Insert-only bindings, so the keys reach the app as ^C/^V.
# Add each key to its action unless the user disabled the action or already
# bound the key elsewhere in [key-bindings].

foot_config="$HOME/.config/foot/foot.ini"

[[ -f $foot_config ]] || exit 0

tmp=$(mktemp)
awk '
  function trim(s) {
    sub(/^[[:space:]]+/, "", s)
    sub(/[[:space:]]+$/, "", s)
    return s
  }

  function add_key(action, key) {
    if (name == action && tolower(value) != "none" && !(tolower(key) in bound)) {
      sub(/[[:space:]]+$/, "")
      $0 = $0 " " key
    }
  }

  FNR == 1 { section = "" }

  /^[[:space:]]*\[/ {
    section = $0
    gsub(/[[:space:]]/, "", section)
  }

  {
    name = ""
    value = ""
    if (section == "[key-bindings]" && $0 !~ /^[[:space:]]*#/ && index($0, "=")) {
      name = trim(substr($0, 1, index($0, "=") - 1))
      value = trim(substr($0, index($0, "=") + 1))
    }
  }

  NR == FNR {
    if (name != "") {
      count = split(tolower(value), keys, /[[:space:]]+/)
      for (i = 1; i <= count; i++) bound[keys[i]] = 1
    }
    next
  }

  {
    add_key("clipboard-copy", "Control+Shift+c")
    add_key("clipboard-paste", "Control+Shift+v")
    print
  }
' "$foot_config" "$foot_config" >"$tmp"

if [[ $(<"$tmp") != "$(<"$foot_config")" ]]; then
  cat "$tmp" >"$foot_config"
fi
rm -f "$tmp"
