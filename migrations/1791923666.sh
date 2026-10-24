echo "Enable Omarchy palette syncing for OpenCode 2"

config_dir="${OPENCODE_CONFIG_DIR:-${XDG_CONFIG_HOME:-$HOME/.config}/opencode}"
[[ -d $config_dir ]] || exit 0

theme_dir="$HOME/.local/state/omarchy/current/theme"
theme_name_path="$HOME/.local/state/omarchy/current/theme.name"
if [[ ! -f $theme_dir/opencode.json && -s $theme_name_path ]]; then
  theme_name=$(<"$theme_name_path")
  if [[ -d $OMARCHY_PATH/themes/$theme_name || -d $HOME/.config/omarchy/themes/$theme_name ]]; then
    omarchy-theme-refresh
  fi
fi
if [[ ! -f $theme_dir/opencode.json ]]; then
  echo "OpenCode theme activation skipped: the active palette is unavailable; select an installed theme to enable syncing."
  exit 0
fi
omarchy-theme-set-opencode --activate
