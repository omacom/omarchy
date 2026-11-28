import QtQuick
import Quickshell
import Quickshell.Io

// The real Menu.qml, never shown, with its answer rows driven through the same
// functions the search line and the keyboard call. Each step acts on the menu and
// then waits for its check to pass, as curl and the menu files arrive when they do.
ShellRoot {
  id: root

  readonly property string resultPath: Quickshell.env("OMARCHY_QML_TEST_RESULT")
  readonly property string rootPath: Quickshell.env("OMARCHY_PATH")
  property var menu: null
  property var model: null
  property var failures: []
  property int index: -1
  property int waited: 0
  property int serialBefore: 0
  property string copiedAfterSearch: "unset"
  property var lookup: null
  property string fetchingAfterSearch: "unset"

  function row(i) { return i < root.model.count ? root.model.get(i) : ({}) }
  function kinds() {
    var out = []
    for (var i = 0; i < root.model.count; i++) out.push(root.model.get(i).kind)
    return out
  }
  function state() {
    return JSON.stringify({ filter: root.menu.filterText, cursor: root.menu.selectedIndex, active: root.menu.cursorActive, copied: root.menu.copiedAction, kinds: root.kinds(), first: root.row(0).label, action: root.row(0).action, detail: root.row(0).detail })
  }
  function search(text) { root.menu.setFilter(text) }

  readonly property var steps: [
    { name: "the rows have loaded", check: function() { return root.menu.rowsLoaded } },

    // First, before anything has loaded the currency list, as "pounds" names a
    // currency and would otherwise send for it.
    { name: "pounds to kilograms is weight, and never reaches the network", act: function() { root.search("5 pounds to kg"); root.fetchingAfterSearch = root.lookup.fetching },
      check: function() { return root.fetchingAfterSearch === "" && root.row(0).kind === "unit" && root.row(0).label === "2.26796185 kg" && root.kinds().indexOf("currency") === -1 } },

    // Calculator rows
    { name: "a sum is answered first, on the cursor", act: function() { root.search("2+3*4") },
      check: function() { var r = root.row(0); return r.kind === "calc" && r.label === "14" && r.action === "wl-copy -- 14" && r.detail === "2+3*4" && root.menu.selectedIndex === 0 && root.menu.cursorActive } },
    { name: "a tiny sum is shown and copied in plain digits", act: function() { root.search("0.000001/10") },
      check: function() { var r = root.row(0); return r.kind === "calc" && r.label === "0.0000001" && r.action === "wl-copy -- 0.0000001" } },
    { name: "an unfinished sum has no answer row", act: function() { root.search("2+") },
      check: function() { return root.kinds().indexOf("calc") === -1 } },
    { name: "a sum too big to be exact has no answer row", act: function() { root.search("12345678901234567+1") },
      check: function() { return root.kinds().indexOf("calc") === -1 } },
    { name: "an ordinary search has no answer row", act: function() { root.search("7-zip") },
      check: function() { return root.kinds().indexOf("calc") === -1 && root.kinds().indexOf("currency") === -1 } },

    // The copy button
    { name: "the copy button copies and leaves the menu as it was", act: function() { root.search("40+2"); root.menu.copyAnswer(root.row(0).action) },
      check: function() { return root.menu.copiedAction === "wl-copy -- 42" && root.menu.filterText === "40+2" && root.row(0).label === "42" } },
    { name: "the copied tick goes away by itself", check: function() { return root.menu.copiedAction === "" } },
    { name: "changing the search clears the tick at once", act: function() { root.menu.copyAnswer(root.row(0).action); root.search("40+3"); root.copiedAfterSearch = root.menu.copiedAction },
      check: function() { return root.copiedAfterSearch === "" } },

    // A conversion's row, while it is on its way and once it lands
    { name: "a conversion shows it is on its way, with no cursor to pick it", act: function() { root.search("$5 to INR") },
      check: function() { var r = root.row(0); return r.kind === "currency" && r.disabled && r.action === "" && r.detail === "$5 to INR" && !root.menu.cursorActive } },
    { name: "the answer takes the cursor when it lands", check: function() { var r = root.row(0); return r.kind === "currency" && !r.disabled && r.label === "450 INR" && r.action === "wl-copy -- 450" && r.detail === "5 USD · 2026-11-05" && root.menu.selectedIndex === 0 && root.menu.cursorActive } },
    { name: "a tiny conversion is shown and copied in plain digits", act: function() { root.search("1 inr to btc") },
      check: function() { var r = root.row(0); return r.label === "0.0000001111 BTC" && r.action === "wl-copy -- 0.0000001111" } },
    { name: "rates with no date leave no separator", act: function() { root.search("2 nodate to usd") },
      check: function() { var r = root.row(0); return r.label === "4 USD" && r.detail === "2 NODATE" } },
    { name: "a search that names no currency has no conversion row", act: function() { root.search("go to settings") },
      check: function() { return root.kinds().indexOf("currency") === -1 } },

    // The cursor when a match sits under the conversion
    { name: "the cursor waits on the match under a conversion on its way", act: function() { root.search("7 jpy to usd") },
      check: function() { return root.row(0).kind === "currency" && root.row(0).disabled && root.row(1).label === "7 jpy to usd notes" && root.menu.selectedIndex === 1 && root.menu.cursorActive } },
    { name: "the answer takes the cursor from a match nobody chose", check: function() { return root.row(0).label === "3.5 USD" && root.menu.selectedIndex === 0 } },
    { name: "a cursor moved to the match stays there when the answer lands", act: function() { root.search("7 cad to usd"); root.menu.select(1) },
      check: function() { return root.row(0).label === "3.5 USD" && root.row(1).label === "7 cad to usd notes" && root.menu.selectedIndex === 1 } },

    // Rebuilding
    { name: "typing an answer rebuilds the rows once", act: function() { root.serialBefore = root.menu.layoutSerial; root.search("1 usd to inr") },
      check: function() { return root.row(0).label === "90 INR" && root.menu.layoutSerial === root.serialBefore + 1 } },
    { name: "leaving an answer rebuilds the rows once", act: function() { root.serialBefore = root.menu.layoutSerial; root.search("zen") },
      check: function() { return root.kinds().indexOf("currency") === -1 && root.menu.layoutSerial === root.serialBefore + 1 } },
    { name: "cancelling leaves the rows alone while the menu goes away", act: function() { root.search("1 usd to inr"); root.serialBefore = root.menu.layoutSerial; root.menu.cancel() },
      check: function() { return root.menu.filterText === "" && root.row(0).kind === "currency" && root.menu.layoutSerial === root.serialBefore } },

    // Unit conversions, answered on the spot with no request
    { name: "a unit conversion is answered first, on the cursor", act: function() { root.search("5 km to mi") },
      check: function() { var r = root.row(0); return r.kind === "unit" && r.label === "3.106855961 mi" && r.detail === "5 km" && r.action === "wl-copy -- 3.106855961" && root.menu.selectedIndex === 0 && root.menu.cursorActive } },
    { name: "a length in parts is shown as it was typed", act: function() { root.search("5 ft 11 in to cm") },
      check: function() { var r = root.row(0); return r.kind === "unit" && r.label === "180.34 cm" && r.detail === "5 ft 11 in" } },
    { name: "a tiny unit conversion is shown and copied in plain digits", act: function() { root.search("1 nm to ly") },
      check: function() { var r = root.row(0); return r.label === "0.0000000000000000000000001057000834 ly" && r.action === "wl-copy -- 0.0000000000000000000000001057000834" } },
    { name: "units of two kinds have no answer row", act: function() { root.search("5 kg to m") },
      check: function() { return root.kinds().indexOf("unit") === -1 && root.kinds().indexOf("currency") === -1 } },
    { name: "the copy button copies a unit answer", act: function() { root.search("1 mi to km"); root.menu.copyAnswer(root.row(0).action) },
      check: function() { return root.menu.copiedAction === "wl-copy -- 1.609344" && root.row(0).kind === "unit" } },

    // Other modes
    { name: "a picker for another command never answers", act: function() { root.menu.mode = "select"; root.search("2+2") },
      check: function() { return root.kinds().indexOf("calc") === -1 } },
    { name: "a picker never converts", act: function() { root.search("1 usd to inr") },
      check: function() { return root.kinds().indexOf("currency") === -1 } },
    { name: "a picker never converts units", act: function() { root.search("5 km to mi") },
      check: function() { return root.kinds().indexOf("unit") === -1 } },
    { name: "back in the menu it answers again", act: function() { root.menu.mode = "menu"; root.search("2+2") },
      check: function() { return root.row(0).kind === "calc" && root.row(0).label === "4" } },
    { name: "clearing the search drops the answer", act: function() { root.search("") },
      check: function() { return root.kinds().indexOf("calc") === -1 } }
  ]

  function next() {
    root.index += 1
    root.waited = 0
    if (root.index >= root.steps.length) {
      root.finish()
      return
    }
    var step = root.steps[root.index]
    if (step.act) step.act()
    poll.restart()
  }

  function finish() {
    poll.stop()
    writer.command = ["bash", "-c", 'printf "%s" "$2" >"$1"', "bash", root.resultPath,
      JSON.stringify({ ok: root.failures.length === 0, failures: root.failures })]
    writer.running = true
  }

  Timer {
    id: poll
    interval: 25
    repeat: true
    onTriggered: {
      var step = root.steps[root.index]
      if (step.check()) {
        stop()
        root.next()
      } else if (++root.waited > 200) {
        stop()
        root.failures = root.failures.concat([step.name + ": " + root.state()])
        root.next()
      }
    }
  }

  Process { id: writer }

  Component.onCompleted: {
    var component = Qt.createComponent("file://" + root.rootPath + "/shell/plugins/menu/Menu.qml")
    root.menu = component.createObject(root)
    if (!root.menu) {
      root.failures = [component.errorString()]
      root.finish()
      return
    }
    for (var i = 0; i < root.menu.data.length; i++) {
      var item = root.menu.data[i]
      if (item && item.count !== undefined && typeof item.get === "function" && typeof item.append === "function") root.model = root.model || item
      if (item && item.ratesLifetimeMs !== undefined) root.lookup = item
    }
    root.next()
  }
}
