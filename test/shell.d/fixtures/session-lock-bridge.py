import os
import select
import subprocess
import sys
import time
from pathlib import Path

from gi.repository import Gio, GLib

BUS_NAME = "org.freedesktop.ScreenSaver"
OBJECT_PATH = "/org/freedesktop/ScreenSaver"
bridge_script = Path(os.environ["ROOT"]) / "shell/plugins/lock/session-lock-bridge.py"
connection = Gio.bus_get_sync(Gio.BusType.SESSION, None)
context = GLib.MainContext.default()
lock_events = []


def receive_lock_event(connection, sender, path, interface, member, parameters):
  lock_events.append(parameters.unpack()[0])


connection.signal_subscribe(
  BUS_NAME,
  BUS_NAME,
  "ActiveChanged",
  OBJECT_PATH,
  None,
  Gio.DBusSignalFlags.NONE,
  receive_lock_event,
)


def wait_for(condition):
  deadline = time.monotonic() + 3
  while time.monotonic() < deadline:
    while context.pending():
      context.iteration(False)
    if condition():
      return
    time.sleep(0.01)
  raise AssertionError("timed out waiting for the session-lock bridge")


def get_active():
  return connection.call_sync(
    BUS_NAME,
    OBJECT_PATH,
    BUS_NAME,
    "GetActive",
    None,
    GLib.VariantType.new("(b)"),
    Gio.DBusCallFlags.NONE,
    2000,
    None,
  ).unpack()[0]


def start_bridge(environment=None):
  return subprocess.Popen(
    [sys.executable, str(bridge_script)],
    stdin=subprocess.PIPE,
    stdout=subprocess.PIPE,
    stderr=subprocess.PIPE,
    env=environment,
  )


def send_lock_state(child, state):
  child.stdin.write(state)
  child.stdin.flush()


def pass_check(description):
  print(f"ok - {description}", flush=True)


child = start_bridge()
try:
  assert select.select([child.stdout], [], [], 3)[0], "bridge did not start"
  assert child.stdout.readline() == b"ready\n"
  assert get_active() is False
  pass_check("screensaver service starts inactive and answers GetActive")

  send_lock_state(child, b"tr")
  assert get_active() is False
  send_lock_state(child, b"ue\n")
  wait_for(lambda: lock_events == [True])
  assert get_active() is True
  pass_check(
    "fragmented lock input emits ActiveChanged only once the full state arrives"
  )

  send_lock_state(child, b"true\nfalse\ntrue\nfalse\n")
  wait_for(lambda: len(lock_events) >= 4)
  assert lock_events == [True, False, True, False], lock_events
  assert get_active() is False
  pass_check(
    "lock transitions stay ordered and repeated states emit no duplicate signals"
  )

  competing = start_bridge()
  try:
    stdout, stderr = competing.communicate(timeout=3)
    assert competing.returncode == 0, stderr
    assert stdout == b"", stdout
    assert get_active() is False
    pass_check("bridge never replaces or queues behind an existing screensaver owner")
  finally:
    if competing.poll() is None:
      competing.kill()
      competing.wait()

  send_lock_state(child, b"true\n")
  wait_for(lambda: lock_events == [True, False, True, False, True])
  child.stdin.close()
  assert child.wait(timeout=3) == 0, child.stderr.read()
  assert child.stderr.read() == b""
  while context.pending():
    context.iteration(False)
  assert lock_events == [True, False, True, False, True], lock_events
  pass_check("parent exit releases the bus name without announcing a false unlock")

  child = start_bridge()
  assert select.select([child.stdout], [], [], 3)[0], "replacement bridge did not start"
  assert child.stdout.readline() == b"ready\n"
  assert get_active() is False
  pass_check("replacement bridge can acquire the name after its predecessor exits")

  send_lock_state(child, b"preview\n")
  assert child.wait(timeout=3) == 1
  assert b"invalid lock state" in child.stderr.read()
  pass_check("bridge rejects invalid input instead of advertising a lock")
finally:
  if child.poll() is None:
    child.kill()
    child.wait()

# Use a second private bus so disconnecting it cannot affect the test client.
bus_daemon = subprocess.Popen(
  ["dbus-daemon", "--session", "--nofork", "--print-address=1"],
  stdout=subprocess.PIPE,
  stderr=subprocess.PIPE,
)
child = None
try:
  assert select.select([bus_daemon.stdout], [], [], 3)[0], "private bus did not start"
  bus_address = bus_daemon.stdout.readline().decode().strip()
  child = start_bridge(os.environ | {"DBUS_SESSION_BUS_ADDRESS": bus_address})
  assert select.select([child.stdout], [], [], 3)[0], (
    "bridge did not start on the private bus"
  )
  assert child.stdout.readline() == b"ready\n"
  bus_daemon.terminate()
  bus_daemon.wait(timeout=3)
  assert child.wait(timeout=3) == 1
  assert b"session bus connection closed" in child.stderr.read()
  pass_check(
    "session bus disconnection exits unsuccessfully so the shell can restart the bridge"
  )
finally:
  if child is not None and child.poll() is None:
    child.kill()
    child.wait()
  if bus_daemon.poll() is None:
    bus_daemon.kill()
    bus_daemon.wait()
