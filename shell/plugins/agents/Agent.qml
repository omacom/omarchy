import QtQuick
import QtQml.WorkerScript
import Quickshell.Io

// One agent's usage record, read straight off the data file that
// omarchy-agent-usage-update maintains. The panel never learns how the
// numbers were made — a record that appears in the usage directory is an
// agent, whoever wrote it.
Item {
  id: root
  visible: false

  property string agentId: ""
  property string path: ""
  property var record: null
  readonly property var dailyUsage: record && record.dailyUsage ? record.dailyUsage : null

  property int parseGeneration: 0
  property int pendingGeneration: 0
  property string pendingContent: ""
  property bool parserBusy: false

  WorkerScript {
    id: parser
    source: "ApiCost.js"
    onReadyChanged: root.dispatchParse()
    onMessage: function(message) {
      root.parserBusy = false
      root.acceptParsedRecord(message.generation, message.record)
      root.dispatchParse()
    }
  }

  FileView {
    path: root.path
    watchChanges: true
    printErrors: false
    onFileChanged: reload()
    onLoaded: root.parse(text())
    onLoadFailed: {
      root.parseGeneration++
      root.pendingGeneration = 0
      root.pendingContent = ""
      root.record = null
    }
  }

  function parse(content) {
    pendingGeneration = ++parseGeneration
    pendingContent = String(content || "")
    dispatchParse()
  }

  function dispatchParse() {
    if (!parser.ready || parserBusy || pendingGeneration === 0) return
    parserBusy = true
    parser.sendMessage({ generation: pendingGeneration, content: pendingContent })
    pendingGeneration = 0
    pendingContent = ""
  }

  function acceptParsedRecord(generation, parsed) {
    // A newer file read/removal wins over an older background result.
    if (generation !== parseGeneration) return
    if (record && parsed) {
      // Limit-only changes reuse the same compact usage objects and price cache.
      var fields = ["dailyUsage", "recentDays", "modelUsage"]
      for (var i = 0; i < fields.length; i++) {
        var key = fields[i]
        if (JSON.stringify(record[key]) === JSON.stringify(parsed[key]))
          parsed[key] = record[key]
      }
    }
    record = parsed
  }
}
