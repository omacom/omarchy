import QtQuick
import qs.Commons

Item {
  id: root

  property Component sourceComponent: null
  property real sourceSize: Style.bar.iconCanvas
  readonly property rect sourceBounds: bounds.mappedBounds
  readonly property real contentScale: sourceBounds.width > 0 && sourceBounds.height > 0
    ? Style.bar.iconSize / Math.max(sourceBounds.width, sourceBounds.height) : 1
  readonly property real paintedWidth: sourceBounds.width * contentScale
  readonly property real paintedHeight: sourceBounds.height * contentScale
  readonly property real centerErrorX: content.x + (sourceBounds.x + sourceBounds.width / 2) * contentScale - width / 2
  readonly property real centerErrorY: content.y + (sourceBounds.y + sourceBounds.height / 2) * contentScale - height / 2

  Loader {
    id: content
    sourceComponent: root.sourceComponent
    onLoaded: {
      // Keep declared dimensions. Empty wrapper items receive a source canvas.
      if (!(item instanceof Image)) {
        if (item.width <= 0) item.width = Qt.binding(function() { return root.sourceSize })
        if (item.height <= 0) item.height = Qt.binding(function() { return root.sourceSize })
      }
    }
    transformOrigin: Item.TopLeft
    scale: root.contentScale
    x: root.width / 2 - (root.sourceBounds.x + root.sourceBounds.width / 2) * scale
    y: root.height / 2 - (root.sourceBounds.y + root.sourceBounds.height / 2) * scale
  }

  IconContentBounds {
    id: bounds
    sourceItem: content.item
    boundsParent: content
  }
}
