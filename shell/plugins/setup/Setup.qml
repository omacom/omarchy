import QtQuick
import Quickshell
import Quickshell.Wayland
import qs.Commons
import qs.Commons as Commons
import qs.Ui
import "../menu/MenuModel.js" as MenuModel

// Setup: the welcome tour a new user is greeted with, and pages that show what
// each row of the Setup menu does. docs/setup.md has how it is put together.
//
//   omarchy-shell shell summon omarchy.setup '{"mode":"tour"}'
//   omarchy-shell shell summon omarchy.setup '{"page":"security"}'
Item {
  id: root

  property string omarchyPath: Quickshell.env("OMARCHY_PATH")
  property var shell: null
  property var manifest: null

  property bool opened: false
  // Each opening is a request. One that omarchy-launch-setup --wait made
  // names a directory to be answered in, the way the menu answers
  // omarchy-menu-select in a file, and goes by that name: Setup can be opened
  // again while a caller waits, and the caller must not take the new
  // request's window for its own.
  property string reply: ""
  // Whether this request has been on screen. One that closed before its
  // window was ever shown was not seen, and must not count as taken.
  property bool seen: false
  // The steps a finished tour set off, for the caller to be told.
  property var picked: []

  function open(payloadJson) {
    var payload = {}
    try { payload = JSON.parse(payloadJson || "{}") || {} } catch (e) {}

    // A request can sit queued while this plugin loads. One whose caller has
    // stopped waiting by then must not be answered with a window nobody is
    // waiting on.
    if (Number(payload.expires) > 0 && Date.now() / 1000 > Number(payload.expires)) {
      if (!opened) Qt.callLater(root.dismiss)
      return
    }

    // Opened again while open: the request before this one is over.
    release()
    reply = String(payload.reply || "")
    // A window already on screen shows this request from its next frame.
    if (opened && panel.contentRevealed) {
      var request = reply
      Qt.callLater(function() {
        if (root.opened && root.reply === request) root.seen = true
      })
    }

    card.start(payload.mode === "tour" ? "tour" : "app", String(payload.page || ""))
    opened = true
    // The window is built hidden, so focus set then lands nowhere: take it
    // again once the surface is mapped.
    Qt.callLater(function() {
      if (root.opened) keys.forceActiveFocus()
    })
  }

  function close() {
    opened = false
    release()
  }

  // Answers whoever is waiting on this request, if it was seen: a file for
  // each step picked, then `closed`. The shell unloads this plugin as soon as
  // it closes, so the files are written by a process of its own, and one that
  // starts no login shell on its way.
  function release() {
    if (reply !== "" && seen) {
      var names = picked.filter(function(step) { return /^[a-z][a-z-]*$/.test(step) }).concat(["closed"])
      Quickshell.execDetached(["touch", "--"].concat(names.map(function(name) { return root.reply + "/" + name })))
    }
    reply = ""
    seen = false
    picked = []
  }

  // Whether a request is this one. A caller that names none means whichever
  // is open.
  function owns(request) {
    return opened && (String(request || "").charAt(0) !== "/" || request === reply)
  }

  // Where a request stands: "opening" until it is on screen, "shown" from
  // then on, and "other" once Setup is closed or has moved on to another.
  // omarchy-launch-setup --wait asks this before and while it waits.
  function state(request) {
    if (!owns(request)) return "other"
    return seen ? "shown" : "opening"
  }

  // Closes a request that is still the one open, and leaves any other alone.
  function cancel(request) {
    if (owns(request)) dismiss()
  }

  function dismiss() {
    if (shell && typeof shell.hide === "function") shell.hide((manifest && manifest.id) || "omarchy.setup")
    else close()
  }

  // A row runs as it does from the menu, which then has the screen to itself:
  // a terminal or a picker opened under this overlay could not be reached.
  function run(option) {
    var summon = option.route ? { id: "omarchy.menu", payload: JSON.stringify({ menu: option.route }) } : MenuModel.summonAction(option.action)
    if (!(summon && shell && shell.summon(summon.id, summon.payload)) && option.action) Util.execDetached(option.action)
    dismiss()
  }

  function finish(argv, steps) {
    if (argv.length > 0) Util.execArgv(argv)
    picked = steps
    dismiss()
  }

  SetupData {
    id: data
    omarchyPath: root.omarchyPath
  }

  OverlayWindow {
    id: panel
    shown: root.opened
    WlrLayershell.namespace: "omarchy-setup"

    // The splash plays for whoever can see it: a window still waiting for its
    // scale would have spent the first frames unseen.
    onContentRevealedChanged: {
      if (!contentRevealed) return
      root.seen = true
      card.entered()
    }

    Rectangle {
      anchors.fill: parent
      color: Commons.Color.menu.scrim
    }

    // The pages close on a click outside them, as the menu does. The tour
    // holds choices a stray click should not cost, so it leaves by Escape or Skip.
    MouseArea {
      anchors.fill: parent
      onClicked: if (!card.touring) root.dismiss()
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
        pages: data.pages
        steps: data.steps
        offer: data.offer
        ready: data.ready
        // A screen too small for the card shows all of it, smaller.
        readonly property real fit: Math.min(1, (keys.width - Style.space(32)) / width, (keys.height - Style.space(32)) / height)
        scale: fit * (panel.contentRevealed ? 1 : 0.97)
        opacity: panel.contentRevealed ? 1 : 0

        // Grows in like a panel. Closing unmaps the window, so there is no way out to animate.
        Behavior on scale {
          enabled: panel.contentRevealed
          NumberAnimation { duration: Style.duration(180); easing.type: Easing.Bezier; easing.bezierCurve: Style.easeOut }
        }
        Behavior on opacity {
          enabled: panel.contentRevealed
          NumberAnimation { duration: Style.duration(180); easing.type: Easing.OutCubic }
        }

        onDismissed: root.dismiss()
        onActivated: function(option) { root.run(option) }
        onFinished: function(argv, steps) { root.finish(argv, steps) }
      }
    }
  }
}
