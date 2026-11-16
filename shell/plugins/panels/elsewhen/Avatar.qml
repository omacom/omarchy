import QtQuick
import QtQuick.Effects
import qs.Commons
import qs.Commons as Commons
import "Model.js" as Model

// One person on a row: their GitHub avatar when there is one, otherwise the
// first letter of their name on a disc. Edged in the row's own fill, so a few
// of them overlapping still read as separate faces.
Item {
  id: avatar

  property string name: ""
  // A cached image path, "" for a plain name.
  property string source: ""
  // Changes when the cache is refreshed, so a new picture replaces the old one.
  property double stamp: 0
  property real size: Style.font.caption
  property color foreground: Commons.Color.foreground
  property color ground: Commons.Color.popups.background
  property string fontFamily: Style.font.family

  readonly property bool pictured: picture.status === Image.Ready
  readonly property real edge: Math.max(1, Math.round(size / 12))

  implicitWidth: size
  implicitHeight: size

  Rectangle {
    anchors.fill: parent
    anchors.margins: -avatar.edge
    radius: width / 2
    color: avatar.ground
  }

  Rectangle {
    anchors.fill: parent
    radius: width / 2
    color: Model.mix(avatar.ground, avatar.foreground, 0.28)
    visible: !avatar.pictured

    Text {
      anchors.centerIn: parent
      textFormat: Text.PlainText
      text: Model.initialOf(avatar.name)
      color: avatar.foreground
      font.family: avatar.fontFamily
      font.pixelSize: Math.round(avatar.size * 0.55)
      font.weight: Font.DemiBold
    }
  }

  Image {
    id: picture
    anchors.fill: parent
    visible: false
    source: avatar.source === "" ? "" : "file://" + avatar.source + "?v=" + avatar.stamp
    sourceSize.width: Math.ceil(avatar.size * Screen.devicePixelRatio)
    sourceSize.height: Math.ceil(avatar.size * Screen.devicePixelRatio)
    fillMode: Image.PreserveAspectCrop
    asynchronous: true
    cache: false
    smooth: true
  }

  Item {
    id: disc
    anchors.fill: parent
    visible: false
    layer.enabled: true

    Rectangle {
      anchors.fill: parent
      radius: width / 2
      color: "black"
    }
  }

  MultiEffect {
    anchors.fill: parent
    visible: avatar.pictured
    source: picture
    maskEnabled: true
    maskSource: disc
    maskThresholdMin: 0.5
    maskSpreadAtMin: 1.0
  }
}
