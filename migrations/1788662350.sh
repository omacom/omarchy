echo "Add GTK theme stylesheets to the active theme"

# GTK apps load ~/.config/gtk-3.0/gtk.css and ~/.config/gtk-4.0/gtk.css at
# startup, and omarchy-theme-set now links both to the current theme's
# generated stylesheet. A theme staged before the gtk templates shipped has no
# gtk.css to link to, so restage it once (mirroring the staging fix) rather
# than waiting for the user to switch themes. omarchy-theme-refresh also
# re-establishes the links when a user has their own gtk.css in the way.
theme_name_path="$HOME/.local/state/omarchy/current/theme.name"

[[ -s $theme_name_path ]] || exit 0

theme_name=$(<"$theme_name_path")

# The staged theme is the active one, so there is nothing to restage (and no
# colors to generate) once the theme that staged it is gone.
if [[ ! -d $OMARCHY_PATH/themes/$theme_name && ! -d $HOME/.config/omarchy/themes/$theme_name ]]; then
  exit 0
fi

omarchy-theme-refresh
