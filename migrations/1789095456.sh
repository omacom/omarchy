echo "Remove automatic project bin directories from PATH"

mise_config="$HOME/Work/.mise.toml"
# install/user/mise-work.sh as shipped in Omarchy 4.0.3.
stock_sha="bd04f191d63bbde86920f44f76f0989fad980afc84e268e8474c201ec7149245"
cwd_bin='\{\{[[:space:]]*cwd[[:space:]]*\}\}/bin'
unsafe_path="^[[:space:]]*_[.]path[[:space:]]*=[[:space:]]*(\"$cwd_bin\"|'$cwd_bin')[[:space:]]*(#.*)?$"

if [[ -f $mise_config ]]; then
  if [[ ! -L $mise_config && $(sha256sum "$mise_config" | cut -d ' ' -f 1) == $stock_sha ]]; then
    rm -f -- "$mise_config"
  elif grep -qE "$unsafe_path" "$mise_config"; then
    backup=$(mktemp "$mise_config.bak.XXXXXX")
    cp -p -- "$mise_config" "$backup"
    sed --follow-symlinks -i -E "\\%$unsafe_path%d" "$mise_config"

    printf '\n%s\n' \
      "Automatic project bin directories were removed from your Mise PATH." \
      "Your other Mise settings were preserved."
    printf '\nBackup saved to:\n  %s\n' "$backup"
  fi
fi
