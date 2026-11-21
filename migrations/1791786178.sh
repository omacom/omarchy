echo "Point Neovim's monokai-pro theme at its maintained repository"

# ~/.config/nvim is copied once from omarchy-nvim, so a copy made before
# 2026.9.21 still names the deleted gthelding fork and Lazy fails to clone it.
config="$HOME/.config/nvim"
themes="$config/lua/plugins/all-themes.lua"

[[ -f $themes ]] || exit 0

# Dotfile managers may own the file or a parent directory through a symlink.
# Preserve that layout rather than detaching or editing its target.
path=$themes
while [[ $path != "$HOME" && $path != / ]]; do
  if [[ -L $path ]]; then
    echo "Preserving symlink-managed Neovim config: $path"
    exit 0
  fi
  path=$(dirname "$path")
done

# grep exits 2 on a file it cannot read, which must leave this pending.
found=0
grep -qF '"gthelding/monokai-pro.nvim"' "$themes" || found=$?
if (( found == 0 )); then
  sed -i 's|"gthelding/monokai-pro\.nvim"|"loctvl842/monokai-pro.nvim"|' "$themes"
elif (( found > 1 )); then
  exit 1
fi
