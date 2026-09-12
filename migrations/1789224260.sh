echo "Move terminal font size into per-machine overlay files"

size=""
ghostty="$HOME/.config/ghostty/config"
kitty="$HOME/.config/kitty/kitty.conf"
foot="$HOME/.config/foot/foot.ini"
alacritty="$HOME/.config/alacritty/alacritty.toml"
ghostty_local="${XDG_CONFIG_HOME:-$HOME/.config}/ghostty/local"
kitty_local="${XDG_CONFIG_HOME:-$HOME/.config}/kitty/local.conf"
foot_local="${XDG_CONFIG_HOME:-$HOME/.config}/foot/local.ini"
alacritty_local="${XDG_CONFIG_HOME:-$HOME/.config}/alacritty/local.toml"

if [[ -f $ghostty_local ]]; then
  size=$(sed -n 's/^font-size[[:space:]]*=[[:space:]]*//p' "$ghostty_local" | head -1)
fi
if [[ -z $size && -f $kitty_local ]]; then
  size=$(sed -n 's/^font_size[[:space:]]*//p' "$kitty_local" | head -1)
fi
if [[ -z $size && -f $foot_local ]]; then
  size=$(sed -n 's/.*:size=\([0-9.]*\).*/\1/p' "$foot_local" | head -1)
fi
if [[ -z $size && -f $alacritty_local ]]; then
  size=$(sed -n 's/^size[[:space:]]*=[[:space:]]*//p' "$alacritty_local" | head -1)
fi
if [[ -z $size && -f $ghostty ]]; then
  size=$(sed -n 's/^font-size[[:space:]]*=[[:space:]]*//p' "$ghostty" | head -1)
fi
if [[ -z $size && -f $kitty ]]; then
  size=$(sed -n 's/^[[:space:]]*font_size[[:space:]]*//p' "$kitty" | head -1)
fi
if [[ -z $size && -f $foot ]]; then
  size=$(sed -n 's/.*:size=\([0-9.]*\).*/\1/p' "$foot" | head -1)
fi
if [[ -z $size && -f $alacritty ]]; then
  size=$(sed -n 's/^size[[:space:]]*=[[:space:]]*//p' "$alacritty" | head -1)
fi
size=${size:-9}
size=${size%.0}

omarchy-font-size --quiet "$size"

if [[ -f $ghostty ]]; then
  sed -i '/^font-size[[:space:]]*=/d' "$ghostty"
fi
if [[ -f $kitty ]]; then
  sed --follow-symlinks -i '/^[[:space:]]*font_size[[:space:]]/d' "$kitty"
fi
if [[ -f $foot ]]; then
  sed -i 's/^\(font=[^:]*\):size=[0-9.]*/\1/' "$foot"
fi
if [[ -f $alacritty ]]; then
  sed -i '/^size[[:space:]]*=/d' "$alacritty"
fi
