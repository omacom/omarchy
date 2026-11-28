echo "Loosen the offline install's exact Node pin so mise up tracks new releases"

mise_config="$HOME/.config/mise/config.toml"

if [[ -f $mise_config ]] && grep -qE '^node = "[0-9]+\.[0-9]+\.[0-9]+"$' "$mise_config"; then
  if omarchy-config-symlinked "$mise_config"; then
    echo "Preserving symlink-managed mise config: $mise_config"
  else
    sed -i -E 's/^node = "[0-9]+\.[0-9]+\.[0-9]+"$/node = "latest"/' "$mise_config"
  fi
fi
