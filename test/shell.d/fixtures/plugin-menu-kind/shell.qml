import QtQuick
import Quickshell
import Quickshell.Io

ShellRoot {
  id: root

  // MANIFEST_HAS_KIND

  FileView {
    id: resultFile
    path: Quickshell.env("OMARCHY_QML_TEST_RESULT")
    atomicWrites: true
  }

  // A plain array model reaches the delegate through modelData, which is how
  // the panel loader used to receive plugin manifests.
  Instantiator {
    model: [{ manifest: { id: "example.menu", kinds: ["menu", "bar-widget"] } }]

    delegate: QtObject {
      required property var modelData
      Component.onCompleted: root.check(modelData.manifest)
    }
  }

  function check(manifest) {
    var out = {
      kindsIsSequence: !Array.isArray(manifest.kinds),
      menu: root.manifestHasKind(manifest, "menu"),
      barWidget: root.manifestHasKind(manifest, "bar-widget"),
      bar: root.manifestHasKind(manifest, "bar"),
      plainArray: root.manifestHasKind({ kinds: ["menu"] }, "menu"),
      stringKinds: root.manifestHasKind({ kinds: "menu" }, "menu"),
      missingKinds: root.manifestHasKind({}, "menu"),
      noManifest: root.manifestHasKind(null, "menu")
    }
    out.ok = out.menu && out.barWidget && !out.bar && out.plainArray
      && !out.stringKinds && !out.missingKinds && !out.noManifest
    resultFile.setText(JSON.stringify(out))
  }
}
