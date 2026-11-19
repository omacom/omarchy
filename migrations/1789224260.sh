echo "Move terminal font size into per-machine overlay files"

config_home="${XDG_CONFIG_HOME:-$HOME/.config}"
ghostty="$config_home/ghostty/config"
kitty="$config_home/kitty/kitty.conf"
foot="$config_home/foot/foot.ini"
alacritty="$config_home/alacritty/alacritty.toml"

# Each terminal keeps its own size. A missing size is left alone; a value that
# is not a number becomes 9 inside omarchy-font-size --read, and this migration
# keeps going so later ones are not stuck.
apply_terminal() {
  local term="$1" size
  size=$(omarchy-font-size --read "$term")
  if [[ -n $size ]]; then
    omarchy-font-size --quiet --only "$term" "$size"
  fi
}

apply_terminal ghostty
apply_terminal kitty
apply_terminal foot
apply_terminal alacritty

omarchy-font-size --includes-only

if [[ -f $ghostty ]]; then
  sed --follow-symlinks -i '/^[[:space:]]*font-size[[:space:]]*=/d' "$ghostty"
fi
if [[ -f $kitty ]]; then
  sed --follow-symlinks -i '/^[[:space:]]*font_size[[:space:]]/d' "$kitty"
fi
if [[ -f $foot ]]; then
  sed --follow-symlinks -i 's/^\(font=[^:]*\):size=[0-9.]*/\1/' "$foot"
fi
# Drop the shared size only when Alacritty will actually load the overlay.
# A [general] import array counts; a file we could not edit keeps its size.
if [[ -f $alacritty ]] && omarchy-font-size --query alacritty-import; then
  sed --follow-symlinks -i '/^[[:space:]]*size[[:space:]]*=/d' "$alacritty"
fi
