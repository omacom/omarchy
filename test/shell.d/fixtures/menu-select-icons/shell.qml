import QtQuick
import Quickshell
import Quickshell.Io
import "services"

// Drives the real menu through a select request whose rows ask for app icons:
// each name resolves to an app the way the dock matches windows, and the row
// draws that app's icon like a row of the Apps menu. A cloned dock, which has
// no app library, must match the same way.
ShellRoot {
  id: root

  readonly property string resultPath: Quickshell.env("OMARCHY_QML_TEST_RESULT")
  readonly property string rootPath: Quickshell.env("OMARCHY_PATH")
  readonly property string scratch: Quickshell.env("HOME")
  property var failures: []
  property var menu: null
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

  function row(label) {
    return root.find(root.surface, function(item) { return item.label === label && item.isApp !== undefined })
  }

  function load(path, properties) {
    var component = Qt.createComponent("file://" + path, Component.PreferSynchronous)
    root.check(component.status === Component.Ready, path + " loads: " + component.errorString())
    return component.status === Component.Ready ? component.createObject(root, properties || {}) : null
  }

  // The shell's own app library, which turns a row's icon name into an image.
  QtObject {
    id: host
    property var appLibrary: AppLibrary { }
    function summon() { return false }
  }

  FileView {
    id: result
    path: root.resultPath
  }

  Component.onCompleted: {
    steps = [
      [function() {
        // Quickshell scans desktop entries in the background on first use, as
        // the shell has long done by the time anyone opens a menu.
        root.check(DesktopEntries.applications.values.length >= 0, "desktop entries scan")
        root.menu = root.load(root.rootPath + "/shell/plugins/menu/Menu.qml", { shell: host })
      }, 1500],

      [function() {
        function icon(name) { return root.menu.dmenuAppIcon(name) }
        root.check(icon("app:TUI.tile") === "docker", "app:TUI.tile is the shipped Docker TUI: " + icon("app:TUI.tile"))
        root.check(icon("app:org.omarchy.fixturetop") === "fixture-top", "app:org.omarchy.<command> is the terminal app the TUI launcher named: " + icon("app:org.omarchy.fixturetop"))
        root.check(icon("app:fixture-direct") === "fixture-direct-icon", "app:<desktop id> is that app: " + icon("app:fixture-direct"))
        root.check(icon("app:FixtureClass") === "fixture-direct-icon", "app:<window class> is the app that claims it: " + icon("app:FixtureClass"))
        root.check(icon("app:no-such-app-xyz") === "no-such-app-xyz", "an unknown app name is taken as an icon name")
        root.check(icon("app:") === "application-x-executable", "an unnamed app gets the generic icon")
        root.check(icon("") === "" && icon("") === "", "a glyph stays a glyph")

        // The dock's own matcher, run from a clone's directory without the app library.
        var clone = root.load(root.scratch + "/.config/omarchy/plugins/dock-clone/DockMatch.qml")
        var docker = clone ? clone.entryForAppId("TUI.tile") : null
        var top = clone ? clone.entryForAppId("org.omarchy.fixturetop") : null
        var direct = clone ? clone.entryForAppId("FixtureClass") : null
        root.check(docker && docker.id === "Docker", "a cloned dock gives the Docker TUI's window its entry: " + (docker && docker.id))
        root.check(top && top.id === "fixture-top", "a cloned dock gives a TUI launcher window its terminal entry: " + (top && top.id))
        root.check(direct && direct.id === "fixture-direct", "a cloned dock matches a window class: " + (direct && direct.id))

        root.menu.open(JSON.stringify({
          mode: "select",
          prompt: "Icons",
          options: ["app:TUI.tile\tDocker", "app:fixture-direct\tDirect", "\tGlyph"],
          selectionFile: root.scratch + "/icons.selection",
          doneFile: root.scratch + "/icons.done"
        }))
      }, 600],

      [function() {
        var docker = root.row("Docker")
        var glyph = root.row("Glyph")
        root.check(docker && docker.isApp && docker.appIcon === "docker" && docker.icon === "", "an app: row draws the app's icon like an Apps row")
        root.check(glyph && !glyph.isApp && glyph.icon === "", "a glyph row keeps its glyph")

        // The row's image loads the app's own icon file, not a blank or the generic icon.
        var image = root.find(root.row("Direct"), function(item) { return item.sourceSize !== undefined && item.visible })
        var source = image ? String(image.source) : ""
        root.check(image && image.status === Image.Ready && /\/fixture-direct-icon\.svg(\?|$)/.test(source),
          "an app: row loads the app's icon image: " + source + " status " + (image && image.status))

        // Only rows that pass the filter are drawn, and resolved.
        root.menu.setFilter("dock")
      }, 300],

      [function() {
        root.check(root.row("Docker") && !root.row("Direct"), "a filtered select keeps its app rows")
        root.menu.cancel()

        // A multi-select keeps its check marks where the icon would go.
        root.menu.open(JSON.stringify({
          mode: "select",
          prompt: "Many",
          options: ["app:TUI.tile\tDocker"],
          multiple: true,
          selectionFile: root.scratch + "/many.selection",
          doneFile: root.scratch + "/many.done"
        }))
      }, 400],

      [function() {
        var docker = root.row("Docker")
        root.check(docker && !docker.isApp && docker.icon === "○", "a multi-select ignores app: icons: " + (docker && docker.icon))
        root.menu.cancel()
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
