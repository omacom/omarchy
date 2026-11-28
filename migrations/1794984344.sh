echo "Remove Neovim's stray normal-mode status-line separator"

file="lua/plugins/lualine-transparent.lua"
config="$HOME/.config/nvim"
destination="$config/$file"

[[ -d $config ]] || exit 0

# Users without omarchy-nvim manage their own Neovim configuration.
omarchy-pkg-present omarchy-nvim || exit 0

# Dotfile managers may own the file or a parent directory through a symlink.
# Preserve that layout rather than detaching or editing its target.
path="$destination"
while [[ $path != "$HOME" && $path != / ]]; do
  if [[ -L $path ]]; then
    echo "Preserving symlink-managed Neovim config: $path"
    exit 0
  fi
  path=$(dirname "$path")
done

[[ -f $destination ]] || exit 0

# Replace only the exact lualine transparency spec Omarchy previously shipped.
[[ $(sha256sum <"$destination") == d59f78b55f99ced1423db44b84b97f855daa49e7ba8b9ce9a432aab73075bcb7* ]] || exit 0

staged=$(mktemp "$destination.new.XXXXXX")
trap 'rm -f -- "$staged"' EXIT
sed 's/ipairs({ "b", "c" })/ipairs({ "b", "c", "x" })/' "$destination" >"$staged"

# Refuse to replace the file if the exact expected edit was not produced.
[[ $(sha256sum <"$staged") == f89e589a116fa13c857d8061e22dd604d3c94dfd845ccd4fef1c041c676348cf* ]]

chmod 0644 "$staged"
mv -fT -- "$staged" "$destination"
