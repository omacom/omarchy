echo "Point Neovim's monokai-pro plugin at its upstream repository"

nvim_themes="$HOME/.config/nvim/lua/plugins/all-themes.lua"
nvim_lock="$HOME/.config/nvim/lazy-lock.json"
monokai_clone="$HOME/.local/share/nvim/lazy/monokai-pro.nvim"

# Only a home still holding the spec omarchy-nvim seeded; the spec goes last so a failed run retries the rest.
if [[ -f $nvim_themes ]] && grep -qF '"gthelding/monokai-pro.nvim"' "$nvim_themes"; then
  # The deleted fork's pin is not on upstream, so a fresh clone could never check it out.
  if [[ -f $nvim_lock ]]; then
    sed -i '/"monokai-pro\.nvim":/s|"commit": "5b06ae0736813b1c65d76a4be9edbe92be0b9c74"|"commit": "a68e38b8e55d69a215d0f02598900a79c356da9d"|' "$nvim_lock"
  fi

  if [[ -d $monokai_clone/.git && $(git -C "$monokai_clone" remote get-url origin 2>/dev/null) == "https://github.com/gthelding/monokai-pro.nvim.git" ]]; then
    git -C "$monokai_clone" remote set-url origin "https://github.com/loctvl842/monokai-pro.nvim.git"
  fi

  sed -i 's|"gthelding/monokai-pro\.nvim"|"loctvl842/monokai-pro.nvim"|' "$nvim_themes"
fi
