import QtQuick
import Quickshell
import Quickshell.Hyprland
import qs.Commons
import "SwitcherModel.js" as SwitcherModel

// Alt + Tab, the way Windows does it. A quick Alt + Tab goes back to the window
// used before; holding Alt shows every window, the one used last first, and
// Tab, Shift + Tab and the arrows move along them. Letting go of Alt goes to
// the one picked, Escape stays put, and Delete closes it. Every window is
// listed, whatever workspace or monitor it is on, minimized ones too.
//
// Hyprland binds Alt + Tab and Shift + Alt + Tab to the switcher.next and
// switcher.previous shortcuts, repeating while Tab is held, and both Alt keys
// to switcher.alt, which is released when Alt is let go. The shortcuts are
// registered here rather than in default/omarchy/shortcuts because the
// release matters. Hyprland's default/hypr/window-switcher.lua brings the
// window forward.
Item {
  id: root

  property var shell: null
  property var manifest: null

  // Window addresses, the one used last first, kept from Hyprland's focus
  // events. Hyprland keeps its own order too, but only hands it over when
  // asked, which is too late for a key press.
  property var order: []
  // Until Hyprland reports a focus change, nothing reads as focused, so the
  // focus history it gave at startup says which window is.
  property bool focusReported: false

  // A switch in progress: the windows as they were when it started, and the
  // one picked so far.
  property bool active: false
  // Opened from the command line rather than with Alt held, so letting go of
  // Alt does not end it. Enter, a click or Escape does.
  property bool sticky: false
  // A quick Alt + Tab is over before anything shows, as on Windows.
  property bool revealed: false
  property var entries: []
  property int selected: -1

  // Long enough that a quick Alt + Tab never flashes the switcher.
  readonly property int revealDelay: 100

  // Hyprland gives no window focus while the switcher's surface holds the
  // keyboard, so the window picked is brought forward once the surface is
  // gone. A pick made before the surface showed goes at once, and again
  // should the surface turn up after all.
  readonly property string overlayNamespace: "omarchy-switcher"
  property bool overlayMapped: false
  property var pendingActivation: null
  property var lastActivation: null

  GlobalShortcut {
    appid: "omarchy"
    name: "switcher.next"
    description: "Switch to the next window"
    onPressed: root.step(1)
  }

  GlobalShortcut {
    appid: "omarchy"
    name: "switcher.previous"
    description: "Switch to the previous window"
    onPressed: root.step(-1)
  }

  GlobalShortcut {
    appid: "omarchy"
    name: "switcher.alt"
    description: "Go to the window the switcher is on"
    onReleased: if (!root.sticky) root.commit()
  }

  Timer {
    id: revealTimer
    interval: root.revealDelay
    onTriggered: if (root.active) root.revealed = true
  }

  Connections {
    target: Hyprland
    function onRawEvent(event) {
      var name = event ? String(event.name) : ""
      if (name === "openlayer" && String(event.data) === root.overlayNamespace) {
        root.overlayMapped = true
        if (!root.active && root.lastActivation && Date.now() - root.lastActivation.at < 1000)
          root.pendingActivation = root.lastActivation
      } else if (name === "closelayer" && String(event.data) === root.overlayNamespace) {
        root.overlayMapped = false
        root.runPendingActivation()
      } else if (name === "activewindowv2") {
        root.focusReported = true
        root.order = SwitcherModel.touch(root.order, event.data)
        root.settleActivation(event.data)
      } else if (name === "closewindow") {
        root.order = SwitcherModel.forget(root.order, event.data)
      } else if (name === "movewindowv2") {
        var fields = String(event.data || "").split(",")
        if (fields.length >= 3 && fields.slice(2).join(",") === "special:minimized")
          root.order = SwitcherModel.demote(root.order, fields[0])
      }
    }
  }

  // A window that closes while the switcher is up leaves it, and the pick
  // stays on the same window.
  Connections {
    target: Hyprland.toplevels
    enabled: root.active
    function onValuesChanged() {
      var open = Hyprland.toplevels.values
      var entries = root.entries.slice()
      var selected = root.selected
      for (var i = entries.length - 1; i >= 0; i--) {
        if (open.indexOf(entries[i].toplevel) >= 0) continue
        entries.splice(i, 1)
        selected = SwitcherModel.indexAfterRemoval(selected, i, entries.length)
      }
      if (entries.length === root.entries.length) return
      if (entries.length === 0) {
        root.finish()
        return
      }
      root.entries = entries
      root.selected = selected
    }
  }

  function windowsNow() {
    var toplevels = Hyprland.toplevels.values
    var byWayland = new Map()
    for (var i = 0; i < toplevels.length; i++) {
      if (toplevels[i].wayland) byWayland.set(toplevels[i].wayland, toplevels[i])
    }

    var windows = []
    for (var j = 0; j < toplevels.length; j++) {
      var toplevel = toplevels[j]
      var ipc = toplevel.lastIpcObject || {}
      var owner = toplevel.wayland && toplevel.wayland.parent ? byWayland.get(toplevel.wayland.parent) : null
      var workspace = toplevel.workspace ? String(toplevel.workspace.name) : ""
      windows.push({
        address: SwitcherModel.normalizeAddress(toplevel.address),
        parent: owner ? SwitcherModel.normalizeAddress(owner.address) : "",
        shown: !!toplevel.wayland,
        minimized: workspace === "special:minimized",
        workspace: workspace,
        appId: toplevel.wayland ? String(toplevel.wayland.appId || "") : "",
        focusHistory: typeof ipc.focusHistoryID === "number" ? ipc.focusHistoryID : undefined,
        toplevel: toplevel
      })
    }
    return windows
  }

  function start(delta, sticky) {
    // Window sizes for the thumbnails; they arrive before the switcher shows.
    Hyprland.refreshToplevels()

    var windows = root.windowsNow()
    var focused = root.focusedAddress(windows)
    if (focused) root.order = SwitcherModel.touch(root.order, focused)

    var entries = SwitcherModel.orderWindows(root.order, windows)
    if (entries.length === 0) return

    root.entries = entries
    root.selected = SwitcherModel.firstPick(root.order, windows, focused, delta)
    root.sticky = sticky
    root.revealed = false
    root.active = true
    revealTimer.restart()
  }

  // The window with the keyboard. One just picked counts until Hyprland reports
  // it focused, so a quick second Alt + Tab goes back rather than to it again.
  function focusedAddress(windows) {
    var activation = root.pendingActivation || root.lastActivation
    if (activation && !activation.settled && Date.now() - activation.at < 1000) return activation.target
    for (var i = 0; i < windows.length; i++) {
      if (windows[i].toplevel.activated) return windows[i].address
    }
    if (root.focusReported) return ""
    for (var j = 0; j < windows.length; j++) {
      if (windows[j].focusHistory === 0) return windows[j].address
    }
    return ""
  }

  // An activation is done once its window has the keyboard, or once another
  // window took it first.
  function settleActivation(address) {
    var activation = root.lastActivation
    if (!activation || activation.settled) return
    var key = SwitcherModel.normalizeAddress(address)
    if (key === activation.target || activation.windows.indexOf(key) < 0) activation.settled = true
  }

  function step(delta) {
    if (!root.active) root.start(delta, false)
    else root.selected = SwitcherModel.stepIndex(root.selected, root.entries.length, delta)
  }

  function select(index) {
    if (root.active && index >= 0 && index < root.entries.length) root.selected = index
  }

  function finish() {
    revealTimer.stop()
    root.active = false
    root.sticky = false
    root.revealed = false
    root.entries = []
    root.selected = -1
  }

  function commit() {
    if (!root.active) return
    var entry = root.entries[root.selected]
    root.finish()
    if (entry) root.activate(entry.address)
  }

  function cancel() {
    root.finish()
  }

  // A window with a dialog open comes back with the dialog on top and focused,
  // as the dialog is what it is waiting on, and with any dialog between them.
  function activate(address) {
    var windows = root.windowsNow()
    var dialog = SwitcherModel.dialogFor(root.order, windows, address)
    var target = SwitcherModel.normalizeAddress(dialog ? dialog.address : address)
    var activation = {
      target: target,
      windows: SwitcherModel.lineage(windows, target),
      settled: false,
      at: Date.now()
    }
    root.order = SwitcherModel.touch(root.order, activation.target)
    root.lastActivation = activation
    if (root.overlayMapped) {
      root.pendingActivation = activation
      pendingTimer.restart()
    } else {
      root.dispatchActivation(activation)
    }
  }

  function runPendingActivation() {
    var activation = root.pendingActivation
    root.pendingActivation = null
    pendingTimer.stop()
    if (activation) root.dispatchActivation(activation)
  }

  function dispatchActivation(activation) {
    var addresses = activation.windows.map(function(address) { return "\"0x" + address + "\"" })
    Hyprland.dispatch("o.window_switcher.activate(" + addresses.join(", ") + ")")
  }

  // Should Hyprland never report the surface gone, the window still comes.
  Timer {
    id: pendingTimer
    interval: 500
    onTriggered: root.runPendingActivation()
  }

  // Closing is a request the app may answer with a prompt, so the window
  // leaves the switcher only once it is gone.
  function closeEntry(index) {
    var entry = root.active ? root.entries[index] : null
    if (entry) Hyprland.dispatch("hl.dsp.window.close({ window = \"address:0x" + entry.address + "\" })")
  }

  function iconFor(entry) {
    var toplevel = entry && entry.toplevel ? entry.toplevel.wayland : null
    var appId = toplevel ? String(toplevel.appId || "") : ""
    var dock = root.shell && typeof root.shell.serviceFor === "function" ? root.shell.serviceFor("omarchy.dock") : null
    var desktopEntry = dock && typeof dock.entryForAppId === "function" ? dock.entryForAppId(appId) : DesktopEntries.heuristicLookup(appId)
    var icon = desktopEntry && desktopEntry.icon ? desktopEntry.icon : appId
    var library = root.shell ? root.shell.appLibrary : null
    return library ? library.iconSource(icon) : Quickshell.iconPath(icon, true)
  }

  Component.onCompleted: Hyprland.refreshToplevels()

  ShellIpc {
    target: "omarchy.switcher"

    // From here the switcher stays up until a window is picked, as there may
    // be no Alt held to let go of.
    function open(): void { if (!root.active) root.start(1, true) }
    function next(): void { if (root.active) root.step(1); else root.start(1, true) }
    function previous(): void { if (root.active) root.step(-1); else root.start(-1, true) }
    function commit(): void { root.commit() }
    function cancel(): void { root.cancel() }
  }

  SwitcherOverlay {
    switcher: root
  }
}
