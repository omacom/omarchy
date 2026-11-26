echo "Enable the default sound for low-battery warnings"

default_hook="$OMARCHY_PATH/config/omarchy/hooks/battery-low.d/play-warning-sound"
user_hook="$HOME/.config/omarchy/hooks/battery-low.d/play-warning-sound"

if [[ -e $user_hook || -L $user_hook ]]; then
  exit 0
fi

[[ -f $default_hook ]] || {
  echo "Waiting for omarchy-settings to provide: $default_hook" >&2
  exit 75
}

mkdir -p "$(dirname "$user_hook")"
cp -- "$default_hook" "$user_hook"
