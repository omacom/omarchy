import QtQuick
import Quickshell
import Quickshell.Io
import qs.Commons
import qs.Ui

// Hidden until a comm newer than the one already on disk arrives, then
// visible until the timer fires. An empty read is not a snapshot: the
// file view can report that before the feed exists, and priming on it
// would treat the real history as new.
BarWidget {
  id: root
  moduleName: "omarchy.agent-comms"

  property string omarchyPath: Quickshell.env("OMARCHY_PATH")
  readonly property string home: Quickshell.env("HOME")
  readonly property string stateHome: {
    var fromEnv = Quickshell.env("XDG_STATE_HOME")
    return (fromEnv && fromEnv.length) ? fromEnv : (home + "/.local/state")
  }
  readonly property string feedPath: stateHome + "/omarchy/agent-comms/feed.json"
  readonly property color ink: (bar && bar.barForeground) ? bar.barForeground : Color.bar.text
  readonly property string fontFamily: (bar && bar.fontFamily) ? bar.fontFamily : Style.font.family
  readonly property int speed: Math.max(12, Number(setting("pixelsPerSecond", 42)) || 42)
  readonly property int maxWidth: Math.max(160, Number(setting("maxWidth", 480)) || 480)
  readonly property int visibleMs: Math.max(5, Number(setting("visibleSeconds", 60)) || 60) * 1000
  readonly property string markText: {
    var label = String(setting("label", "comms") || "comms")
    return label.length ? label : "comms"
  }
  readonly property string apps: String(setting("apps", "chatgpt,grok,muse"))
  readonly property real span: tape.children.length > 0 ? tape.children[0].implicitWidth : 0

  property var items: []
  property bool hovered: false
  property bool primed: false
  property bool revealed: false
  property bool holdOpen: false
  property real seenStamp: 0

  function newestStamp(rows) {
    var max = 0
    if (!rows) return 0
    for (var i = 0; i < rows.length; i++) {
      var row = rows[i]
      var ts = row ? Number(row.ts) || 0 : 0
      if (ts > max) max = ts
    }
    return max
  }

  function reveal() {
    revealed = true
    holdOpen = false
    if (hideTimer) hideTimer.restart()
    if (tape) tape.x = 0
    if (scroll && !Style.reduceMotion) scroll.restart()
  }

  function conceal() {
    revealed = false
    holdOpen = false
    if (scroll && (scroll.running || scroll.paused)) scroll.stop()
  }

  readonly property string tapeText: {
    if (!items || items.length === 0)
      return "waiting on agent comms"
    var parts = []
    for (var i = items.length - 1; i >= 0; i--) {
      var row = items[i]
      if (!row || !row.text) continue
      var who = row.agent || "agent"
      parts.push(row.role === "in" ? ("you → " + who + "   " + row.text) : (who + " → you   " + row.text))
    }
    return parts.length ? parts.join("      ·      ") : "waiting on agent comms"
  }

  function applyFeed(raw) {
    var text = String(raw || "")
    if (!text.trim()) return
    var next = []
    try {
      var parsed = JSON.parse(text)
      if (!parsed || !parsed.items) return
      next = parsed.items
    } catch (error) {
      return
    }
    var stamp = newestStamp(next)
    root.items = next
    if (!primed) {
      primed = true
      seenStamp = stamp
      return
    }
    if (stamp > seenStamp) {
      seenStamp = stamp
      reveal()
    }
  }

  visible: revealed
  implicitWidth: revealed ? (vertical ? barSize : maxWidth) : 0
  implicitHeight: revealed ? barSize : 0

  Timer {
    id: hideTimer
    interval: root.visibleMs
    onTriggered: {
      if (root.hovered) root.holdOpen = true
      else root.conceal()
    }
  }

  Item {
    anchors.fill: parent
    visible: !root.vertical

    Text {
      id: mark
      text: root.markText
      textFormat: Text.PlainText
      color: root.ink
      font.family: root.fontFamily
      font.pixelSize: Style.font.body
      font.bold: true
      anchors.left: parent.left
      anchors.verticalCenter: parent.verticalCenter
      opacity: 0.72
    }

    Item {
      id: clip
      anchors.left: mark.right
      anchors.leftMargin: Style.space(16)
      anchors.right: parent.right
      anchors.top: parent.top
      anchors.bottom: parent.bottom
      clip: true

      Row {
        id: tape
        spacing: 0
        anchors.verticalCenter: parent.verticalCenter
        x: 0

        Text {
          text: root.tapeText + "      ·      "
          textFormat: Text.PlainText
          color: root.ink
          font.family: root.fontFamily
          font.pixelSize: Style.font.body
        }
        Text {
          text: root.tapeText + "      ·      "
          textFormat: Text.PlainText
          color: root.ink
          font.family: root.fontFamily
          font.pixelSize: Style.font.body
        }
      }

      NumberAnimation {
        id: scroll
        target: tape
        property: "x"
        from: 0
        to: -root.span
        duration: Math.max(3000, root.span / root.speed * 1000)
        loops: Animation.Infinite
        easing.type: Easing.Linear
        running: root.revealed && root.span > 8 && !Style.reduceMotion
      }
    }
  }

  Text {
    visible: root.vertical && root.revealed
    anchors.centerIn: parent
    text: "•"
    textFormat: Text.PlainText
    color: root.ink
    font.family: root.fontFamily
    font.pixelSize: Style.font.body
  }

  HoverHandler {
    onHoveredChanged: {
      root.hovered = hovered
      if (hovered) {
        if (scroll.running && !scroll.paused) scroll.pause()
      } else {
        if (scroll.paused) scroll.resume()
        if (root.holdOpen) root.conceal()
      }
    }
  }

  Process {
    id: producer
    command: ["python3", "-B", "-u", root.omarchyPath + "/shell/plugins/agent-comms/feed.py", "--apps", root.apps]
    running: root.omarchyPath.length > 0
    onExited: revive.start()
  }

  Timer {
    id: revive
    interval: 1500
    onTriggered: if (root.omarchyPath.length > 0) producer.running = true
  }

  FileView {
    path: root.feedPath
    watchChanges: true
    printErrors: false
    onLoaded: root.applyFeed(text())
    onFileChanged: reload()
  }
}
