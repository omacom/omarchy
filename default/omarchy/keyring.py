"""Native GNOME keyring enrollment. Passwords never pass through this process."""

import argparse
import os
from pathlib import Path
import re
import sys

from gi.repository import Gio, GLib


SERVICE = "org.freedesktop.secrets"
ROOT = "/org/freedesktop/secrets"
SERVICE_INTERFACE = "org.freedesktop.Secret.Service"
COLLECTION = "org.freedesktop.Secret.Collection"
PROMPT = "org.freedesktop.Secret.Prompt"
INTERNAL = "org.gnome.keyring.InternalUnsupportedGuiltRiddenInterface"
LEGACY = ROOT + "/collection/Default_5fkeyring"
ENCRYPTED_HEADER = b"GnomeKeyring\n\r\0\n"
PROMPT_TIMEOUT_SECONDS = 120


class EnrollmentError(Exception):
  pass


def keyring_directory():
  directory = Path(os.environ.get("XDG_DATA_HOME", str(Path.home() / ".local/share"))) / "keyrings"
  old = Path.home() / ".gnome2/keyrings"
  return old if not directory.is_dir() and old.is_dir() else directory


def storage_format(path):
  # Read only the format header, never stored item values or their attributes.
  if not path.exists():
    return "missing"
  with path.open("rb") as source:
    header = source.read(16)
  if header.startswith(ENCRYPTED_HEADER):
    return "encrypted"
  if header.startswith(b"[keyring]\n"):
    return "plaintext"
  return "unknown"


def collection_file(directory, collection):
  prefix = ROOT + "/collection/"
  if not collection.startswith(prefix):
    raise EnrollmentError("Unsupported keyring collection; no collection was replaced.")
  encoded = collection[len(prefix):].encode("ascii")
  identifier = re.sub(rb"_([0-9a-fA-F]{2})", lambda match: bytes([int(match[1], 16)]), encoded).decode("utf-8")
  if not identifier or identifier in (".", "..", "session") or any(c in identifier for c in ("/", "\\", "\0")):
    raise EnrollmentError("Unsupported persistent keyring identifier.")
  return directory / (identifier + ".keyring")


class NativeKeyring:
  def __init__(self):
    self.bus = Gio.bus_get_sync(Gio.BusType.SESSION, None)

  def call(self, path, interface, method, signature=None, args=(), timeout=10000):
    parameters = GLib.Variant(signature, args) if signature else None
    return self.bus.call_sync(SERVICE, path, interface, method, parameters,
                              None, Gio.DBusCallFlags.NONE, timeout, None).unpack()

  def alias(self):
    return self.call(ROOT, SERVICE_INTERFACE, "ReadAlias", "(s)", ("default",))[0]

  def items(self, collection):
    return set(self.call(collection, "org.freedesktop.DBus.Properties", "Get", "(ss)",
                         (COLLECTION, "Items"))[0])

  def prompt(self, path):
    if path == "/":
      return None
    loop = GLib.MainLoop()
    outcome = {}

    def completed(_connection, _sender, _path, _interface, _signal, parameters):
      dismissed, result = parameters.unpack()
      outcome.update(dismissed=dismissed, result=result)
      loop.quit()

    def expired():
      outcome["timeout"] = True
      try:
        self.call(path, PROMPT, "Dismiss", timeout=1000)
      except GLib.Error:
        pass
      loop.quit()
      return GLib.SOURCE_REMOVE

    # Completed is directed at this caller; keep the same connection from
    # ChangeWithPrompt/CreateCollection through subscription and completion.
    subscription = self.bus.signal_subscribe(SERVICE, PROMPT, "Completed", path,
                                              None, Gio.DBusSignalFlags.NONE, completed)
    timer = GLib.timeout_add_seconds(PROMPT_TIMEOUT_SECONDS, expired)
    try:
      self.call(path, PROMPT, "Prompt", "(s)", ("",))
      if not outcome:
        loop.run()
      if outcome.get("timeout"):
        raise EnrollmentError("Keyring setup timed out; rerun omarchy-setup-security-keyring in your desktop session.")
      if outcome.get("dismissed", True):
        raise EnrollmentError("Keyring setup was cancelled; encryption setup remains pending.")
      return outcome.get("result")
    finally:
      self.bus.signal_unsubscribe(subscription)
      if not outcome.get("timeout"):
        GLib.source_remove(timer)

  def encrypt(self, collection, directory):
    path = collection_file(directory, collection)
    before_alias = self.alias()
    before_items = self.items(collection)
    print("For an unencrypted keyring, leave the OLD password empty; choose a nonempty NEW password.", flush=True)
    prompt = self.call(ROOT, INTERNAL, "ChangeWithPrompt", "(o)", (collection,))[0]
    self.prompt(prompt)
    if storage_format(path) != "encrypted":
      raise EnrollmentError("Keyring is still unencrypted. Rerun setup and choose a nonempty password.")
    # Native GNOME changes the master password in place. Do not rename files,
    # copy secrets, delete the collection, or switch the user's default alias.
    if self.alias() != before_alias or not before_items.issubset(self.items(collection)):
      raise EnrollmentError("Keyring metadata changed during setup; review it before rerunning the migration.")

  def create(self, directory):
    # GNOME derives the collection identifier from this label. Lowercase login
    # is the collection PAM can subsequently unlock with the login password.
    collection, prompt = self.call(ROOT, SERVICE_INTERFACE, "CreateCollection", "(a{sv}s)",
                                   ({COLLECTION + ".Label": GLib.Variant("s", "login")}, "default"))
    if prompt != "/":
      collection = self.prompt(prompt)
    if not collection or collection == "/" or self.alias() != collection:
      raise EnrollmentError("GNOME did not create a default keyring; setup remains pending.")
    if storage_format(collection_file(directory, collection)) != "encrypted":
      raise EnrollmentError("Keyring is still unencrypted. Rerun setup and choose a nonempty password.")
    return collection

  def unlock(self, collection):
    _unlocked, prompt = self.call(ROOT, SERVICE_INTERFACE, "Unlock", "(ao)", ([collection],))
    self.prompt(prompt)
    locked = self.call(collection, "org.freedesktop.DBus.Properties", "Get", "(ss)",
                       (COLLECTION, "Locked"))[0]
    if locked:
      raise EnrollmentError("Keyring remains locked; rerun setup in your desktop session.")


def enroll(migrate=False):
  directory = keyring_directory()
  legacy_format = storage_format(directory / "Default_keyring.keyring")
  if migrate and legacy_format in ("missing", "encrypted"):
    print("Legacy keyring encryption needs no change.")
    return
  if migrate and legacy_format != "plaintext":
    raise EnrollmentError("Legacy keyring format is unrecognized; review it manually. No collection was replaced.")
  if not os.environ.get("DBUS_SESSION_BUS_ADDRESS") or not (os.environ.get("WAYLAND_DISPLAY") or os.environ.get("DISPLAY")):
    raise EnrollmentError("A graphical desktop session is required. Run omarchy-setup-security-keyring there, then rerun omarchy-migrate. Encryption setup remains pending.")
  print("Use GNOME's password dialog to protect your application keyring. Choose a nonempty password.", flush=True)
  native = NativeKeyring()
  if legacy_format == "plaintext":
    native.encrypt(LEGACY, directory)
  if not migrate:
    collection = native.alias()
    if collection == "/":
      collection = native.create(directory)
    else:
      form = storage_format(collection_file(directory, collection))
      if form == "plaintext":
        native.encrypt(collection, directory)
      elif form != "encrypted":
        raise EnrollmentError("Default keyring storage cannot be verified; no collection was replaced.")
    native.unlock(collection)
  print("Application keyring encryption is configured.")


def main():
  parser = argparse.ArgumentParser(description=__doc__)
  parser.add_argument("--migrate", action="store_true", help="encrypt only the legacy Omarchy keyring, preserving its alias and items")
  args = parser.parse_args()
  try:
    enroll(args.migrate)
  except (EnrollmentError, GLib.Error, OSError, UnicodeError) as error:
    print(f"Keyring setup incomplete: {error}", file=sys.stderr)
    return 1
  return 0


if __name__ == "__main__":
  sys.exit(main())
