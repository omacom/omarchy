import QtQuick
import QtQuick.Layouts
import qs.Commons
import qs.Ui
import "Model.js" as Model
import "Greetings.js" as Greet

// One city: name, weather, date (or a local greeting on hover) and the time,
// over its daylight strip. Drag the body to reorder, click it to turn the
// globe there. Every toggle on the row flips the setting for the whole list.
Rectangle {
  id: row

  required property var modelData
  required property int index
  // The owning Panel: the row reads its clock, facts and drag state.
  property var panel

  readonly property color foreground: panel.foreground
  readonly property color dim: panel.dim
  readonly property color fainter: panel.fainter
  readonly property string fontFamily: panel.fontFamily

  readonly property var rowData: panel.clockRows[index]
    || ({ ready: false, label: modelData.label, id: modelData.id })
  readonly property bool ready: rowData.ready
  readonly property var greeting: Greet.greeting(rowData.id, ready ? rowData.hour : 0)
  readonly property bool removable: panel.clockRows.length > 1
  readonly property bool dragged: panel.dragIndex === index

  // Lightest at midday, darkest at night, so the list dims into the small hours.
  readonly property real phaseFill: {
    var p = ready ? rowData.phase : "day"
    if (p === "day") return 0.10
    if (p === "night") return 0.035
    return 0.07
  }

  readonly property int pad: Style.space(15)
  readonly property int stripGap: Style.space(9)

  width: parent.width
  // The top pad is measured to the cap height, not the line box, so the row
  // looks as tall above the name as below the strip.
  implicitHeight: (pad - panel.capGap) + rowLabels.implicitHeight + stripGap + strip.trackHeight + pad
  radius: Style.cornerRadius
  // Opaque: knocked-aside rows pass over one another and over the globe.
  // The picked city lights up like a hovered one, so the arrow keys show where they are.
  readonly property bool lit: rowHover.hovered || (panel.focusIndex === index && !panel.addSelected)
  color: Model.mix(Color.popups.background, foreground, lit ? phaseFill + 0.05 : phaseFill)

  // Transforms leave the Column's layout alone: the knock that clears the
  // globe's way, then the drag offset.
  transform: [
    Translate {
      x: Model.knockX(row.index, row.panel.zoom, Style.space(95))
      y: Model.knockY(row.index, row.panel.zoom, row.panel.knockFall)
    },
    Rotation {
      origin.x: row.width / 2
      origin.y: row.height / 2
      angle: Model.knockTilt(row.index, row.panel.zoom)
    },
    Scale {
      origin.x: row.width / 2
      origin.y: row.height / 2
      xScale: Model.knockShrink(row.index, row.panel.zoom)
      yScale: Model.knockShrink(row.index, row.panel.zoom)
    },
    Translate {
      y: Model.rowShift(row.index, row.panel.dragIndex, row.panel.dragTarget,
                        row.panel.dragOffset, row.panel.rowPitch)
      // The dragged row follows the pointer one-to-one; the others ease aside.
      Behavior on y {
        enabled: !row.dragged
        NumberAnimation { duration: 130; easing.type: Easing.OutCubic }
      }
    }
  ]
  z: dragged ? 2 : 0
  opacity: dragged ? 0.9 : 1
  Behavior on opacity { NumberAnimation { duration: 120 } }

  HoverHandler { id: rowHover }

  // The row body is the reorder grab; later siblings keep their own taps.
  MouseArea {
    id: grab
    anchors.left: parent.left
    anchors.right: parent.right
    anchors.top: parent.top
    anchors.bottom: strip.top
    preventStealing: true
    cursorShape: row.dragged ? Qt.ClosedHandCursor : Qt.OpenHandCursor

    property real pressY: 0
    property bool armed: false
    property int chipAtPress: Model.NO_CHIP

    // Measured in the Column, which does not move; the row's own frame slides
    // with the drag and would feed the offset back into itself.
    function pointerY(mouse) { return grab.mapToItem(row.parent, 0, mouse.y).y }

    function finish() {
      armed = false
      strip.dismissUnlessChanged(chipAtPress)
    }

    onPressed: function(mouse) {
      pressY = pointerY(mouse)
      armed = false
      chipAtPress = strip.shownChip
    }

    onPositionChanged: function(mouse) {
      var dy = pointerY(mouse) - pressY
      // A few pixels of slack, so a click is never a reorder.
      if (!armed) {
        if (Math.abs(dy) < Style.space(4)) return
        armed = true
        row.panel.beginRowDrag(row.index, row.height + row.parent.spacing)
      }
      row.panel.moveRowDrag(dy)
    }

    onReleased: {
      if (armed) row.panel.releaseRowDrag()
      else row.panel.focusOn(row.index)
      finish()
    }
    onCanceled: {
      row.panel.cancelRowDrag()
      finish()
    }
  }

  Column {
    id: rowLabels
    anchors.left: parent.left
    anchors.leftMargin: Style.spacing.rowPaddingX
    anchors.right: timeBlock.left
    anchors.rightMargin: Style.spacing.xl
    anchors.top: parent.top
    anchors.topMargin: row.pad - row.panel.capGap
    spacing: Style.space(2)

    // A layout so the name is what gives way when the line is tight.
    RowLayout {
      width: parent.width
      spacing: Style.space(7)

      // Caps the name at its unelided width; the Text's own implicitWidth
      // shrinks as it elides, which would make the cap circular.
      TextMetrics {
        id: nameMetrics
        font.family: row.fontFamily
        font.pixelSize: Style.font.subtitle
        font.weight: Font.DemiBold
        text: row.rowData.label
      }

      Text {
        Layout.fillWidth: true
        Layout.maximumWidth: Math.ceil(nameMetrics.advanceWidth) + 2
        Layout.minimumWidth: 0
        Layout.alignment: Qt.AlignBaseline
        textFormat: Text.PlainText
        text: row.rowData.label
        color: row.foreground
        font.family: row.fontFamily
        font.pixelSize: Style.font.subtitle
        font.weight: Font.DemiBold
        elide: Text.ElideRight
      }

      Caption {
        Layout.alignment: Qt.AlignBaseline
        text: Model.tempLabel(row.panel.facts[Model.factsKey(row.rowData)], row.panel.units)
        visible: text !== ""
        color: tempHover.hovered ? row.foreground : row.dim

        HoverHandler {
          id: tempHover
          cursorShape: Qt.PointingHandCursor
        }
        TapHandler { onTapped: { row.panel.toggleUnits(); strip.dismissChips() } }
      }

      Caption {
        Layout.alignment: Qt.AlignBaseline
        text: row.panel.weatherGlyph(row.rowData)
        visible: text !== ""
        font.pixelSize: Style.font.bodySmall
      }
    }

    // The date, and the greeting in its place while hovered. Stacked in one
    // slot so the row never changes size under the pointer.
    Item {
      width: parent.width
      implicitHeight: dateLine.implicitHeight

      // No greeting before the probe lands: a wrong one is worse than none.
      readonly property bool greeting: row.ready && rowHover.hovered

      Row {
        id: dateLine
        spacing: Style.spacing.sm
        opacity: parent.greeting ? 0 : 1
        visible: opacity > 0
        Behavior on opacity { NumberAnimation { duration: 110 } }

        Caption {
          text: row.ready ? row.rowData.date : "\u2026"
          color: row.ready && row.rowData.dayLabel !== "" ? row.dim : row.fainter
        }

        Caption {
          text: "\u00b7"
          visible: row.ready && row.rowData.dayLabel !== ""
          color: row.fainter
        }

        Caption {
          text: row.ready ? row.rowData.dayLabel : ""
          visible: text !== ""
        }
      }

      Row {
        spacing: Style.space(5)
        opacity: parent.greeting ? 1 : 0
        visible: opacity > 0
        Behavior on opacity { NumberAnimation { duration: 110 } }

        // Non-Latin scripts fall back per character through fontconfig.
        Caption {
          text: row.greeting.text
          color: row.foreground
        }

        // A pronunciation, not a translation; absent for Latin scripts.
        Caption {
          text: row.greeting.roman
          visible: text !== ""
          color: row.fainter
        }
      }
    }
  }

  DaylightStrip {
    id: strip
    anchors.left: parent.left
    anchors.right: parent.right
    anchors.leftMargin: Style.spacing.rowPaddingX
    anchors.rightMargin: Style.spacing.rowPaddingX
    anchors.verticalCenter: parent.bottom
    anchors.verticalCenterOffset: -(row.pad + trackHeight / 2)

    ready: row.ready
    offsetMinutes: row.ready ? row.rowData.offsetMinutes : 0
    progress: row.ready ? row.rowData.progress : 0
    fallbackLit: row.ready && row.rowData.lit
    place: row.panel.facts[Model.factsKey(row.modelData)] || null
    nowMs: row.panel.effectiveMs
    hovered: rowHover.hovered
    hour24: row.panel.hour24
    moonPhase: row.panel.moonPhase
    foreground: row.foreground
    fainter: row.fainter
    daylightMarker: row.panel.daylightMarker
    fontFamily: row.fontFamily

    onScrubStarted: function(fraction) { row.panel.beginScrub(row.rowData, fraction) }
    onScrubMoved: function(fraction) { row.panel.scrubTo(row.rowData, fraction) }
    onScrubEnded: row.panel.endScrub()
    onMoonShowRequested: row.panel.startMoonShow()
  }

  // The last city stays; removing it would leave no way back.
  PanelActionButton {
    anchors.right: parent.right
    anchors.top: parent.top
    anchors.margins: Style.space(1)
    iconText: "\u00d7"
    tooltipText: "Remove"
    foreground: row.fainter
    hoverColor: row.foreground
    fontFamily: row.fontFamily
    fontSize: Style.font.bodySmall
    enabled: row.removable
    // Shown on the keyboard's pick too, so Delete's target is plain.
    opacity: row.removable && row.lit ? 1 : 0
    visible: opacity > 0
    Behavior on opacity { NumberAnimation { duration: 120 } }
    onClicked: row.panel.removeCityAt(row.index)
  }

  Column {
    id: timeBlock
    anchors.right: parent.right
    anchors.rightMargin: Style.spacing.rowPaddingX
    anchors.verticalCenter: rowLabels.verticalCenter
    spacing: Style.space(1)

    // The hour is already the brightest thing on the row, so hover lifts the meridiem.
    LinkRow {
      id: timeLine
      anchors.right: parent.right
      spacing: Style.spacing.xs
      onClicked: { row.panel.toggleHour24(); strip.dismissChips() }

      Text {
        id: bigTime
        textFormat: Text.PlainText
        text: row.ready ? row.rowData.time : "--:--"
        color: row.foreground
        font.family: row.fontFamily
        font.pixelSize: Style.font.heading
        font.weight: Font.DemiBold
      }

      Caption {
        anchors.baseline: bigTime.baseline
        text: row.rowData.meridiem || ""
        visible: text !== ""
        color: timeLine.hovered ? row.foreground : row.dim
      }
    }

    LinkRow {
      id: offsetLine
      anchors.right: parent.right
      spacing: Style.space(5)
      visible: row.ready
      onClicked: { row.panel.toggleOffsetMode(); strip.dismissChips() }

      Caption {
        text: row.ready ? row.rowData.abbr : ""
        color: offsetLine.hovered ? row.dim : row.fainter
      }

      Caption {
        text: row.panel.offsetTextFor(row.rowData)
        visible: text !== ""
        color: offsetLine.hovered ? row.foreground : row.fainter
      }
    }
  }

  component Caption: Text {
    textFormat: Text.PlainText
    color: row.dim
    font.family: row.fontFamily
    font.pixelSize: Style.font.caption
  }

  component LinkRow: Row {
    id: link
    signal clicked()
    readonly property bool hovered: linkHover.hovered
    HoverHandler {
      id: linkHover
      cursorShape: Qt.PointingHandCursor
    }
    TapHandler { onTapped: link.clicked() }
  }
}
