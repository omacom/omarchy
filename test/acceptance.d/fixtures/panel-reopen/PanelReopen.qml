import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import qs.Commons
import qs.Ui

// Installed temporarily by the acceptance test, inside the whole running
// Omarchy shell. No production IPC or component hooks are added for this test.
Item {
  id: root
  property string omarchyPath: Quickshell.env("OMARCHY_PATH")
  property var shell: null
  property var manifest: null
  property var pluginRegistry: null
  property bool opened: false
  property string phase: "idle"
  property string error: ""
  property int unmaps: 0
  property int unmapsBeforeClose: 0
  property bool retainedMapping: false
  property int escapeDelay: 0
  property int escapeCount: 0
  property double reopenedAt: 0
  property double escapeAt: 0
  property bool primedAtEscape: false
  property bool targetFocusedAtEscape: false
  property bool windowActiveAtEscape: false
  property bool activationLost: false
  property bool activationGained: false
  property bool escapePending: false
  readonly property bool observedWindowActive: panel.focusTarget ? panel.focusTarget.Window.active : false

  onObservedWindowActiveChanged: observeWindowActivation()

  function observeWindowActivation() {
    if (root.phase !== "closing-for-reopen" && root.phase !== "waiting-for-escape") return
    if (!root.observedWindowActive) {
      root.activationLost = true
      if (root.phase === "closing-for-reopen") Qt.callLater(root.reopenAfterFocusRelease)
    }
    else if (root.phase === "waiting-for-escape" && root.activationLost) root.activationGained = true
    root.sendEscapeWhenReady()
  }

  function sendEscapeWhenReady() {
    if (!root.escapePending || root.phase !== "waiting-for-escape" || !root.activationGained || !root.observedWindowActive) return
    if (root.escapeDelay === 1 && panel.focusPrimed) { root.abort("keyboard activation missed the early focus-prime window"); return }
    root.escapePending = false
    escapeProcess.running = true
  }

  function abort(message) {
    error = message
    phase = "failed"
    warmup.stop()
    sendEscape.stop()
    deadline.stop()
    escapePending = false
    opened = false
  }

  function open(payloadJson) {
    if (phase !== "idle" && phase !== "done") { abort("previous trial unfinished"); return }
    if (panel.backingWindowVisible) { abort("trial must start fully unmapped"); return }
    var payload
    try { payload = JSON.parse(payloadJson) } catch (e) { abort("invalid trial payload"); return }
    if (payload.escapeDelay !== 1 && payload.escapeDelay !== 110) { abort("invalid Escape delay"); return }
    error = ""
    escapeDelay = payload.escapeDelay
    escapeCount = 0
    reopenedAt = 0
    escapeAt = 0
    retainedMapping = false
    targetFocusedAtEscape = false
    windowActiveAtEscape = false
    activationLost = false
    activationGained = false
    escapePending = false
    primedAtEscape = false
    phase = "warming"
    opened = true
    deadline.restart()
  }

  function close() {
    warmup.stop()
    sendEscape.stop()
    deadline.stop()
    escapePending = false
    opened = false
    phase = "idle"
  }

  ShellIpc {
    target: "acceptance.panel-reopen"
    function refreshStyle(): bool {
      if (Style.animationsProc.running) return false
      Style.refresh()
      return true
    }
    function begin(): bool {
      if (root.phase !== "ready") { root.abort("initial panel is not ready"); return false }
      if (!root.observedWindowActive) { root.abort("initial panel window is not active"); return false }
      root.activationLost = false
      root.activationGained = false
      root.unmapsBeforeClose = root.unmaps
      root.phase = "closing-for-reopen"
      root.opened = false
      deadline.restart()
      return true
    }
    function state(): string {
      return JSON.stringify({phase: root.phase, error: root.error,
        activationLost: root.activationLost, activationGained: root.activationGained,
        escapePending: root.escapePending, windowActive: root.observedWindowActive,
        windowActiveAtEscape: root.windowActiveAtEscape,
        fadeDuration: Style.duration(140), mapped: panel.backingWindowVisible,
        open: root.opened, unmaps: root.unmaps,
        unmapsBeforeClose: root.unmapsBeforeClose, retainedMapping: root.retainedMapping,
        escapeCount: root.escapeCount,
        elapsedToEscape: root.escapeCount > 0 ? root.escapeAt - root.reopenedAt : null,
        primedAtEscape: root.primedAtEscape, targetFocusedAtEscape: root.targetFocusedAtEscape})
    }
  }

  PanelWindow {
    id: anchorWindow
    screen: Quickshell.screens.length ? Quickshell.screens[0] : null
    visible: true
    color: "transparent"
    exclusionMode: ExclusionMode.Ignore
    anchors { top: true; left: true; right: true }
    implicitHeight: 26
    mask: Region {}
    WlrLayershell.namespace: "omarchy-acceptance-anchor"
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.None
    Item { id: anchor; width: 26; height: 26 }
  }

  KeyboardPanel {
    id: panel
    anchorItem: anchor
    bar: null
    owner: root
    open: root.opened
    focusTarget: panel.loadedContent
    contentWidth: 320
    contentHeight: 100
    onBackingWindowVisibleChanged: {
      if (backingWindowVisible && root.phase === "warming") warmup.restart()
      if (!backingWindowVisible) {
        root.unmaps++
        if (root.phase === "closing-after-escape") {
          deadline.stop()
          root.phase = "done"
        }
      }
    }
    content: PanelKeyCatcher {
      implicitHeight: 60
      onCloseRequested: {
        if (root.phase !== "waiting-for-escape") { root.abort("Escape outside trial"); return }
        root.escapeCount++
        root.escapeAt = Date.now()
        root.primedAtEscape = panel.focusPrimed
        root.targetFocusedAtEscape = activeFocus
        root.windowActiveAtEscape = Window.active
        root.phase = "closing-after-escape"
        root.opened = false
      }
      Text {
        anchors.centerIn: parent
        text: "Panel fade-reopen acceptance"
        color: "white"
      }
    }
  }

  Timer {
    id: warmup
    // Settle the initial open animation before starting the measured close.
    interval: 300
    onTriggered: {
      if (Style.duration(140) <= 0) { root.abort("fade duration is zero"); return }
      if (!panel.open || !panel.backingWindowVisible) { root.abort("initial panel did not map"); return }
      root.phase = "ready"
    }
  }
  // Qt defers activation notification until a Wayland sync. Reopening on a
  // fixed timer can combine leave/enter into unchanged Window.active, so the
  // later input gate waits forever. Observe release before requesting focus
  // again; this must still happen during the real mapped fade.
  function reopenAfterFocusRelease() {
    if (root.phase !== "closing-for-reopen" || root.observedWindowActive) return
    root.retainedMapping = !panel.open && panel.visible && panel.backingWindowVisible
      && !panel.popoutSwitching && root.unmaps === root.unmapsBeforeClose
    if (!root.retainedMapping) { root.abort("panel unmapped before fade reopen"); return }
    root.phase = "waiting-for-escape"
    root.opened = true
    root.reopenedAt = Date.now()
    sendEscape.interval = root.escapeDelay
    sendEscape.restart()
  }
  Timer {
    id: sendEscape
    onTriggered: { root.escapePending = true; root.sendEscapeWhenReady() }
  }
  Process {
    id: escapeProcess
    command: ["wtype", "-k", "Escape"]
    onExited: function(exitCode) { if (exitCode !== 0) root.abort("wtype failed: " + exitCode) }
  }
  Timer {
    id: deadline
    interval: 15000
    onTriggered: root.abort(root.escapePending ? "panel window did not reactivate before Escape" : "one Escape did not close the fade-reopened panel")
  }
}
