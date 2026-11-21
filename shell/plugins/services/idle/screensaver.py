#!/usr/bin/python3

# Owns org.freedesktop.ScreenSaver for the idle service, which runs it as a
# child and reads one JSON line per change in the outstanding inhibits. Browsers
# and players inhibit idle over this name (xdg-desktop-portal-gtk forwards the
# Inhibit portal to it too) rather than with a Wayland idle inhibitor, and
# QML has no way to export a D-Bus object of its own.
#
# Only ScreenSaver is owned. Chromium sends audio, downloads and WebRTC to
# org.freedesktop.PowerManagement, and owning that would keep the screen awake
# for background music.

import json
import os
import random
import sys

import gi

gi.require_version("Gio", "2.0")
gi.require_version("GLibUnix", "2.0")
from gi.repository import Gio, GLib, GLibUnix

NAME = "org.freedesktop.ScreenSaver"

# Chromium calls the long path, Firefox, Zen and VLC the short one.
PATHS = ["/org/freedesktop/ScreenSaver", "/ScreenSaver"]

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
# A random start keeps a cookie a client held before a restart from matching
# one handed out since.
next_cookie = random.randint(1, 0x7FFFFFFF)


def publish():
  print(json.dumps({"inhibitors": [{"app": i["app"], "reason": i["reason"]} for i in inhibitors.values()]}), flush=True)


def on_method_call(connection, sender, path, interface, method, params, invocation):
  global next_cookie

  if method == "Inhibit":
    app, reason = params.unpack()
    cookie = next_cookie
    next_cookie = next_cookie % 0xFFFFFFFF + 1
    inhibitors[cookie] = {"app": app, "reason": reason, "owner": sender}
    invocation.return_value(GLib.Variant("(u)", (cookie,)))
    publish()
  else:
    (cookie,) = params.unpack()
    invocation.return_value(None)
    # Only the caller that took an inhibit can release it.
    if inhibitors.get(cookie, {}).get("owner") == sender:
      del inhibitors[cookie]
      publish()


# A caller that leaves the bus without UnInhibit, by crashing or quitting
# mid-video, releases everything it held.
def on_name_owner_changed(connection, sender, path, interface, signal, params):
  name, old_owner, new_owner = params.unpack()
  if name != old_owner or new_owner:
    return
  gone = [cookie for cookie, inhibitor in inhibitors.items() if inhibitor["owner"] == old_owner]
  for cookie in gone:
    del inhibitors[cookie]
  if gone:
    publish()


# The shell holds this pipe open for as long as it runs, so its closing means
# the shell is gone, however it went.
def on_stdin(fd, condition, loop):
  if condition & GLib.IOCondition.IN and os.read(fd, 4096):
    return GLib.SOURCE_CONTINUE
  loop.quit()
  return GLib.SOURCE_REMOVE


def main():
  loop = GLib.MainLoop()
  connection = Gio.bus_get_sync(Gio.BusType.SESSION, None)

  for path in PATHS:
    connection.register_object(path, INTERFACE, on_method_call)
  connection.signal_subscribe(
    "org.freedesktop.DBus", "org.freedesktop.DBus", "NameOwnerChanged",
    "/org/freedesktop/DBus", None, Gio.DBusSignalFlags.NONE, on_name_owner_changed,
  )

  # Without DO_NOT_QUEUE a second shell, or this one restarting before the old
  # helper has seen its pipe close, waits in line for the name instead of
  # failing to get it.
  Gio.bus_own_name_on_connection(connection, NAME, Gio.BusNameOwnerFlags.NONE, None, None)

  GLibUnix.fd_add_full(GLib.PRIORITY_DEFAULT, sys.stdin.fileno(), GLib.IOCondition.IN | GLib.IOCondition.HUP, on_stdin, loop)

  publish()
  loop.run()


if __name__ == "__main__":
  main()
