import QtQuick
import Quickshell

ShellRoot {
  id: shell

  readonly property string resultPath: Quickshell.env("OMARCHY_QML_TEST_RESULT")

  property var entries: [
    {
      pluginId: "jr.menu",
      entryKind: "menu",
      keepLoaded: false,
      sourceUrl: "",
      manifest: {
        id: "jr.menu",
        name: "Cloned Menu",
        kinds: ["menu"],
        omarchy: { clonedFrom: "omarchy.menu" }
      }
    }
  ]

  function manifestHasKind(manifest, kind) {
    var kinds = manifest && manifest.kinds
    return !!kinds && typeof kinds === "object" && typeof kinds.indexOf === "function"
      && kinds.indexOf(kind) !== -1
  }

  function createScopedPluginShell(manifest) {
    return {
      pluginId: String(manifest && manifest.id || ""),
      appLibrary: shell.manifestHasKind(manifest, "menu") ? { loaded: true } : null
    }
  }

  function shellQuote(value) {
    return "'" + String(value).replace(/'/g, "'\\''") + "'"
  }

  function writeResult(payload) {
    if (resultPath) {
      Quickshell.execDetached(["bash", "-lc", "printf '%s' " + shellQuote(JSON.stringify(payload)) + " > " + shellQuote(resultPath)])
    }
  }

  Instantiator {
    model: shell.entries
    active: true

    delegate: QtObject {
      id: panelEntry
      required property var modelData

      Component.onCompleted: {
        var manifest = modelData.manifest
        var isSequence = !Array.isArray(manifest.kinds)
        var hasKind = shell.manifestHasKind(manifest, "menu")
        var scopedShell = shell.createScopedPluginShell(manifest)
        var hasAppLibrary = scopedShell && scopedShell.appLibrary !== null

        shell.writeResult({
          ok: hasKind && hasAppLibrary,
          isSequence: isSequence,
          hasKind: hasKind,
          hasAppLibrary: hasAppLibrary
        })
      }
    }
  }
}
