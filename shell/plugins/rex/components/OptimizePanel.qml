import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import qs.Commons
import qs.Commons as Commons
import qs.Ui
import "../lib/Analyze.js" as Analyze
import "../lib/Compare.js" as Compare
import "../lib/Parser.js" as Parser

// What could make the pattern faster, safer, or clearer. Every suggested
// rewrite is run on the real engine against the test text before it can be
// applied, and a backtracking risk can be measured on texts built to
// trigger it.
Item {
  id: root

  property var app

  readonly property color foreground: app.foreground
  readonly property color accent: app.accent
  readonly property color dim: Qt.darker(foreground, 1.5)
  readonly property var findings: app.findings

  // finding index -> { id, verdict, detail } for rewrites being checked
  property var checks: ({})
  // finding index -> { ids, sizes, times } for witness measurements
  property var measures: ({})
  property int generation: 0

  function severityColor(s) {
    if (s === "danger") return Commons.Color.urgent
    if (s === "warning") return Qt.hsla(0.1, 0.8, 0.6, 1)
    if (s === "tip") return root.accent
    return root.dim
  }

  // Each rewrite runs as soon as the original's result is in.
  function verifyAll() {
    generation++
    measures = ({})
    var next = {}
    if (!app.result.done || app.result.ok === false || app.result.id === undefined) { checks = next; return }
    for (var i = 0; i < findings.length; i++) {
      var f = findings[i]
      if (!f.rewrite) continue
      var id = app.engine.match({
        flavor: app.flavor,
        pattern: f.rewrite,
        flags: app.flags,
        text: app.testText,
        textPath: app.textFile,
        textVersion: app.textVersion,
        all: app.all,
        limit: 100000,
        parsed: Parser.parse(f.rewrite, app.flavor, app.flags),
        channel: "verify",
        keep: true,
      })
      next[i] = { id: id, verdict: "checking", detail: "Checking on your text…" }
    }
    checks = next
  }

  function measure(index) {
    var f = findings[index]
    var sizes = [6, 10, 14, 18, 22, 26]
    var ids = []
    for (var s = 0; s < sizes.length; s++) {
      var text = Analyze.witness(f, sizes[s])
      ids.push(app.engine.match({
        flavor: app.flavor, pattern: app.pattern, flags: app.flags, text: text,
        textVersion: 1000000 + generation * 100 + s, all: false, limit: 1,
        parsed: app.parsed, channel: "measure", keep: true,
      }))
    }
    var next = {}
    for (var k in measures) next[k] = measures[k]
    next[index] = { ids: ids, sizes: sizes, times: sizes.map(function() { return null }) }
    measures = next
  }

  Timer { id: verifyTimer; interval: 150; onTriggered: root.verifyAll() }
  onFindingsChanged: verifyTimer.restart()
  Connections {
    target: root.app
    function onResultChanged() { if (root.app.result.done) verifyTimer.restart() }
  }

  Connections {
    target: root.app.engine
    function onResult(reply) {
      if (!reply.done) return
      for (var key in root.checks) {
        var c = root.checks[key]
        if (c.id !== reply.id) continue
        var f = root.findings[key]
        var result = { ok: reply.ok, matches: reply.matches, stride: reply.stride, count: reply.ok ? reply.matches.length / reply.stride : 0, error: reply.error }
        var verdict, detail
        if (reply.ok === false) { verdict = "error"; detail = "The rewrite does not compile: " + reply.error }
        else {
          var cmp = Compare.compare(root.app.result, result)
          if (cmp.verdict === "same" || (cmp.verdict === "groups" && f.changesGroups)) { verdict = "same"; detail = "The same matches on your text" + (f.changesGroups ? " (group numbers change)" : "") + (reply.elapsed !== undefined ? ", in " + root.app.formatMs(reply.elapsed) + " against " + root.app.formatMs(root.app.result.elapsed) : "") }
          else { verdict = "different"; detail = "Not the same on your text: " + cmp.detail }
        }
        var next = {}
        for (var k in root.checks) next[k] = root.checks[k]
        next[key] = { id: c.id, verdict: verdict, detail: detail }
        root.checks = next
        return
      }
      for (var m in root.measures) {
        var entry = root.measures[m]
        var at = entry.ids.indexOf(reply.id)
        if (at < 0) continue
        var times = entry.times.slice()
        times[at] = reply.ok === false ? ({ timeout: "timed out", limit: "hit the engine's limit" }[reply.kind] || "error") : reply.elapsed
        var updated = {}
        for (var n in root.measures) updated[n] = root.measures[n]
        updated[m] = { ids: entry.ids, sizes: entry.sizes, times: times }
        root.measures = updated
        return
      }
    }
  }

  ListView {
    id: list
    anchors.fill: parent
    clip: true
    model: root.findings
    spacing: Style.spacing.md
    boundsBehavior: Flickable.StopAtBounds
    ScrollBar.vertical: ScrollBar {}

    delegate: Rectangle {
      id: card
      required property int index
      required property var modelData
      readonly property var check: root.checks[index]
      readonly property var measured: root.measures[index]

      width: list.width - Style.spacing.lg
      height: content.implicitHeight + Style.spacing.lg * 2
      radius: Style.cornerRadius
      color: Util.alpha(root.foreground, 0.03)
      border.width: 1
      border.color: Util.alpha(root.severityColor(modelData.severity), 0.35)

      HoverHandler {
        onHoveredChanged: root.app.patternHighlight = hovered && card.modelData.end > card.modelData.start ? [card.modelData.start, card.modelData.end] : []
      }

      ColumnLayout {
        id: content
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.margins: Style.spacing.lg
        spacing: Style.spacing.sm

        RowLayout {
          Layout.fillWidth: true
          spacing: Style.spacing.md

          Text {
            text: { return { danger: "Danger", warning: "Warning", tip: "Tip", info: "Note" }[card.modelData.severity] }
            color: root.severityColor(card.modelData.severity)
            font.family: Style.font.family
            font.pixelSize: Style.font.caption
            font.bold: true
          }

          Text {
            Layout.fillWidth: true
            text: card.modelData.title
            color: root.foreground
            wrapMode: Text.Wrap
            font.family: Style.font.family
            font.pixelSize: Style.font.bodySmall
            textFormat: Text.PlainText
          }
        }

        Text {
          Layout.fillWidth: true
          text: card.modelData.detail
          color: root.dim
          wrapMode: Text.Wrap
          font.family: Style.font.family
          font.pixelSize: Style.font.caption
          textFormat: Text.PlainText
        }

        Rectangle {
          Layout.fillWidth: true
          visible: card.modelData.rewrite !== ""
          implicitHeight: rewriteText.implicitHeight + Style.spacing.md * 2
          radius: Style.cornerRadius
          color: Util.alpha(root.foreground, 0.05)

          Text {
            id: rewriteText
            anchors.fill: parent
            anchors.margins: Style.spacing.md
            text: card.modelData.rewrite
            color: root.foreground
            wrapMode: Text.WrapAnywhere
            font.family: Style.font.family
            font.pixelSize: Style.font.body
            textFormat: Text.PlainText
          }
        }

        RowLayout {
          Layout.fillWidth: true
          visible: card.modelData.rewrite !== "" || !!card.modelData.witness
          spacing: Style.spacing.md

          Text {
            Layout.fillWidth: true
            visible: card.modelData.rewrite !== ""
            text: card.check ? card.check.detail : "Waiting for the original's matches…"
            color: card.check && card.check.verdict === "same" ? root.accent : (card.check && card.check.verdict !== "checking" ? Commons.Color.urgent : root.dim)
            wrapMode: Text.Wrap
            font.family: Style.font.family
            font.pixelSize: Style.font.caption
            textFormat: Text.PlainText
          }

          Item { Layout.fillWidth: true; visible: card.modelData.rewrite === "" }

          Button {
            visible: !!card.modelData.witness
            text: "Measure"
            tooltipText: "Time the pattern on texts built to trigger this, of growing length"
            bordered: true
            onClicked: root.measure(card.index)
          }

          Button {
            visible: card.modelData.rewrite !== ""
            text: "Apply"
            tooltipText: card.check && card.check.verdict === "same" ? "Use the rewritten pattern" : "Only a rewrite that matches the same on your text can be applied"
            bordered: true
            enabled: !!card.check && card.check.verdict === "same"
            opacity: enabled ? 1 : 0.4
            onClicked: root.app.pattern = card.modelData.rewrite
          }
        }

        // Timings on texts of growing length: steady doubling is exponential.
        Flow {
          Layout.fillWidth: true
          visible: !!card.measured
          spacing: Style.spacing.lg

          Repeater {
            model: card.measured ? card.measured.sizes.length : 0
            Text {
              required property int index
              readonly property var time: card.measured.times[index]
              text: card.measured.sizes[index] + " chars: " + (time === null ? "…" : (typeof time === "number" ? root.app.formatMs(time) : time))
              color: typeof time === "string" ? Commons.Color.urgent : root.foreground
              font.family: Style.font.family
              font.pixelSize: Style.font.caption
            }
          }
        }
      }
    }
  }

  Text {
    anchors.centerIn: parent
    width: parent.width - Style.spacing.xxl * 2
    horizontalAlignment: Text.AlignHCenter
    visible: root.findings.length === 0
    text: root.app.pattern === "" ? "Type a pattern to have it reviewed" : (root.app.parsed.errors.length ? "Fix the pattern's errors first" : "Nothing to improve that Rex can see")
    color: root.dim
    wrapMode: Text.Wrap
    font.family: Style.font.family
    font.pixelSize: Style.font.body
  }
}
