echo "Teach older foot configs the Ctrl+Shift clipboard chords that Super+C and Super+V now send"

# Universal copy and paste send Ctrl+Shift+C and Ctrl+Shift+V to terminals. A foot
# config from before those chords were added binds copy and paste to the Insert
# keys alone, which replaces foot's own defaults, so Super+C reaches the program
# as an interrupt. Only the exact lines Omarchy shipped are rewritten; a binding
# the user changed is left alone.

foot_config="$HOME/.config/foot/foot.ini"

if [[ -f $foot_config ]] && grep -qx 'clipboard-copy=Control+Insert\|clipboard-paste=Shift+Insert' "$foot_config"; then
  # The rewrite is renamed over the real file, so a failed write leaves it whole and a symlink survives.
  # A config in a directory the user can't write to has no room beside it, so that one is written in place.
  target=$(readlink -f "$foot_config")
  if [[ -w ${target%/*} ]]; then
    tmp=$(mktemp "$target.XXXXXX")
    replace=1
  else
    tmp=$(mktemp)
    replace=0
  fi
  trap 'rm -f "$tmp"' EXIT
  # Two passes: the first notes every key bound in [key-bindings] or [text-bindings],
  # one set to foot, since a chord bound twice makes foot reject the whole config.
  awk '
    # foot ignores modifier order but not the case of the key itself.
    function norm(combo,    n, i, j, t, parts, out) {
      n = split(combo, parts, "+")
      for (i = 2; i < n; i++) for (j = i; j > 1 && parts[j - 1] > parts[j]; j--) { t = parts[j]; parts[j] = parts[j - 1]; parts[j - 1] = t }
      out = parts[n]
      for (i = n - 1; i >= 1; i--) out = parts[i] "+" out
      return out
    }
    function add(line, keys,    n, i, list, extra) {
      n = split(keys, list, " ")
      for (i = 1; i <= n; i++) if (!(norm(list[i]) in bound)) extra = extra " " list[i]
      return line extra
    }
    FNR == 1 { section = "" }
    /^[[:space:]]*\[/ { section = $0; sub(/^[[:space:]]+/, "", section); sub(/\].*/, "]", section) }
    NR == FNR {
      if ((section == "[key-bindings]" || section == "[text-bindings]") && $0 !~ /^[[:space:]]*#/ && index($0, "=")) {
        value = substr($0, index($0, "=") + 1)
        sub(/[[:space:]]#.*/, "", value)
        n = split(value, keys, /[[:space:]]+/)
        for (i = 1; i <= n; i++) if (keys[i] != "") bound[norm(keys[i])] = 1
      }
      next
    }
    section == "[key-bindings]" && $0 == "clipboard-copy=Control+Insert" { $0 = add($0, "Control+Shift+c XF86Copy") }
    section == "[key-bindings]" && $0 == "clipboard-paste=Shift+Insert" { $0 = add($0, "Control+Shift+v XF86Paste") }
    { print }
  ' "$foot_config" "$foot_config" >"$tmp"
  if (( replace )); then
    # Mode carries the file's ACLs with it.
    cp --attributes-only --preserve=mode "$target" "$tmp"
    mv "$tmp" "$target"
  else
    cat "$tmp" >"$target"
  fi
fi
