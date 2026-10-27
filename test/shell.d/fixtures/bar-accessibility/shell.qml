import QtQuick
import Quickshell
import qs.Ui

ShellRoot {
  id: root

  readonly property string resultPath: Quickshell.env("OMARCHY_QML_TEST_RESULT")
  readonly property string glyph: String.fromCodePoint(0xe900)
  property var failures: []
  property var presses: []

  function same(actual, expected, message) {
    if (actual !== expected) failures.push(message + " expected=" + JSON.stringify(expected) + " actual=" + JSON.stringify(actual))
  }

  function shellQuote(value) {
    return "'" + String(value).replace(/'/g, "'\\''") + "'"
  }

  function writeResult() {
    var payload = JSON.stringify({ ok: failures.length === 0, failures: failures })
    if (resultPath) Quickshell.execDetached(["bash", "-c", "printf '%s' " + shellQuote(payload) + " > " + shellQuote(resultPath)])
  }

  Item {
    WidgetButton {
      id: widget
      text: "Tuesday 14:32"
      tooltipText: "Calendar"
      onPressed: function(button) { root.presses.push("widget:" + button) }
    }
    WidgetButton { id: textWidget; text: "Tuesday 14:32" }
    WidgetButton { id: glyphWidget; text: root.glyph }
    WidgetButton { id: staticWidget; text: "3"; pressable: false }
    WidgetButton { id: concealedWidget; text: "x"; concealed: true }
    WidgetButton { id: disabledWidget; text: "x"; enabled: false; onPressed: root.presses.push("disabled") }
    WidgetButton { id: inertWidget; text: "x"; interactive: false; onPressed: root.presses.push("inert") }
    BarIconButton { id: glyphIcon; text: root.glyph }
    BarIconButton {
      id: namedIcon
      text: root.glyph
      accessibleName: "Network"
      tooltipText: "Limited internet access"
      onPressed: function(button) { root.presses.push("icon:" + button) }
    }
  }

  Component.onCompleted: Qt.callLater(runChecks)

  function runChecks() {
    same(widget.Accessible.role, Accessible.Button, "pressable WidgetButton is a button")
    same(widget.Accessible.name, "Calendar", "WidgetButton prefers its tooltip")
    same(textWidget.Accessible.name, "Tuesday 14:32", "WidgetButton falls back to its text")
    same(glyphWidget.Accessible.name, "", "WidgetButton never announces an icon glyph")
    same(staticWidget.Accessible.role, Accessible.StaticText, "non-pressable WidgetButton reads as text")
    same(concealedWidget.Accessible.ignored, true, "concealed WidgetButton is hidden")
    same(glyphIcon.Accessible.name, "", "BarIconButton never announces its glyph")
    same(namedIcon.Accessible.name, "Network", "BarIconButton takes accessibleName")
    same(namedIcon.Accessible.description, "Limited internet access", "a tooltip that differs from the name describes the button")

    widget.Accessible.pressAction()
    namedIcon.Accessible.pressAction()
    disabledWidget.Accessible.pressAction()
    inertWidget.Accessible.pressAction()
    same(presses.join(","), "widget:" + Qt.LeftButton + ",icon:" + Qt.LeftButton, "press is a left click, only on enabled interactive buttons")

    writeResult()
  }
}
