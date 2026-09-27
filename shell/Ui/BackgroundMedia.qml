import QtQuick
import qs.Commons

// The shell draws stills only. OWE owns video backgrounds on the desktop, and
// it feeds the lock screen through its own socket.
Item {
  id: root

  property string path: ""
  property int version: 0
  property real alignRatio: 0.5
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

    Item {
      anchors.fill: parent
      clip: true
      readonly property bool ready: img.status === Image.Ready

      Image {
        id: img
        source: root.imageUrl
        asynchronous: true
        cache: root.version === 0
        smooth: true
        sourceSize.width: root.version > 0 ? parent.width : 0
        sourceSize.height: root.version > 0 ? parent.height : 0

        readonly property real scaleFactor: (implicitWidth > 0 && implicitHeight > 0)
          ? Math.max(parent.width / implicitWidth, parent.height / implicitHeight) : 1.0
        width: Math.ceil(implicitWidth * scaleFactor)
        height: Math.ceil(implicitHeight * scaleFactor)

        x: Math.round(-root.alignRatio * Math.max(0, width - parent.width))
        y: Math.round(-0.5 * Math.max(0, height - parent.height))
      }
    }
  }
}
