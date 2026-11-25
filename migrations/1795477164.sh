echo "Restore Caps Lock in legacy personal keyboard options"

# #14939 changed the defaults, but a copied personal kb_options still wins.
# Only migrate the old default pair; a standalone Compose remap is intentional.
python3 - <<'PYTHON'
import os
import re
import shutil
import tempfile
from pathlib import Path

path = Path.home() / ".config/hypr/input.lua"
if not path.is_file():
  raise SystemExit(0)

# Lua accepts any bytes in comments, so an odd encoding must not stall the queue.
original_bytes = path.read_bytes()
original = original_bytes.decode(errors="surrogateescape")

def migrate(match):
  options = [option.strip() for option in match[3].split(",")]
  if "compose:caps" not in options or "shift:both_capslock_cancel" not in options:
    return match[0]
  options = [option for option in options if option != "shift:both_capslock_cancel"]
  options = ["omarchy:shift_caps_compose" if option == "compose:caps" else option for option in options]
  return match[1] + match[2] + ",".join(options) + match[2]

patterns = (
  r"(?m)^([ \t]*kb_options[ \t]*=[ \t]*)([\"'])([^\"'\n]*)\2",
  r"(?m)^([ \t]*hl\.config\(\{[^\n]*?\bkb_options[ \t]*=[ \t]*)([\"'])([^\"'\n]*)\2",
)
updated = original
for pattern in patterns:
  updated = re.sub(pattern, migrate, updated)
if updated == original:
  raise SystemExit(0)

if not Path("/etc/xkb/symbols/omarchy").is_file():
  print("Waiting for the omarchy-settings package that provides the Caps Lock XKB option")
  raise SystemExit(75)

target = path.resolve()
with tempfile.NamedTemporaryFile(dir=path.parent, prefix=path.name + ".before-caps-lock-", delete=False) as backup_file:
  backup = Path(backup_file.name)
  backup_file.write(original_bytes)

with tempfile.NamedTemporaryFile(dir=target.parent, prefix=".omarchy-caps-lock-", delete=False) as updated_file:
  replacement = Path(updated_file.name)
  try:
    updated_file.write(updated.encode(errors="surrogateescape"))
    updated_file.flush()
    shutil.copymode(target, replacement)
    os.replace(replacement, target)
  finally:
    replacement.unlink(missing_ok=True)

print(f"Updated {path}; previous configuration saved to {backup}")
PYTHON
