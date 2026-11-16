import QtQuick
import Quickshell
import qs.Commons
import qs.Ui

BarIndicator {
  id: root

  readonly property var idleService: bar?.shell?.firstPartyServiceFor("omarchy.idle")
  // A mug without a saucer, which drew a line under the cup.
  readonly property string mugGlyph: "\uef59"

  active: idleService ? idleService.stayAwake : false
  // A blank keeps the slot; the mug is drawn by `art` below.
  activeText: " "
  inactiveText: " "
  activeTooltipText: I18n.t("bar.allowIdleLock")
  inactiveTooltipText: I18n.t("bar.stayAwake")

  function toggle() {
    if (root.idleService) root.idleService.setIdleEnabled(root.active)
  }

  Component.onCompleted: watchAncestors()

  // The mug and a solid bottom row, flattened into one layer so dimming fades
  // them as a single image; dimmed separately, the row's overlap with the
  // glyph's own soft bottom edge came out brighter. The layer sits on whole
  // device pixels and is exactly as many texels as it covers, so nothing is
  // resampled, and the glyph inside keeps the sub-pixel offset the button
  // would have drawn it at.
  Item {
    id: art

    // Share of the glyph's width taken by the cup body, from the outline.
    readonly property real bodyShare: 0.7476
    readonly property int margin: 2
    property real dpr: 1
    readonly property var window: root.QsWindow.window
    readonly property real windowDpr: window && window.devicePixelRatio > 0 ? window.devicePixelRatio : 1
    readonly property rect glyphBounds: Qt.rect(glyph.paintedCenterX, glyph.paintedCenterY, glyph.paintedWidth, glyph.paintedHeight)
    onWindowDprChanged: root.placeSoon()
    onGlyphBoundsChanged: root.placeSoon()
    // Device pixel grid, relative to the layer's top-left texel.
    property int texels: 0
    property real canvasDevX: 0
    property real canvasDevY: 0
    property int rowX0: 0
    property int rowX1: 0
    property int rowY: 0
    property real originX: 0
    property real originY: 0
    property int layerDevX: 0
    property int layerDevY: 0

    x: layerDevX / dpr - originX
    y: layerDevY / dpr - originY
    width: texels / dpr
    height: texels / dpr
    visible: texels > 0
    layer.enabled: true
    layer.smooth: false
    layer.textureSize: Qt.size(texels, texels)

    // The button's icon canvas, where BarIconButton would draw the glyph.
    Item {
      id: canvas

      x: art.canvasDevX / art.dpr
      y: art.canvasDevY / art.dpr
      width: root.canvasSize
      height: root.canvasSize

      OpticalGlyph {
        id: glyph
        anchors.fill: parent
        text: root.mugGlyph
        fontFamily: root.fontFamily
        fontSize: root.fontSize
        paintedSize: root.visualIconSize
        color: root.foreground
      }
    }

    // The glyph's base ends on a partly covered row, which renders as a ragged
    // gray edge. Paint that row solid across the flat of the base.
    Rectangle {
      x: art.rowX0 / art.dpr
      y: art.rowY / art.dpr
      width: Math.max(0, art.rowX1 - art.rowX0) / art.dpr
      height: 1 / art.dpr
      color: root.foreground
      antialiasing: false
    }

    function place() {
      if (!window || !root.visible) return
      var d = windowDpr
      var origin = root.mapToItem(null, 0, 0)
      // Where BarIconButton centres its icon canvas.
      var cx = (origin.x + (root.width - root.canvasSize) / 2) * d
      var cy = (origin.y + (root.height - root.canvasSize) / 2) * d
      var lx = Math.floor(cx) - margin
      var ly = Math.floor(cy) - margin
      var inkLeft = cx + (glyph.paintedCenterX - glyph.paintedWidth / 2) * d
      var inkBottom = cy + (glyph.paintedCenterY + glyph.paintedHeight / 2) * d
      var left = Math.round(inkLeft)

      dpr = d
      originX = origin.x
      originY = origin.y
      layerDevX = lx
      layerDevY = ly
      texels = Math.ceil(root.canvasSize * d) + 2 * margin + 1
      canvasDevX = cx - lx
      canvasDevY = cy - ly
      rowX0 = left + 2 - lx
      rowX1 = Math.round(left + bodyShare * glyph.paintedWidth * d) - 2 - lx
      rowY = Math.ceil(inkBottom) - 1 - ly
    }
  }

  // The layer has to land on device pixels, so it follows every move of the
  // icon in the window, including moves of its ancestors.
  property var watchedAncestors: []

  function placeSoon() {
    Qt.callLater(art.place)
  }

  function watchAncestors() {
    for (var i = 0; i < watchedAncestors.length; i++) {
      var old = watchedAncestors[i]
      old.xChanged.disconnect(placeSoon)
      old.yChanged.disconnect(placeSoon)
      old.parentChanged.disconnect(rewatchAncestors)
    }
    var watched = []
    for (var item = root; item; item = item.parent) {
      item.xChanged.connect(placeSoon)
      item.yChanged.connect(placeSoon)
      item.parentChanged.connect(rewatchAncestors)
      watched.push(item)
    }
    watchedAncestors = watched
    placeSoon()
  }

  function rewatchAncestors() {
    Qt.callLater(watchAncestors)
  }

  Component.onDestruction: {
    for (var i = 0; i < watchedAncestors.length; i++) {
      watchedAncestors[i].xChanged.disconnect(placeSoon)
      watchedAncestors[i].yChanged.disconnect(placeSoon)
      watchedAncestors[i].parentChanged.disconnect(rewatchAncestors)
    }
  }

  onWidthChanged: placeSoon()
  onHeightChanged: placeSoon()
  onVisibleChanged: placeSoon()
  onCanvasSizeChanged: placeSoon()

  onPressed: function() { root.toggle() }
}
