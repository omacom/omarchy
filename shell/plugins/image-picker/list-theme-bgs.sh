#!/bin/bash

theme_name="${1:-}"
if [[ -z $theme_name ]]; then
  exit 0
fi

declare -A seen=()

add_dir() {
  local dir="$1"
  local image real

  if [[ ! -d $dir ]]; then
    return 0
  fi

  while IFS= read -r -d '' image; do
    real=$(readlink -f "$image" 2>/dev/null || printf '%s' "$image")
    if [[ -z $real ]]; then
      continue
    fi
    if [[ -n ${seen[$real]+x} ]]; then
      continue
    fi

    seen[$real]=1
    printf '%s\n' "$image"
  done < <(find -L "$dir" -maxdepth 1 -type f \
    \( -iname '*.jpg' -o -iname '*.jpeg' -o -iname '*.png' -o -iname '*.gif' -o -iname '*.bmp' -o -iname '*.webp' \) \
    -print0 2>/dev/null | sort -z)
}

add_dir "$HOME/.config/omarchy/backgrounds/$theme_name"
add_dir "$HOME/.config/omarchy/themes/$theme_name/backgrounds"
add_dir "$OMARCHY_PATH/themes/$theme_name/backgrounds"
