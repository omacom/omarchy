import QtQuick
import qs.Commons
import "EffectsModel.js" as EffectsModel

// Effects drawn over a still background on one screen, from its sidecar
// backgrounds/effects/<stem>.json (format in EffectsModel.js). Each effect
// maps image pixels through the same centered PreserveAspectCrop the
// wallpaper uses, so it lands on the picture at any screen size.
Item {
  id: root

  // The parsed sidecar of the still this screen shows (EffectsSidecar.qml),
  // and the still's size in pixels.
  property var effects: ({})
  property size imageSize: Qt.size(0, 0)
  // This screen's place on the desktop, and the pointer's, in the same
  // global coordinates, so an effect on one screen can follow a pointer on
  // another.
  property point screenOrigin: Qt.point(0, 0)
  property point pointer: Qt.point(0, 0)
  // Until the pointer moves over the desktop, effects hold the image's pose.
  property bool tracking: false

  readonly property var crop: EffectsModel.cropTransform(imageSize.width, imageSize.height, width, height)
  readonly property var eyes: crop && effects.eyes ? effects.eyes : []
  readonly property bool active: eyes.length > 0
  // Whether anything here follows the pointer, so the desktop asks for hover
  // only while it is needed.
  readonly property bool wantsPointer: visible && active

  Repeater {
    model: root.eyes

    BackgroundEye {
      required property var modelData
      eye: modelData
      crop: root.crop
      // The pointer relative to this screen's corner, where the eye's own
      // position is measured from.
      pointer: Qt.point(root.pointer.x - root.screenOrigin.x, root.pointer.y - root.screenOrigin.y)
      tracking: root.tracking
      reach: Math.min(root.width, root.height) * 0.15
    }
  }
}
