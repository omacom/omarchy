import QtQuick
import Quickshell
import qs.Commons
import qs.Ui

// A bar label centers on the ink its figures paint, not on the line box that
// carries them: the box keeps room for descenders and Qt rounds it up, so
// centering the box leaves the figures above the bar's middle. Measured on the
// real WidgetButton, including after its font changes at runtime.
ShellRoot {
  id: root

  readonly property string resultPath: Quickshell.env("OMARCHY_QML_TEST_RESULT")
  property var failures: []
  property int step: 0

  function fail(message) {
    failures.push(String(message))
  }

  function shellQuote(value) {
    return "'" + String(value).replace(/'/g, "'\\''") + "'"
  }

  function writeResult() {
    var payload = JSON.stringify({
      ok: failures.length === 0,
      failures: failures
    })

    if (resultPath) {
      Quickshell.execDetached(["bash", "-lc", "printf '%s' " + shellQuote(payload) + " > " + shellQuote(resultPath)])
    }
  }

  // The label a button draws. Item has a text property of its own, so match on
  // the text properties instead.
  function labelOf(item) {
    for (var i = 0; i < item.children.length; i++) {
      var child = item.children[i]
      if (child.text !== undefined && child.textFormat !== undefined) return child
      var nested = labelOf(child)
      if (nested) return nested
    }
    return null
  }

  function metricsFor(label) {
    var metrics = Qt.createQmlObject("import QtQuick; FontMetrics {}", label)
    metrics.font = Qt.font({
      family: label.font.family,
      pixelSize: label.font.pixelSize,
      weight: label.font.weight
    })
    return metrics
  }

  // Where the digit's ink sits in the button, and where its line box does.
  function inkCenter(button, label) {
    var metrics = metricsFor(label)
    var ink = metrics.tightBoundingRect("0")
    var center = label.y + label.baselineOffset + ink.top + ink.height / 2
    metrics.destroy()
    return center
  }

  function boxCenter(label) {
    return label.y + label.height / 2
  }

  function checkFigures(button, name) {
    var label = labelOf(button)
    if (!label) {
      fail(name + " draws a text label")
      return
    }
    var center = inkCenter(button, label)
    if (Math.abs(center - button.height / 2) > 0.5) {
      fail(name + " figure ink centers at " + center + " in a button whose middle is " + (button.height / 2))
    }
  }

  function checkLineBox(button, name) {
    var label = labelOf(button)
    if (!label) {
      fail(name + " draws a text label")
      return
    }
    var center = boxCenter(label)
    if (Math.abs(center - button.height / 2) > 0.5) {
      fail(name + " line box centers at " + center + " in a button whose middle is " + (button.height / 2))
    }
  }

  function checkLabels() {
    checkFigures(digits, "a two-digit label")
    checkFigures(caption, "a caption-size label")
    // The offset has to follow the label's font, not keep a value it computed
    // for the one it had when the binding first ran.
    digits.fontSize = 18
    Qt.callLater(checkAfterFontChange)
  }

  function checkAfterFontChange() {
    checkFigures(digits, "a label whose font grew")
    // Opt-outs keep their line box centered instead.
    checkLineBox(boxed, "a label that opts out of figure centering")
    checkLineBox(vertical, "a label on a vertical bar")
    checkLineBox(twoLines, "a label of two lines")
    writeResult()
    quitter.start()
  }

  Item {
    id: host
    width: 200
    height: 160
  }

  QtObject {
    id: testBar
    property bool vertical: false
    property int barSize: 26
    property string fontFamily: Style.font.family
    property color barForeground: "white"
    property color urgent: "red"
    property bool foregroundAnimationEnabled: false

    function registerClickTarget(target) {}
    function unregisterClickTarget(target) {}
    function hideTooltip(target) {}
    function showTooltip(target, text) {}
  }

  QtObject {
    id: verticalBar
    property bool vertical: true
    property int barSize: 26
    property string fontFamily: Style.font.family
    property color barForeground: "white"
    property color urgent: "red"
    property bool foregroundAnimationEnabled: false

    function registerClickTarget(target) {}
    function unregisterClickTarget(target) {}
    function hideTooltip(target) {}
    function showTooltip(target, text) {}
  }

  WidgetButton { id: digits; parent: host; bar: testBar; text: "12"; fontSize: 12; width: 40; height: 26 }
  WidgetButton { id: caption; parent: host; bar: testBar; text: "EN"; fontSize: Style.font.caption; width: 30; height: 26 }
  WidgetButton { id: boxed; parent: host; bar: testBar; text: "EN"; width: 30; height: 26; centerFigures: false }
  WidgetButton { id: vertical; parent: host; bar: verticalBar; text: "12"; width: 26; height: 40 }
  WidgetButton { id: twoLines; parent: host; bar: testBar; text: "1\n2"; width: 30; height: 40 }

  Timer {
    interval: 1
    running: true
    repeat: false
    onTriggered: {
      try {
        checkLabels()
      } catch (error) {
        fail("bar label centering fixture threw: " + error)
        writeResult()
      }
    }
  }

  Timer {
    id: quitter
    interval: 50
    onTriggered: Qt.quit()
  }
}
