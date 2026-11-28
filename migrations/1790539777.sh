echo "Teach older foot configs the Ctrl+Shift clipboard chords that Super+C and Super+V now send"

# Repair Insert-only bindings while leaving customized chords alone.
# foot replaces its defaults when these actions are set, so Super+C otherwise reaches the app as an interrupt.

foot_config="$HOME/.config/foot/foot.ini"

if [[ -f $foot_config ]] && grep -Eq '^[[:space:]]*clipboard-(copy[[:space:]]*=[[:space:]]*Control|paste[[:space:]]*=[[:space:]]*Shift)\+Insert([[:space:]]+#.*|[[:space:]]*)$' "$foot_config"; then
  # The rewrite is renamed over the real file, so a failed write leaves it whole and a symlink survives.
  # A config in a directory the user can't write to is written over in place rather than truncated first; the rewrite only lengthens lines, so no old bytes are left past its end.
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
    function add(line, keys,    n, i, list, extra, trailing) {
      match(line, /[[:space:]]*$/)
      trailing = substr(line, RSTART)
      line = substr(line, 1, RSTART - 1)
      n = split(keys, list, " ")
      for (i = 1; i <= n; i++) if (!(norm(list[i]) in bound)) extra = extra " " list[i]
      return line extra trailing
    }
    function trim(s) {
      sub(/^[[:space:]]+/, "", s)
      sub(/[[:space:]]+$/, "", s)
      return s
    }
    FNR == 1 { section = "" }
    /^[[:space:]]*\[/ { section = $0; sub(/^[[:space:]]+/, "", section); sub(/\].*/, "]", section) }
    {
      binding = $0
      comment = ""
      if (match(binding, /[[:space:]]+#/)) {
        comment = substr(binding, RSTART)
        binding = substr(binding, 1, RSTART - 1)
      }
      name = trim(substr(binding, 1, index(binding, "=") - 1))
      value = trim(substr(binding, index(binding, "=") + 1))
    }
    NR == FNR {
      if ((section == "[key-bindings]" || section == "[text-bindings]") && $0 !~ /^[[:space:]]*#/ && index(binding, "=")) {
        n = split(value, keys, /[[:space:]]+/)
        for (i = 1; i <= n; i++) if (keys[i] != "") bound[norm(keys[i])] = 1
      }
      next
    }
    section == "[key-bindings]" && name == "clipboard-copy" && value == "Control+Insert" { $0 = add(binding, "Control+Shift+c XF86Copy") comment }
    section == "[key-bindings]" && name == "clipboard-paste" && value == "Shift+Insert" { $0 = add(binding, "Control+Shift+v XF86Paste") comment }
    { print }
  ' "$foot_config" "$foot_config" >"$tmp"
  if cmp -s "$tmp" "$foot_config"; then
    rm -f "$tmp"
  elif (( replace )); then
    # Mode carries the file's ACLs with it.
    cp --attributes-only --preserve=mode "$target" "$tmp"
    mv "$tmp" "$target"
  else
    cat "$tmp" 1<>"$target"
  fi
fi
