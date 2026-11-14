import QtQuick
import QtTest
import Quickshell
import Quickshell.Io

// Drives the real menu through select requests whose picks ask first: the
// prompt asks in place, answers only the request it was asked in, and backs out
// to the list, search and keyboard focus kept, on Cancel, Escape or a click
// outside it. The Apps menu's uninstall prompt, the same dialog, still closes
// the whole menu on a click past its edge.
ShellRoot {
  id: root

  readonly property string resultPath: Quickshell.env("OMARCHY_QML_TEST_RESULT")
  readonly property string rootPath: Quickshell.env("OMARCHY_PATH")
  readonly property string scratch: Quickshell.env("HOME")
  property var failures: []
  property var menu: null
  property string answer: ""
  property var removed: []
  property var steps: []
  property int step: 0

  function check(condition, message) {
    if (!condition) failures = failures.concat([String(message)])
  }

  function find(node, test) {
    if (!node) return null
    if (test(node)) return node
    var kids = node.children || []
    for (var i = 0; i < kids.length; i++) {
      var found = find(kids[i], test)
      if (found) return found
    }
    return null
  }

  function windowContent(object) {
    if (object && object.contentItem) return object.contentItem
    var kids = object ? (object.data || []) : []
    for (var i = 0; i < kids.length; i++) {
      var found = windowContent(kids[i])
      if (found) return found
    }
    return null
  }

  readonly property var surface: menu ? windowContent(menu) : null
  readonly property var dialog: surface ? find(surface, function(item) { return typeof item.handleKey === "function" && item.confirmText !== undefined }) : null
  readonly property var searchField: surface ? find(surface, function(item) { return item.keyHandler !== undefined && item.readOnly !== undefined }) : null

  function button(label) {
    return dialog ? find(dialog, function(item) { return item.modelData === label }) : null
  }

  function clickCenter(item) {
    tc.mouseClick(item, item.width / 2, item.height / 2)
  }

  // A corner of the fullscreen surface, well past the centered card.
  function clickOutside() {
    tc.mouseClick(root.surface, 3, 3)
  }

  function request(name, options, extra) {
    var payload = Object.assign({
      mode: "select",
      prompt: name,
      options: options,
      selectionFile: root.scratch + "/" + name + ".selection",
      doneFile: root.scratch + "/" + name + ".done",
      width: 520
    }, extra || {})
    root.menu.open(JSON.stringify(payload))
  }

  // What a request returned: its selection, "(none)" for a cancel, or
  // "(waiting)" while it is still open.
  function readAnswer(name) {
    reader.command = ["bash", "-c", "f=\"$HOME/$1\"; if [[ -e $f.done ]]; then if [[ -s $f.selection ]]; then cat \"$f.selection\"; else echo '(none)'; fi; else echo '(waiting)'; fi", "_", name]
    reader.running = true
  }

  Process {
    id: reader
    stdout: StdioCollector { onStreamFinished: root.answer = text.trim() }
  }

  // Records an uninstall instead of running one.
  QtObject {
    id: library
    signal appsChanged()
    function sortedEntries() { return [{ entry: { id: "fixture-app", name: "Fixture App", icon: "" } }] }
    function entrySubtext() { return "" }
    function entryName(entry) { return String(entry && entry.name || "") }
    function iconSource() { return "" }
    function refreshIcons() {}
    function launch() {}
    function remove(appId) { root.removed = root.removed.concat([appId]) }
  }

  QtObject {
    id: host
    property var appLibrary: library
    function summon() { return false }
  }

  TestCase {
    id: tc
    name: "menu-select"
    when: false
  }

  FileView {
    id: result
    path: root.resultPath
  }

  Component.onCompleted: {
    var confirm = { confirm: "Quit %1?", confirmLabel: "Permanently Delete" }
    steps = [
      [function() {
        var menuComponent = Qt.createComponent("file://" + root.rootPath + "/shell/plugins/menu/Menu.qml", Component.PreferSynchronous)
        root.check(menuComponent.status === Component.Ready, "Menu.qml loads: " + menuComponent.errorString())
        root.menu = menuComponent.createObject(root, { shell: host })

        // Confirming returns the pick, through the prompt's own button.
        root.request("accept", ["\tOld", "\tKeep"], confirm)
      }, 1500],
      [function() {
        root.menu.activateIndex(0)
        root.check(root.menu.confirmOpen, "a pick opens the confirm prompt")
        root.check(root.menu.requestActive, "a pick under a prompt does not return yet")
      }, 300],
      [function() {
        root.check(root.dialog && root.dialog.message === "Quit Old?", "the prompt names the pick: " + (root.dialog && root.dialog.message))
        var long = root.button("Permanently Delete")
        var label = long ? root.find(long, function(item) { return item.text === "Permanently Delete" }) : null
        root.check(long && label && !label.truncated && label.width <= long.width, "a long confirm label fits its button")
        var cancel = root.button(root.dialog.cancelText)
        root.check(cancel && long && cancel.x + cancel.width <= long.x && cancel.x >= 0, "the buttons sit side by side inside the prompt")
        root.clickCenter(long)
      }, 300],
      [function() { root.readAnswer("accept") }, 300],
      [function() {
        root.check(root.answer === "Old", "confirming returns the pick: " + root.answer)
        root.check(!root.menu.opened, "confirming closes the menu")

        // Cancel, Escape and a click outside each back out to the list.
        root.request("cancel", ["\tOld", "\tKeep"], confirm)
      }, 300],
      [function() {
        // The prompt comes up over a search, which backing out keeps.
        root.menu.setFilter("ol")
        root.menu.activateIndex(0)
        root.check(root.searchField && root.searchField.readOnly, "the search line takes no typing under the prompt")
      }, 300],
      [function() { root.clickCenter(root.button(root.dialog.cancelText)) }, 300],
      [function() {
        root.check(!root.menu.confirmOpen && root.menu.opened && root.menu.requestActive, "Cancel goes back to the list")
        root.check(root.menu.filterText === "ol" && root.searchField.text === "ol", "Cancel keeps the search: " + root.menu.filterText)
        root.check(root.searchField.activeFocus && !root.searchField.readOnly, "Cancel gives the keyboard back to the search line")
        root.menu.activateIndex(0)
        root.dialog.handleKey({ key: Qt.Key_Escape, text: "" })
        root.check(!root.menu.confirmOpen && root.menu.opened && root.menu.requestActive, "Escape goes back to the list")
      }, 300],
      [function() {
        root.check(root.menu.filterText === "ol" && root.searchField.activeFocus, "Escape keeps the search and its focus")
        root.menu.activateIndex(0)
      }, 300],
      [function() { root.clickOutside() }, 300],
      [function() {
        root.check(!root.menu.confirmOpen && root.menu.opened && root.menu.requestActive, "a click outside the menu backs out of the prompt to the list")
        root.check(root.menu.filterText === "ol" && root.searchField.activeFocus, "a click outside keeps the search and its focus")
        root.clickOutside()
      }, 300],
      [function() { root.readAnswer("cancel") }, 300],
      [function() {
        root.check(!root.menu.opened && root.answer === "(none)", "a click outside the list closes the menu with no pick: " + root.answer)

        // A request that replaces another while its prompt is open starts clean.
        root.request("old", ["\tOld"], confirm)
      }, 300],
      [function() { root.menu.activateIndex(0) }, 300],
      [function() {
        var stale = root.menu.confirmTarget
        root.request("new", ["\tNew"], confirm)
        root.check(!root.menu.confirmOpen && root.menu.confirmTarget === null, "a new request closes the old request's prompt")
        root.menu.confirmTarget = stale
        root.menu.acceptConfirm()
        root.check(root.menu.opened && root.menu.requestActive, "an old request's pick never answers the new one")
      }, 300],
      [function() { root.readAnswer("new") }, 300],
      [function() {
        root.check(root.answer === "(waiting)", "the new request is still waiting: " + root.answer)
        root.menu.activateIndex(0)
      }, 300],
      [function() {
        root.check(root.dialog.message === "Quit New?", "the new request's prompt names its own pick: " + root.dialog.message)
        root.clickCenter(root.button("Permanently Delete"))
      }, 300],
      [function() { root.readAnswer("new") }, 300],
      [function() {
        root.check(root.answer === "New", "the new request returns its own pick: " + root.answer)

        // A card too narrow for both labels keeps the buttons apart.
        root.request("narrow", ["\tOld"], Object.assign({ width: 150 }, confirm))
      }, 300],
      [function() { root.menu.activateIndex(0) }, 300],
      [function() {
        var cancel = root.button(root.dialog.cancelText)
        var long = root.button("Permanently Delete")
        var row = long.parent
        root.check(cancel.x >= 0 && cancel.x + cancel.width <= long.x && long.x + long.width <= row.width && row.x >= 0, "narrow: the buttons neither overlap nor leave the prompt")
        root.menu.cancel()
      }, 300],
      [function() {
        // The Apps menu asks before an uninstall with the same prompt. Opened
        // as a menu: its route would run the Apps row's own action instead.
        root.menu.openExistingMenu("apps")
      }, 600],
      [function() {
        root.check(root.menu.opened && !root.menu.dmenuActive && root.menu.activeMenu === "apps", "the Apps menu opens: " + root.menu.activeMenu)
        root.menu.requestConfirm({ appId: "fixture-app", label: "Fixture App" }, 1)
      }, 300],
      [function() {
        root.check(root.dialog.message.indexOf("Fixture App") >= 0 && root.dialog.selectedIndex === 1, "the uninstall prompt names the app, Uninstall focused: " + root.dialog.message)
        root.clickOutside()
      }, 300],
      [function() {
        root.check(!root.menu.opened && !root.menu.confirmOpen, "a click past the edge still closes the Apps menu from its uninstall prompt")
        root.check(root.removed.length === 0, "closing the uninstall prompt uninstalls nothing: " + root.removed)
      }, 300]
    ]
    stepper.start()
  }

  Timer {
    id: stepper
    interval: 10
    onTriggered: {
      if (root.step >= root.steps.length) {
        result.setText(JSON.stringify({ ok: root.failures.length === 0, failures: root.failures }))
        quitter.start()
        return
      }
      var current = root.steps[root.step++]
      try {
        current[0]()
      } catch (e) {
        root.check(false, "step " + root.step + " threw: " + e)
      }
      interval = current[1]
      restart()
    }
  }

  Timer {
    id: quitter
    interval: 200
    onTriggered: Qt.quit()
  }
}
