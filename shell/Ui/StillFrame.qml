import QtQuick

// A still background. A flat image fills the frame as a crop; a 360 panorama
// (an equirectangular image tagged with GPano XMP, as cameras and phones
// write it) is drawn as the view of a camera turned to `yaw` degrees, so the
// desktop can look around the scene.
Item {
  id: root

  property url source: ""
  property size sourceSize: Qt.size(0, 0)
  property bool asynchronous: true
  property bool cache: true
  property bool mipmap: false
  // Null for a flat image; { heading, pitch, fov } in degrees for a panorama.
  property var panorama: null
  // Degrees added to the panorama's own heading.
  property real yaw: 0

  readonly property alias status: image.status
  readonly property bool isPanorama: panorama !== null && panorama !== undefined

  Image {
    id: image
    anchors.fill: parent
    source: root.source
    sourceSize: root.sourceSize
    fillMode: Image.PreserveAspectCrop
    asynchronous: root.asynchronous
    cache: root.cache
    smooth: true
    // The shader shrinks a panorama several times over, which needs mipmaps.
    mipmap: root.mipmap || root.isPanorama
    // A panorama is sampled by the shader, which reads the image as its
    // texture whether or not it is visible.
    visible: !root.isPanorama
  }

  ShaderEffect {
    anchors.fill: parent
    visible: root.isPanorama && image.status === Image.Ready
    property variant source: image
    property real yaw: root.isPanorama ? (root.panorama.heading + root.yaw) * Math.PI / 180 : 0
    property real pitch: root.isPanorama ? root.panorama.pitch * Math.PI / 180 : 0
    property real tanHalfFov: Math.tan((root.isPanorama ? root.panorama.fov : 90) * Math.PI / 360)
    property real aspect: width > 0 ? height / width : 1
    fragmentShader: Qt.resolvedUrl("shaders/panorama.frag.qsb")
  }
}
