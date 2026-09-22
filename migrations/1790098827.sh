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
    -e '/<\?xml[^>]*\?>/d' \
    -e '/<!DOCTYPE[^>]*>/d' \
    -e '/<\/?fontconfig>/d' \
    -e '/^[[:space:]]*$/d' \
    "$file")

  local expected_clean="<match target=\"pattern\"><test name=\"family\" qual=\"any\"><string>monospace</string></test><edit name=\"family\" mode=\"prepend_first\" binding=\"strong\"></edit></match>"
  expected_clean=$(printf "%s" "$expected_clean" | tr -d '[:space:]')
  local edit_stripped
  edit_stripped=$(printf "%s\n" "$stripped" | sed -E '/<string>.*<\/string>/ { /<string>monospace<\/string>/!d; }' | tr -d '[:space:]')

  [[ $edit_stripped == "$expected_clean" ]]
}

if [[ -f $legacy_fonts_conf ]] && is_pure_omarchy_fontconfig "$legacy_fonts_conf"; then
  if [[ ! -f $dropin_file ]]; then
    mkdir -p "$dropin_dir"
    cp "$legacy_fonts_conf" "$dropin_file"
  fi
  rm -f "$legacy_fonts_conf"
fi
