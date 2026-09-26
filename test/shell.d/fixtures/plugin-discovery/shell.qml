import QtQuick
import Quickshell
import "services"

ShellRoot {
  id: root

  function writeResult() {
    var plugins = {}
    var capabilities = {}
    for (var id in registry.installedPlugins) {
      var manifest = registry.installedPlugins[id]
      plugins[id] = { sourceDir: manifest.__sourceDir, firstParty: manifest.__isFirstParty }
      capabilities[id] = manifest.__hostCapabilities
    }
    var payload = JSON.stringify({
      plugins: plugins,
      capabilities: capabilities,
      scanXdgArg: registry.scanProcess.command[5]
    })
    Quickshell.execDetached(["bash", "-c", "printf '%s' \"$1\" > \"$2\"", "plugin-discovery", payload, Quickshell.env("OMARCHY_QML_TEST_RESULT")])
  }

  PluginRegistry {
    id: registry
    firstPartyDir: Quickshell.env("OMARCHY_PATH") + "/shell/plugins"
    onScanFinished: root.writeResult()
  }
}
