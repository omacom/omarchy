import QtQuick
import qs.Commons

// The shell draws stills only. OWE owns video backgrounds on the desktop, and
// it feeds the lock screen through its own socket.
Item {
  id: root

  property string path: ""
  property int version: 0
  readonly property var current: imageLoader.item
  readonly property bool ready: current ? current.ready : false
  readonly property bool video: Util.isVideoPath(path)
  // Cache-bust images selected in a running lock session, so a theme switch
  // that replaces the file behind an unchanged path shows the new pixels.
  readonly property url imageUrl: path && !video ? Util.fileUrl(path) + (version ? "?v=" + version : "") : ""

  Loader {
    id: imageLoader
    anchors.fill: parent
    active: root.path !== "" && !root.video
    sourceComponent: imageComponent
  }

  Component {
    id: imageComponent

    Image {
      readonly property bool ready: status === Image.Ready
      source: root.imageUrl
      fillMode: Image.PreserveAspectCrop
      asynchronous: true
      cache: root.version === 0
      sourceSize.width: root.version > 0 ? width : 0
      sourceSize.height: root.version > 0 ? height : 0
    }
  }
}
