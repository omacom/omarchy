import Quickshell.Io
import QtQuick
import "MenuModel.js" as MenuModel

// Owns the complete lifecycle of one lazy activity search: debounce, worker
// reuse, request correlation, streamed reduction, retry, and idle shutdown.
// Consumers only schedule searches and observe results for a scope/query pair.
Item {
  id: controller

  property bool active: false
  property int limit: 15
  property int generation: 0
  property string candidateScope: ""
  property string candidateQuery: ""
  property string resultScope: ""
  property string resultQuery: ""
  property var results: []
  property string errorMessage: ""
  readonly property bool pending: debounce.running || worker.requestPending

  signal resultsReady()

  function hasResults(scope, query) {
    return resultScope === scope && resultQuery === query
  }

  function search(scope, query) {
    scope = String(scope || "")
    query = String(query || "").trim()
    if (!scope || !query || hasResults(scope, query)) return
    if (candidateScope === scope && candidateQuery === query
        && (debounce.running || worker.requestPending)) return

    generation += 1
    candidateScope = scope
    candidateQuery = query
    resultScope = ""
    resultQuery = ""
    results = []
    errorMessage = ""
    worker.requestPending = false
    worker.streamRows = []
    worker.streamStarted = false
    worker.restartCount = 0
    idle.stop()
    debounce.restart()
  }

  function cancel() {
    generation += 1
    candidateScope = ""
    candidateQuery = ""
    resultScope = ""
    resultQuery = ""
    results = []
    errorMessage = ""
    debounce.stop()
    worker.requestPending = false
    worker.streamRows = []
    worker.streamStarted = false
    if (worker.running) idle.restart()
  }

  function shutdown() {
    cancel()
    idle.stop()
    if (worker.running) worker.running = false
  }

  function requestJson() {
    return JSON.stringify({
      version: 1,
      queryId: String(worker.generation),
      query: candidateQuery,
      kind: candidateScope,
      limit: limit
    }) + "\n"
  }

  function launch() {
    if (!candidateScope || !candidateQuery) return
    idle.stop()
    worker.generation = generation
    worker.streamRows = []
    worker.streamStarted = false
    worker.requestPending = true
    worker.restartCount = 0
    var request = requestJson()
    if (worker.running) {
      worker.write(request)
    } else {
      worker.queuedRequest = request
      worker.running = true
    }
  }

  function publish(rows, failed, message) {
    resultScope = candidateScope
    resultQuery = candidateQuery
    results = rows.slice()
    errorMessage = failed ? String(message || "Search failed") : ""
    resultsReady()
  }

  Timer {
    id: debounce
    interval: 40
    repeat: false
    onTriggered: controller.launch()
  }

  Timer {
    id: idle
    interval: 5000
    repeat: false
    onTriggered: {
      if (worker.running && !worker.requestPending) worker.running = false
    }
  }

  Process {
    id: worker
    command: ["omarchy-activity", "search", "--worker"]
    stdinEnabled: true
    property int generation: -1
    property var streamRows: []
    property bool streamStarted: false
    property bool requestPending: false
    property string queuedRequest: ""
    property int restartCount: 0

    onStarted: {
      if (queuedRequest) {
        write(queuedRequest)
        queuedRequest = ""
      }
    }

    stdout: SplitParser {
      onRead: function(data) {
        if (worker.generation !== controller.generation
            || !controller.candidateScope || !controller.candidateQuery) return

        try {
          var event = JSON.parse(data)
          var next = MenuModel.reduceScopeSearchEvent(
            worker.streamRows,
            worker.streamStarted,
            event,
            String(worker.generation)
          )
          if (!next.accepted) return

          worker.streamRows = next.rows
          worker.streamStarted = next.started
          if (next.terminal) {
            worker.requestPending = false
            idle.restart()
          }

          if (event.type === "rows" && next.changed) {
            controller.publish(next.rows, false, "")
          } else if (event.type === "done" && next.changed) {
            controller.publish([], false, "")
          } else if (event.type === "error") {
            controller.publish(next.rows, true, event.message)
          }
        } catch (error) {
          worker.requestPending = false
          idle.restart()
          controller.publish(worker.streamRows, true, "Invalid search response")
        }
      }
    }

    onExited: function(exitCode, exitStatus) {
      if (controller.active && requestPending && restartCount < 1
          && generation === controller.generation
          && controller.candidateScope && controller.candidateQuery) {
        restartCount += 1
        queuedRequest = controller.requestJson()
        running = true
      } else if (requestPending) {
        requestPending = false
      }
    }
  }
}
