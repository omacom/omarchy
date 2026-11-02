echo "Bind Ctrl+Shift+N in Alacritty to create a window"

config="$HOME/.config/alacritty/alacritty.toml"
[[ -f $config ]] || exit 0

if grep -q 'action = "CreateNewWindow"' "$config"; then
  exit 0
fi

if grep -qxF '{ key = "Return", mods = "Alt|Shift", chars = "\u001B[13;4u" }' "$config"; then
  sed -i '/^{ key = "Return", mods = "Alt|Shift", chars = "\\u001B\[13;4u" }$/s/$/,/' "$config"
  sed -i '/^{ key = "Return", mods = "Alt|Shift", chars = "\\u001B\[13;4u" },$/a { key = "N", mods = "Control|Shift", action = "CreateNewWindow" }' "$config"
else
  printf '\n{ key = "N", mods = "Control|Shift", action = "CreateNewWindow" }\n' >>"$config"
fi
