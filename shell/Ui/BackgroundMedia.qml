import QtQuick
import qs.Commons

// The shell draws stills only. OWE owns video backgrounds on the desktop, and
// it feeds the lock screen through its own socket.
Item {
  id: root

  property string path: ""
  property int version: 0
  property string fill: "crop"
  property string backdrop: "solid"
  property color fillColor: "black"
  property real focalX: 0.5
  property real focalY: 0.5
  // Versioned callers may opt into caching because the version is in the URL.
  property bool cached: version === 0
  property bool constrainDecode: false
  property size decodeSize: Qt.size(0, 0)
  readonly property var current: imageLoader.item
  readonly property bool ready: current ? current.ready : false
  readonly property int status: current ? current.status : Image.Null
  readonly property bool video: Util.isVideoPath(path)
  readonly property url imageUrl: path && !video ? Util.fileUrl(path) + (version ? "?v=" + version : "") : ""

  Loader {
    id: imageLoader
    anchors.fill: parent
    active: root.path !== "" && !root.video
    sourceComponent: imageComponent
  }

  Component {
    id: imageComponent

    WallpaperImage {
      readonly property bool ready: status === Image.Ready
      path: root.path
      fill: root.fill
      backdrop: root.backdrop
      fillColor: root.fillColor
      focalX: root.focalX
      focalY: root.focalY
      sourceVersion: root.version
      useSourceSizeCap: root.constrainDecode || root.version > 0
      constrainDecode: root.constrainDecode
      decodeSize: root.decodeSize
      asynchronous: true
      cache: root.cached
    }
  }
}
