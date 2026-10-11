import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import qs.Commons
import qs.Commons as Commons
import qs.Ui
import "../components"
import "../lib/Debug.js" as Debug
import "../lib/Parser.js" as Parser

// Every step PCRE2 takes to match the workbench's pattern against its text,
// from PCRE2's own callouts: which item it tries, where, when it gives up
// and backtracks, and which items it spends its time on.
Item {
  id: root

  property var app

  readonly property color foreground: app.foreground
  readonly property color accent: app.accent
  readonly property color dim: Qt.darker(foreground, 1.5)
  readonly property color backtrackColor: Qt.hsla(0.02, 0.75, 0.6, 1)

  property var reply: null
  property var steps: []
  property int requestId: 0
  property int step: 0
  property bool optimize: false
  property bool playing: false
  readonly property var current: steps.length ? steps[Math.min(step, steps.length - 1)] : null
  readonly property var hot: Debug.hotspots(steps)
  readonly property var attempts: Debug.attempts(steps)
  readonly property var parsed: Parser.parse(app.pattern, "pcre2", app.pcre2Flags)

  function run() {
    if (!visible || app.pattern === "") return
    playing = false
    requestId = app.engine.match({
      op: "debug",
      flavor: "pcre2",
      pattern: app.pattern,
      flags: app.pcre2Flags,
      text: app.testText,
      textPath: app.textFile,
      textVersion: app.textVersion,
      parsed: parsed,
      channel: "debug",
      options: { optimize: optimize },
    })
  }

  function shown() {
    runTimer.restart()
    forceActiveFocus()
  }

  onVisibleChanged: if (visible) shown()
  // The page may be built already showing.
  Component.onCompleted: if (visible) Qt.callLater(shown)

  // Clicking anywhere that is not a control gives the arrow keys back.
  MouseArea {
    anchors.fill: parent
    onPressed: function(mouse) { root.forceActiveFocus(); mouse.accepted = false }
  }
  onOptimizeChanged: runTimer.restart()

  Connections {
    target: root.app
    function onPatternChanged() { runTimer.restart() }
    function onTestTextChanged() { runTimer.restart() }
    function onFlagsChanged() { runTimer.restart() }
  }

  Connections {
    target: root.app.engine
    function onDetectedChanged() { runTimer.restart() }
    function onResult(reply) {
      if (reply.id !== root.requestId || !reply.done) return
      root.reply = reply
      root.steps = reply.steps || []
      root.step = 0
    }
  }

  Timer { id: runTimer; interval: 250; onTriggered: root.run() }

  Timer {
    interval: Math.max(16, 400 / speed.value)
    repeat: true
    running: root.playing
    onTriggered: {
      if (root.step >= root.steps.length - 1) root.playing = false
      else root.step++
    }
  }

  function go(to) {
    playing = false
    step = Math.max(0, Math.min(steps.length - 1, to))
  }

  // The previous or next step where the engine backtracked.
  function nextBacktrack(direction) {
    for (var i = step + direction; i >= 0 && i < steps.length; i += direction) {
      if (steps[i][4] & Debug.BACKTRACK) { go(i); return }
    }
  }

  Keys.onPressed: function(event) {
    if (event.key === Qt.Key_Right || event.key === Qt.Key_L) { go(step + 1); event.accepted = true }
    else if (event.key === Qt.Key_Left || event.key === Qt.Key_H) { go(step - 1); event.accepted = true }
    else if (event.key === Qt.Key_Space) { playing = !playing; event.accepted = true }
  }

  ColumnLayout {
    anchors.fill: parent
    anchors.margins: Style.spacing.panelPadding
    spacing: Style.spacing.lg

    RowLayout {
      Layout.fillWidth: true
      spacing: Style.spacing.lg

      Text {
        text: "Debugger"
        color: root.foreground
        font.family: Style.font.family
        font.pixelSize: Style.font.heading
        font.bold: true
      }

      Text {
        Layout.fillWidth: true
        text: root.app.flavor === "pcre2" ? "PCRE2, step by step" : "Runs the pattern on PCRE2, which may read it differently from " + root.app.flavorInfo.name
        textFormat: Text.PlainText
        color: root.dim
        elide: Text.ElideRight
        font.family: Style.font.family
        font.pixelSize: Style.font.caption
      }

      Button {
        text: root.optimize ? "Optimized" : "Unoptimized"
        tooltipText: root.optimize
          ? "What PCRE2 really does, skipping work it can prove pointless. Click to see every step of the plain algorithm."
          : "The plain backtracking algorithm, every step. Click to see what PCRE2's optimizations save."
        bordered: true
        selected: root.optimize
        onClicked: root.optimize = !root.optimize
      }
    }

    Text {
      Layout.fillWidth: true
      visible: root.app.pattern === ""
      text: "Type a pattern on the workbench first."
      color: root.dim
      font.family: Style.font.family
      font.pixelSize: Style.font.body
    }

    Text {
      Layout.fillWidth: true
      visible: !!root.reply && root.reply.ok === false
      text: root.reply ? root.reply.error || "" : ""
      color: Commons.Color.urgent
      wrapMode: Text.Wrap
      font.family: Style.font.family
      font.pixelSize: Style.font.caption
      textFormat: Text.PlainText
    }

    // ---- the pattern, with the item being tried ----
    MarkedText {
      Layout.fillWidth: true
      Layout.preferredHeight: implicitHeight
      maximumHeight: root.height * 0.2
      visible: root.app.pattern !== ""
      foreground: root.foreground
      fontSize: Style.font.title
      text: root.app.pattern
      spans: root.current ? [{
        start: root.current[2],
        end: root.current[2] + Math.max(root.current[3], 0),
        color: (root.current[4] & Debug.BACKTRACK) ? root.backtrackColor : root.accent,
        outline: true,
      }] : []
      markers: root.current && root.current[3] === 0 ? [{ at: root.current[2], color: root.accent }] : []
    }

    // ---- the text, with the attempt and position ----
    MarkedText {
      Layout.fillWidth: true
      Layout.fillHeight: true
      visible: root.app.pattern !== ""
      foreground: root.foreground
      text: root.app.testText.length > 65536 ? root.app.testText.substr(0, 65536) : root.app.testText
      follow: root.current ? root.current[1] : -1
      spans: {
        if (!root.current) return []
        var s = root.current
        var out = [{ start: s[0], end: Math.max(s[0], s[1]), color: Util.alpha(root.accent, 0.3) }]
        for (var g = 0; 5 + g * 2 + 1 < s.length; g++) {
          if (s[5 + g * 2] < 0) continue
          out.push({ start: s[5 + g * 2], end: s[6 + g * 2], color: root.app.groupColors[g % Math.max(1, root.app.groupColors.length)], outline: true })
        }
        if (root.step === root.steps.length - 1 && root.reply && root.reply.match)
          out.push({ start: root.reply.match[0], end: root.reply.match[1], color: Util.alpha(root.accent, 0.5) })
        return out
      }
      markers: root.current ? [
        { at: root.current[0], color: Util.alpha(root.foreground, 0.5) },
        { at: root.current[1], color: (root.current[4] & Debug.BACKTRACK) ? root.backtrackColor : root.accent },
      ] : []
    }

    // ---- where we are ----
    Text {
      Layout.fillWidth: true
      visible: !!root.current
      text: root.current ? "Step " + (root.step + 1) + " of " + root.steps.length + ": " + Debug.describe(root.current, root.app.pattern, root.app.testText) : ""
      color: root.current && (root.current[4] & Debug.BACKTRACK) ? root.backtrackColor : root.foreground
      wrapMode: Text.Wrap
      font.family: Style.font.family
      font.pixelSize: Style.font.body
      textFormat: Text.PlainText
    }

    RowLayout {
      Layout.fillWidth: true
      visible: root.steps.length > 0
      spacing: Style.spacing.md

      Button { iconText: "󰒮"; tooltipText: "First step"; onClicked: root.go(0) }
      Button { iconText: "󰼨"; tooltipText: "Previous backtrack"; onClicked: root.nextBacktrack(-1) }
      Button { iconText: "󰁍"; tooltipText: "Previous step (←)"; onClicked: root.go(root.step - 1) }
      Button { iconText: root.playing ? "󰏤" : "󰐊"; tooltipText: root.playing ? "Pause (space)" : "Play (space)"; onClicked: root.playing = !root.playing }
      Button { iconText: "󰁔"; tooltipText: "Next step (→)"; onClicked: root.go(root.step + 1) }
      Button { iconText: "󰼧"; tooltipText: "Next backtrack"; onClicked: root.nextBacktrack(1) }
      Button { iconText: "󰒭"; tooltipText: "Last step"; onClicked: root.go(root.steps.length - 1) }

      Slider {
        id: scrub
        Layout.fillWidth: true
        from: 0
        to: Math.max(0, root.steps.length - 1)
        stepSize: 1
        value: root.step
        onMoved: root.go(Math.round(value))
      }

      Text {
        text: "speed"
        color: root.dim
        font.family: Style.font.family
        font.pixelSize: Style.font.caption
      }

      Slider {
        id: speed
        Layout.preferredWidth: Style.space(90)
        from: 1
        to: 40
        value: 4
      }
    }

    Text {
      Layout.fillWidth: true
      visible: !!root.reply && root.reply.ok !== false
      text: root.reply && root.reply.ok !== false ? Debug.summary(root.reply, root.steps) + (root.reply.textTruncated ? " (on the first 65,536 characters)" : "") : ""
      color: root.reply && (root.reply.stopped || root.reply.limit) ? root.backtrackColor : root.dim
      wrapMode: Text.Wrap
      font.family: Style.font.family
      font.pixelSize: Style.font.caption
      textFormat: Text.PlainText
    }

    // ---- where the time goes ----
    Flow {
      Layout.fillWidth: true
      visible: root.hot.length > 0
      spacing: Style.spacing.md

      Text {
        text: "Busiest items:"
        color: root.dim
        font.family: Style.font.family
        font.pixelSize: Style.font.caption
      }

      Repeater {
        model: root.hot.slice(0, 8)

        Text {
          required property var modelData
          text: root.app.pattern.substr(modelData.start, modelData.length) + " at " + modelData.start + " ×" + modelData.count + (modelData.backtracks ? " (" + modelData.backtracks + " after backtracking)" : "")
          color: root.foreground
          font.family: Style.font.family
          font.pixelSize: Style.font.caption
          textFormat: Text.PlainText
        }
      }
    }
  }
}
