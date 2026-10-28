import QtQuick
import QtQuick.Shapes

Item {
  id: root

  property Item sourceItem: null
  property Item boundsParent: null
  property rect mappedBounds: Qt.rect(0, 0, 0, 0)
  visible: false

  readonly property bool textItem: sourceItem instanceof Text
  readonly property bool imageItem: sourceItem instanceof Image
  readonly property bool shapeItem: sourceItem instanceof Shape
  readonly property bool boxItem: sourceItem instanceof Rectangle
    || sourceItem instanceof Canvas || sourceItem instanceof ShaderEffect

  function unionBounds(a, b) {
    if (b.width <= 0 || b.height <= 0) return a
    if (a.width <= 0 || a.height <= 0) return b
    var x = Math.min(a.x, b.x)
    var y = Math.min(a.y, b.y)
    return Qt.rect(x, y, Math.max(a.x + a.width, b.x + b.width) - x,
      Math.max(a.y + a.height, b.y + b.height) - y)
  }

  function shapeBounds(item) {
    var bounds = item.boundingRect
    var sx = 1
    var sy = 1
    if (item.fillMode !== Shape.NoResize && item.implicitWidth > 0 && item.implicitHeight > 0) {
      sx = item.width / item.implicitWidth
      sy = item.height / item.implicitHeight
      if (item.fillMode === Shape.PreserveAspectFit) sx = sy = Math.min(sx, sy)
      else if (item.fillMode === Shape.PreserveAspectCrop) sx = sy = Math.max(sx, sy)
    }
    var spareWidth = item.width - item.implicitWidth * sx
    var spareHeight = item.height - item.implicitHeight * sy
    var x = item.horizontalAlignment === Shape.AlignHCenter ? spareWidth / 2
      : (item.horizontalAlignment === Shape.AlignRight ? spareWidth : 0)
    var y = item.verticalAlignment === Shape.AlignVCenter ? spareHeight / 2
      : (item.verticalAlignment === Shape.AlignBottom ? spareHeight : 0)
    return Qt.rect(x + bounds.x * sx, y + bounds.y * sy, bounds.width * sx, bounds.height * sy)
  }

  readonly property rect paintedBounds: {
    var item = sourceItem
    var bounds = Qt.rect(0, 0, 0, 0)
    if (!item || !item.visible || item.opacity <= 0) return bounds
    if (textItem) {
      var ink = textMetrics.tightBoundingRect
      var spareWidth = item.width - item.leftPadding - item.rightPadding - item.contentWidth
      var textX = item.leftPadding
      if (item.effectiveHorizontalAlignment === Text.AlignHCenter) textX += spareWidth / 2
      else if (item.effectiveHorizontalAlignment === Text.AlignRight) textX += spareWidth
      bounds = Qt.rect(textX + ink.x, item.baselineOffset + ink.y, ink.width, ink.height)
    } else if (imageItem) {
      var w = item.paintedWidth
      var h = item.paintedHeight
      var x = item.horizontalAlignment === Image.AlignLeft ? 0
        : (item.horizontalAlignment === Image.AlignRight ? item.width - w : (item.width - w) / 2)
      var y = item.verticalAlignment === Image.AlignTop ? 0
        : (item.verticalAlignment === Image.AlignBottom ? item.height - h : (item.height - h) / 2)
      if (item.fillMode === Image.PreserveAspectFit) {
        bounds = Qt.rect(x, y, w, h)
      } else if (item.fillMode === Image.Pad) {
        var left = Math.max(0, x)
        var top = Math.max(0, y)
        bounds = Qt.rect(left, top, Math.max(0, Math.min(item.width, x + w) - left),
          Math.max(0, Math.min(item.height, y + h) - top))
      } else {
        bounds = Qt.rect(0, 0, item.width, item.height)
      }
    } else if (shapeItem) {
      bounds = shapeBounds(item)
    } else if (boxItem) {
      bounds = Qt.rect(0, 0, item.width, item.height)
    }
    for (var i = 0; i < childrenBounds.count; i++) {
      var child = childrenBounds.itemAt(i)
      if (child) bounds = unionBounds(bounds, child.mappedBounds)
    }
    if (item.clip && bounds.width > 0 && bounds.height > 0) {
      var left = Math.max(0, bounds.x)
      var top = Math.max(0, bounds.y)
      bounds = Qt.rect(left, top,
        Math.max(0, Math.min(item.width, bounds.x + bounds.width) - left),
        Math.max(0, Math.min(item.height, bounds.y + bounds.height) - top))
    }
    return bounds
  }

  function updateMappedBounds() {
    var b = paintedBounds
    mappedBounds = sourceItem && boundsParent && b.width > 0 && b.height > 0
      ? sourceItem.mapToItem(boundsParent, b.x, b.y, b.width, b.height)
      : b
  }

  function configureSource() {
    if (sourceItem instanceof Text) sourceItem.renderType = Text.CurveRendering
    updateMappedBounds()
  }

  onPaintedBoundsChanged: updateMappedBounds()
  onSourceItemChanged: configureSource()
  onBoundsParentChanged: updateMappedBounds()
  Component.onCompleted: updateMappedBounds()

  TextMetrics {
    id: textMetrics
    font: root.textItem ? root.sourceItem.font : Qt.font({ pixelSize: 12 })
    text: root.textItem ? root.sourceItem.text : ""
  }

  Connections {
    target: root.sourceItem
    function onXChanged() { root.updateMappedBounds() }
    function onYChanged() { root.updateMappedBounds() }
    function onWidthChanged() { root.updateMappedBounds() }
    function onHeightChanged() { root.updateMappedBounds() }
    function onScaleChanged() { root.updateMappedBounds() }
    function onRotationChanged() { root.updateMappedBounds() }
    function onTransformOriginChanged() { root.updateMappedBounds() }
  }

  Repeater {
    id: childrenBounds
    model: root.sourceItem ? root.sourceItem.children : []
    delegate: Loader {
      id: childLoader
      required property var modelData
      readonly property rect mappedBounds: item ? item.mappedBounds : Qt.rect(0, 0, 0, 0)
      source: Qt.resolvedUrl("IconContentBounds.qml")
      onLoaded: {
        item.sourceItem = Qt.binding(function() { return childLoader.modelData })
        item.boundsParent = Qt.binding(function() { return root.sourceItem })
      }
    }
  }
}
