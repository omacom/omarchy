echo "Drop inert --load-extension flags from Google Chrome configs"

# Chrome 137+ ignores --load-extension in Google-branded builds. Fresh chrome
# installs omit the line; strip it from existing chrome/google-chrome flags so
# the dead switch is not left in place.
strip_chrome_load_extension() {
  local file=$1

  [[ -f $file ]] || return 0
  grep -q '^--load-extension=' "$file" || return 0

  sed -i --follow-symlinks '/^--load-extension=/d' "$file"
}

for conf in chrome google-chrome; do
  strip_chrome_load_extension "$HOME/.config/$conf-flags.conf"
done
