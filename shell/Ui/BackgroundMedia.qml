import QtQuick
import qs.Commons

Item {
  id: root

  property string path: ""
  property int version: 0
  property string fill: "crop"
  property string backdrop: "solid"
  property color fillColor: "black"
  property real focalX: 0.5
  property real focalY: 0.5
  property bool imageCache: version === 0
  property bool imageUseSourceSizeCap: version > 0
  property bool playbackEnabled: true
  property bool audioEnabled: false
  // Bumped when the file behind an unchanged path may have been replaced.
  // Images cache-bust through version; a video is rebuilt, since FFmpeg
  // would read a query as part of the filename.
  property int reloads: 0
  property bool reloading: false
  readonly property var current: video ? videoLoader.item : imageLoader.item
  readonly property bool ready: current ? current.ready : false
  readonly property int status: !video && current ? current.status : (ready ? Image.Ready : Image.Loading)
  readonly property bool video: Util.isVideoPath(path)
  // Cache-bust images selected in a running lock session. FFmpeg treats the
  // query as part of a local filename, so videos must keep their plain URL.
  // Each URL is empty for the other kind, so a switch never hands the still
  // loader a video, or the player a still, in the moment before it unloads.
  // Both test the path directly: going through `video` lets a URL evaluate
  // against the stale flag and leak the wrong file for one pass.
  readonly property url imageUrl: path && !Util.isVideoPath(path) ? Util.fileUrl(path) + (version ? "?v=" + version : "") : ""
  readonly property url videoUrl: path && Util.isVideoPath(path) ? Util.fileUrl(path) : ""

  Loader {
    id: imageLoader
    anchors.fill: parent
    active: root.path !== "" && !root.video
    sourceComponent: imageComponent
  }

  // Loaded by URL rather than from a Component here, so QtMultimedia and its
  // audio dependency closure never map into a session that only shows images.
  Loader {
    id: videoLoader
    anchors.fill: parent
    active: root.path !== "" && root.video && !root.reloading
    source: "BackgroundVideo.qml"
  }

  onReloadsChanged: {
    if (!video) return
    reloading = true
    Qt.callLater(function() { root.reloading = false })
  }

  // A player on its way out keeps its source: pushing an empty one starts a
  // load of nothing that its destructor then cancels, which FFmpeg logs.
  Binding {
    target: videoLoader.item
    property: "mediaSource"
    value: root.videoUrl
    when: videoLoader.item !== null && Util.isVideoPath(root.path)
    restoreMode: Binding.RestoreNone
  }

  Binding {
    target: videoLoader.item
    property: "playbackEnabled"
    value: root.playbackEnabled
    when: videoLoader.item !== null
  }

  Binding {
    target: videoLoader.item
    property: "audioEnabled"
    value: root.audioEnabled
    when: videoLoader.item !== null
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
      useSourceSizeCap: root.imageUseSourceSizeCap
      asynchronous: true
      cache: root.imageCache
    }
  }
}
