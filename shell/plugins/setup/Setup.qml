import QtQuick
import Quickshell
import Quickshell.Wayland
import qs.Commons
import qs.Commons as Commons
import qs.Ui

// Welcome: the first-login onboarding tour for Omarchy essentials, re-openable
// anytime from Setup > Welcome or `omarchy launch setup`. docs/setup.md covers
// the flow and IPC reply contract.
//
//   omarchy-shell shell summon omarchy.setup '{}'
Item {
  id: root

  property string omarchyPath: Quickshell.env("OMARCHY_PATH")
  property var shell: null
  property var manifest: null

  property bool opened: false
  property bool hasOpenedOnce: false
  // Each opening is a request. One that `omarchy-launch-setup --wait` made
  // names a runtime directory for the reply: one marker file per outcome token,
  // then `closed` last.
  property string reply: ""
  // Whether this request has actually appeared on screen.
  property bool seen: false
  // Steps a finished tour set off.
  property var picked: []
  // Whether the user actually reached the Agent step or Ready screen during
  // this request, so first-run can suppress duplicate notifications.
  property bool sawAgent: false
  property bool sawReady: false

  function open(payloadJson) {
    var payload = {}
    try { payload = JSON.parse(payloadJson || "{}") || {} } catch (e) {}

    if (Number(payload.expires) > 0 && Date.now() / 1000 > Number(payload.expires)) {
      if (!opened) Qt.callLater(function() { if (!root.opened) root.dismiss() })
      return
    }

    var reopen = hasOpenedOnce
    var replacing = opened
    hasOpenedOnce = true

    release(replacing)
    reply = String(payload.reply || "")
    if (opened && panel.contentRevealed) {
      var request = reply
      Qt.callLater(function() {
        if (root.opened && root.reply === request) root.seen = true
      })
    }

    if (reopen) data.reload()
    card.start()
    opened = true
    Qt.callLater(function() {
      if (root.opened) keys.forceActiveFocus()
    })
  }

  function close() {
    opened = false
    release(false)
  }

  // Whether `omarchy-shell omarchy.agents open` has a live handler to reach.
  function agentsPanelThere() {
    var handler = IpcRegistry.handlerFor("omarchy.agents")
    return !!handler && IpcRegistry.declaredFunctions(handler).indexOf("open") !== -1 && handler.open.length === 0
  }

  // Answers whoever is waiting on this request, if it was seen: a marker for
  // each picked step (and seen-agent / seen-ready / replaced when applicable),
  // then `closed` last.
  function release(wasReplaced) {
    if (reply !== "" && seen) {
      var names = picked.filter(function(step) { return /^[a-z][a-z-]*$/.test(step) })
      if (sawAgent && names.indexOf("seen-agent") === -1) names.push("seen-agent")
      if (sawReady && names.indexOf("seen-ready") === -1) names.push("seen-ready")
      if (wasReplaced && names.indexOf("replaced") === -1) names.push("replaced")
      names.push("closed")
      Quickshell.execDetached(["touch", "--"].concat(names.map(function(name) { return root.reply + "/" + name })))
    }
    reply = ""
    seen = false
    picked = []
    sawAgent = false
    sawReady = false
  }

  function owns(request) {
    return opened && (String(request || "").charAt(0) !== "/" || request === reply)
  }

  function state(request) {
    if (!owns(request)) return "other"
    return seen ? "shown" : "opening"
  }

  function cancel(request) {
    if (owns(request)) dismiss()
  }

  function dismiss() {
    if (shell && typeof shell.hide === "function") shell.hide((manifest && manifest.id) || "omarchy.setup")
    else close()
  }

  function finish(argv, steps) {
    picked = steps
    // Close the overlay before launching anything so terminals or panels never
    // open behind Welcome.
    dismiss()
    if (argv.length > 0) Util.execArgv(argv)
  }

  SetupData {
    id: data
    omarchyPath: root.omarchyPath
  }

  OverlayWindow {
    id: panel
    shown: root.opened
    WlrLayershell.namespace: "omarchy-setup"

    onContentRevealedChanged: {
      if (!contentRevealed) return
      root.seen = true
      card.entered()
    }

    Rectangle {
      anchors.fill: parent
      color: Commons.Color.menu.scrim
    }

    // Stray clicks outside the tour card should not discard choices in progress.
    MouseArea {
      anchors.fill: parent
    }

    Item {
      id: keys
      anchors.fill: parent
      focus: true

      Keys.onPressed: function(event) {
        if (card.handleKey(event)) event.accepted = true
      }

      SetupCard {
        id: card
        anchors.centerIn: parent
        steps: data.steps
        offers: data.offers
        ready: data.ready
        readonly property real fit: Math.min(1, (keys.width - Style.space(32)) / width, (keys.height - Style.space(32)) / height)
        scale: fit * (panel.contentRevealed ? 1 : 0.97)
        opacity: panel.contentRevealed ? 1 : 0

        Behavior on scale {
          enabled: panel.contentRevealed
          NumberAnimation { duration: Style.duration(180); easing.type: Easing.Bezier; easing.bezierCurve: Style.easeOut }
        }
        Behavior on opacity {
          enabled: panel.contentRevealed
          NumberAnimation { duration: Style.duration(180); easing.type: Easing.OutCubic }
        }

        onDismissed: root.dismiss()
        onAboutToList: data.freezeAgents(root.agentsPanelThere())
        onStepViewed: function(stepId) {
          if (stepId === "agent") root.sawAgent = true
          else if (stepId === "ready") root.sawReady = true
        }
        onFinished: function(argv, steps) { root.finish(argv, steps) }
      }
    }
  }
}
