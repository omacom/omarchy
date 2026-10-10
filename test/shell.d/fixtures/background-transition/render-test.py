"""Render production background logic on two isolated, differently shaped Items.

Only desktop integration is replaced (screen surfaces, IPC, theme styling).
The production catalog, selection, capture, mask, images, and finishTransition
run unchanged. A delayed HTTP image exercises real Image.Loading at handoff.
"""

from functools import partial
from http.server import SimpleHTTPRequestHandler, ThreadingHTTPServer
import os
from pathlib import Path
import shutil
import subprocess
import sys
import threading
import time
from urllib.parse import urlsplit


root, work = map(Path, sys.argv[1:])
config = work / "config"
images = work / "images"
runtime = work / "runtime"
for directory in (config, images, runtime, config / "Commons", config / "Ui"):
  directory.mkdir(parents=True, exist_ok=True)
runtime.chmod(0o700)
for marker in ("waiting", "release"):
  (work / marker).unlink(missing_ok=True)


def replace_once(text, old, new):
  assert text.count(old) == 1, f"fixture boundary changed: {old}"
  return text.replace(old, new)


def image(name, size, color):
  path = images / name
  path.parent.mkdir(parents=True, exist_ok=True)
  subprocess.run(["magick", "-size", size, f"xc:{color}", str(path)], check=True)


image("old.png", "100x100", "white")
image("old/wide.png", "160x90", "red")
image("old/portrait.png", "90x160", "blue")
image("new.png", "100x100", "green")
image("new/wide.png", "160x90", "yellow")
image("new/portrait.png", "90x160", "cyan")
image("decoy.png", "100x100", "magenta")


class DelayedImage(SimpleHTTPRequestHandler):
  def log_message(self, *args):
    pass

  def do_GET(self):
    request = urlsplit(self.path)
    if request.path == "/new/portrait.png" and request.query == "v=2":
      # Only the displayed portrait frame is slow; its incoming frame already
      # decoded from a local file. Do not substitute a mocked ready flag.
      (work / "waiting").touch()
      deadline = time.monotonic() + 15
      while not (work / "release").exists() and time.monotonic() < deadline:
        time.sleep(0.02)
    try:
      super().do_GET()
    except (BrokenPipeError, ConnectionResetError):
      # Qt may cancel a replaced image's in-flight request.
      pass


server = ThreadingHTTPServer(("127.0.0.1", 0), partial(DelayedImage, directory=str(images)))
threading.Thread(target=server.serve_forever, daemon=True).start()
port = server.server_port

# Keep the real visual subtree and transition functions; replace only the
# Wayland-only surface with an Item in an OpenGL-backed QQuickWindow.
background = (root / "shell/plugins/background/Background.qml").read_text()
background = replace_once(background, "import Quickshell.Wayland\n", "")
background = replace_once(background, "  id: root\n", """  id: root
  property alias testPanels: backgroundPanels
  function testPause() { revealAnimation.pause(); revealProgress = 0 }
  function testFinish() { revealAnimation.complete() }
""")
background = replace_once(background, "  Component.onCompleted: refreshBackground()", "")
background = replace_once(background, "model: Quickshell.screens", "model: [{width: 160, height: 90, x: 0}, {width: 90, height: 160, x: 180}]")
background = replace_once(background, "    PanelWindow {\n      id: panel", """    Item {
      id: panel
      parent: root
      width: modelData.width
      height: modelData.height
      x: modelData.x
      property real devicePixelRatio: 1
      property alias testBase: base
      property alias testIncoming: incomingFrame""")
for boundary in (
  "      screen: modelData\n",
  "      anchors { top: true; bottom: true; left: true; right: true }\n",
  '      color: "transparent"\n',
  "      updatesEnabled: true\n",
  '      WlrLayershell.namespace: "omarchy-background"\n',
  "      WlrLayershell.layer: WlrLayer.Background\n",
  "      WlrLayershell.keyboardFocus: WlrKeyboardFocus.None\n",
  "      exclusionMode: ExclusionMode.Ignore\n",
):
  background = replace_once(background, boundary, "")
(config / "BackgroundUnderTest.qml").write_text(background)
for name in ("BackgroundVariantCatalog.qml", "BackgroundVariants.js", "variant-images.py"):
  shutil.copy(root / "shell/plugins/background" / name, config / name)

# Serve displayed frames over HTTP to control an actual asynchronous decode.
media = (root / "shell/Ui/BackgroundMedia.qml").read_text()
media = replace_once(media, "Util.fileUrl(path)", f'("http://127.0.0.1:{port}/" + path.slice({len(str(images)) + 1}))')
(config / "Ui/BackgroundMedia.qml").write_text(media)
(config / "Ui/ScreenMoveRemap.qml").write_text("import QtQuick\nItem { property var window; property bool remapping: false }\n")
shutil.copy(root / "shell/Commons/Util.qml", config / "Commons/Util.qml")
(config / "Commons/Style.qml").write_text("""pragma Singleton
import QtQuick
QtObject {
  function duration(ms) { return 1000000 }
  function scheduleRefresh() {}
}
""")
(config / "Commons/Color.qml").write_text("""pragma Singleton
import QtQuick
QtObject {
  function loadColors(raw) {}
  function loadShell(raw) {}
}
""")
(config / "Commons/ShellIpc.qml").write_text("import QtQuick\nQtObject { property string target }\n")
(config / "Commons/qmldir").write_text("singleton Util 1.0 Util.qml\nsingleton Style 1.0 Style.qml\nsingleton Color 1.0 Color.qml\nShellIpc 1.0 ShellIpc.qml\n")
shutil.copy(Path(__file__).with_name("shell.qml"), config / "shell.qml")

try:
  result = subprocess.run(
    ["quickshell", "-p", str(config), "--no-color"],
    env=dict(os.environ, XDG_RUNTIME_DIR=str(runtime), XDG_CACHE_HOME=str(work / "cache"),
             HOME=str(work), VARIANT_RENDER_DIR=str(work)),
    stdout=subprocess.PIPE, stderr=subprocess.STDOUT, text=True, timeout=25,
  )
  (work / "runtime.log").write_text(result.stdout)
  assert result.returncode == 0 and "PASS rendered transition" in result.stdout and "FAIL" not in result.stdout, result.stdout
  assert (work / "waiting").exists(), "displayed portrait frame never exercised Image.Loading"

  # Sample the center and edges of both outputs: old pixels must be the
  # authored variants (red/blue), not the white default or magenta live base.
  for stage, colors in (("initial", (b"\xff\0\0", b"\0\0\xff")),
                        ("captured", (b"\xff\0\0", b"\0\0\xff")),
                        ("held", (b"\xff\xff\0", b"\0\xff\xff")),
                        ("finished", (b"\xff\xff\0", b"\0\xff\xff")),
                        ("reloaded", (b"\xff\0\xff", b"\xff\0\0"))):
    for points, color in ((("5,5", "80,45", "155,85"), colors[0]),
                          (("185,5", "225,80", "265,155"), colors[1])):
      for point in points:
        actual = subprocess.check_output(["magick", str(work / f"{stage}.png"),
          "-crop", "1x1+" + point.replace(",", "+"), "+repage", "-depth", "8", "rgb:-"])
        assert actual == color, f"{stage} at {point}: expected {color!r}, got {actual!r}"
    print(f"ok - rendered {stage} pixels match both output variants")

  for point, color in (("5,5", b"\xff\0\0"), ("80,45", b"\xff\xff\0"),
                       ("155,85", b"\xff\0\0"), ("185,5", b"\0\0\xff"),
                       ("225,80", b"\0\xff\xff"), ("265,155", b"\0\0\xff")):
    actual = subprocess.check_output(["magick", str(work / "reveal.png"),
      "-crop", "1x1+" + point.replace(",", "+"), "+repage", "-depth", "8", "rgb:-"])
    assert actual == color, f"reveal at {point}: expected {color!r}, got {actual!r}"
  print("ok - rendered reveal mask shows incoming centers and captured outgoing edges")
finally:
  server.shutdown()
