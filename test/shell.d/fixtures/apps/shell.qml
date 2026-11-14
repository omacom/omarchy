import QtQuick
import Quickshell
import Quickshell.Io
import "services"

ShellRoot {
  id: root
  property var failures: []
  property var apps: null
  property string launched: ""
  property string dockLaunched: ""
  property int versionRefreshes: 0

  function check(condition, message) {
    if (!condition) failures = failures.concat([message])
  }

  QtObject {
    id: library
    signal appsChanged()
    function refreshIcons() {}
    function refreshVersions() { root.versionRefreshes++ }
    function version(entry) { return entry.id === "editor" ? "1.2.3" : "4.5.6" }
    function sortedEntries(filter) {
      return [{ id: "editor", name: "Editor", icon: "" }, { id: "terminal", name: "Terminal", icon: "" }]
        .filter(function(entry) { return entry.name.toLowerCase().indexOf(filter.toLowerCase()) >= 0 })
        .map(function(entry) { return { entry: entry } })
    }
    function entryName(entry) { return entry.name }
    function iconSource(icon) { return "" }
    function launch(id, name) { root.launched = id }
  }

  QtObject {
    id: host
    property var appLibrary: library
    property var appsDock: null
  }

  PluginAppLibraryApi {
    id: scopedLibrary
    ownerPluginId: "tester.apps"
    _entryName: function(entry) { return library.entryName(entry) }
    _sortedEntries: function(query) { return library.sortedEntries(query) }
    _iconSource: function(icon) { return library.iconSource(icon) }
    _refreshIcons: function() { library.refreshIcons() }
    _refreshVersions: function() { library.refreshVersions() }
    _version: function(entry) { return library.version(entry) }
    _launch: function(id, name) { library.launch(id, name) }
  }

  QtObject {
    id: dock
    property var pinnedKeys: []
    property var calls: []
    function launchEntry(entry) { root.dockLaunched = entry.id }
    function isPinned(id) { return pinnedKeys.indexOf(id) >= 0 }
    function setPinned(id, pinned) { pinnedKeys = pinned ? [id] : [] }
    function moveExternalDrag(screen, x, y) { calls = calls.concat(["move"]) }
    function dropExternalDrag(screen, x, y, id) { calls = calls.concat(["drop:" + id]) }
    function endExternalDrag() { calls = calls.concat(["end"]) }
  }

  PluginAppsDockApi {
    id: scopedDock
    ownerPluginId: "tester.apps"
    available: host.appsDock !== null
    pinnedKeys: dock.pinnedKeys.slice()
    _invoke: function(method, args) { dock[method].apply(dock, args) }
  }

  PluginShellApi {
    id: clonedShell
    pluginId: "tester.apps"
    appLibrary: scopedLibrary
    appsDock: scopedDock.available ? scopedDock : null
  }

  FileView {
    id: result
    path: Quickshell.env("OMARCHY_QML_TEST_RESULT")
  }

  Component.onCompleted: {
    var component = Qt.createComponent("file://" + Quickshell.env("OMARCHY_PATH") + "/shell/plugins/apps/Apps.qml")
    if (component.status !== Component.Ready) {
      check(false, "Apps.qml loads: " + component.errorString())
      finish.start()
      return
    }
    apps = component.createObject(root, { shell: host })
    check(!!apps, "app grid is created without a dock service")
    if (!apps) { finish.start(); return }
    apps.open("{}")
    check(apps.opened && apps.apps.length === 2, "app grid opens and lists installed apps without a dock")
    apps.setFilter("term")
    check(apps.apps.length === 1 && apps.apps[0].id === "terminal", "search filters apps without a dock")
    apps.launch(0)
    check(launched === "terminal" && !apps.opened, "selection launches through the app library and closes the grid")
    host.appsDock = dock
    verifyDock.start()
  }

  Timer {
    id: verifyDock
    interval: 100
    onTriggered: {
      root.check(root.apps.dock === dock, "grid discovers a dock enabled later")
      root.apps.open("{}")
      root.apps.launch(0)
      root.check(root.dockLaunched === "editor", "grid uses the dock launch behavior when available")
      host.appsDock = null
      verifyRemoval.start()
    }
  }

  Timer {
    id: verifyRemoval
    interval: 100
    onTriggered: {
      root.check(root.apps.dock === null, "grid releases a dock disabled later")
      root.apps.open("{}")
      root.apps.launch(1)
      root.check(root.launched === "terminal", "grid still launches after the dock is disabled")
      root.apps.shell = clonedShell
      var refreshes = root.versionRefreshes
      root.apps.open("{}")
      root.check(root.versionRefreshes === refreshes + 1, "a clone refreshes app versions through its scoped library")
      root.check(scopedLibrary.version({id: "editor"}) === "1.2.3", "a clone reads app versions through its scoped library")
      root.check(root.apps.apps.length === 2, "a clone lists apps through its scoped application library")
      root.apps.setFilter("edit")
      root.check(root.apps.apps.length === 1 && root.apps.apps[0].id === "editor", "a clone searches through its scoped application library")
      root.apps.launch(0)
      root.check(root.launched === "editor", "a clone launches through its scoped application library")
      host.appsDock = dock
      verifyCloneDock.start()
    }
  }

  Timer {
    id: verifyCloneDock
    interval: 100
    onTriggered: {
      root.check(root.apps.dock === scopedDock, "a clone receives the narrow dock interface when enabled")
      root.apps.open("{}")
      root.apps.dock.setPinned("editor", true)
      root.check(dock.isPinned("editor"), "a clone pins through the dock interface")
      root.apps.dock.setPinned("editor", false)
      root.check(!dock.isPinned("editor"), "a clone unpins through the dock interface")
      root.apps.dragTo({id: "terminal"}, Qt.point(10, 20))
      root.apps.dropDrag()
      root.check(dock.calls.indexOf("move") >= 0 && dock.calls.indexOf("drop:terminal") >= 0 && dock.calls.indexOf("end") >= 0, "a clone forwards drag, drop and cleanup to the dock")
      root.apps.open("{}")
      root.apps.launch(0)
      root.check(root.dockLaunched === "editor", "a clone uses dock launch behavior when enabled")
      host.appsDock = null
      verifyCloneRemoval.start()
    }
  }

  Timer {
    id: verifyCloneRemoval
    interval: 100
    onTriggered: {
      root.check(root.apps.dock === null, "a clone drops dock access when disabled")
      root.apps.open("{}")
      root.apps.launch(1)
      root.check(root.launched === "terminal", "a clone falls back to its app library after dock removal")
      finish.start()
    }
  }

  Timer {
    id: finish
    interval: 100
    onTriggered: {
      result.setText(JSON.stringify({ ok: root.failures.length === 0, failures: root.failures }))
      quitter.start()
    }
  }

  Timer {
    id: quitter
    interval: 200
    onTriggered: Qt.quit()
  }
}
