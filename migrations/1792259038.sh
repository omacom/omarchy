echo "Keep background selections across renumbered bundled backgrounds"

# Tokyo Night's backgrounds moved up a number when Liftoff took the lead, so
# 0-winding-road became 1-winding-road. A selection of a theme background whose
# name, and its WebP, are gone from the theme moves to the theme's one
# background with the same name under another number. A theme is its bundled
# backgrounds with a user theme of the same name laid over them, as
# omarchy-theme-set stages it. A background that still opens, a user's own
# backgrounds, and anything without exactly one match stay as they are. So does
# a name a symlink stands for: staging keeps some symlinks and not others (not
# those of a cloned theme), so it is left rather than guessed at.
current_dir="$HOME/.local/state/omarchy/current"
staged_backgrounds="$current_dir/theme/backgrounds"

# Prints the theme's file for a renumbered background name.
renumbered_source() {
  local theme="$1" name="$2" stem dir file found=""
  local -A seen=()

  [[ -n $theme && ${theme##*/} == "$theme" && $name =~ ^[0-9]+-(.+)\.[^.]+$ ]] || return 1
  stem=${BASH_REMATCH[1]}

  # The user theme first: its files shadow bundled ones of the same name.
  for dir in "$HOME/.config/omarchy/themes/$theme/backgrounds" "$OMARCHY_PATH/themes/$theme/backgrounds"; do
    # A symlinked backgrounds folder is not staged from a cloned theme.
    [[ ! -L $dir ]] || return 1
    [[ -e $dir/$name || -e $dir/${name%.*}.webp ]] && return 1
    for file in "$dir"/*; do
      [[ ${file##*/} =~ ^[0-9]+-(.+)\.[^.]+$ && ${BASH_REMATCH[1]} == "$stem" ]] || continue
      # Even one of the old name: whether staging keeps it is not known here.
      [[ ! -L $file ]] || return 1
      [[ -f $file && -z ${seen[${file##*/}]:-} ]] || continue
      seen[${file##*/}]=1
      [[ -z $found ]] || return 1
      found=$file
    done
  done

  [[ -n $found ]] && printf '%s\n' "$found"
}

# Selections live in the staged theme; omarchy-theme-set reads a remembered
# one there by name against the theme it stages.
current_background="$current_dir/background"
# A symlinked current/theme is someone's own directory: nothing is copied into it.
if [[ -L $current_background && ! -e $current_background && ! -L $current_dir/theme && -d $staged_backgrounds ]]; then
  background=$(readlink "$current_background")
  if [[ ${background%/*} == "$staged_backgrounds" ]] &&
    source=$(renumbered_source "$(cat "$current_dir/theme.name" 2>/dev/null || true)" "${background##*/}"); then
    replacement="$staged_backgrounds/${source##*/}"
    [[ -f $replacement ]] || cp "$source" "$replacement"
    ln -sfn "$replacement" "$current_background"
    omarchy-shell -q background set "$replacement"
  fi
fi

for state_file in "$HOME/.local/state/omarchy/theme-backgrounds/"*; do
  [[ -f $state_file ]] || continue

  background=$(<"$state_file")
  if [[ ${background%/*} == "$staged_backgrounds" ]] &&
    source=$(renumbered_source "${state_file##*/}" "${background##*/}"); then
    printf '%s\n' "$staged_backgrounds/${source##*/}" >"$state_file"
  fi
done
