import QtQuick
import QtQuick.Shapes
import qs.Commons
import qs.Commons as Commons

Item {
  id: root

  property real iconSize: Style.font.icon
  readonly property real aspectRatio: 1.18
  property real artworkScale: 0.95
  property color color: Commons.Color.foreground

  width: iconSize * aspectRatio
  height: iconSize
  implicitWidth: iconSize * aspectRatio
  implicitHeight: iconSize

  Shape {
    anchors.fill: parent
    antialiasing: true
    layer.enabled: true
    layer.samples: 4
    scale: root.artworkScale

    Tile { cx: root.width * 0.25; cy: root.height * 0.188 }
    Tile { cx: root.width * 0.75; cy: root.height * 0.188 }
    Tile { cx: root.width * 0.25; cy: root.height * 0.564 }
    Tile { cx: root.width * 0.75; cy: root.height * 0.564 }
    Tile { cx: root.width * 0.50; cy: root.height * 0.812 }
  }

  component Tile: ShapePath {
    property real cx: 0
    property real cy: 0
    readonly property real tileWidth: root.width * 0.50
    readonly property real tileHeight: root.height * 0.376

    fillColor: root.color
    strokeWidth: 0
    startX: cx
    startY: cy - tileHeight / 2
    PathLine { x: cx + tileWidth / 2; y: cy }
    PathLine { x: cx; y: cy + tileHeight / 2 }
    PathLine { x: cx - tileWidth / 2; y: cy }
    PathLine { x: cx; y: cy - tileHeight / 2 }
  }
}
