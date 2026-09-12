import QtQuick
import QtQml.Models
import Quickshell
import "services"

ShellRoot {
  id: shell

  property var pluginRegistry: ({ installedPlugins: {
    "example.menu": { id: "example.menu", kinds: ["menu", "bar-widget"] },
    "example.panel": { id: "example.panel", kinds: ["panel"] }
  } })
  property var panelEntries: Object.keys(pluginRegistry.installedPlugins).map(function(id) {
    return { id: id, manifest: shell.pluginRegistry.installedPlugins[id] }
  })
  property var failures: []
  property int checked: 0
  property int iconCompletions: 0
  property int appChanges: 0
  property QtObject appLibrary: QtObject {
    property var iconIndex: ({})
    signal appsChanged()
  }
  property var _pluginAppLibraryApis: ({ "example.menu": menuLibrary })

  __APP_LIBRARY_SIGNALS__

  // Filled from shell.qml by the test runner, not a copy of the implementation.
  __MANIFEST_HAS_KIND__

  PluginAppLibraryApi {
    id: menuLibrary
    ownerPluginId: "example.menu"
    _sortedEntries: function(query) { return [{ entry: { id: "example-app", name: "Example App" } }] }
  }

  function pluginAppLibraryFor(cacheKey, key) { return menuLibrary }

  Connections {
    target: menuLibrary
    function onIconIndexChanged() { shell.iconCompletions += 1 }
    function onAppsChanged() { shell.appChanges += 1 }
  }

  Component { id: apiComponent; PluginShellApi {} }

  function check(manifest, pluginId) {
    var key = pluginId
    var cacheKey = key
    var api = apiComponent.createObject(null, {
      pluginId: key,
      appLibrary: __APP_LIBRARY_GRANT__
    })
    var isMenu = pluginId === "example.menu"
    var granted = !!api && !!api.appLibrary
    if (granted !== isMenu) failures.push(pluginId + ": wrong app-library grant")
    if (granted && api.appLibrary.sortedEntries("")[0].entry.id !== "example-app")
      failures.push(pluginId + ": app entries unavailable")
    if (api) api.destroy()
    checked += 1
  }

  Instantiator {
    model: shell.panelEntries
    delegate: QtObject {
      required property var modelData
      readonly property string pluginId: modelData.id
      __PANEL_MANIFEST_BINDING__
      Component.onCompleted: shell.check(manifest, pluginId)
    }
  }

  Timer {
    interval: 50
    running: true
    onTriggered: {
      shell.appLibrary.iconIndex = ({ updated: true })
      shell.appLibrary.appsChanged()
      if (shell.iconCompletions !== 1) shell.failures.push("icon refresh completion was not forwarded")
      if (shell.appChanges !== 1) shell.failures.push("app changes were not forwarded")
      if (shell.checked !== 2) shell.failures.push("both plugin kinds must be checked")
      if (shell.failures.length) console.error("PANEL_MENU_FAIL", JSON.stringify(shell.failures))
      else console.log("PANEL_MENU_OK menu receives apps; ordinary panel stays restricted")
      Qt.quit()
    }
  }
}
