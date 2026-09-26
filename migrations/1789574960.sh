echo "Relink Neovim treesitter queries orphaned by the retired lazyvim package"

site="$HOME/.local/share/nvim/site"
plugin="$HOME/.local/share/nvim/lazy/nvim-treesitter"

for dir in queries parser; do
  [[ -d $site/$dir ]] || continue
  for link in "$site/$dir"/*; do
    [[ -L $link ]] || continue
    [[ -e $link ]] && continue
    name=${link##*/}
    if [[ $dir == "queries" && -d $plugin/runtime/queries/$name ]]; then
      ln -sfn "$plugin/runtime/queries/$name" "$link"
    else
      rm "$link"
    fi
  done
done
