echo "Point Neovim's Monokai Pro theme at its maintained repository"

# ~/.config/nvim is copied once from omarchy-nvim, so installs from before the
# package fix still name the deleted gthelding fork and fail every Lazy sync.
themes="$HOME/.config/nvim/lua/plugins/all-themes.lua"

[[ -f $themes ]] || exit 0
# An assignment, so a file that cannot be read fails the migration rather than passing it.
contents=$(<"$themes")
[[ $contents == *'"gthelding/monokai-pro.nvim"'* ]] || exit 0

# Dotfile managers may own the file or a parent directory through a symlink.
# Preserve that layout rather than detaching or editing its target.
path="$themes"
while [[ $path != "$HOME" && $path != / ]]; do
  if [[ -L $path ]]; then
    echo "Preserving symlink-managed Neovim config: $themes"
    echo "Replace gthelding/monokai-pro.nvim with loctvl842/monokai-pro.nvim there."
    exit 0
  fi
  path=$(dirname "$path")
done

# Only the dead repository name changes; the rest of the file stays as the user has it.
sed -i 's@"gthelding/monokai-pro\.nvim"@"loctvl842/monokai-pro.nvim"@g' "$themes"
