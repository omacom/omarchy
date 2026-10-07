echo "Enable overlay scrollbars in Chromium-based browsers"

add_overlay_scrollbars() {
  local file=$1

  [[ -f $file ]] || return 0
  grep -Eq -- '^--enable-features=([^,]+,)*OverlayScrollbar([,:]|$)' "$file" && return 0

  if grep -q -- '^--enable-features=.' "$file"; then
    sed -i --follow-symlinks \
      '0,/^--enable-features=./ s/^\(--enable-features=.*\)$/\1,OverlayScrollbar/' "$file"
  elif grep -q -- '^--enable-features=$' "$file"; then
    sed -i --follow-symlinks \
      '0,/^--enable-features=$/ s/^--enable-features=$/--enable-features=OverlayScrollbar/' "$file"
  else
    [[ -n $(tail -c1 "$file") ]] && echo >>"$file"
    echo '--enable-features=OverlayScrollbar' >>"$file"
  fi
}

for flags_file in "$HOME"/.config/{chromium,chrome,microsoft-edge-stable,brave,brave-origin}-flags.conf; do
  add_overlay_scrollbars "$flags_file"
done
