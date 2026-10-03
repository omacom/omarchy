pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io
import "AudioNodesModel.js" as Model

// Which PipeWire nodes the audio panel and the microphone widget leave out:
// the shell's own level meters, and the nodes a platform's audio processing
// adds, which its platform package names in the fixed platform root (see
// Model.parsePlatformAudio). No environment variable moves that file, and most
// machines have none, so nothing of theirs is left out.
Singleton {
  id: root

  readonly property var hints: Model.parsePlatformAudio(hintsFile.missing ? "" : hintsFile.text())

  // Whether the platform's hints hide a node, given the names of every node
  // now in the graph (for a "replaced" node).
  function platformHides(name, nodeNames) {
    return Model.platformHidesNode(name, hints, nodeNames)
  }

  function isShellLevelMeter(name) {
    return Model.isShellLevelMeter(name)
  }

  FileView {
    id: hintsFile

    // A file that went away hints nothing, whatever text() still holds.
    property bool missing: false

    path: "/usr/share/omarchy-platform/audio.json"
    blockLoading: true
    watchChanges: true
    printErrors: false
    onLoaded: missing = false
    onLoadFailed: missing = true
    onFileChanged: reload()
  }
}
