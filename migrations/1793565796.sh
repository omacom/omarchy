echo "Open OpenCode 2 with the Omarchy theme"

# OpenCode 2 reads its theme from cli.json, not opencode.json. Leave a theme
# the user picked alone, and leave a missing cli.json to OpenCode's own
# migration when it has an older tui.json or kv.json to carry over.
config_dir="${XDG_CONFIG_HOME:-$HOME/.config}/opencode"
cli_config="$config_dir/cli.json"

if [[ -f $cli_config ]]; then
  if updated=$(jq 'if has("theme") then empty else .theme = {name: "system"} end' "$cli_config" 2>/dev/null) && [[ -n $updated ]]; then
    printf '%s\n' "$updated" >"$cli_config.tmp"
    chmod 600 "$cli_config.tmp"
    mv "$cli_config.tmp" "$cli_config"
  fi
elif [[ -d $config_dir && ! -e $config_dir/tui.json && ! -e ${XDG_STATE_HOME:-$HOME/.local/state}/opencode/kv.json ]]; then
  cp "$OMARCHY_PATH/config/opencode/cli.json" "$cli_config"
  chmod 600 "$cli_config"
fi
