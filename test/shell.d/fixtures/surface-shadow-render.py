"""Offscreen Qt rendering checks; no Quickshell process or desktop state needed."""
import os
from pathlib import Path
import shutil
import tempfile

from PySide6.QtCore import QUrl
from PySide6.QtGui import QGuiApplication
from PySide6.QtQml import QQmlComponent
from PySide6.QtQuick import QQuickView

root = Path(os.environ["ROOT"])
app = QGuiApplication([])

with tempfile.TemporaryDirectory(prefix="omarchy-shadow-") as directory:
    fixture = Path(directory)
    # Exercise the production resolver and border color parser with a fixed
    # palette, without starting the Color singleton's desktop file watchers.
    for name in ("Shadow.qml", "ShadowGeometry.js", "Border.qml", "BorderGeometry.js"):
        shutil.copyfile(root / "shell/Commons" / name, fixture / name)
    (fixture / "qmldir").write_text("singleton Shadow 1.0 Shadow.qml\nsingleton Border 1.0 Border.qml\nsingleton Color 1.0 Color.qml\n")
    (fixture / "Color.qml").write_text('''pragma Singleton
import QtQuick
QtObject {
  property var shellValues: ({})
  property color background: "#101010"
  property color foreground: "#eeeeee"
  property color accent: "#cc2244"
  property color urgent: "#ff3333"
  property color muted: "#888888"
}
''')
    source = '''import QtQuick
import "."
import "%s"
Item {
  id: root
  width: 400; height: 300
  property var values: ({})
  onValuesChanged: Color.shellValues = values
  readonly property var spec: Shadow.surfaceSpec("popups")
  readonly property color resolvedColor: spec.color
  readonly property bool enabledShadow: spec.enabled
  readonly property bool loaded: shadowLoader.item !== null
  Loader {
    id: shadowLoader
    x: 100; y: 100; width: 200; height: 100
    active: root.spec.enabled
    sourceComponent: SurfaceShadow { spec: root.spec; radius: 16 }
  }
}
''' % (root / "shell/Ui").as_uri()
    view = QQuickView()
    view.resize(400, 300)
    view.setColor("white")
    component = QQmlComponent(view.engine())
    component.setData(source.encode(), QUrl.fromLocalFile(str(fixture / "Test.qml")))
    item = component.create()
    assert item is not None, [error.toString() for error in component.errors()]
    view.setContent(QUrl(), component, item)
    view.show()

    def configure(**values):
        item.setProperty("values", {"popups.shadow-" + k.replace("_", "-"): v for k, v in values.items()})
        for _ in range(40):
            app.processEvents()
        image = view.grabWindow()
        assert not image.isNull(), "Qt Quick renderer did not produce a frame"
        return image

    def white(image, x, y):
        return image.pixelColor(x, y).red() == 255 and image.pixelColor(x, y).green() == 255 and image.pixelColor(x, y).blue() == 255

    image = configure()
    assert not item.property("loaded"), "disabled shadow allocated a renderer"
    assert white(image, 200, 205)
    print("ok - default shadow has no renderer or pixels")

    image = configure(alpha=0.5, color="#000000", blur=24, offset_y=6)
    assert item.property("loaded")
    assert white(image, 200, 150), "shadow darkened the card interior"
    assert not white(image, 200, 205), "outer shadow is missing"
    assert white(image, 200, 240), "shadow extends beyond reserved geometry"
    assert not white(image, 101, 101), "rounded corner was masked as a square"
    print("ok - rendered shadow follows rounded corners and excludes translucent interiors")

    for color, red, alpha in [("red", 255, 0.5), ("accent", 204, 0.5), ("rgba(ff000080)", 255, 0.25), ("not-a-color", 0, 0.5)]:
        configure(alpha=0.5, color=color)
        resolved = item.property("resolvedColor")
        assert abs(resolved.red() - red) <= 1, (color, resolved.name())
        assert abs(resolved.alphaF() - alpha) < 0.01, (color, resolved.alphaF())
    print("ok - named colors, roles, embedded alpha, and invalid colors resolve correctly")

    item.setProperty("values", {"popups.shadow-alpha": 0.5, "popups.shadow-color": "menu.text", "menu.text": "accent"})
    app.processEvents()
    assert item.property("resolvedColor").red() == 204
    item.setProperty("values", {"popups.shadow-alpha": 0.5, "popups.shadow-color": "menu.text", "menu.text": "popups.shadow-color"})
    app.processEvents()
    assert item.property("resolvedColor").red() == 0
    print("ok - color references resolve and cycles safely fall back")

    image = configure(alpha=0.5, color="transparent")
    assert not item.property("loaded") and white(image, 200, 205)
    image = configure(alpha=0)
    assert not item.property("loaded") and white(image, 200, 205)
    print("ok - live disable and transparent colors remove renderer and pixels")
    view.close()
