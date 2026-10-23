import QtQuick
import Quickshell
import Quickshell.Io
import "BrightnessModel.js" as BrightnessModel

Item {
  id: root

  property var state: BrightnessModel.initial()
  readonly property int percent: state.percent
  readonly property bool available: state.available
  signal verified(int percent)

  function readGeneration() {
    return BrightnessModel.readGeneration(state)
  }

  function acceptRead(monitor, raw, generation) {
    var previousEpoch = state.epoch
    state = BrightnessModel.acceptRead(state, monitor, raw, generation)
    if (state.epoch !== previousEpoch) debounce.stop()
  }

  function request(value, osd = false) {
    debounce.stop()
    state = BrightnessModel.request(state, value, osd)
    startLatest()
  }

  function preview(value) {
    state = BrightnessModel.request(state, value, false)
    debounce.restart()
  }

  function startLatest() {
    if (writeProc.running || state.active || !state.latest) return
    debounce.stop()
    state = BrightnessModel.start(state)
    writeProc.request = state.active
    writeProc.command = ["omarchy-brightness-display", "--no-osd", "--monitor", state.active.epoch.monitor, state.active.target + "%"]
    writeProc.running = true
  }

  function finish(request, success) {
    var result = BrightnessModel.finish(state, request, success)
    if (result.state === state) return
    state = result.state
    if (result.verified !== null) verified(result.verified)
    if (state.latest) Qt.callLater(startLatest)
  }

  Timer {
    id: debounce
    interval: 180
    repeat: false
    onTriggered: root.startLatest()
  }

  Process {
    id: writeProc
    property var request: null
    stdout: StdioCollector { waitForEnd: true }
    onExited: function(exitCode, exitStatus) {
      root.finish(request, exitStatus === 0 && exitCode === 0)
    }
    onRunningChanged: {
      if (running) return
      // A failed start only changes running. Let a normal exit complete first.
      var completedRequest = request
      Qt.callLater(function() {
        if (!writeProc.running) root.finish(completedRequest, false)
      })
    }
  }
}
