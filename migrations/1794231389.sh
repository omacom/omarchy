echo "Bind Ctrl+Shift+C/V to copy and paste in foot so universal copy and paste reach it"

# Universal copy/paste sends Ctrl+Shift+C/V to terminals. A foot.ini copied
# before those keys were added to clipboard-copy/clipboard-paste replaces
# foot's defaults with Insert-only bindings, so the keys reach the app as ^C/^V.
# Add each key to its action unless the user disabled the action or already
# bound the key elsewhere in [key-bindings]: foot rejects a config that maps
# one key to two actions.
#
# Keys are compared the way foot compares them: modifier order is ignored, but
# modifier and key names are case-sensitive. A comment starts at a # that
# follows whitespace, on section headers and values alike.

foot_config="$HOME/.config/foot/foot.ini"

[[ -f $foot_config ]] || exit 0

tmp=$(mktemp)
awk '
  function trim(s) {
    sub(/^[[:space:]]+/, "", s)
    sub(/[[:space:]]+$/, "", s)
    return s
  }

  function canonical(combo,    parts, count, i, j, part, result) {
    count = split(combo, parts, "+")
    for (i = 2; i < count; i++) {
      part = parts[i]
      for (j = i - 1; j >= 1 && parts[j] > part; j--) parts[j + 1] = parts[j]
      parts[j + 1] = part
    }
    result = parts[count]
    for (i = count - 1; i >= 1; i--) result = parts[i] "+" result
    return result
  }

  function add_key(action, key) {
    if (name == action && value != "" && value != "none" && !(canonical(key) in bound)) {
      sub(/[[:space:]]+$/, "", binding)
      $0 = binding " " key comment
    }
  }

  FNR == 1 { section = "" }

  /^[[:space:]]*\[/ {
    section = $0
    sub(/[[:space:]]+#.*$/, "", section)
    gsub(/[[:space:]]/, "", section)
  }

  {
    name = ""
    value = ""
    binding = ""
    comment = ""
    if (section == "[key-bindings]" && $0 !~ /^[[:space:]]*#/ && index($0, "=")) {
      binding = $0
      if (match(binding, /[[:space:]]+#/) && RSTART > index(binding, "=")) {
        comment = substr(binding, RSTART)
        binding = substr(binding, 1, RSTART - 1)
      }
      name = trim(substr(binding, 1, index(binding, "=") - 1))
      value = trim(substr(binding, index(binding, "=") + 1))
    }
  }

  NR == FNR {
    if (name != "") {
      count = split(value, keys, /[[:space:]]+/)
      for (i = 1; i <= count; i++) bound[canonical(keys[i])] = 1
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
