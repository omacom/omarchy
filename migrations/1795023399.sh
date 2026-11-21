echo "Give Ghostty's dialogs, tabs and popovers hard corners"

config="$HOME/.config/ghostty/config"

[[ -f $config && ! -L $config ]] || exit 0
grep -q '^gtk-custom-css = omarchy.css$' "$config" && exit 0

cp -n "$OMARCHY_PATH/config/ghostty/omarchy.css" "$HOME/.config/ghostty/omarchy.css"
printf '\ngtk-custom-css = omarchy.css\n' >>"$config"
