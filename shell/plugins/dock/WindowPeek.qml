import QtQuick
import QtQuick.Effects
import QtQuick.Shapes
import Quickshell
import Quickshell.Wayland
import qs.Commons
import qs.Commons as Commons
import qs.Ui
import "DockModel.js" as DockModel

// The windows of the app the pointer rests on, as a strip of live previews that
// rises from its slot, shaped like the image picker's carousel: one slanted
// slice for each window, the selected one wide and the others narrow and
// dimmed, with the selected window's title below. The pointer picks the
// selection as it moves along the strip; a click brings the window under it to
// the front and a middle click closes it. Nothing is captured until the strip
// is out.
Item {
  id: peek

  property var dock: null
  property string position: "bottom"
  // The workspace in front of the user: a window elsewhere says where it is.
  property int workspaceId: -1
  // The dock's inward edge, which the strip rises from, across the dock.
  property real edge: 0
  // The width of a slot, which the pointer crosses on its way to the strip.
  property real slotSize: 0
  property real screenWidth: width
  property real screenHeight: height

  // The app whose windows are out, and its slot's center along the dock.
  property string key: ""
  property real anchor: 0
  property bool open: false
  // The slice that is wide: the one the pointer last rested on.
  property int selected: 0
  readonly property bool hovered: areaHover.hovered || sizeSlider.dragging
  property alias area: area

  // A slice was picked, or the app has no windows left to show.
  signal dismissed()

  readonly property bool vertical: position === "left" || position === "right"
  // Whether the dock's edge is at the larger coordinate: the bottom, the right.
  readonly property bool before: position === "bottom" || position === "right"

  // Reserve control space before it appears, so revealing it never moves the
  // selected window. Keep the layer surface at its maximum size during drag.
  readonly property int controlGap: Style.spacing.md
  readonly property int controlWidth: Style.space(vertical ? 132 : 40)
  readonly property int controlHeight: Style.space(vertical ? 40 : 132)
  readonly property int controlRoom: controlGap + (vertical ? controlHeight : controlWidth)
  readonly property int labelGap: Style.space(8)
  readonly property int labelHeight: Style.font.body + Style.spacing.md
  readonly property int dockGap: Style.spacing.lg + Style.spacing.md * 2
  readonly property int margin: Style.spacing.lg
  readonly property int fringe: 3
  readonly property real maximumScale: Math.max(0.2, Math.min(1.75,
    (screenWidth - margin * 2 - (vertical ? slotSize + dockGap : controlRoom)) / Style.space(320),
    (screenHeight - margin * 2 - slotSize - dockGap - labelGap - labelHeight - (vertical ? controlRoom : 0)) / Style.space(200)))
  readonly property real minimumScale: Math.min(0.45, maximumScale)
  readonly property real previewScale: Math.min(maximumScale, dock ? dock.previewScale : 1)
  readonly property int expandedWidth: Math.round(Style.space(320) * previewScale)
  readonly property int expandedHeight: Math.round(Style.space(200) * previewScale)
  readonly property int sliceWidth: Math.round(Style.space(45) * previewScale)
  readonly property int sliceHeight: Math.round(Style.space(180) * previewScale)
  readonly property int sliceOverlap: Math.round(Style.space(12) * previewScale)
  readonly property int skew: Math.round(Style.space(12) * previewScale)
  readonly property int minStep: Math.max(3, Math.round(Style.space(10) * previewScale))
  readonly property int blockHeight: expandedHeight + labelGap + labelHeight
  readonly property int sideWidth: Math.min(expandedWidth + 8 * (sliceWidth - sliceOverlap),
    Math.max(expandedWidth, screenWidth - slotSize - dockGap - margin * 2))
  readonly property int reach: dockGap + (vertical
    ? Math.min(Style.space(584) * maximumScale, screenWidth - slotSize - dockGap - margin * 2)
    : Style.space(200) * maximumScale + labelGap + labelHeight) + margin + fringe

  property bool controlsReady: false
  property real heldControlX: 0
  property real heldControlY: 0
  readonly property real desiredControlX: vertical ? stripX + (stripWidth - controlWidth) / 2 : stripX + stripWidth + controlGap
  readonly property real desiredControlY: vertical ? stripY + blockHeight + controlGap : stripY + (expandedHeight - controlHeight) / 2
  readonly property real controlX: sizeSlider.dragging ? heldControlX : desiredControlX
  readonly property real controlY: sizeSlider.dragging ? heldControlY : desiredControlY
  readonly property bool controlsShown: open && controlsReady

  onOpenChanged: {
    if (open) return
    controlsReady = false
    sizeSlider.dragging = false
  }
  onKeyChanged: {
    controlsReady = false
  }

  Timer {
    id: resizeDelay
    interval: 5000
    running: peek.open && stripHover.hovered && !peek.controlsReady
    onTriggered: peek.controlsReady = true
  }

  readonly property var item: key && dock ? dock.itemFor(key) : null
  // In the indicator's order: the windows in front of the user, then the minimized.
  readonly property var windows: {
    var list = item ? item.windows : []
    return list.filter(function(window) { return !window.minimized })
      .concat(list.filter(function(window) { return window.minimized }))
  }
  readonly property var byAddress: {
    var map = {}
    for (var i = 0; i < windows.length; i++) map[windows[i].address] = windows[i]
    return map
  }
  property var addresses: []

  readonly property var stripOptions: ({
    expanded: expandedWidth,
    slice: sliceWidth,
    overlap: sliceOverlap,
    expandedHeight: expandedHeight,
    sliceHeight: sliceHeight,
    minStep: minStep,
    maxWidth: vertical ? sideWidth : Math.max(expandedWidth, width - margin * 2 - controlRoom)
  })
  readonly property var layout: DockModel.stripLayout(addresses.length, selected, stripOptions)

  // Where the strip stands: along the dock it is centered on the slot, kept on
  // screen; across it, it starts at the dock's inward edge.
  readonly property real stripWidth: layout.width
  readonly property real stripX: vertical
    ? (before ? edge - dockGap - stripWidth : edge + dockGap)
    : Math.max(margin, Math.min(width - margin - stripWidth - controlRoom, anchor - (stripWidth + controlRoom) / 2))
  readonly property real stripY: vertical
    ? Math.max(margin, Math.min(height - margin - blockHeight - controlRoom, anchor - (blockHeight + controlRoom) / 2))
    : (before ? edge - dockGap - blockHeight : edge + dockGap)

  function show(key, anchor) {
    peek.key = key
    peek.anchor = anchor
    peek.syncCards()
    if (peek.addresses.length === 0) return
    // The window with the focus leads, or the first one.
    var focused = -1
    for (var i = 0; i < peek.windows.length && focused < 0; i++) {
      if (peek.windows[i].toplevel.activated) focused = i
    }
    peek.selected = Math.max(0, focused)
    peek.open = true
  }

  function hide() {
    peek.open = false
  }

  // The slice under a point along the strip.
  function indexAt(x) {
    return DockModel.stripIndexAt(peek.addresses.length, peek.selected, x, peek.stripOptions)
  }

  // The slices follow this model rather than the windows themselves, so a
  // window opening or closing leaves the other previews as they are.
  ListModel { id: cardModel }

  onWindowsChanged: {
    peek.syncCards()
    if (peek.open && peek.addresses.length === 0) peek.dismissed()
  }

  function syncCards() {
    var next = peek.windows.map(function(window) { return String(window.address) })
    for (var i = 0; i < next.length; i++) {
      if (i < cardModel.count && cardModel.get(i).address === next[i]) continue
      var found = -1
      for (var j = i + 1; j < cardModel.count; j++) {
        if (cardModel.get(j).address === next[i]) { found = j; break }
      }
      if (found >= 0) cardModel.move(found, i, 1)
      else cardModel.insert(i, { address: next[i] })
    }
    if (cardModel.count > next.length) cardModel.remove(next.length, cardModel.count - next.length)
    peek.addresses = next
    peek.selected = Math.max(0, Math.min(peek.selected, next.length - 1))
  }

  // The strip grows out of its slot and fades in; it leaves faster than it came.
  property real rise: open ? 1 : 0

  Behavior on rise {
    NumberAnimation {
      duration: Style.duration(peek.open ? 180 : 120)
      easing.type: Easing.Bezier
      easing.bezierCurve: Style.easeOut
    }
  }

  // The previews stop once the strip has gone.
  onRiseChanged: {
    if (rise > 0 || open) return
    peek.key = ""
    peek.syncCards()
  }

  // Everything the strip covers, and the way to it from its slot.
  Item {
    id: area

    readonly property real boundsLeft: Math.min(peek.stripX, peek.controlsShown ? peek.controlX : peek.stripX) - peek.fringe
    readonly property real boundsRight: Math.max(peek.stripX + peek.stripWidth, peek.controlsShown ? peek.controlX + peek.controlWidth : 0) + peek.fringe
    readonly property real boundsTop: Math.min(peek.stripY, peek.controlsShown ? peek.controlY : peek.stripY) - peek.fringe
    readonly property real boundsBottom: Math.max(peek.stripY + peek.blockHeight, peek.controlsShown ? peek.controlY + peek.controlHeight : 0) + peek.fringe
    readonly property real across: peek.vertical
      ? (peek.before ? peek.edge - boundsLeft : boundsRight - peek.edge)
      : (peek.before ? peek.edge - boundsTop : boundsBottom - peek.edge)
    readonly property real from: Math.min(peek.vertical ? boundsTop : boundsLeft, peek.anchor - peek.slotSize / 2)
    readonly property real to: Math.max(peek.vertical ? boundsBottom : boundsRight, peek.anchor + peek.slotSize / 2)

    x: peek.vertical ? (peek.before ? peek.edge - across : peek.edge) : from
    y: peek.vertical ? from : (peek.before ? peek.edge - across : peek.edge)
    width: peek.vertical ? across : to - from
    height: peek.vertical ? to - from : across
    visible: peek.rise > 0
    opacity: peek.rise

    transform: Scale {
      origin.x: peek.vertical ? (peek.before ? area.width : 0) : peek.anchor - area.x
      origin.y: peek.vertical ? peek.anchor - area.y : (peek.before ? area.height : 0)
      xScale: 0.97 + 0.03 * peek.rise
      yScale: xScale
    }

    HoverHandler { id: areaHover }

    // The strip itself: one pointer area over all of it, which reads where
    // along the strip the pointer is. Slices that move under the pointer do not
    // take part, so a slice that is picked is still under it afterwards.
    Item {
      id: strip

      x: peek.stripX - area.x
      y: peek.stripY - area.y
      width: peek.stripWidth
      height: peek.expandedHeight

      HoverHandler { id: stripHover }

      Repeater {
        model: cardModel

        delegate: Slice {}
      }

      MouseArea {
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        acceptedButtons: Qt.LeftButton | Qt.MiddleButton
        z: 200

        onPositionChanged: function(mouse) {
          var index = peek.indexAt(mouse.x)
          if (index >= 0) peek.selected = index
        }

        onClicked: function(mouse) {
          var index = peek.indexAt(mouse.x)
          if (index < 0) return
          peek.selected = index
          var window = peek.byAddress[peek.addresses[index]]
          if (!window) return
          if (mouse.button === Qt.MiddleButton) {
            window.toplevel.close()
            return
          }
          peek.dock.bringForward(window)
          peek.dismissed()
        }
      }
    }

    Rectangle {
      id: resizeControl
      x: peek.controlX - area.x
      y: peek.controlY - area.y
      width: peek.controlWidth
      height: peek.controlHeight
      radius: Style.cornerRadius
      color: Util.alpha(Commons.Color.popups.background, 0.94)
      visible: opacity > 0
      enabled: peek.controlsShown
      opacity: peek.controlsShown ? 1 : 0
      Behavior on opacity { NumberAnimation { duration: Style.duration(160); easing.type: Easing.OutCubic } }

      PanelSlider {
        id: sizeSlider
        width: Style.space(100)
        height: Style.space(28)
        x: peek.vertical ? Style.space(2) : (parent.width - width) / 2
        y: peek.vertical ? (parent.height - height) / 2 : Style.space(36)
        rotation: peek.vertical ? 0 : -90
        value: peek.previewScale
        minimum: peek.minimumScale
        maximum: peek.maximumScale
        step: 0.05
        trackHeight: Style.space(3)
        knobSize: Style.space(12)
        trackColor: Util.alpha(Commons.Color.popups.text, 0.25)
        fillColor: Commons.Color.accent
        knobColor: Commons.Color.accent
        onDraggingChanged: {
          if (!dragging) return
          peek.heldControlX = peek.desiredControlX
          peek.heldControlY = peek.desiredControlY
        }
        onMoved: function(value) { if (peek.dock) peek.dock.setPreviewScale(value, false) }
        onReleased: function(value) { if (peek.dock) peek.dock.setPreviewScale(value, true) }
      }

      Text {
        x: peek.vertical ? Style.space(102) : 0
        y: peek.vertical ? 0 : parent.height - height - Style.space(5)
        width: peek.vertical ? parent.width - x : parent.width
        height: peek.vertical ? parent.height : Style.font.caption + Style.spacing.xs
        text: Math.round(peek.previewScale * 100) + "%"
        color: Commons.Color.popups.text
        font.family: Style.font.family
        font.pixelSize: Style.font.caption
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
      }
    }

    // The selected window's title, under its slice.
    Text {
      readonly property var window: peek.byAddress[peek.addresses[peek.selected]] || null

      x: peek.stripX - area.x + (peek.layout.cards[peek.selected] ? peek.layout.cards[peek.selected].x : 0)
      y: peek.stripY - area.y + peek.expandedHeight + peek.labelGap
      width: peek.layout.expanded
      Behavior on x { enabled: !sizeSlider.dragging; NumberAnimation { duration: Style.duration(180); easing.type: Easing.Bezier; easing.bezierCurve: Style.easeOut } }
      Behavior on width { enabled: !sizeSlider.dragging; NumberAnimation { duration: Style.duration(180); easing.type: Easing.Bezier; easing.bezierCurve: Style.easeOut } }
      height: peek.labelHeight
      verticalAlignment: Text.AlignTop
      horizontalAlignment: Text.AlignHCenter
      elide: Text.ElideRight
      textFormat: Text.PlainText
      text: window ? window.toplevel.title : ""
      color: Commons.Color.imagePicker.text
      style: Text.Outline
      styleColor: Util.alpha(Commons.Color.background, 0.7)
      font.family: Style.font.family
      font.pixelSize: Style.font.body
      font.weight: Font.DemiBold
    }
  }

  component Slice: Item {
    id: slice

    required property int index
    required property string address
    readonly property var window: peek.byAddress[address] || null
    readonly property var toplevel: window ? window.toplevel : null
    readonly property var spec: peek.layout.cards[index] || null
    readonly property bool chosen: !!spec && spec.selected
    readonly property bool minimized: !!window && window.minimized
    // The slanted outline, left leaning like the picker's.
    readonly property real topLeft: peek.skew
    readonly property real bottomRight: width - peek.skew

    x: spec ? spec.x : 0
    y: spec ? spec.y : 0
    width: spec ? spec.width : 0
    height: spec ? spec.height : 0
    z: chosen ? 100 : 50 - Math.min(Math.abs(index - peek.selected), 40)

    // Hit testing uses the target layout, independent of these moving slices.
    Behavior on x {
      enabled: peek.open && peek.rise > 0 && !sizeSlider.dragging
      NumberAnimation { duration: Style.duration(180); easing.type: Easing.Bezier; easing.bezierCurve: Style.easeOut }
    }
    Behavior on y {
      enabled: peek.open && peek.rise > 0 && !sizeSlider.dragging
      NumberAnimation { duration: Style.duration(180); easing.type: Easing.Bezier; easing.bezierCurve: Style.easeOut }
    }
    Behavior on width {
      enabled: peek.open && peek.rise > 0 && !sizeSlider.dragging
      NumberAnimation { duration: Style.duration(180); easing.type: Easing.Bezier; easing.bezierCurve: Style.easeOut }
    }
    Behavior on height {
      enabled: peek.open && peek.rise > 0 && !sizeSlider.dragging
      NumberAnimation { duration: Style.duration(180); easing.type: Easing.Bezier; easing.bezierCurve: Style.easeOut }
    }

    Item {
      id: maskShape

      anchors.fill: parent
      visible: false
      layer.enabled: true

      Shape {
        anchors.fill: parent
        antialiasing: true
        preferredRendererType: Shape.CurveRenderer

        ShapePath {
          fillColor: "white"
          strokeColor: "transparent"
          startX: slice.topLeft; startY: 0

          PathLine { x: slice.width; y: 0 }
          PathLine { x: slice.bottomRight; y: slice.height }
          PathLine { x: 0; y: slice.height }
          PathLine { x: slice.topLeft; y: 0 }
        }
      }
    }

    Item {
      anchors.fill: parent
      layer.enabled: true
      layer.smooth: true
      layer.effect: MultiEffect {
        maskEnabled: true
        maskSource: maskShape
        maskThresholdMin: 0.3
        maskSpreadAtMin: 0.3
      }

      Rectangle { anchors.fill: parent; color: Commons.Color.background }

      // Until the first frame arrives, and for a window that cannot be
      // captured, the app's icon stands in.
      Image {
        anchors.centerIn: parent
        width: Math.min(slice.width, slice.height) / 2
        height: width
        visible: !view.hasContent
        source: !view.hasContent && peek.dock && peek.item ? peek.dock.iconFor(peek.item) : ""
        sourceSize: Qt.size(width * 2, height * 2)
        fillMode: Image.PreserveAspectFit
        asynchronous: true
        smooth: true
        mipmap: true
      }

      // The selected slice shows the whole window; a narrow one a crop of its
      // middle that fills it. A window with a translucent background is
      // captured with its alpha, so the capture is drawn on its own layer: the
      // backing under it is then blended with it, not overwritten.
      Item {
        anchors.fill: parent
        layer.enabled: true

        ScreencopyView {
          id: view

          readonly property real shape: implicitWidth > 0 && implicitHeight > 0 ? implicitWidth / implicitHeight : 1.6
          // Blend between fitting the full window and filling a narrow slice.
          property real fit: slice.chosen ? 1 : 0
          Behavior on fit {
            NumberAnimation { duration: Style.duration(180); easing.type: Easing.Bezier; easing.bezierCurve: Style.easeOut }
          }

          anchors.centerIn: parent
          width: fit * Math.min(slice.width, slice.height * shape)
            + (1 - fit) * Math.max(slice.width, slice.height * shape)
          height: width / shape
          constraintSize: Qt.size(peek.expandedWidth, peek.expandedHeight)
          captureSource: slice.toplevel
          live: true
        }
      }

      Rectangle {
        anchors.fill: parent
        color: Commons.Color.background
        opacity: slice.chosen ? (slice.minimized ? 0.3 : 0) : (slice.minimized ? 0.62 : 0.42)
        Behavior on opacity { NumberAnimation { duration: Style.duration(180); easing.type: Easing.OutCubic } }
      }

      // Where a window not in front of the user is: its workspace, or a bar for
      // one that is minimized. Only the selected slice has room for it.
      Rectangle {
        readonly property bool away: !!slice.window && (slice.minimized || slice.window.workspaceId !== peek.workspaceId)

        visible: opacity > 0
        opacity: slice.chosen && away ? 1 : 0
        Behavior on opacity { NumberAnimation { duration: Style.duration(120); easing.type: Easing.OutCubic } }
        x: slice.topLeft + Style.spacing.sm
        y: Style.spacing.sm
        width: Math.max(height, place.implicitWidth + Style.spacing.md * 2)
        height: Style.font.bodySmall + Style.spacing.sm * 2
        radius: Style.cornerRadius
        color: Util.alpha(Commons.Color.popups.background, 0.95)

        Text {
          id: place

          anchors.centerIn: parent
          visible: !slice.minimized
          textFormat: Text.PlainText
          text: slice.window && !slice.minimized ? String(slice.window.workspaceId) : ""
          color: Commons.Color.popups.text
          font.family: Style.font.family
          font.pixelSize: Style.font.bodySmall
        }

        Rectangle {
          anchors.centerIn: parent
          anchors.verticalCenterOffset: parent.height / 5
          visible: slice.minimized
          width: Math.round(parent.width * 0.6)
          height: Math.max(2, Math.round(Style.font.bodySmall / 6))
          color: Commons.Color.popups.text
        }
      }
    }

    Shape {
      anchors.fill: parent
      antialiasing: true
      preferredRendererType: Shape.CurveRenderer

      ShapePath {
        fillColor: "transparent"
        strokeColor: slice.chosen ? Commons.Color.imagePicker.selectedBorder : Commons.Color.imagePicker.unselectedBorder
        strokeWidth: slice.chosen ? 3 : 1
        Behavior on strokeColor { ColorAnimation { duration: Style.duration(180); easing.type: Easing.InOutQuad } }
        Behavior on strokeWidth { NumberAnimation { duration: Style.duration(180); easing.type: Easing.OutCubic } }
        startX: slice.topLeft; startY: 0

        PathLine { x: slice.width; y: 0 }
        PathLine { x: slice.bottomRight; y: slice.height }
        PathLine { x: 0; y: slice.height }
        PathLine { x: slice.topLeft; y: 0 }
      }
    }
  }
}
