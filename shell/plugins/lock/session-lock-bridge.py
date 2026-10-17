"""Publish Omarchy's confirmed session-lock state to desktop applications."""

import os
import sys

from gi.repository import Gio, GLib

# ScreenSaver is the desktop compatibility protocol for session-lock notifications.
BUS_NAME = "org.freedesktop.ScreenSaver"
OBJECT_PATH = "/org/freedesktop/ScreenSaver"
REQUEST_NAME_DO_NOT_QUEUE = 4
REQUEST_NAME_PRIMARY_OWNER = 1
INTERFACE_XML = """
<node>
  <interface name="org.freedesktop.ScreenSaver">
    <method name="GetActive">
      <arg type="b" direction="out"/>
    </method>
    <signal name="ActiveChanged">
      <arg type="b"/>
    </signal>
  </interface>
</node>
"""


class SessionLockBridge:
  def __init__(self, connection, main_loop):
    self.connection = connection
    self.main_loop = main_loop
    self.is_locked = False
    self.input_buffer = b""
    self.exit_code = 0

  def handle_get_active(
    self, connection, sender, path, interface, method, parameters, invocation
  ):
    invocation.return_value(GLib.Variant("(b)", (self.is_locked,)))

  def publish_lock_state(self, is_locked):
    if is_locked == self.is_locked:
      return
    self.is_locked = is_locked
    self.connection.emit_signal(
      None,
      OBJECT_PATH,
      BUS_NAME,
      "ActiveChanged",
      GLib.Variant("(b)", (is_locked,)),
    )

  def stop_with_error(self, message):
    print(f"omarchy session-lock bridge: {message}", file=sys.stderr)
    self.exit_code = 1
    self.main_loop.quit()

  def on_bus_closed(self, connection, remote_peer_vanished, error):
    self.stop_with_error("session bus connection closed")

  def read_lock_state(self, fd, condition):
    try:
      data = os.read(fd, 4096)
    except OSError as error:
      self.stop_with_error(f"cannot read lock state: {error}")
      return False
    if not data:
      # A dying lock client leaves Wayland's failsafe locked, not unlocked.
      self.main_loop.quit()
      return False
    self.input_buffer += data
    while b"\n" in self.input_buffer:
      lock_state, self.input_buffer = self.input_buffer.split(b"\n", 1)
      if lock_state not in (b"true", b"false"):
        self.stop_with_error("invalid lock state")
        return False
      try:
        self.publish_lock_state(lock_state == b"true")
      except GLib.Error as error:
        self.stop_with_error(f"cannot publish lock state: {error.message}")
        return False
    return True


def request_bus_name(connection):
  # Do not replace or queue behind another desktop's screensaver service.
  reply = connection.call_sync(
    "org.freedesktop.DBus",
    "/org/freedesktop/DBus",
    "org.freedesktop.DBus",
    "RequestName",
    GLib.Variant("(su)", (BUS_NAME, REQUEST_NAME_DO_NOT_QUEUE)),
    GLib.VariantType.new("(u)"),
    Gio.DBusCallFlags.NONE,
    2000,
    None,
  )
  return reply.unpack()[0] == REQUEST_NAME_PRIMARY_OWNER


def main():
  connection = Gio.bus_get_sync(Gio.BusType.SESSION, None)
  connection.set_exit_on_close(False)
  main_loop = GLib.MainLoop()
  bridge = SessionLockBridge(connection, main_loop)
  node = Gio.DBusNodeInfo.new_for_xml(INTERFACE_XML)
  registration_id = connection.register_object_with_closures2(
    OBJECT_PATH,
    node.interfaces[0],
    bridge.handle_get_active,
    None,
    None,
  )
  bus_closed_handler = connection.connect("closed", bridge.on_bus_closed)
  try:
    if not request_bus_name(connection):
      return 0
    GLib.io_add_watch(
      sys.stdin.fileno(), GLib.IO_IN | GLib.IO_HUP, bridge.read_lock_state
    )
    print("ready", flush=True)
    main_loop.run()
  finally:
    connection.disconnect(bus_closed_handler)
    connection.unregister_object(registration_id)
    if not connection.is_closed():
      connection.flush_sync(None)
      connection.close_sync(None)
  return bridge.exit_code


if __name__ == "__main__":
  raise SystemExit(main())
