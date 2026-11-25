import QtQuick
import Quickshell

ShellRoot {
  id: root

  readonly property string resultPath: Quickshell.env("OMARCHY_QML_TEST_RESULT")
  readonly property string rootPath: Quickshell.env("OMARCHY_PATH")
  property var agent: null
  property bool loaded: false
  property string error: ""

  function shellQuote(value) {
    return "'" + String(value).replace(/'/g, "'\\''") + "'"
  }

  function writeResult() {
    var payload = JSON.stringify({ loaded: loaded, error: error })
    if (resultPath) {
      Quickshell.execDetached(["bash", "-lc", "printf '%s' " + shellQuote(payload) + " > " + shellQuote(resultPath)])
    }
  }

  Item { id: host; width: 800; height: 600 }

  Timer {
    interval: 1
    running: true
    repeat: false
    onTriggered: {
      var component = Qt.createComponent("file://" + root.rootPath + "/shell/plugins/polkit/PolkitAgent.qml", Component.PreferSynchronous)
      if (component.status !== Component.Ready) {
        root.error = "PolkitAgent failed to load: " + component.errorString()
        root.writeResult()
        return
      }
      root.agent = component.createObject(host)
      root.loaded = root.agent !== null
      recreate.start()
    }
  }

  // Recreate while another component's Qt.callLater batch is pending, as the
  // live shell can, before the agent's own 2s startup poll gets a chance.
  Timer {
    id: recreate
    interval: 500
    repeat: false
    onTriggered: {
      Qt.callLater(function() {})
      root.agent.recreateAgent()
      finish.start()
    }
  }

  Timer {
    id: finish
    interval: 500
    repeat: false
    // Its own startup poll would retry about 4s in; stop it so the log the
    // harness counts holds only the attempts made so far.
    onTriggered: {
      root.agent.destroy()
      root.writeResult()
    }
  }
}
