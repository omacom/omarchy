pragma ComponentBehavior: Bound
import QtQuick
import Quickshell
import Quickshell.Wayland
import "AmigaInput" as Native

Item {
  id: root
  property string token: ""
  property string monitorName: ""
  property string appId: ""
  property string reason: ""
  property bool dismissed: false
  property bool armed: false
  property bool frameReady: false
  property bool requestedMuted: true
  property bool audioMuted: true
  property int audioRevision: 0
  property int navigationRevision: 0
  property string navigationDirection: ""
  function requestNavigation(direction) {
    navigationDirection = direction
    navigationRevision++
  }
  property string hintOn: "M = Turn On Audio"
  property string hintOff: "M = Turn Off Audio"
  function requestAudioToggle() { requestedMuted = !requestedMuted; audioRevision++ }
  function audioApplied(owner, revision, muted) {
    if (owner !== token || !active || revision !== audioRevision) return "stale"
    audioMuted = muted; hint.restart(); return "ok"
  }
  Timer { id: hint; interval: 2000 }
  property string demoTitle: ""
  property bool titlePending: false
  property int presentationGeneration: 0
  property int titlePendingGeneration: 0
  function frameArrived(generation) {
    if (titlePending && generation === titlePendingGeneration && active && !dismissed) {
      frameReady = true; titlePending = false; titleHint.restart(); hint.restart()
    }
  }
  Timer { id: titleHint; interval: 5000 }

  signal opened(string owner)
  signal closed(string owner)
  readonly property bool active: token !== ""
  readonly property var source: {
    const windows = ToplevelManager.toplevels.values
    for (const w of windows) if (w.appId === root.appId) return w
    return null
  }
  function begin(owner, monitor) {
    if (active || !/^[a-f0-9]{32}$/.test(owner)) return "busy"
    if (!motion.ready) return "input-unavailable"
    requestedMuted = true; audioMuted = true; audioRevision = 0; navigationRevision = 0; navigationDirection = ""
    presentationGeneration = 0; titlePendingGeneration = 0; titlePending = false; titleHint.stop(); demoTitle = ""
    monitorName = monitor; appId = ""; dismissed = false; reason = ""; armed = true
    token = owner; lease.restart(); hint.restart(); opened(owner); return "ok"
  }
  function poll(owner) {
    if (owner !== token || !active) return JSON.stringify({state: "closed", reason: reason || "ownership-lost"})
    lease.restart()
    return JSON.stringify({state: dismissed ? "dismissed" : "active", reason: reason, frameReady: frameReady, armed: armed, requestedMuted: requestedMuted, audioMuted: audioMuted, audioRevision: audioRevision, titleVisible: titleHint.running, demoTitle: demoTitle, hintVisible: hint.running, hintText: audioMuted ? hintOn : hintOff, relativeReady: motion.ready, navigationRevision: navigationRevision, navigationDirection: navigationDirection})
  }
  function present(owner, monitor, id, title) {
    if (owner !== token || !active || dismissed) return "closed"
    if (!/^org\.omarchy\.amiga-screensaver\.[a-f0-9]{32}$/.test(id)) return "invalid"
    titleHint.stop(); appId = ""; monitorName = monitor; frameReady = false
    presentationGeneration++; titlePendingGeneration = presentationGeneration
    demoTitle = title || ""; titlePending = true; appId = id; return "ok"
  }
  function cover(owner) {
    if (owner !== token || !active || dismissed) return "closed"
    appId = ""; frameReady = false; reason = ""; titlePending = false; titleHint.stop(); return "ok"
  }
  function dismiss(why) { if (!dismissed) { dismissed = true; reason = why } }
  function end(owner) {
    if (owner !== token || !active) return "closed"
    token = ""; appId = ""; lease.stop(); closed(owner); return "ok"
  }
  Timer { id: lease; interval: 10000; onTriggered: { root.reason = "lease-expired"; root.end(root.token) } }
  // Classified protocol deltas share Qt's actual wl_pointer/connection.
  // ext-idle-notify cannot exempt M; never infer key identity from timing.
  Native.RelativeMotion {
    id: motion
    onButton: { if (root.active) root.dismiss("button") }
    onWheel: { if (root.active) root.dismiss("wheel") }
    onMotion: (dx, dy) => { if (root.active && (dx !== 0 || dy !== 0)) root.dismiss("motion") }
    onReadyChanged: { if (root.active && !ready) root.dismiss("input-unavailable") }
  }
  Variants {
    model: Quickshell.screens
    PanelWindow {
      id: panel
      required property var modelData
      screen: modelData
      visible: root.active
      anchors { top: true; bottom: true; left: true; right: true }
      color: "black"
      exclusionMode: ExclusionMode.Ignore
      WlrLayershell.namespace: "omarchy-amiga-screensaver"
      WlrLayershell.layer: WlrLayer.Overlay
      WlrLayershell.keyboardFocus: WlrKeyboardFocus.Exclusive
      // Export ONLY the owned toplevel, never the output (which recurses and
      // includes pinned panels). Opaque overlay keeps desktop UI underneath.
      ScreencopyView {
        anchors.fill: parent
        captureSource: panel.screen.name === root.monitorName ? root.source : null
        live: root.active && !root.dismissed
        paintCursor: false
        onCaptureSourceChanged: {
          const generation = root.presentationGeneration
          Qt.callLater(function() {
            if (panel.screen.name === root.monitorName && captureSource && hasContent)
              root.frameArrived(generation)
          })
        }
        onHasContentChanged: if (panel.screen.name === root.monitorName) {
          if (!hasContent) root.frameReady = false
          else root.frameArrived(root.presentationGeneration)
        }
        onStopped: if (root.active && root.source) root.reason = "capture-stopped"
      }
      Item {
        anchors.fill: parent; focus: true
        Keys.onPressed: event => {
          event.accepted = true
          if (event.key === Qt.Key_M) {
            if (!event.isAutoRepeat) root.requestAudioToggle()
          } else if (event.key === Qt.Key_Left || event.key === Qt.Key_Right) {
            if (!event.isAutoRepeat) root.requestNavigation(event.key === Qt.Key_Left ? "previous" : "next")
          } else root.dismiss("key")
        }
        Keys.onReleased: event => { event.accepted = true }
      }
      MouseArea {
        anchors.fill: parent; hoverEnabled: true
        acceptedButtons: Qt.AllButtons; cursorShape: Qt.BlankCursor
        onPressed: root.dismiss("button")
        onWheel: root.dismiss("wheel")
        // Absolute position/enter includes compositor warps; intentionally ignored.
      }
      Rectangle {
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottom: controls.top; anchors.bottomMargin: 12
        width: Math.min(titleLabel.implicitWidth + 32, parent.width - 64)
        height: titleLabel.implicitHeight + 18
        radius: 8; color: "#202020"
        visible: root.active && titleHint.running && root.demoTitle !== "" && panel.screen.name === root.monitorName
        Text {
          id: titleLabel; anchors.centerIn: parent
          width: Math.min(implicitWidth, parent.width - 32)
          text: root.demoTitle; textFormat: Text.PlainText; elide: Text.ElideRight
          font.pixelSize: 18; color: "white"
        }
      }
      Rectangle {
        id: controls
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottom: parent.bottom; anchors.bottomMargin: 32
        width: hintLabel.implicitWidth + 32; height: hintLabel.implicitHeight + 18
        radius: 8; color: "#202020"
        visible: root.active && hint.running && panel.screen.name === root.monitorName
        Text {
          id: hintLabel; anchors.centerIn: parent
          text: (root.audioMuted ? root.hintOn : root.hintOff) + "   |   ← / →"
          font.pixelSize: 18; color: "white"
        }
      }
    }
  }
}
