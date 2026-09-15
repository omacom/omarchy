#!/usr/bin/env python3
"""Private JSON command dispatcher used by the supervised native plugin."""
from pathlib import Path
import json
import sys

# Omarchy watches the plugin tree for changes. Runtime bytecode caches would
# look like source edits and repeatedly reload the shell when the helper runs.
sys.dont_write_bytecode = True

if __package__ in (None, ""):
  sys.path.insert(0, str(Path(__file__).resolve().parent.parent))

from backend.catalog import Catalog, SettingsError, SHORTCUTS
from backend.session import Hyprland, Session


def dispatch(action, request):
  """Run one validated action and return its JSON-serializable data."""
  if not isinstance(request, dict):
    raise SettingsError("Invalid request.")
  if action == "catalog":
    return {"layouts": Catalog().layouts,
        "shortcuts": [{"value": key, "label": value[0]}
               for key, value in SHORTCUTS.items()]}
  if action == "animations":
    return {"enabled": Hyprland().animations()}

  session = Session()
  session.recover_pending()
  if action == "status":
    return session.status(request.get("eventDevice", ""))
  if action == "choose":
    return session.choose(request["device"], request["revision"])
  if action == "switch":
    return session.switch(request["index"], request["revision"])
  if action == "save":
    return session.save(request["layouts"], request["shortcut"], request["revision"],
              request.get("eventDevice", ""), request.get("expectedActiveId"))
  raise SettingsError("Unknown request.")


def response(action, request):
  """Mirror the established domain-error response without leaking internals."""
  try:
    return {"ok": True, "data": dispatch(action, request)}
  except (SettingsError, ValueError, KeyError, OSError) as exc:
    message = (str(exc) if isinstance(exc, SettingsError) else
         "Keyboard settings could not complete the request. "
         "Your recovery record has been retained.")
    return {"ok": False, "error": message}


def parse_request(arguments):
  action = arguments[0] if arguments else "status"
  request = json.loads(arguments[1]) if len(arguments) > 1 else {}
  return action, request


def main(arguments=None):
  arguments = sys.argv[1:] if arguments is None else arguments
  try:
    action, request = parse_request(arguments)
    value = response(action, request)
  except (ValueError, UnicodeError):
    value = {"ok": False, "error":
        "Keyboard settings could not complete the request. "
        "Your recovery record has been retained."}
  print(json.dumps(value, ensure_ascii=False))
  return 0 if value.get("ok") else 1


if __name__ == "__main__":
  raise SystemExit(main())
