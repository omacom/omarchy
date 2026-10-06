echo "Rewrite the font override that captured every family named *mono*"

# `omarchy font set` wrote the chosen family as a prepend_first edit on any
# pattern carrying the monospace generic. /etc/fonts/conf.d/48-guessfamily.conf
# appends that generic to every pattern whose family name merely contains
# "mono", so the edit fired for a request naming Liberation Mono as readily as
# for one naming monospace, and put the chosen family at the head of the list,
# ahead of the family the application actually asked for. The previous
# migration moved that override into conf.d unchanged. Restate it as the alias
# it should have been, which inserts the family at the generic instead.

dropin_file="$HOME/.config/fontconfig/conf.d/50-omarchy-monospace.conf"

[[ -f $dropin_file ]] || exit 0

font_name=$(sed -n '/mode="prepend_first"/{n;s#^ *<string>\(.*\)</string> *$#\1#p;}' "$dropin_file")

[[ -n $font_name ]] || exit 0

previous_override() {
  cat <<XML
<?xml version="1.0"?>
<!DOCTYPE fontconfig SYSTEM "fonts.dtd">
<fontconfig>
  <match target="pattern">
    <test name="family" qual="any">
      <string>monospace</string>
    </test>
    <edit name="family" mode="prepend_first" binding="strong">
      <string>$font_name</string>
    </edit>
  </match>
</fontconfig>
XML
}

# The whole file has to be what Omarchy wrote, so an override someone has
# edited by hand is left as it is rather than silently replaced.
[[ $(<"$dropin_file") == "$(previous_override)" ]] || exit 0

temporary=$(mktemp "${dropin_file%/*}/.50-omarchy-monospace.conf.XXXXXX") || exit 1
chmod --reference="$dropin_file" "$temporary" || { rm -f "$temporary"; exit 1; }
cat >"$temporary" <<XML
<?xml version="1.0"?>
<!DOCTYPE fontconfig SYSTEM "fonts.dtd">
<fontconfig>
  <alias binding="strong">
    <family>monospace</family>
    <prefer>
      <family>$font_name</family>
    </prefer>
  </alias>
</fontconfig>
XML
mv -fT "$temporary" "$dropin_file" || { rm -f "$temporary"; exit 1; }
