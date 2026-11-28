"""Exercise the panel helper on a private system bus with one three-slot reader."""
import json
import os
from pathlib import Path
import subprocess
import sys
import tempfile
import time

from gi.repository import Gio, GLib

SERVICE = "net.reactivated.Fprint"
DEVICE = SERVICE + ".Device"
DEVICE_PATH = "/net/reactivated/Fprint/Device/0"
HELPER = Path(__file__).resolve().parents[4] / "default/fingerprint/manage.py"


def serve(ready):
  bus = Gio.bus_get_sync(Gio.BusType.SESSION)
  loop = GLib.MainLoop()
  fingers = ["right-index-finger"]
  claimed = None
  def method(connection, sender, path, interface, name, args, reply):
    nonlocal claimed
    values = args.unpack()
    if name == "GetDevices":
      result = GLib.Variant("(ao)", ([DEVICE_PATH],))
    elif name == "GetDefaultDevice":
      result = GLib.Variant("(o)", (DEVICE_PATH,))
    elif name == "ListEnrolledFingers":
      assert values == ("",)
      result = GLib.Variant("(as)", (fingers,))
    elif name == "Claim":
      assert claimed is None and values == ("",)
      claimed, result = sender, None
    else:
      assert claimed == sender, "the claim belongs to another connection"
      result = None
      if name == "Release":
        claimed = None
      elif name == "DeleteEnrolledFinger":
        fingers.remove(values[0])
      elif name in ("EnrollStart", "VerifyStart"):
        slot = values[0]
        if name == "EnrollStart":
          if slot == "left-little-finger":
            reply.return_dbus_error(SERVICE + ".Error.PermissionDenied", "Authorization declined")
            return
          assert slot not in fingers and len(fingers) < 3
          fingers.append(slot)
          signal, status = "EnrollStatus", "enroll-completed"
        else:
          assert slot in fingers or slot == "any"
          # This reader checks just one template even when the client asks for any.
          selected = fingers[0] if slot == "any" else slot
          bus.emit_signal(sender, path, DEVICE, "VerifyFingerSelected", GLib.Variant("(s)", (selected,)))
          signal, status = "VerifyStatus", "verify-match"
        bus.emit_signal(sender, path, DEVICE, signal, GLib.Variant("(sb)", (status, True)))
    reply.return_value(result)

  def register(path, interface, body):
    xml = '<node><interface name="' + interface + '">' + body + '</interface></node>'
    info = Gio.DBusNodeInfo.new_for_xml(xml).interfaces[0]
    props = {"name": GLib.Variant("s", "Apple secure enclave fingerprint sensor"),
             "scan-type": GLib.Variant("s", "press"), "num-enroll-stages": GLib.Variant("i", 37)}
    bus.register_object(path, info, method, lambda *args: props[args[4]], None)

  register("/net/reactivated/Fprint/Manager", SERVICE + ".Manager", """
    <method name="GetDevices"><arg type="ao" direction="out"/></method>
    <method name="GetDefaultDevice"><arg type="o" direction="out"/></method>""")
  register(DEVICE_PATH, DEVICE, """
    <property name="name" type="s" access="read"/><property name="scan-type" type="s" access="read"/>
    <property name="num-enroll-stages" type="i" access="read"/>
    <method name="ListEnrolledFingers"><arg type="s"/><arg type="as" direction="out"/></method>
    <method name="Claim"><arg type="s"/></method><method name="Release"/>
    <method name="VerifyStart"><arg type="s"/></method><method name="VerifyStop"/>
    <method name="EnrollStart"><arg type="s"/></method><method name="EnrollStop"/>
    <method name="DeleteEnrolledFinger"><arg type="s"/></method>""")
  Gio.bus_own_name_on_connection(bus, SERVICE, Gio.BusNameOwnerFlags.NONE,
                                 lambda *_: Path(ready).touch(), None)
  loop.run()


def exercise():
  with tempfile.TemporaryDirectory() as tmp:
    env = dict(os.environ, HOME=tmp, XDG_DATA_HOME=tmp, DBUS_SYSTEM_BUS_ADDRESS=os.environ["DBUS_SESSION_BUS_ADDRESS"])
    ready = Path(tmp) / "ready"
    service = subprocess.Popen([sys.executable, __file__, "serve", str(ready)], env=env)
    try:
      for _ in range(100):
        if ready.exists(): break
        time.sleep(.03)
      assert ready.exists()
      def run(*args, ok=True):
        proc = subprocess.run([HELPER, *args], env=env, capture_output=True, text=True, timeout=6)
        assert (proc.returncode == 0) == ok, (args[0], proc.stdout, proc.stderr)
        return proc.stdout
      def snapshot(): return json.loads(run("list"))
      first = snapshot()
      reader = first["reader"]
      assert reader and first["capacity"] == 3 and len(first["prints"]) == 1, first
      finger = first["prints"][0]["slot"]
      run("rename", reader, finger, "Right index")
      assert snapshot()["prints"][0]["name"] == "Right index"
      assert "matched" in run("verify", reader, finger)
      assert "fail denied" in run("add", reader, "left-little-finger", ok=False)
      assert "done" in run("add", reader, "left-thumb")
      assert "selected " + finger in run("verify", reader, "any")
      run("add", reader, "right-thumb")
      assert "fail full" in run("add", reader, "left-index-finger", ok=False)
      # The default reader holds the same slot. Refreshing a stale selection
      # must never let an open removal confirmation reach that other reader.
      stale = json.loads(run("list", reader + "stale"))
      assert stale["readers"] and not stale["reader"] and not stale["prints"]
      run("remove", reader + "stale", finger, ok=False)
      run("remove", reader, "right-thumb")
      rows = snapshot()["prints"]
      assert [r["slot"] for r in rows] == [finger, "left-thumb"] and rows[0]["name"] == "Right index"
      run("rename", reader, "right-thumb", "Gone", ok=False)
      labels = Path(tmp) / "omarchy/fingerprint-names.sqlite3"
      labels.write_bytes(b"damaged")
      degraded = snapshot()
      assert not degraded["canRename"] and len(degraded["prints"]) == 2
      assert "matched" in run("verify", reader, finger)
      run("remove", reader, finger)
      assert [row["slot"] for row in snapshot()["prints"]] == ["left-thumb"]
    finally:
      service.terminate()
      service.wait(timeout=3)


if __name__ == "__main__":
  if sys.argv[1:2] == ["serve"]:
    serve(sys.argv[2])
  else:
    exercise()
