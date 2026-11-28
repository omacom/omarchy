import QtQuick
import Quickshell
import Quickshell.Wayland
import qs.Commons
import qs.Commons as Commons

// Full-screen fingerprint setup: a big fingerprint on a darkened scrim with one
// status line. Summoning it registers the next free finger, running the whole
// setup in the background (packages, enrollment, a verifying touch, PAM for
// sudo, polkit and the lock screen) after one authorization prompt, which is
// asked before the panel shows so the two never share the screen. Once a
// finger is registered it signs off and closes by itself; dismissing it
// earlier stops a run in flight. omarchy-setup-security-fingerprint summons it.
//
// A failure the status line can't explain closes the panel and opens what the
// commands said in a floating terminal.
//
// For looking at it without touching root or the reader:
//   omarchy-shell shell summon omarchy.fingerprint '{"demo": true}'
//   omarchy-shell shell summon omarchy.fingerprint '{"demo": "fail"}'
Item {
  id: root

  property var shell: null
  property var manifest: null

  property bool opened: false
  // Fades the whole panel out after the sign-off.
  property real veil: 1

  NumberAnimation {
    id: fadeOut
    target: root
    property: "veil"
    to: 0
    duration: Style.duration(240)
    easing.type: Easing.OutCubic
    onFinished: root.dismiss()
  }

  function open(payloadJson) {
    var payload = {}
    try { payload = JSON.parse(payloadJson || "{}") || {} } catch (e) {}
    enrollment.demo = payload.demo === true || payload.demo === "fail"
    enrollment.demoFails = payload.demo === "fail"
    enrollment.cancel()
    fadeOut.stop()
    root.veil = 1
    root.opened = true
    enrollment.begin()
  }

  function close() {
    root.opened = false
    enrollment.cancel()
    fadeOut.stop()
    view.settle()
  }

  function dismiss() {
    if (root.shell && typeof root.shell.hide === "function")
      root.shell.hide((root.manifest && root.manifest.id) || "omarchy.fingerprint")
    else close()
  }

  Enrollment {
    id: enrollment
    reason: Commons.I18n.t("fingerprint.authorize")
    // A dismissed authorization prompt ends it there: nothing was shown yet.
    onDismissedChanged: if (dismissed && root.opened) Qt.callLater(root.dismiss)
    onFailureKindChanged: {
      if (!root.opened || failureKind === "" || failureKind === "line") return
      if (failureKind === "terminal") {
        // A reader its platform keeps off: the terminal setup explains what
        // turning it on means, asks, and carries on from there.
        Quickshell.execDetached(["omarchy-launch-floating-terminal-with-presentation",
          "omarchy-setup-security-fingerprint --terminal"])
      } else {
        // What the commands said, at the end, where the error is.
        Quickshell.execDetached(["setsid", "uwsm-app", "--", "xdg-terminal-exec", "--app-id=org.omarchy.terminal",
          "--title=Omarchy", "-e", "less", "+G", logPath])
      }
      // Dismissing resets the failure this handler is answering, so let the
      // change settle first.
      Qt.callLater(root.dismiss)
    }
  }

  PanelWindow {
    id: window
    // Right-to-left languages read this window mirrored.
    Binding { target: window.contentItem; property: "LayoutMirroring.enabled"; value: Commons.I18n.rightToLeft }
    Binding { target: window.contentItem; property: "LayoutMirroring.childrenInherit"; value: true }

    // The authorization prompt comes first, on its own: the panel only maps
    // once the helper is running, or there is something else to say.
    visible: root.opened && enrollment.phase !== "idle" && enrollment.phase !== "auth"
    // Mapped hidden, so take the focus and open the transmission once the
    // surface is actually on screen.
    onVisibleChanged: {
      if (visible) Qt.callLater(function() {
        if (root.opened && window.visible) view.transmit()
      })
    }
    anchors { top: true; bottom: true; left: true; right: true }
    color: "transparent"
    exclusionMode: ExclusionMode.Ignore
    WlrLayershell.namespace: "omarchy-fingerprint"
    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.Exclusive

    Rectangle {
      anchors.fill: parent
      color: Qt.rgba(0, 0, 0, 0.82)
      opacity: root.veil

      // A stray click must not throw away a scan in flight.
      MouseArea {
        anchors.fill: parent
        onClicked: if (!enrollment.busy) root.dismiss()
      }
    }

    EnrollView {
      id: view
      anchors.fill: parent
      ctl: enrollment
      onCloseRequested: root.dismiss()
      onSignedOff: if (root.opened) fadeOut.restart()
      opacity: root.veil
    }
  }
}
