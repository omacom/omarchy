import QtQuick
import Quickshell
import Quickshell.Io
import qs.Commons
import "Model.js" as Model

// One ModemManager watcher for the whole shell. Bar widgets on every monitor
// read this singleton through firstPartyServiceFor("omarchy.cellular") and
// hold it with acquire()/release(), so a shell without the widget in its bar
// starts nothing at all.
//
// State arrives as a push: a single long-running `gdbus monitor` on
// ModemManager's bus name. Signal quality is read straight off that stream;
// every other change (state, registration, bearers, a modem coming or going,
// the daemon restarting) schedules one debounced `mmcli` read. There is no
// periodic poll. The only timer that repeats reads two sysfs counters
// in-process while a panel is open to show them.
Item {
  id: root

  property var shell: null

  // Bar widgets holding the service, and panels showing session counters.
  property int consumers: 0
  property int openPanels: 0
  readonly property bool wanted: consumers > 0

  property var status: Model.parseStatus("", true)
  property int level: -1
  property string primaryIface: ""
  property real rxBytes: -1
  property real txBytes: -1
  property bool refreshing: false
  property string pendingAction: ""
  property string lastError: ""
  property real nowSeconds: Date.now() / 1000

  readonly property var view: Model.presentation(status, level, primaryIface, I18n.t, I18n.formatNumber)
  readonly property bool available: view.visual !== "hidden"
  readonly property string device: status.primaryPort
  readonly property string iface: status.bearer && status.bearer.connected ? status.bearer.iface : ""

  property bool _refreshQueued: false
  property int _monitorFailures: 0
  property real _monitorStartedAt: 0

  function acquire() {
    consumers += 1
  }

  function release() {
    consumers = Math.max(0, consumers - 1)
  }

  function panelOpened() {
    openPanels += 1
    nowSeconds = Date.now() / 1000
    refresh()
    readCounters()
  }

  function panelClosed() {
    openPanels = Math.max(0, openPanels - 1)
  }

  onWantedChanged: {
    if (wanted) {
      refresh()
    } else {
      debounce.stop()
      respawn.stop()
      monitor.running = false
    }
  }

  // Reads now, or right after the read in flight: a change that lands while
  // mmcli is still answering must not be lost behind its stale result.
  function refresh() {
    if (!wanted) return
    if (reader.running) {
      _refreshQueued = true
      return
    }
    refreshing = true
    reader.running = true
  }

  function scheduleRefresh() {
    debounce.restart()
  }

  function applyStatus(raw, exitCode) {
    var next = Model.parseStatus(raw, exitCode !== 127)
    primaryIface = Model.primaryRouteInterface(raw)
    level = next.present && next.signal >= 0 ? Model.signalLevel(next.signal, level) : -1
    status = next
    if (next.installed && wanted && !monitor.running && !respawn.running) monitor.running = true
    if (!next.bearer || !next.bearer.connected) {
      rxBytes = -1
      txBytes = -1
    }
  }

  function applySignal(quality) {
    if (!status.present) return
    var next = Object.assign({}, status)
    next.signal = Math.max(0, Math.min(100, quality))
    level = Model.signalLevel(next.signal, level)
    status = next
  }

  function handleMonitorLine(line) {
    var event = Model.classifyMonitorLine(line)
    if (event.kind === "signal") {
      applySignal(event.quality)
    } else if (event.kind === "owner") {
      if (event.present) {
        refresh()
      } else {
        // The daemon left the bus; mmcli would only say so slowly.
        status = Model.parseStatus("couldn't find the ModemManager process", true)
        level = -1
      }
    } else if (event.kind === "refresh") {
      scheduleRefresh()
    }
  }

  function readCounters() {
    if (iface === "") return
    rxFile.reload()
    txFile.reload()
  }

  function setData(enabled) {
    if (pendingAction !== "" || device === "") return
    lastError = ""
    pendingAction = enabled ? "connect" : "disconnect"
    action.command = ["nmcli", "device", enabled ? "connect" : "disconnect", device]
    action.running = true
  }

  function toggleData() {
    if (!view.canToggle) return
    setData(!view.connected)
  }

  // A burst of property changes (a reconnect sends a dozen) costs one read.
  Timer {
    id: debounce
    interval: 400
    onTriggered: root.refresh()
  }

  // gdbus monitor rides out ModemManager restarts on its own, printing the
  // name's new owner. It only ends when the system bus goes, or gdbus is
  // missing; back off so that is not a respawn loop.
  Timer {
    id: respawn
    onTriggered: if (root.wanted && root.status.installed) monitor.running = true
  }

  Timer {
    id: counters
    interval: 2000
    repeat: true
    running: root.openPanels > 0 && root.iface !== ""
    onTriggered: {
      root.nowSeconds = Date.now() / 1000
      root.readCounters()
    }
  }

  Process {
    id: monitor
    command: ["gdbus", "monitor", "--system", "--dest", "org.freedesktop.ModemManager1"]
    environment: ({ LC_ALL: "C" })
    onRunningChanged: if (running) root._monitorStartedAt = Date.now()
    onExited: {
      if (!root.wanted) return
      root._monitorFailures = Date.now() - root._monitorStartedAt < 30000 ? root._monitorFailures + 1 : 0
      respawn.interval = Math.min(60000, 1000 * Math.pow(2, root._monitorFailures))
      respawn.restart()
    }
    stdout: SplitParser {
      onRead: function(line) { root.handleMonitorLine(line) }
    }
  }

  // One read: the modem, each of its bearers, and the routing table that
  // says whether cellular is the uplink. Exit 127 means no mmcli, which is
  // ModemManager not installed.
  Process {
    id: reader
    command: ["bash", "-c", "command -v mmcli >/dev/null || exit 127\n"
      + "modem=$(mmcli -m any -K 2>&1)\n"
      + "printf '%s\\n' \"$modem\"\n"
      + "for bearer in $(printf '%s\\n' \"$modem\" | sed -n 's/^modem\\.generic\\.bearers\\.value\\[[0-9]*\\] *: *//p'); do mmcli -b \"$bearer\" -K 2>/dev/null; done\n"
      + "cat /proc/net/route"]
    environment: ({ LC_ALL: "C" })
    stdout: StdioCollector { id: readerOut; waitForEnd: true }
    onExited: function(exitCode) {
      root.refreshing = false
      root.applyStatus(String(readerOut.text || ""), exitCode)
      if (root._refreshQueued) {
        root._refreshQueued = false
        root.refresh()
      }
    }
  }

  Process {
    id: action
    stderr: StdioCollector { id: actionErr; waitForEnd: true }
    onExited: function(exitCode) {
      var message = String(actionErr.text || "").replace(/^Error:\s*/, "").replace(/\s+/g, " ").trim()
      if (exitCode !== 0) root.lastError = I18n.t("cellular.actionFailed").arg(message || String(exitCode))
      root.pendingAction = ""
      root.refresh()
    }
  }

  FileView {
    id: rxFile
    path: root.iface !== "" ? "/sys/class/net/" + root.iface + "/statistics/rx_bytes" : ""
    printErrors: false
    onLoaded: root.rxBytes = Model.parseCounter(text())
  }

  FileView {
    id: txFile
    path: root.iface !== "" ? "/sys/class/net/" + root.iface + "/statistics/tx_bytes" : ""
    printErrors: false
    onLoaded: root.txBytes = Model.parseCounter(text())
  }
}
