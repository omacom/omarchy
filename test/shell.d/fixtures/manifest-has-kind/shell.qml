import QtQuick
import Quickshell
import Quickshell.Io

// Regression fixture for manifestHasKind()'s array check. A manifest read
// straight off pluginRegistry.installedPlugins keeps its `kinds` as a real JS
// array, but a manifest that has passed through a QML Instantiator's `model:`
// (as shell.qml's panelEntries does) comes back with `kinds` as a list-like
// value that Array.isArray() no longer recognizes, even though indexing and
// .length still work. That inconsistency made shell.qml compute
// manifestHasKind(manifest, "menu") differently for the same cloned menu
// plugin depending on which caller triggered it, so one call silently evicted
// the other's cached, working PluginShellApi and replaced it with one missing
// appLibrary. This pins the underlying platform behavior and proves a
// duck-typed length/index check (mirroring shell.qml's manifestHasKind)
// handles both shapes the same way.
ShellRoot {
  id: root

  FileView {
    id: resultFile
    path: Quickshell.env("OMARCHY_QML_TEST_RESULT")
    atomicWrites: true
  }

  // Kept in sync with manifestHasKind() in shell.qml.
  function manifestHasKind(manifest, kind) {
    if (!manifest || !manifest.kinds || typeof manifest.kinds.length !== "number") return false
    for (var i = 0; i < manifest.kinds.length; i++) {
      if (manifest.kinds[i] === kind) return true
    }
    return false
  }

  property var directManifest: ({ id: "shashi.menu", kinds: ["menu", "bar-widget"] })
  property var entries: [{ id: "shashi.menu", manifest: directManifest }]

  function writeResult(viaModelManifest) {
    var result = {
      // Pins the platform quirk this fix works around. If a future Qt/
      // Quickshell version starts preserving Array-ness through Instantiator
      // models, this flips to true and the duck-typed check below is no
      // longer load-bearing — the checks that matter are hasKindDirect and
      // hasKindViaModel.
      directKindsIsArray: Array.isArray(root.directManifest.kinds),
      viaModelKindsIsArray: Array.isArray(viaModelManifest.kinds),
      hasKindDirect: root.manifestHasKind(root.directManifest, "menu"),
      hasKindViaModel: root.manifestHasKind(viaModelManifest, "menu"),
      missingKindDirect: root.manifestHasKind(root.directManifest, "service"),
      missingKindViaModel: root.manifestHasKind(viaModelManifest, "service")
    }
    result.ok = result.hasKindDirect === true
      && result.hasKindViaModel === true
      && result.missingKindDirect === false
      && result.missingKindViaModel === false

    resultFile.setText(JSON.stringify(result))
    Qt.quit()
  }

  Instantiator {
    id: modelInstantiator
    model: root.entries
    delegate: QtObject {
      id: delegateItem
      required property var modelData
      readonly property var manifest: modelData.manifest
    }
    onObjectAdded: function(index, object) {
      root.writeResult(object.manifest)
    }
  }
}
