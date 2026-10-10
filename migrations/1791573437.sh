echo "Restrict permissions on shell.json to protect plugin settings and credentials"

shell_config="$HOME/.config/omarchy/shell.json"

if [[ -f $shell_config ]]; then
  chmod 0600 "$shell_config"
fi
