"""Replace Fcitx's ordinary input notices with the stock shell OSD."""

import json
import os
from pathlib import Path
import re

from gi.repository import Gio, GLib

from configure import atomic_write, read
from indicator import call, owner_environment, profile_path


def without_notices(text):
  section = re.search(r"(?ms)^\[Behavior\][ \t]*(?:\n|\Z)(.*?)(?=^\[|\Z)", text)
  if section is None:
    text = text.rstrip() + ("\n\n" if text.strip() else "") + "[Behavior]\n"
    return without_notices(text)
  body = section[1]
  for key in ("ShowInputMethodInformation", "showInputMethodInformationWhenFocusIn"):
    pattern = r"(?m)^[ \t]*" + key + r"[ \t]*=.*$"
    if re.search(pattern, body):
      body = re.sub(pattern, key + "=False", body)
    else:
      body = body.rstrip() + ("\n" if body.strip() else "") + key + "=False\n"
  prefix = text[:section.start(1)]
  if not prefix.endswith("\n"):
    prefix += "\n"
  return prefix + body + text[section.end(1):]


def migrate():
  config_home = Path(os.environ.get("XDG_CONFIG_HOME") or str(Path.home() / ".config"))
  shell = json.loads(read(config_home / "omarchy/shell.json") or "{}")
  # Cloning the OSD disables its source too. Preserve feedback for either
  # customization: an older clone does not have the new input listener.
  if "omarchy.osd" in shell.get("disabledPlugins", []):
    return
  bus = None
  try:
    bus = Gio.bus_get_sync(Gio.BusType.SESSION, None)
  except GLib.Error:
    pass
  owner = owner_environment(bus) if bus is not None else None
  path = Path(profile_path(owner)).with_name("config").resolve()
  original = read(path) if path.exists() else None
  if not atomic_write(path, without_notices(original or "")):
    return
  if bus is not None:
    try:
      call(bus, "ReloadConfig")
    except GLib.Error as error:
      if Gio.DBusError.get_remote_error(error) in (
          "org.freedesktop.DBus.Error.ServiceUnknown", "org.freedesktop.DBus.Error.NameHasNoOwner"):
        return
      # Keep the migration pending if a running daemon cannot reload. Retry
      # against the original file, without interrupting composition.
      if original is None:
        path.unlink()
      else:
        atomic_write(path, original)
      raise


if __name__ == "__main__":
  try:
    migrate()
  except (GLib.Error, OSError, ValueError) as error:
    raise SystemExit(f"Input notice migration failed: {error}")
