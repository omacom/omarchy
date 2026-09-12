import QtQuick
import Quickshell.Io

Item {
  id: root
  visible: false
  property bool active: false
  property bool paused: false
  property bool live: false
  property string period: "week"
  property string provider: "all"
  property string project: "*"
  property string search: ""
  property int offset: 0
  property var snapshot: ({projects: [], rows: [], tokens: 0, calls: 0, records: 0, errors: []})
  property string error: ""
  property bool pending: false
  readonly property bool busy: collector.running
  onPeriodChanged: resetPage()
  onProviderChanged: { project = "*"; resetPage() }
  onProjectChanged: resetPage()
  onSearchChanged: resetPage()
  onOffsetChanged: refreshDelay.restart()
  onActiveChanged: { if (active) refreshDelay.restart(); else refreshDelay.stop() }
  onPausedChanged: if (!paused && active) refreshDelay.restart()
  function resetPage() { offset = 0; refreshDelay.restart() }
  function refresh() {
    if (collector.running) { pending = true; return }
    collector.command = ["python3", decodeURIComponent(Qt.resolvedUrl("bin/tracking.py").toString().substring(7)),
      "--period", period, "--provider", provider, "--project", project, "--search", search, "--offset", String(offset)]
    collector.running = true
  }
  property var detail: null
  property string detailId: ""
  readonly property bool detailBusy: detailReader.running
  function loadDetails(id) {
    detailId = id
    detail = null
    if (!detailReader.running) readDetails()
  }
  function readDetails() {
    detailReader.command = ["python3", decodeURIComponent(Qt.resolvedUrl("bin/tracking.py").toString().substring(7)), "--detail", detailId]
    detailReader.requestedId = detailId
    detailReader.running = true
  }
  Process {
    id: detailReader
    property string requestedId: ""
    onExited: { if (root.detailId !== requestedId) root.readDetails() }
    stdout: StdioCollector {
      onStreamFinished: {
        try {
          var result = JSON.parse(text)
          if (result.id === root.detailId) root.detail = result
        } catch (e) { root.detail = null }
      }
    }
  }
  Timer { id: refreshDelay; interval: 250; onTriggered: if (root.active) root.refresh() }
  Timer { interval: root.live ? 5000 : 30000; repeat: true; running: root.active && !root.paused; onTriggered: if (!root.busy) root.refresh() }
  Process {
    id: collector
    onExited: (code, status) => {
      if (code !== 0) root.error = "Não foi possível atualizar. Tentando novamente…"
      if (root.pending) { root.pending = false; refreshDelay.restart() }
    }
    stdout: StdioCollector {
      onStreamFinished: {
        try { root.snapshot = JSON.parse(text); root.error = "" }
        catch (e) { root.error = "Resposta do coletor inválida" }
      }
    }
  }
}
