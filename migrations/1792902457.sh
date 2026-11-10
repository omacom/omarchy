echo "Theme Qt apps through qtengine instead of the GTK platform theme"

omarchy-pkg-add qtengine

# A qtengine config the user already wrote is theirs; only seed a missing one,
# where qtengine and omarchy-theme-set-qt look for it.
config="${XDG_CONFIG_HOME:-$HOME/.config}/qtengine/config.json"
if [[ ! -e $config && ! -L $config ]]; then
  install -Dm644 "$OMARCHY_PATH/config/qtengine/config.json" "$config"
fi

# The current theme was staged before qtengine.colors had a template. The
# refresh renders it, and its retints point the config at the theme's icons.
omarchy-theme-refresh
