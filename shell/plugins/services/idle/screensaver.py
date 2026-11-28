#!/usr/bin/python3

# Owns org.freedesktop.ScreenSaver for the idle service, which runs it as a
# child and reads one JSON line per change in the outstanding inhibits.
# Browsers and players request idle inhibition over this D-Bus name
# (xdg-desktop-portal-gtk forwards the Inhibit portal here too), and QML has
# no way to export a D-Bus object of its own.
#
# Only ScreenSaver is owned. Chromium sends audio, downloads, and WebRTC to
# org.freedesktop.PowerManagement, which stays unowned so background music
# cannot pin the screensaver and lock off.

import json
import os
import random
import signal
import sys
import warnings

import gi

warnings.filterwarnings("ignore", message=".*register_object is deprecated.*")

gi.require_version("Gio", "2.0")
gi.require_version("GLibUnix", "2.0")
from gi.repository import Gio, GLib, GLibUnix  # noqa: E402

NAME = "org.freedesktop.ScreenSaver"

# Chromium, Chrome, Electron, Steam, and xdg-desktop-portal-gtk call the
# standard path; Firefox, Zen, and VLC call the legacy KDE path.
PATHS = ["/org/freedesktop/ScreenSaver", "/ScreenSaver"]

MAX_INHIBITORS = 256
MAX_TEXT = 4096
NO_SESSION_BUS_EXIT = 78

INTERFACE = Gio.DBusNodeInfo.new_for_xml("""
<node>
  <interface name="org.freedesktop.ScreenSaver">
    <method name="Inhibit">
      <arg name="application_name" type="s" direction="in"/>
      <arg name="reason_for_inhibit" type="s" direction="in"/>
      <arg name="cookie" type="u" direction="out"/>
    </method>
    <method name="UnInhibit">
      <arg name="cookie" type="u" direction="in"/>
    </method>
  </interface>
</node>
""").interfaces[0]

inhibitors = {}
# Random nonzero start keeps a stale cookie from before a restart from matching
# one handed out since, and avoids 0 (which xdg-desktop-portal-gtk skips on
# UnInhibit).
next_cookie = random.randint(1, 0x7FFFFFFF)
name_owned = False
main_loop = None


def publish():
  payload = {"inhibitors": [{"app": i["app"], "reason": i["reason"]} for i in inhibitors.values()]}
  try:
    print(json.dumps(payload), flush=True)
  except BrokenPipeError:
    devnull = os.open(os.devnull, os.O_WRONLY)
    os.dup2(devnull, sys.stdout.fileno())
    os.close(devnull)
    if main_loop is not None:
      main_loop.quit()
    return False
  return True


def allocate_cookie():
  global next_cookie
  while next_cookie in inhibitors or next_cookie == 0:
    next_cookie = next_cookie % 0xFFFFFFFF + 1
  cookie = next_cookie
  next_cookie = next_cookie % 0xFFFFFFFF + 1
  return cookie


def on_method_call(connection, sender, path, interface, method, params, invocation):
  if method == "Inhibit":
    if len(inhibitors) >= MAX_INHIBITORS:
      invocation.return_dbus_error(
        "org.freedesktop.DBus.Error.LimitsExceeded",
        "too many outstanding inhibits",
      )
      return
    app, reason = params.unpack()
    cookie = allocate_cookie()
    inhibitors[cookie] = {
      "app": str(app)[:MAX_TEXT],
      "reason": str(reason)[:MAX_TEXT],
      "owner": sender,
    }
    if not publish():
      del inhibitors[cookie]
      invocation.return_dbus_error(
        "org.freedesktop.DBus.Error.Failed",
        "idle service disconnected",
      )
      try:
        connection.flush_sync(None)
      except GLib.Error:
        pass
      return
    invocation.return_value(GLib.Variant("(u)", (cookie,)))
  elif method == "UnInhibit":
    (cookie,) = params.unpack()
    invocation.return_value(None)
    # Only the caller that took an inhibit can release it.
    if inhibitors.get(cookie, {}).get("owner") == sender:
      del inhibitors[cookie]
      publish()


# A caller that leaves the bus without UnInhibit, by crashing or quitting
# mid-video, releases everything it held. Only the unique name vanishing means
# it disconnected; dropping a well-known name (like an MPRIS name) leaves it
# connected and inhibiting.
def on_name_owner_changed(connection, sender, path, interface, signal_name, params):
  name, old_owner, new_owner = params.unpack()
  if name != old_owner or new_owner:
    return
  gone = [cookie for cookie, inhibitor in inhibitors.items() if inhibitor["owner"] == old_owner]
  for cookie in gone:
    del inhibitors[cookie]
  if gone:
    publish()


def on_name_acquired(connection, name):
  global name_owned
  name_owned = True


def on_name_lost(connection, name):
  global name_owned
  if name_owned:
    name_owned = False
    if inhibitors:
      inhibitors.clear()
      publish()


# The shell holds this pipe open for as long as it runs, so its closing means
# the shell is gone, however it went.
def on_stdin(fd, condition, loop):
  if condition & GLib.IOCondition.IN and not (condition & (GLib.IOCondition.HUP | GLib.IOCondition.ERR)):
    if os.read(fd, 4096):
      return GLib.SOURCE_CONTINUE
  loop.quit()
  return GLib.SOURCE_REMOVE


def main():
  global main_loop
  try:
    connection = Gio.bus_get_sync(Gio.BusType.SESSION, None)
  except GLib.Error:
    return NO_SESSION_BUS_EXIT

  loop = GLib.MainLoop()
  main_loop = loop

  for path in PATHS:
    connection.register_object(path, INTERFACE, on_method_call)
  connection.signal_subscribe(
    "org.freedesktop.DBus",
    "org.freedesktop.DBus",
    "NameOwnerChanged",
    "/org/freedesktop/DBus",
    None,
    Gio.DBusSignalFlags.NONE,
    on_name_owner_changed,
  )

  # Without DO_NOT_QUEUE a replacement shell restarting before the old helper
  # sees its pipe close queues for the name instead of failing to acquire it.
  Gio.bus_own_name_on_connection(
    connection,
    NAME,
    Gio.BusNameOwnerFlags.NONE,
    on_name_acquired,
    on_name_lost,
  )

  GLibUnix.fd_add_full(
    GLib.PRIORITY_DEFAULT,
    sys.stdin.fileno(),
    GLib.IOCondition.IN | GLib.IOCondition.HUP | GLib.IOCondition.ERR,
    on_stdin,
    loop,
  )
  GLibUnix.signal_add(GLib.PRIORITY_DEFAULT, signal.SIGTERM, lambda: (loop.quit(), GLib.SOURCE_REMOVE)[1])
  GLibUnix.signal_add(GLib.PRIORITY_DEFAULT, signal.SIGINT, lambda: (loop.quit(), GLib.SOURCE_REMOVE)[1])

  if not publish():
    return 0
  loop.run()
  return 0


if __name__ == "__main__":
  sys.exit(main())
