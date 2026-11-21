# Chromium-family flags files (~/.config/*-flags.conf) load Omarchy's unpacked
# extensions from a --load-extension switch. Users add their own extensions and
# switches to these files, so changes splice into the switch instead of
# rewriting lines.

# The --load-extension value Chromium honors: the last such switch outside a
# comment, which may share its line with other switches. A comment starts at a
# # that begins a line or follows whitespace, as omarchy-install-video-decode
# reads the same files.
browser_flags_loaded_extensions() {
  awk '{ sub(/(^|[[:space:]])#.*$/, ""); for (i = 1; i <= NF; i++) if ($i ~ /^--load-extension=/) last = substr($i, 18) } END { print last }' "$1"
}

# The extensions among the comma-separated lists after the file that it does
# not load yet, one per line.
browser_flags_missing_extensions() {
  local file=$1 loaded extension
  shift

  loaded=$(browser_flags_loaded_extensions "$file" | tr ',' '\n')
  while read -r extension; do
    [[ -z $extension ]] || grep -Fxq -- "$extension" <<<"$loaded" || printf '%s\n' "$extension"
  done < <(printf '%s\n' "$@" | tr ',' '\n')
}

# Add the extensions the file doesn't load yet to its last active
# --load-extension switch, keeping the user's own flags and extensions, or
# append a switch when there is none.
browser_flags_add_extensions() {
  local file=$1 missing repaired
  shift

  missing=$(browser_flags_missing_extensions "$file" "$@" | paste -sd,)
  [[ -n $missing ]] || return 0

  # Extend the last active --load-extension switch in place, leaving comments
  # and any other switches on its line alone. A comment only ever ends a line,
  # so offsets into the uncommented part hold for the whole line. Writing
  # through the redirect keeps a symlinked flags file a symlink.
  if repaired=$(awk -v missing="$missing" '
    function active(line) {
      sub(/(^|[[:space:]])#.*$/, "", line)
      return line
    }
    FNR == NR {
      if (active($0) ~ /(^|[[:space:]])--load-extension=/) target = FNR
      next
    }
    FNR == target {
      line = active($0)
      rest = line
      offset = 0
      while (match(rest, /(^|[[:space:]])--load-extension=[^[:space:]]*/)) {
        offset += RSTART + RLENGTH - 1
        rest = substr(line, offset + 1)
      }
      $0 = substr($0, 1, offset) "," missing substr($0, offset + 1)
    }
    { print }
    END { exit !target }
  ' "$file" "$file"); then
    printf '%s\n' "$repaired" >"$file"
  else
    [[ -z $(tail -c1 "$file") ]] || echo >>"$file"
    echo "--load-extension=$missing" >>"$file"
  fi
}
