echo "Enable overlay scrollbars in Chromium-based browsers"

for flags_file in "$HOME"/.config/{chromium,chrome,microsoft-edge-stable,brave,brave-origin}-flags.conf; do
  [[ -f $flags_file ]] || continue
  grep -Eq -- '^--enable-features=([^,]+,)*OverlayScrollbar([,:]|$)' "$flags_file" && continue

  if grep -q -- '^--enable-features=' "$flags_file"; then
    sed -i --follow-symlinks \
      -e '/^--enable-features=/ s/$/,OverlayScrollbar/' \
      -e '/^--enable-features=/ s/=,/=/' "$flags_file"
  else
    [[ -n $(tail -c1 "$flags_file") ]] && echo >>"$flags_file"
    echo '--enable-features=OverlayScrollbar' >>"$flags_file"
  fi
done
