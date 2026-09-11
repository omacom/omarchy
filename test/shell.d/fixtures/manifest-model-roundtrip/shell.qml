import QtQuick
import QtQml.Models
import Quickshell
import qs.Commons

// The 4.0.3 cloned-menu regression in a jar. Manifests the panel hands out
// through Instantiator modelData carry kinds as a QVariantList, and
// Array.isArray() is false for those, so the menu capability read as absent
// and the panel nulled a cloned plugin's app library. This fixture
// round-trips the same shape and asserts Util.hasKind answers for the model
// path and the plain registry path, so a revert to Array.isArray reddens the
// model half while the registry half stays green.
ShellRoot {
  id: root

  readonly property string resultPath: Quickshell.env("OMARCHY_QML_TEST_RESULT")
  property var failures: []
  property var entries: [
    { id: "acme.menu",
      manifest: ({ id: "acme.menu", kinds: ["menu", "bar-widget"],
                   entryPoints: ({ menu: "Menu.qml" }) }) }
  ]

  function fail(message) {
    failures.push(String(message))
  }

  function assertTrue(condition, message) {
    if (!condition) fail(message)
  }

  function shellQuote(value) {
    return "'" + String(value).replace(/'/g, "'\\''") + "'"
  }

  function writeResult() {
    var payload = JSON.stringify({ ok: failures.length === 0, failures: failures })
    if (resultPath) {
      Quickshell.execDetached(["bash", "-lc", "printf '%s' " + shellQuote(payload) + " > " + shellQuote(resultPath)])
    }
  }

  // The plain-object path the registry uses: never broken by the model shape.
  readonly property bool directMenu: Util.hasKind(entries[0].manifest, "menu")
  readonly property bool directPanel: !Util.hasKind(entries[0].manifest, "panel")
  readonly property bool nullManifest: !Util.hasKind(null, "menu")
  readonly property bool kindlessManifest: !Util.hasKind({ id: "acme.bare" }, "menu")

  Instantiator {
    model: root.entries
    delegate: QtObject {
      required property var modelData
      readonly property bool hasMenu: Util.hasKind(modelData.manifest, "menu")
      readonly property bool hasBarWidget: Util.hasKind(modelData.manifest, "bar-widget")
      readonly property bool hasService: Util.hasKind(modelData.manifest, "service")

      Component.onCompleted: {
        var kinds = modelData.manifest.kinds
        // The precondition that makes this the regression and not a shape
        // assertion of its own: the model path hands kinds over indexable,
        // but not as an array Array.isArray recognises.
        root.assertTrue(kinds && typeof kinds.indexOf === "function",
                        "fixture: modelData did not carry indexable kinds")
        root.assertTrue(Array.isArray(kinds) === false,
                        "fixture: kinds stayed a plain array through the model; the regression cannot reproduce")
        root.assertTrue(hasMenu, "a cloned menu keeps its menu kind through the model path")
        root.assertTrue(hasBarWidget, "a cloned bar widget keeps its bar-widget kind through the model path")
        root.assertTrue(!hasService, "an absent kind stays absent through the model path")
        root.assertTrue(root.directMenu, "the registry path answers menu")
        root.assertTrue(root.directPanel, "the registry path refuses an absent kind")
        root.assertTrue(root.nullManifest, "a null manifest has no kind")
        root.assertTrue(root.kindlessManifest, "a manifest without kinds has no kind")
        root.writeResult()
      }
    }
  }
}
