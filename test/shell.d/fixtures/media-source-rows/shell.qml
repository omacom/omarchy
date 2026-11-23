import QtQuick
import Quickshell
import Quickshell.Io

// A cloned bar reaches the media service through the narrow proxy that full-bar
// facades get, not the service itself, so build the media widget's source rows
// against that proxy.
ShellRoot {
  id: root

  readonly property string rootPath: Quickshell.env("OMARCHY_PATH")
  property var failures: []

  function check(condition, message) {
    if (!condition) failures.push(String(message))
  }

  function create(path, properties) {
    var component = Qt.createComponent("file://" + rootPath + path)
    if (component.status !== Component.Ready) {
      check(false, path + " failed to load: " + component.errorString())
      return null
    }
    return component.createObject(root, properties)
  }

  // Source rows sit inside the popup window, which is not a visual child.
  function sourceDetails(object) {
    if (!object) return []
    var found = object.player !== undefined && typeof object.sourceDetail === "string" ? [object.sourceDetail] : []
    var data = object.data || []
    for (var i = 0; i < data.length; i++) found = found.concat(sourceDetails(data[i]))
    return found
  }

  QtObject {
    id: mockShell
    property var mediaService: null
    function firstPartyServiceFor(id) {
      return id === "omarchy.media" ? mediaService : null
    }
  }

  QtObject {
    id: mockBar
    property bool vertical: false
    property int barSize: 26
    property string fontFamily: "monospace"
    property color foreground: "white"
    property color barForeground: "white"
    property bool foregroundAnimationEnabled: false
    property bool barHidden: false
    property var shell: mockShell
    function showTooltip(target, text) {}
    function hideTooltip(target) {}
  }

  FileView {
    id: result
    path: Quickshell.env("OMARCHY_QML_TEST_RESULT")
  }

  Component.onCompleted: {
    var spotify = { trackTitle: "Song", trackArtist: "Artist", identity: "Spotify" }
    var browser = { trackTitle: "Clip", trackArtist: "Channel", identity: "Firefox" }
    mockShell.mediaService = create("/shell/services/PluginFirstPartyServiceApi.qml", {
      ownerPluginId: "omarchy.bar",
      serviceId: "omarchy.media",
      activePlayer: spotify,
      sourcePlayers: [spotify, browser]
    })

    var widget = create("/shell/plugins/services/media/BarWidget.qml", { bar: mockBar })
    check(!!widget, "the media widget builds on a cloned bar")
    var details = sourceDetails(widget)
    check(details.join(" | ") === "Artist · Spotify | Channel · Firefox",
      "each source row names its artist and app on a cloned bar, got " + JSON.stringify(details))

    result.setText(JSON.stringify({ ok: failures.length === 0, failures: failures }))
    quitter.start()
  }

  Timer {
    id: quitter
    interval: 200
    onTriggered: Qt.quit()
  }
}
