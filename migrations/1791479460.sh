echo "Move user monospace fontconfig override to conf.d drop-in"

legacy_fonts_conf="$HOME/.config/fontconfig/fonts.conf"
dropin_dir="$HOME/.config/fontconfig/conf.d"
dropin_file="$dropin_dir/50-omarchy-monospace.conf"

is_pure_omarchy_fontconfig() {
  local file="$1"
  [[ -f $file ]] || return 1
  # XML declarations are harmless, but processing instructions are user/tool
  # content. In particular, the normalization below must not erase xml-stylesheet.
  python3 - "$file" <<'PYTHON' || return 1
from pathlib import Path
import sys
from xml.parsers import expat

def reject(*args):
  raise ValueError('custom XML content')

try:
  parser = expat.ParserCreate()
  parser.ProcessingInstructionHandler = reject
  parser.EntityDeclHandler = reject
  parser.Parse(Path(sys.argv[1]).read_bytes(), True)
except (OSError, ValueError, expat.ExpatError):
  sys.exit(1)
PYTHON
  local stripped
  stripped=$(sed -E \
    -e 's/<!--([^-]|-[^-])*-->//g' \
    -e 's/<\?xml[^>]*\?>//g' \
    -e 's/<!DOCTYPE[^>]*>//g' \
    -e 's/<\/?fontconfig[^>]*>//g' \
    "$file" | tr -s '[:space:]' ' ' | sed -E 's/> </></g; s/ *= */=/g; s/ +>/>/g; s/^ //; s/ $//')

  # Only whitespace between and inside tags goes: " monospace " and "mono space" are other families.
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
