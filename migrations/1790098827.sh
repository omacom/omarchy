echo "Move user monospace fontconfig override to conf.d drop-in"

legacy_fonts_conf="$HOME/.config/fontconfig/fonts.conf"
dropin_dir="$HOME/.config/fontconfig/conf.d"
dropin_file="$dropin_dir/50-omarchy-monospace.conf"

is_pure_omarchy_fontconfig() {
  local file="$1"
  [[ -f $file ]] || return 1
  local stripped
  stripped=$(sed -E \
    -e 's/<!--([^-]|-[^-])*-->//g' \
    -e 's/<\?xml[^>]*\?>//g' \
    -e 's/<!DOCTYPE[^>]*>//g' \
    -e 's/<\/?fontconfig[^>]*>//g' \
    "$file" | tr -s '[:space:]' ' ' | sed -E 's/ *([<>=]) */\1/g')

  # Whitespace inside a value is kept: a family named "mono space" is not monospace.
  local pattern='^<match target="pattern"><test name="family" qual="any"><string>monospace</string></test><edit name="family" mode="prepend_first" binding="strong"><string>[^<]+</string></edit></match>$'
  [[ $stripped =~ $pattern ]]
}

if [[ -f $legacy_fonts_conf ]] && is_pure_omarchy_fontconfig "$legacy_fonts_conf"; then
  if [[ ! -f $dropin_file ]]; then
    mkdir -p "$dropin_dir"
    temporary=$(mktemp "$dropin_dir/.50-omarchy-monospace.conf.XXXXXX")
    if cp "$legacy_fonts_conf" "$temporary" && mv -T "$temporary" "$dropin_file"; then
      :
    else
      rm -f "$temporary"
      exit 1
    fi
  fi
  rm -f "$legacy_fonts_conf"
fi
