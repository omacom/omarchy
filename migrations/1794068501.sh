echo "Give the Herdr desktop app the same keybindings as the terminal herdr"

app_home="${HERDR_APP_HOME:-${XDG_CONFIG_HOME:-$HOME/.config}/herdr-app}"

# Leave people who never installed the app alone; its installer seeds the keys.
[[ -d $app_home ]] || exit 0

omarchy-refresh-herdr-app
