echo "Repair background selections after bundled images moved to WebP"

theme_webp_source() {
  local theme="$1"
  local background="$2"
  local original_name=${background##*/}
  local replacement_name="${original_name%.*}.webp"
  local user_theme_backgrounds="$HOME/.config/omarchy/themes/$theme/backgrounds"
  local bundled_theme_backgrounds="$OMARCHY_PATH/themes/$theme/backgrounds"

  if [[ -f $user_theme_backgrounds/$original_name || -f $bundled_theme_backgrounds/$original_name ]]; then
    return 1
  elif [[ -f $user_theme_backgrounds/$replacement_name ]]; then
    printf '%s\n' "$user_theme_backgrounds/$replacement_name"
  elif [[ -f $bundled_theme_backgrounds/$replacement_name ]]; then
    printf '%s\n' "$bundled_theme_backgrounds/$replacement_name"
  else
    return 1
  fi
}

replacement_webp() {
  local background="$1"
  local theme="${2:-}"
  local replacement

  case ${background,,} in
  *.jpg | *.jpeg | *.png) replacement="${background%.*}.webp" ;;
  *) return 1 ;;
  esac

  if [[ -n $theme && ${background%/*} == "$HOME/.local/state/omarchy/current/theme/backgrounds" ]]; then
    theme_webp_source "$theme" "$background" >/dev/null || return 1
    printf '%s\n' "$replacement"
    return 0
  fi

  [[ ! -e $background && -f $replacement ]] || return 1
  printf '%s\n' "$replacement"
}

current_dir="$HOME/.local/state/omarchy/current"
current_background="$current_dir/background"
if [[ -L $current_background ]]; then
  active_theme=$(cat "$current_dir/theme.name" 2>/dev/null || true)
  background=$(readlink "$current_background")
  if replacement=$(replacement_webp "$background" "$active_theme"); then
    if [[ ! -f $replacement ]]; then
      source=$(theme_webp_source "$active_theme" "$background")
      cp "$source" "$replacement"
    fi
    ln -sfn "$replacement" "$current_background"
    omarchy-shell -q background set "$replacement"
  fi
fi

for state_file in "$HOME/.local/state/omarchy/theme-backgrounds/"*; do
  [[ -f $state_file ]] || continue

  background=$(<"$state_file")
  if replacement=$(replacement_webp "$background" "${state_file##*/}"); then
    printf '%s\n' "$replacement" >"$state_file"
  fi
done
