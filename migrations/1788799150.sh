echo "Launch Kitty as a single instance"

# An existing file keeps its other keys. Exec lines that launch kitty gain --single-instance.
write_kitty_desktop() {
  local dest="$HOME/.local/share/applications/kitty.desktop"
  local source="$OMARCHY_PATH/default/kitty/kitty.desktop"
  local tmp line value command token rest has_flag mode
  mkdir -p "${dest%/*}"
  if [[ ! -f $dest ]]; then
    cp "$source" "$dest"
    return
  fi
  tmp=$(mktemp)
  while IFS= read -r line || [[ -n $line ]]; do
    if [[ $line == Exec=* ]]; then
      value="${line#Exec=}"
      command="${value%%[[:space:]]*}"
      if [[ $command == "kitty" ]]; then
        has_flag=0
        read -ra tokens <<<"$value"
        for token in "${tokens[@]}"; do
          if [[ $token == "--single-instance" ]]; then
            has_flag=1
          fi
        done
        if (( has_flag == 0 )); then
          rest="${value#"$command"}"
          line="Exec=kitty --single-instance${rest}"
        fi
      fi
    fi
    printf '%s\n' "$line"
  done <"$dest" >"$tmp"
  mode=$(stat -c '%a' "$dest")
  mv "$tmp" "$dest"
  chmod "$mode" "$dest"
}

if omarchy-cmd-present kitty; then
  write_kitty_desktop
fi
