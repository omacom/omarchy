echo "Move user monospace fontconfig override to conf.d drop-in"

legacy_fonts_conf="$HOME/.config/fontconfig/fonts.conf"
dropin_dir="$HOME/.config/fontconfig/conf.d"
dropin_file="$dropin_dir/50-omarchy-monospace.conf"

is_pure_omarchy_fontconfig() {
  local file="$1"
  [[ -f $file ]] || return 1
  local stripped
  stripped=$(sed -E \
    -e 's/<!--.*-->//g' \
    -e 's/<\?xml[^>]*\?>//g' \
    -e 's/<!DOCTYPE[^>]*>//g' \
    -e 's/<\/?fontconfig[^>]*>//g' \
    "$file" | tr -d '[:space:]')

  local pattern='^<matchtarget="pattern"><testname="family"qual="any"><string>monospace</string></test><editname="family"mode="prepend_first"binding="strong"><string>[^<]+</string></edit></match>$'
  [[ $stripped =~ $pattern ]]
}

if [[ -f $legacy_fonts_conf ]] && is_pure_omarchy_fontconfig "$legacy_fonts_conf"; then
  if [[ ! -f $dropin_file ]]; then
    mkdir -p "$dropin_dir"
    cp "$legacy_fonts_conf" "$dropin_file"
  fi
  rm -f "$legacy_fonts_conf"
fi
