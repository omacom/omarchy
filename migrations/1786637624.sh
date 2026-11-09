echo "Make terminal AI tools follow the Omarchy palette"

current_theme="$HOME/.local/state/omarchy/current/theme"
codex_dir="${CODEX_HOME:-$HOME/.codex}"
grok_dir="${GROK_CONFIG_DIR:-${GROK_HOME:-$HOME/.grok}}"
claude_dir="${CLAUDE_CONFIG_DIR:-$HOME/.claude}"
pi_dir="$HOME/.pi/agent"

# Older staged themes may predate these templates. Generate the missing files
# before activation, without changing the running desktop during an upgrade.
if [[ -d $claude_dir && ! -f $current_theme/claude.json ]] ||
  [[ -d $pi_dir && ! -f $current_theme/pi.json ]]; then
  OMARCHY_THEME_HEADLESS=1 omarchy-theme-refresh
fi
if [[ -d $claude_dir && ! -f $current_theme/claude.json ]] ||
  [[ -d $pi_dir && ! -f $current_theme/pi.json ]]; then
  echo "Terminal AI palettes are missing; select a theme and rerun omarchy-migrate." >&2
  exit 1
fi

# Activate once; later theme switches preserve explicit application choices.
if [[ -d $codex_dir || -f ${CODEX_CONFIG_PATH:-$codex_dir/config.toml} ]]; then
  omarchy-theme-set-codex --activate
fi
if [[ -d $grok_dir || -f ${GROK_CONFIG_PATH:-$grok_dir/config.toml} ]]; then
  omarchy-theme-set-grok --activate
fi
if [[ -d $claude_dir ]]; then
  omarchy-theme-set-claude --activate
fi
if [[ -d $pi_dir ]]; then
  omarchy-theme-set-pi --activate
  rm -f "$pi_dir/extensions/omarchy-system-theme.ts"
fi
