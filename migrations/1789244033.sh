echo "Enable two-finger swipe back/forward in Nautilus"

OMARCHY_PATH="${OMARCHY_PATH:-/usr/share/omarchy}"
src="$OMARCHY_PATH/default/nautilus-python/extensions/swipe_navigation.py"
dst_dir="$HOME/.local/share/nautilus-python/extensions"

if [[ -f $src ]]; then
  mkdir -p "$dst_dir"
  cp "$src" "$dst_dir/swipe_navigation.py"
fi
