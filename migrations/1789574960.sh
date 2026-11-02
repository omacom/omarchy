echo "Relink Neovim treesitter queries orphaned by old Omarchy Neovim package builds"

site="$HOME/.local/share/nvim/site"
plugin="$HOME/.local/share/nvim/lazy/nvim-treesitter"

if [[ -d $site/queries ]]; then
  for link in "$site/queries"/*; do
    [[ -L $link ]] || continue
    [[ -e $link ]] && continue
    # Only the links the packages made, into the home they were built in
    [[ $(readlink "$link") == */build-home/.local/share/nvim/* ]] || continue
    name=${link##*/}
    if [[ -d $plugin/runtime/queries/$name ]]; then
      ln -sfn "$plugin/runtime/queries/$name" "$link"
    else
      rm "$link"
    fi
  done
fi
