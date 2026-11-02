#!/usr/bin/python3

import base64
import os
from pathlib import Path
import re
import struct
import subprocess
import sys
import tempfile
import threading

import gi

gi.require_version("Gio", "2.0")
from gi.repository import Gio, GLib

helper = sys.argv[1]
executable = os.readlink("/proc/self/exe")
bus = Gio.bus_get_sync(Gio.BusType.SESSION, None)
loop = GLib.MainLoop()
thread = threading.Thread(target=loop.run, daemon=True)
thread.start()
records = []
held = []
mode = "ack"


def method(connection, sender, path, interface, name, params, invocation):
  raw = bytes(params.unpack()[0])
  count = struct.unpack_from("<I", raw)[0]
  offsets = struct.unpack_from("<%dI" % count, raw, 4)
  cwd = raw[4 * (count + 1):offsets[0] - 1]
  args = [raw[offset:raw.index(0, offset)] for offset in offsets]
  records.append((cwd, args))
  if mode == "hold":
    held.append(invocation)
  elif mode == "reject":
    invocation.return_dbus_error("org.freedesktop.DBus.Error.InvalidArgs", "Rejected")
  else:
    invocation.return_value(GLib.Variant("()", ()))


info = Gio.DBusNodeInfo.new_for_xml('''
<node><interface name="org.mozilla.zen">
<method name="OpenURL"><arg name="commandline" type="ay" direction="in"/></method>
</interface></node>
''').interfaces[0]
bus.register_object("/org/mozilla/zen/Remote", info, method, None, None)


def own(profile):
  encoded = base64.b64encode(os.fsencode(profile)).decode()
  name = ("org.mozilla.zen." + re.sub("[^A-Za-z0-9_]", "_", encoded))[:255]
  result = bus.call_sync("org.freedesktop.DBus", "/org/freedesktop/DBus",
    "org.freedesktop.DBus", "RequestName", GLib.Variant("(su)", (name, 0)),
    GLib.VariantType("(u)"), Gio.DBusCallFlags.NONE, 1000, None)
  assert result.unpack()[0] == 1
  return name


with tempfile.TemporaryDirectory(prefix="omarchy-zen-handoff.") as temporary:
  home = Path(temporary)
  legacy = home / ".zen"
  config = home / "custom-config"
  modern = config / "zen"
  profile_name = "a%✓.Default (release)"
  environment = {k: v for k, v in os.environ.items()
    if not k.startswith(("MOZ_", "XRE_PROFILE_"))}
  environment.update(HOME=str(home), XDG_CONFIG_HOME=str(config),
    XDG_ACTIVATION_TOKEN="activation token ✓", DESKTOP_STARTUP_ID="older token")
  cwd = home / "working directory ✓"
  cwd.mkdir()

  def registry(root):
    profile = root / profile_name
    profile.mkdir(parents=True)
    text = ("[General]\nStartWithLastProfile=1\n[Profile0]\n"
      "Name=Default\nIsRelative=1\nPath=%s\n[InstallTEST]\nDefault=%s\n" %
      (profile_name, profile_name))
    (root / "profiles.ini").write_text(text)
    return text

  legacy_ini = registry(legacy)
  modern_ini = registry(modern)
  legacy_name = own(legacy / profile_name)

  def run(*arguments, expected=0, binary=executable, overrides=None):
    env = environment | (overrides or {})
    result = subprocess.run([helper, binary, *arguments], cwd=cwd, env=env,
      capture_output=True, text=True, timeout=5)
    assert result.returncode == expected, (arguments, result.returncode, result.stderr)

  url = 'https://example.test/a b?q="comma,quote"&unicode=✓'
  run("--new-window", url)
  assert records[-1] == (os.fsencode(cwd), [
    os.fsencode(executable + " STARTUP_TOKEN=activation token ✓"),
    b"--new-window", url.encode()])
  print("ok - Zen handoff preserves Mozilla's byte protocol, cwd, arguments, and activation token")

  # Legacy configuration wins even when an XDG profile also exists.
  assert len(records) == 1
  legacy.rename(home / "legacy-saved")
  own(modern / profile_name)
  run("--private-window", url, overrides={"XDG_ACTIVATION_TOKEN": ""})
  assert records[-1][1] == [os.fsencode(executable + " STARTUP_TOKEN=older token"),
    b"--private-window", url.encode()]
  (home / "legacy-saved").rename(legacy)
  print("ok - Zen handoff supports XDG and legacy profiles and preserves private-window arguments")

  count = len(records)
  for arguments in [("--profile", "/elsewhere"), ("-P", "Work"),
      ("--ProfileManager",), ("--no-remote",), ("--new-instance",),
      ("--headless",), ("--safe-mode",), ("--version",), ("---new-window",)]:
    run(*arguments, expected=1)
  for variable in ["MOZ_NEW_INSTANCE", "MOZ_NO_REMOTE", "XRE_PROFILE_PATH",
      "XRE_PROFILE_LOCAL_PATH", "MOZ_LEGACY_PROFILES", "MOZ_APP_REMOTINGNAME"]:
    run(url, expected=1, overrides={variable: "/elsewhere"})
  assert len(records) == count
  print("ok - explicit profiles, process flags, and profile environment overrides stay with Zen")

  ini = legacy / "profiles.ini"
  for content in [legacy_ini.replace("StartWithLastProfile=1", "StartWithLastProfile=0"),
      legacy_ini + "[Profile1]\nPath=another-profile\n",
      legacy_ini.replace("Default=" + profile_name, "Default=another-profile"),
      "[malformed"]:
    ini.write_text(content)
    run(url, expected=1)
  ini.write_text(legacy_ini)
  assert len(records) == count
  print("ok - ambiguous or malformed profile selection falls back without sending a command")

  run(url, expected=1, binary="/opt/zen-browser-bin/zen-bin")
  assert len(records) == count
  print("ok - a D-Bus service owned by another executable cannot receive the launch")

  mode = "reject"
  run(url, expected=1)
  mode = "hold"
  run(url)
  assert len(held) == 1
  print("ok - a rejected call falls back, but a pending timed-out call is not replayed")

  bus.call_sync("org.freedesktop.DBus", "/org/freedesktop/DBus",
    "org.freedesktop.DBus", "ReleaseName", GLib.Variant("(s)", (legacy_name,)),
    GLib.VariantType("(u)"), Gio.DBusCallFlags.NONE, 1000, None)
  count = len(records)
  run(url, expected=1)
  assert len(records) == count
  print("ok - an absent browser falls back without activating a D-Bus service")

loop.quit()
thread.join(timeout=2)
