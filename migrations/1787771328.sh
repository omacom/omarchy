echo "Rewrite the font override that captured every family named *mono*"

# Match the generated block exactly; surrounding user rules and dotfile symlinks stay intact.
python3 - <<'PYTHON'
from pathlib import Path
import re

path = Path.home() / ".config/fontconfig/fonts.conf"
if not path.is_file():
  raise SystemExit(0)

data = path.read_bytes()
legacy = rb'''  <match target="pattern">
    <test name="family" qual="any">
      <string>monospace</string>
    </test>
    <edit name="family" mode="prepend_first" binding="strong">
      <string>(?P<font>[^<>\n]+)</string>
    </edit>
  </match>'''


def upgrade(match):
  if match.group("font") is None:
    return match.group(0)
  return b'''  <alias binding="strong">
    <family>Omarchy Fixed Pitch</family>
    <prefer>
      <family>''' + match.group("font") + b'''</family>
    </prefer>
  </alias>'''


# Consume comments as a whole so a commented-out example stays untouched.
updated = re.sub(rb"<!--.*?-->|" + legacy, upgrade, data, flags=re.DOTALL)
if updated != data:
  path.write_bytes(updated)
PYTHON
