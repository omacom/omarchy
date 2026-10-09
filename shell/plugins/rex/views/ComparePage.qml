import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import qs.Commons
import qs.Commons as Commons
import qs.Ui
import "../lib/Flavors.js" as Flavors
import "../lib/Parser.js" as Parser
import "../lib/Compare.js" as Compare

// One pattern on every installed engine at once, compared with the
// workbench's flavor: where they agree, where they differ, and why a
// flavor rejects the pattern outright.
Item {
  id: root

  property var app

  readonly property color foreground: app.foreground
  readonly property color accent: app.accent
  readonly property color dim: Qt.darker(foreground, 1.5)

  // flavor id -> { id, result } for the current run
  property var runs: ({})
  property var order: []
  property int generation: 0
  property string selected: ""

  readonly property var reference: runs[app.flavor] ? runs[app.flavor].result : null

  function run() {
    if (!visible) return
    var flavors = Flavors.FLAVORS.filter(function(f) { return root.app.engine.supports(f.id) })
    var next = {}
    generation++
    for (var i = 0; i < flavors.length; i++) {
      var f = flavors[i]
      // Each flavor gets the flags it has in common with the workbench's.
      var flags = Flavors.validFlags(f.id, root.app.flags)
      var parsed = Parser.parse(root.app.pattern, f.id, flags)
      var id = root.app.engine.match({
        flavor: f.id,
        pattern: root.app.pattern,
        flags: flags,
        text: root.app.testText,
        textPath: root.app.textFile,
        textVersion: root.app.textVersion,
        all: root.app.all,
        limit: 10000,
        parsed: parsed,
        channel: "compare",
        keep: true,
      })
      next[f.id] = { id: id, flags: flags, parserErrors: parsed.errors, result: null }
    }
    order = flavors.map(function(f) { return f.id })
    runs = next
  }

  onVisibleChanged: if (visible) runTimer.restart()

  Connections {
    target: root.app
    function onPatternChanged() { runTimer.restart() }
    function onTestTextChanged() { runTimer.restart() }
    function onFlagsChanged() { runTimer.restart() }
    function onAllChanged() { runTimer.restart() }
  }

  Connections {
    target: root.app.engine
    function onDetectedChanged() { runTimer.restart() }
    function onResult(reply) {
      for (var flavor in root.runs) {
        var entry = root.runs[flavor]
        if (entry.id !== reply.id) continue
        var previous = entry.result
        var matches = previous && !previous.done ? previous.matches.concat(reply.matches) : reply.matches
        var next = {}
        for (var key in root.runs) next[key] = root.runs[key]
        next[flavor] = {
          id: entry.id,
          flags: entry.flags,
          parserErrors: entry.parserErrors,
          result: {
            ok: reply.ok, done: reply.done, error: reply.error || "", kind: reply.kind || "",
            building: reply.building || "", matches: matches, stride: reply.stride,
            count: reply.ok ? matches.length / reply.stride : 0, elapsed: reply.elapsed,
          },
        }
        root.runs = next
        return
      }
    }
  }

  Timer {
    id: runTimer
    interval: 250
    onTriggered: root.run()
  }

  function verdict(flavor) {
    var entry = runs[flavor]
    if (!entry || !entry.result) return { verdict: "running", detail: "running…" }
    var r = entry.result
    if (r.building) return { verdict: "running", detail: "building the engine (first use only)…" }
    if (!r.done) return { verdict: "running", detail: "running…" }
    if (flavor === app.flavor) return r.ok === false ? { verdict: "error", detail: r.error } : { verdict: "reference", detail: "the workbench's flavor" }
    if (!reference || !reference.done) return { verdict: "running", detail: "waiting for " + app.flavorInfo.name + "…" }
    return Compare.compare(reference, r)
  }

  function verdictColor(v) {
    if (v === "same" || v === "reference") return root.accent
    if (v === "error") return Commons.Color.urgent
    if (v === "different" || v === "groups") return Qt.hsla(0.12, 0.8, 0.6, 1)
    return root.dim
  }

  ColumnLayout {
    anchors.fill: parent
    anchors.margins: Style.spacing.panelPadding
    spacing: Style.spacing.lg

    Text {
      text: "Compare flavors"
      color: root.foreground
      font.family: Style.font.family
      font.pixelSize: Style.font.heading
      font.bold: true
    }

    Text {
      Layout.fillWidth: true
      text: "The workbench's pattern and text on every installed engine, measured against " + root.app.flavorInfo.name + ". Each flavor gets the flags it shares with " + root.app.flavorInfo.name + "."
      color: root.dim
      wrapMode: Text.Wrap
      font.family: Style.font.family
      font.pixelSize: Style.font.caption
    }

    Text {
      visible: root.app.pattern === ""
      text: "Type a pattern on the workbench first."
      color: root.dim
      font.family: Style.font.family
      font.pixelSize: Style.font.body
    }

    ListView {
      id: list
      Layout.fillWidth: true
      Layout.fillHeight: true
      visible: root.app.pattern !== ""
      clip: true
      model: root.order
      spacing: Style.spacing.xs
      boundsBehavior: Flickable.StopAtBounds
      ScrollBar.vertical: ScrollBar {}

      delegate: Rectangle {
        id: row
        required property string modelData
        readonly property var info: Flavors.byId(modelData)
        readonly property var entry: root.runs[modelData]
        readonly property var result: entry ? entry.result : null
        readonly property var v: root.verdict(modelData)

        width: list.width - Style.spacing.lg
        height: content.implicitHeight + Style.spacing.md * 2
        radius: Style.cornerRadius
        color: root.selected === modelData ? Util.alpha(root.accent, 0.12) : (mouse.containsMouse ? Util.alpha(root.foreground, 0.05) : Util.alpha(root.foreground, 0.025))

        MouseArea {
          id: mouse
          anchors.fill: parent
          hoverEnabled: true
          onClicked: root.selected = root.selected === row.modelData ? "" : row.modelData
        }

        ColumnLayout {
          id: content
          anchors.left: parent.left
          anchors.right: parent.right
          anchors.top: parent.top
          anchors.margins: Style.spacing.md
          spacing: Style.spacing.xs

          RowLayout {
            Layout.fillWidth: true
            spacing: Style.spacing.lg

            Rectangle {
              Layout.preferredWidth: Style.spacing.md
              Layout.preferredHeight: Style.spacing.md
              radius: width / 2
              color: root.verdictColor(row.v.verdict)
            }

            Text {
              Layout.preferredWidth: Style.space(150)
              text: row.info.name
              color: root.foreground
              font.family: Style.font.family
              font.pixelSize: Style.font.body
              font.bold: row.modelData === root.app.flavor
              elide: Text.ElideRight
            }

            Text {
              Layout.preferredWidth: Style.space(110)
              text: row.result && row.result.done && row.result.ok !== false ? (row.result.count === 1 ? "1 match" : row.result.count + " matches") : ""
              color: root.foreground
              font.family: Style.font.family
              font.pixelSize: Style.font.bodySmall
            }

            Text {
              Layout.preferredWidth: Style.space(80)
              text: row.result && row.result.done && row.result.ok !== false ? root.app.formatMs(row.result.elapsed) : ""
              color: root.dim
              horizontalAlignment: Text.AlignRight
              font.family: Style.font.family
              font.pixelSize: Style.font.caption
            }

            Text {
              Layout.fillWidth: true
              text: row.v.detail
              color: row.v.verdict === "error" ? Commons.Color.urgent : root.dim
              elide: Text.ElideRight
              font.family: Style.font.family
              font.pixelSize: Style.font.caption
              textFormat: Text.PlainText
            }

            Button {
              visible: row.modelData !== root.app.flavor
              text: "Use"
              tooltipText: "Make " + row.info.name + " the workbench's flavor"
              bordered: true
              onClicked: root.app.setFlavor(row.modelData)
            }
          }

          // Details when selected: the full error, Rex's own reading, and
          // the first matches side by side with the reference.
          ColumnLayout {
            Layout.fillWidth: true
            Layout.leftMargin: Style.spacing.xxl
            visible: root.selected === row.modelData
            spacing: Style.spacing.xs

            Text {
              Layout.fillWidth: true
              visible: !!row.result && row.result.ok === false
              text: row.result ? row.result.error : ""
              color: Commons.Color.urgent
              wrapMode: Text.Wrap
              font.family: Style.font.family
              font.pixelSize: Style.font.caption
              textFormat: Text.PlainText
            }

            Repeater {
              model: row.entry ? row.entry.parserErrors.slice(0, 3) : []
              Text {
                required property var modelData
                Layout.fillWidth: true
                text: "Rex reads: " + modelData.message
                color: root.dim
                wrapMode: Text.Wrap
                font.family: Style.font.family
                font.pixelSize: Style.font.caption
                textFormat: Text.PlainText
              }
            }

            Text {
              visible: !!row.entry && row.entry.flags.join("") !== root.app.flags.join("")
              text: "Ran with flags: " + (row.entry && row.entry.flags.length ? row.entry.flags.join(" ") : "none")
              color: root.dim
              font.family: Style.font.family
              font.pixelSize: Style.font.caption
            }

            Repeater {
              model: row.result && row.result.ok !== false ? Math.min(row.result.count, 12) : 0
              Text {
                required property int index
                readonly property int base: index * row.result.stride
                readonly property var ref: root.reference
                readonly property bool differs: !ref || ref.ok === false || index >= ref.count
                  || ref.matches[index * ref.stride] !== row.result.matches[base]
                  || ref.matches[index * ref.stride + 1] !== row.result.matches[base + 1]
                Layout.fillWidth: true
                text: (index + 1) + "  " + row.result.matches[base] + "–" + row.result.matches[base + 1] + "  " + JSON.stringify(root.app.testText.substring(row.result.matches[base], Math.min(row.result.matches[base + 1], row.result.matches[base] + 80)))
                color: differs && row.modelData !== root.app.flavor ? Qt.hsla(0.12, 0.8, 0.6, 1) : root.foreground
                elide: Text.ElideRight
                font.family: Style.font.family
                font.pixelSize: Style.font.caption
                textFormat: Text.PlainText
              }
            }
          }
        }
      }
    }
  }
}
