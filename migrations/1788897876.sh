echo "Restore Ghostty's default scroll speed for discrete mouse wheels"

ghostty_config="$HOME/.config/ghostty/config"

[[ -f $ghostty_config ]] || exit 0
grep -qxF 'mouse-scroll-multiplier = 0.95' "$ghostty_config" || exit 0

# A bare multiplier applies to both device types, so the shipped 0.95 also
# overrode Ghostty's discrete default of 3 and made wheel clicks crawl.
sed -i \
  -e 's/^# Slowdown mouse scrolling$/# Slow down precise scrolling only. A bare value applies to both device types,\n# which would drop discrete wheel clicks from Ghostty'"'"'s default 3 to 0.95./' \
  -e 's/^mouse-scroll-multiplier = 0\.95$/mouse-scroll-multiplier = precision:0.95,discrete:3/' \
  "$ghostty_config"
