import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import qs.Commons
import qs.Commons as Commons
import qs.Ui
import "../lib/Flavors.js" as Flavors
import "../lib/Parser.js" as Parser
import "../lib/Bench.js" as Bench

// The workbench's pattern timed on every installed engine. Engines run one
// after another, never side by side, so they do not compete for the CPU;
// each runs several times and the median counts. A time is the engine's own
// measure of compiling the pattern and finding every match.
Item {
  id: root

  property var app

  readonly property color foreground: app.foreground
  readonly property color accent: app.accent
  readonly property color dim: Qt.darker(foreground, 1.5)

  property int runs: 5
  property int scale: 1
  property bool running: false
  // [{ flavor, name, times: [], matches, error }]
  property var rows: []
  property var queue: []
  property int pendingId: 0
  property string pendingFlavor: ""
  property string benchText: ""
  property int benchVersion: 0
  readonly property var ranked: Bench.rank(rows)

  // Everything a run measures, fixed when it starts, so editing the
  // workbench or the controls mid-run cannot mix inputs into one result.
  property var frozen: null

  function start() {
    var flavors = Flavors.FLAVORS.filter(function(f) { return root.app.engine.supports(f.id) })
    var text = root.app.testText
    benchText = scale === 1 ? text : new Array(scale + 1).join(text)
    benchVersion = 2000000 + Math.floor(Math.random() * 1000000)
    frozen = {
      pattern: root.app.pattern,
      flags: root.app.flags.slice(),
      textPath: scale === 1 ? root.app.textFile : "",
      textVersion: scale === 1 ? root.app.textVersion : benchVersion,
    }
    rows = flavors.map(function(f) { return { flavor: f.id, name: f.name, times: [], matches: null, error: "" } })
    var jobs = []
    // A warm-up run first, which is not counted, then the timed runs.
    for (var i = 0; i < flavors.length; i++) for (var r = 0; r <= runs; r++) jobs.push({ flavor: flavors[i].id, warmup: r === 0 })
    queue = jobs
    running = true
    next()
  }

  function stop() {
    queue = []
    running = false
    pendingId = 0
  }

  function next() {
    if (!queue.length) { running = false; pendingId = 0; return }
    var job = queue[0]
    queue = queue.slice(1)
    var flags = Flavors.validFlags(job.flavor, frozen.flags)
    pendingFlavor = job.flavor
    pendingWarmup = job.warmup
    pendingCount = 0
    pendingId = root.app.engine.match({
      flavor: job.flavor,
      pattern: frozen.pattern,
      flags: flags,
      text: benchText,
      // A repeated text is sent to each worker once; an opened file is read
      // from disk as on the workbench.
      textPath: frozen.textPath,
      textVersion: frozen.textVersion,
      all: true,
      limit: 1000000,
      parsed: Parser.parse(frozen.pattern, job.flavor, flags),
      channel: "bench",
    })
  }

  property bool pendingWarmup: false
  // Matches so far for the request in flight; streaming engines send them
  // in batches.
  property int pendingCount: 0

  Connections {
    target: root.app.engine
    function onResult(reply) {
      if (reply.id !== root.pendingId) return
      if (reply.ok !== false) root.pendingCount += reply.matches.length / reply.stride
      if (!reply.done) return
      var updated = root.rows.map(function(r) {
        if (r.flavor !== root.pendingFlavor) return r
        var copy = { flavor: r.flavor, name: r.name, times: r.times.slice(), matches: r.matches, error: r.error }
        if (reply.ok === false) copy.error = reply.error || "failed"
        else {
          copy.matches = root.pendingCount
          if (!root.pendingWarmup) copy.times.push(reply.elapsed)
        }
        copy.median = Bench.median(copy.times)
        copy.min = Bench.minimum(copy.times)
        return copy
      })
      root.rows = updated
      // A flavor that failed once will fail again; skip its other runs.
      if (reply.ok === false) root.queue = root.queue.filter(function(j) { return j.flavor !== root.pendingFlavor })
      root.next()
    }
  }

  ColumnLayout {
    anchors.fill: parent
    anchors.margins: Style.spacing.panelPadding
    spacing: Style.spacing.lg

    RowLayout {
      Layout.fillWidth: true
      spacing: Style.spacing.lg

      Text {
        text: "Benchmark"
        color: root.foreground
        font.family: Style.font.family
        font.pixelSize: Style.font.heading
        font.bold: true
      }

      Item { Layout.fillWidth: true }

      Text { text: "runs"; color: root.dim; font.family: Style.font.family; font.pixelSize: Style.font.caption }
      ButtonGroup {
        options: ["3", "5", "10"]
        value: String(root.runs)
        onChanged: function(value) { root.runs = parseInt(value, 10) }
      }

      Text { text: "text"; color: root.dim; font.family: Style.font.family; font.pixelSize: Style.font.caption }
      ButtonGroup {
        options: [{ value: "1", label: "×1" }, { value: "10", label: "×10" }, { value: "100", label: "×100" }]
        value: String(root.scale)
        onChanged: function(value) { root.scale = parseInt(value, 10) }
      }

      Button {
        text: root.running ? "Stop" : "Run"
        bordered: true
        enabled: root.app.pattern !== ""
        onClicked: root.running ? root.stop() : root.start()
      }
    }

    Text {
      Layout.fillWidth: true
      text: "Each engine compiles the pattern and finds every match in the test text" + (root.running && root.frozen && root.frozen.pattern !== root.app.pattern ? " (running the pattern as it was when the run started)" : "") + (root.scale > 1 ? " repeated " + root.scale + " times" : "") + ", " + root.runs + " times after a warm-up run. Engines run one at a time. Times include compiling, which interpreted engines usually cache."
      textFormat: Text.PlainText
      color: root.dim
      wrapMode: Text.Wrap
      font.family: Style.font.family
      font.pixelSize: Style.font.caption
    }

    ListView {
      id: list
      Layout.fillWidth: true
      Layout.fillHeight: true
      clip: true
      model: root.ranked
      spacing: Style.spacing.sm
      boundsBehavior: Flickable.StopAtBounds
      ScrollBar.vertical: ScrollBar {}

      delegate: RowLayout {
        required property var modelData
        width: list.width - Style.spacing.lg
        spacing: Style.spacing.lg

        Text {
          Layout.preferredWidth: Style.space(150)
          text: modelData.name
          textFormat: Text.PlainText
          color: root.foreground
          font.family: Style.font.family
          font.pixelSize: Style.font.body
          font.bold: modelData.flavor === root.app.flavor
          elide: Text.ElideRight
        }

        Item {
          Layout.fillWidth: true
          Layout.preferredHeight: Style.font.body * 1.4

          Rectangle {
            visible: !modelData.error
            anchors.verticalCenter: parent.verticalCenter
            height: parent.height * 0.6
            width: Math.max(2, parent.width * modelData.share)
            radius: Style.cornerRadius
            color: modelData.flavor === root.app.flavor ? root.accent : Util.alpha(root.accent, 0.45)
          }

          Text {
            anchors.verticalCenter: parent.verticalCenter
            visible: !!modelData.error
            width: parent.width
            text: modelData.error
            color: Commons.Color.urgent
            elide: Text.ElideRight
            font.family: Style.font.family
            font.pixelSize: Style.font.caption
            textFormat: Text.PlainText
          }
        }

        Text {
          Layout.preferredWidth: Style.space(170)
          horizontalAlignment: Text.AlignRight
          text: modelData.median === null || modelData.median === undefined
            ? (root.running && !modelData.error ? "…" : "")
            : root.app.formatMs(modelData.median) + " median, " + root.app.formatMs(modelData.min) + " best"
          textFormat: Text.PlainText
          color: root.foreground
          font.family: Style.font.family
          font.pixelSize: Style.font.caption
        }

        Text {
          Layout.preferredWidth: Style.space(90)
          horizontalAlignment: Text.AlignRight
          text: modelData.matches === null ? "" : modelData.matches + " found"
          textFormat: Text.PlainText
          color: root.dim
          font.family: Style.font.family
          font.pixelSize: Style.font.caption
        }
      }
    }
  }
}
