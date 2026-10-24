echo "Restore Caps Lock in legacy personal keyboard options"

# #14939 changed the defaults, but a copied personal kb_options still wins.
# Only migrate the old default pair; a standalone Compose remap is intentional.
python3 - <<'PYTHON'
import re
import shutil
from pathlib import Path

path = Path.home() / ".config/hypr/input.lua"
if not path.is_file():
  raise SystemExit(0)

# Lua accepts any bytes in comments, so an odd encoding must not stall the queue.
original = path.read_text(errors="surrogateescape")

def migrate(match):
  options = [option.strip() for option in match[3].split(",")]
  if "compose:caps" not in options or "shift:both_capslock_cancel" not in options:
    return match[0]
  options = [option for option in options if option != "shift:both_capslock_cancel"]
  options = ["omarchy:shift_caps_compose" if option == "compose:caps" else option for option in options]
  return match[1] + match[2] + ",".join(options) + match[2]

updated = re.sub(r"(?m)^([ \t]*kb_options[ \t]*=[ \t]*)([\"'])([^\"'\n]*)\2", migrate, original)
if updated != original:
  backup = path.with_name(path.name + ".before-caps-lock-migration")
  if backup.exists():
    if backup.read_bytes() != path.read_bytes():
      raise SystemExit(f"Backup differs from the current configuration: {backup}; review it before retrying.")
  else:
    shutil.copy2(path, backup)
  path.write_text(updated, errors="surrogateescape")
  print(f"Updated {path}; previous configuration saved to {backup}")
PYTHON
