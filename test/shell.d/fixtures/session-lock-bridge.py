import atexit
import json
import os
import select
import shutil
import signal
import subprocess
import sys
import time
from pathlib import Path
from tempfile import TemporaryDirectory

from gi.repository import Gio, GLib

BUS_NAME = "org.freedesktop.ScreenSaver"
OBJECT_PATH = "/org/freedesktop/ScreenSaver"
LOCK_NAME = "org.omarchy.SessionLock"
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


def wait_for(condition, timeout=3):
  deadline = time.monotonic() + timeout
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


def bus_call(method, arguments, return_type):
  return connection.call_sync(
    "org.freedesktop.DBus",
    "/org/freedesktop/DBus",
    "org.freedesktop.DBus",
    method,
    arguments,
    GLib.VariantType.new(return_type),
    Gio.DBusCallFlags.NONE,
    2000,
    None,
  ).unpack()[0]


def bridge_has_owner():
  return bus_call("NameHasOwner", GLib.Variant("(s)", (LOCK_NAME,)), "(b)")


def bridge_process_id():
  return bus_call("GetConnectionUnixProcessID", GLib.Variant("(s)", (LOCK_NAME,)), "(u)")


daemon_directory = TemporaryDirectory(prefix="omarchy-screensaver-")
atexit.register(daemon_directory.cleanup)
daemon_command = [
  sys.executable, str(Path(os.environ["ROOT"]) / "bin/omarchy-idle-inhibit"),
  "--state-file", str(Path(daemon_directory.name) / "state"),
]


def start_daemon():
  daemon = subprocess.Popen(daemon_command)

  def stop():
    if daemon.poll() is None:
      daemon.terminate()
      daemon.wait(timeout=3)

  atexit.register(stop)
  wait_for(lambda: bus_call("NameHasOwner", GLib.Variant("(s)", (BUS_NAME,)), "(b)"))
  return daemon


assert bus_call("RequestName", GLib.Variant("(su)", (BUS_NAME, 4)), "(u)") == 1
state_path = Path(daemon_directory.name) / "state"
state_path.write_text("existing owner state")
try:
  denied = subprocess.run(daemon_command, capture_output=True, timeout=3)
  assert denied.returncode == 1, denied.stderr
  assert b"unavailable; exiting for retry" in denied.stderr
  assert state_path.read_text() == "existing owner state"
  assert bus_call("GetNameOwner", GLib.Variant("(s)", (BUS_NAME,)), "(s)") == connection.get_unique_name()
  pass_check("public name conflict exits unsuccessfully without replacing the owner or its state")
finally:
  bus_call("ReleaseName", GLib.Variant("(s)", (BUS_NAME,)), "(u)")
  state_path.unlink()


def test_state_write_failure(trigger):
  with TemporaryDirectory(dir=daemon_directory.name) as directory:
    state = Path(directory) / "state"
    temporary_state = Path(directory) / "state.tmp"
    if trigger == "startup":
      temporary_state.mkdir()
    process = subprocess.Popen(
      [*daemon_command, "--state-file", str(state)],
      stderr=subprocess.PIPE,
    )
    holder = None
    try:
      if trigger != "startup":
        wait_for(state.exists)
        holder = Gio.DBusConnection.new_for_address_sync(
          os.environ["DBUS_SESSION_BUS_ADDRESS"],
          Gio.DBusConnectionFlags.AUTHENTICATION_CLIENT | Gio.DBusConnectionFlags.MESSAGE_BUS_CONNECTION,
          None, None,
        )
        cookie = holder.call_sync(
          BUS_NAME, OBJECT_PATH, BUS_NAME, "Inhibit",
          GLib.Variant("(ss)", ("write-failure-test", "video")),
          GLib.VariantType.new("(u)"), Gio.DBusCallFlags.NONE, 2000, None,
        ).unpack()[0]
        assert json.loads(state.read_text())["count"] == 1
        # A directory at the temporary filename forces a real filesystem error.
        temporary_state.mkdir()
        if trigger == "release":
          holder.call_sync(
            BUS_NAME, OBJECT_PATH, BUS_NAME, "UnInhibit",
            GLib.Variant("(u)", (cookie,)), None, Gio.DBusCallFlags.NONE, 2000, None,
          )
        else:
          holder.close_sync(None)
      assert process.wait(timeout=3) == 1
      assert b"cannot write" in process.stderr.read()
      if trigger != "startup":
        assert json.loads(state.read_text())["count"] == 1
        probe = subprocess.run(
          [str(Path(os.environ["ROOT"]) / "bin/omarchy-idle-inhibit-probe"), str(state)],
          capture_output=True, text=True, check=True,
        )
        assert probe.stdout == "\n", probe.stdout
      pass_check(f"{trigger} state-write failure exits nonzero so stale inhibitors cannot stay trusted")
    finally:
      if holder is not None and not holder.is_closed():
        holder.close_sync(None)
      if process.poll() is None:
        process.kill()
        process.wait()


for trigger in ("startup", "release", "disconnect"):
  test_state_write_failure(trigger)

daemon = start_daemon()
assert get_active() is False
pass_check("shared service acquires the public name when restarted after the conflict clears")


def test_quickshell_connection():
  source_path = Path(os.environ["ROOT"])
  lock_events.clear()
  activatable_names = bus_call("ListActivatableNames", None, "(as)")
  assert set(activatable_names) <= {"org.freedesktop.DBus"}, activatable_names
  pass_check("test bus cannot activate portals or other desktop services")
  with TemporaryDirectory(prefix="omarchy-lock-bridge-") as temporary_path:
    runtime_path = Path(temporary_path) / "runtime"
    runtime_path.mkdir(mode=0o700)
    fixture_path = Path(temporary_path) / "shell"
    fixture_path.mkdir()
    shutil.copyfile(
      source_path / "test/shell.d/fixtures/session-lock-bridge/shell.qml",
      fixture_path / "shell.qml",
    )
    shutil.copyfile(
      source_path / "shell/plugins/lock/SessionLockBridge.qml",
      fixture_path / "SessionLockBridge.qml",
    )
    environment = os.environ | {
      "QT_QPA_PLATFORM": "offscreen",
      "QT_QUICK_BACKEND": "software",
      "QT_QPA_PLATFORMTHEME": "",
      "QT_ACCESSIBILITY": "0",
      "NO_AT_BRIDGE": "1",
      "GIO_USE_VFS": "local",
      "OMARCHY_PATH": os.environ["ROOT"],
      "XDG_RUNTIME_DIR": str(runtime_path),
      "XDG_CACHE_HOME": temporary_path,
    }
    for variable in ("WAYLAND_DISPLAY", "DISPLAY"):
      environment.pop(variable, None)

    def ipc(method, *arguments):
      result = subprocess.run(
        [
          "quickshell",
          "ipc",
          "-p",
          str(fixture_path),
          "call",
          "session-lock-bridge-test",
          method,
          *arguments,
        ],
        capture_output=True,
        text=True,
        timeout=2,
        env=environment,
        check=True,
      )
      return result.stdout.strip()

    def bridge_ready():
      return json.loads(ipc("status"))["ready"]

    log_path = Path(temporary_path) / "quickshell.log"
    with log_path.open("w") as log_file:
      shell_process = subprocess.Popen(
        ["quickshell", "-n", "-p", str(fixture_path), "--no-color"],
        stdout=log_file,
        stderr=subprocess.STDOUT,
        env=environment,
        start_new_session=True,
      )
      try:
        wait_for(bridge_has_owner, timeout=5)
        wait_for(bridge_ready)
        runtime_status = json.loads(ipc("status"))
        assert runtime_status["platform"] == "offscreen", runtime_status
        assert not runtime_status["waylandDisplay"], runtime_status
        assert not runtime_status["x11Display"], runtime_status
        pass_check(
          "Quickshell fixture runs offscreen without access to the desktop display"
        )
        wait_for(lambda: lock_events == [True])
        assert get_active() is True
        pass_check(
          "real Quickshell receives ready and publishes an initially secure session"
        )

        assert ipc("setSecure", "false") == "ok"
        wait_for(lambda: lock_events == [True, False])
        assert get_active() is False
        assert ipc("setSecure", "true") == "ok"
        wait_for(lambda: lock_events == [True, False, True])
        assert get_active() is True
        pass_check(
          "real Quickshell writes unlock and lock changes to the Python bridge"
        )

        previous_bridge_pid = bridge_process_id()
        os.kill(previous_bridge_pid, signal.SIGKILL)
        wait_for(lambda: not bridge_ready())
        pass_check("real Quickshell clears readiness when the Python bridge fails")
        wait_for(
          lambda: bridge_has_owner() and bridge_process_id() != previous_bridge_pid
        )
        wait_for(bridge_ready)
        wait_for(lambda: lock_events == [True, False, True, True])
        assert get_active() is True
        pass_check(
          "real Quickshell restarts the bridge and republishes the current secure state"
        )

        assert ipc("setSecure", "false") == "ok"
        wait_for(lambda: lock_events == [True, False, True, True, False])
        assert get_active() is False
        pass_check("restarted Quickshell bridge continues forwarding unlock changes")
      except Exception:
        log_file.flush()
        print(log_path.read_text(), file=sys.stderr)
        raise
      finally:
        try:
          os.killpg(shell_process.pid, signal.SIGTERM)
        except ProcessLookupError:
          pass
        try:
          shell_process.wait(timeout=3)
        except subprocess.TimeoutExpired:
          os.killpg(shell_process.pid, signal.SIGKILL)
          shell_process.wait()
    wait_for(lambda: not bridge_has_owner())
    pass_check(
      "Quickshell fixture exits without leaving a bridge or D-Bus owner behind"
    )


child = start_bridge()
try:
  assert select.select([child.stdout], [], [], 3)[0], "bridge did not start"
  assert child.stdout.readline() == b"ready\n"
  send_lock_state(child, b"false\n")
  wait_for(lambda: lock_events == [False])
  lock_events.clear()
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

  public_owner = bus_call("GetNameOwner", GLib.Variant("(s)", (BUS_NAME,)), "(s)")
  for path in (OBJECT_PATH, "/ScreenSaver"):
    cookie = connection.call_sync(
      BUS_NAME, path, BUS_NAME, "Inhibit",
      GLib.Variant("(ss)", ("lock-test", "video")),
      GLib.VariantType.new("(u)"), Gio.DBusCallFlags.NONE, 2000, None,
    ).unpack()[0]
    expected_count = len(lock_events) + 2
    send_lock_state(child, b"true\n")
    wait_for(lambda: get_active() is True)
    assert connection.call_sync(
      BUS_NAME, path, BUS_NAME, "GetActive", None,
      GLib.VariantType.new("(b)"), Gio.DBusCallFlags.NONE, 2000, None,
    ).unpack()[0] is True
    send_lock_state(child, b"false\n")
    wait_for(lambda count=expected_count: len(lock_events) == count)
    assert get_active() is False
    state = json.loads((Path(daemon_directory.name) / "state").read_text())
    assert state["count"] == 1
    connection.call_sync(
      BUS_NAME, path, BUS_NAME, "UnInhibit", GLib.Variant("(u)", (cookie,)),
      None, Gio.DBusCallFlags.NONE, 2000, None,
    )
    assert bus_call("GetNameOwner", GLib.Variant("(s)", (BUS_NAME,)), "(s)") == public_owner
  pass_check("one public owner serves inhibitors on both paths while forwarding lock changes")
  lock_events.clear()

  competing = start_bridge()
  try:
    stdout, stderr = competing.communicate(timeout=3)
    assert competing.returncode == 0, stderr
    assert stdout == b"", stdout
    assert get_active() is False
    pass_check("a second lock publisher cannot replace or queue behind the first")
  finally:
    if competing.poll() is None:
      competing.kill()
      competing.wait()

  send_lock_state(child, b"true\n")
  wait_for(lambda: lock_events == [True])
  child.stdin.close()
  assert child.wait(timeout=3) == 0, child.stderr.read()
  assert child.stderr.read() == b""
  while context.pending():
    context.iteration(False)
  assert lock_events == [True], lock_events
  pass_check("parent exit releases the bus name without announcing a false unlock")

  child = start_bridge()
  assert select.select([child.stdout], [], [], 3)[0], "replacement bridge did not start"
  assert child.stdout.readline() == b"ready\n"
  assert get_active() is True
  send_lock_state(child, b"false\n")
  wait_for(lambda: get_active() is False)
  assert get_active() is False
  pass_check("publisher loss retains the secure state until its replacement publishes")

  send_lock_state(child, b"true\n")
  wait_for(lambda: get_active() is True)
  wait_for(lambda: lock_events[-1] is True)
  lock_events.clear()
  daemon.terminate()
  daemon.wait(timeout=3)
  daemon = start_daemon()
  wait_for(lambda: get_active() is True)
  wait_for(lambda: lock_events == [True])
  pass_check("shared service restart queries and announces the existing publisher's secure state")

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

if shutil.which("quickshell") is None:
  print(
    "ok - quickshell unavailable; skipping session lock bridge QML lifecycle # SKIP",
    flush=True,
  )
else:
  test_quickshell_connection()
