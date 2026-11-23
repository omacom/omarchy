echo "Move terminal font size into per-machine overlay files"

config_home="${XDG_CONFIG_HOME:-$HOME/.config}"
ghostty="$config_home/ghostty/config"
kitty="$config_home/kitty/kitty.conf"
foot="$config_home/foot/foot.ini"
alacritty="$config_home/alacritty/alacritty.toml"

# Each terminal keeps its own size. A missing size is left alone; a value that
# is not a number becomes 9 inside omarchy-font-size --read-shared, and this
# migration keeps going so later ones are not stuck.
#
# The upgrade copies the new overlay files, which ship at size 9, before this
# runs. --read would then report that 9 and throw away the size still in the
# shared config. The size being moved is the shared one. An overlay that
# already has its own size is left alone. One that is missing, still the
# packaged file, or present with other settings and no size gets the shared
# size. A stock Foot overlay names JetBrainsMono at size 9, and Foot's later
# font= replaces the shared line, so that file is rewritten from the shared
# family even when the shared line has no size.
OMARCHY_PATH="${OMARCHY_PATH:-/usr/share/omarchy}"

overlay_path() {
  case $1 in
    ghostty) printf '%s\n' "$config_home/ghostty/local" ;;
    kitty) printf '%s\n' "$config_home/kitty/local.conf" ;;
    foot) printf '%s\n' "$config_home/foot/local.ini" ;;
    alacritty) printf '%s\n' "$config_home/alacritty/local.toml" ;;
  esac
}

stock_overlay_path() {
  case $1 in
    ghostty) printf '%s\n' "$OMARCHY_PATH/config/ghostty/local" ;;
    kitty) printf '%s\n' "$OMARCHY_PATH/config/kitty/local.conf" ;;
    foot) printf '%s\n' "$OMARCHY_PATH/config/foot/local.ini" ;;
    alacritty) printf '%s\n' "$OMARCHY_PATH/config/alacritty/local.toml" ;;
  esac
}

overlay_is_stock() {
  local overlay stock
  overlay=$(overlay_path "$1")
  stock=$(stock_overlay_path "$1")
  [[ -f $overlay && -f $stock ]] && cmp -s "$overlay" "$stock"
}

overlay_has_size() {
  local overlay
  overlay=$(overlay_path "$1")
  [[ -f $overlay ]] || return 1
  case $1 in
    ghostty) grep -qE '^[[:space:]]*font-size[[:space:]]*=' "$overlay" ;;
    kitty) grep -qE '^[[:space:]]*font_size[[:space:]]' "$overlay" ;;
    foot) grep -qE '^[[:space:]]*font[[:space:]]*=[^,]*:size=[0-9.]' "$overlay" ;;
    alacritty) grep -qE '^[[:space:]]*size[[:space:]]*=' "$overlay" ;;
  esac
}

apply_terminal() {
  local term="$1" size
  size=$(omarchy-font-size --read-shared "$term")
  # A size already on a file the user changed wins. Stock still loses,
  # because its size is the packaged 9, not one the user chose.
  if overlay_has_size "$term" && ! overlay_is_stock "$term"; then
    return 0
  fi
  if [[ -z $size ]]; then
    if [[ $term == foot ]] && overlay_is_stock "$term"; then
      size=9
    else
      return 0
    fi
  fi
  omarchy-font-size --quiet --only "$term" "$size"
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
  # Only the primary font's size moves. A comma starts a fallback, and
  # matching through the first colon would strip that fallback's size on a
  # second run, once the primary size is already gone.
  sed --follow-symlinks -i 's/^\(font=[^:,]*\):size=[0-9.]*/\1/' "$foot"
fi
# Drop the shared size only when Alacritty will actually load the overlay.
# A [general] import array counts; a file we could not edit keeps its size.
if [[ -f $alacritty ]] && omarchy-font-size --query alacritty-import; then
  sed --follow-symlinks -i '/^[[:space:]]*size[[:space:]]*=/d' "$alacritty"
fi
