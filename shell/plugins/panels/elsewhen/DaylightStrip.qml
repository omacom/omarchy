import QtQuick
import QtQuick.Controls
import qs.Commons
import qs.Ui
import "Model.js" as Model
import "Sun.js" as Sun

// A city's 24 hours, midnight to midnight: its real daylight lit, a marker at
// now (the sun by day, tonight's moon by night), and sunrise/sunset arrows
// while the row is hovered. Dragging along it scrubs every clock.
Item {
  id: strip

  property bool ready: false
  property int offsetMinutes: 0
  property real progress: 0
  // The fixed civil band's answer, for a city with no coordinates yet.
  property bool fallbackLit: false
  // { lat, lon } from the fetcher's geocode, or null.
  property var place: null
  property double nowMs: 0
  property bool hovered: false
  property bool hour24: false
  property real moonPhase: 0
  property color foreground: Color.foreground
  property color fainter: Qt.darker(foreground, 2.1)
  property color daylightMarker: "#E5C736"
  property string fontFamily: Style.font.family

  readonly property int trackHeight: Math.max(2, Style.space(3))

  // Which arrow's time is showing: its index, or Model.NO_CHIP.
  property int shownChip: Model.NO_CHIP

  signal scrubStarted(real fraction)
  signal scrubMoved(real fraction)
  signal scrubEnded()
  signal moonShowRequested()

  function dismissChips() { shownChip = Model.NO_CHIP }

  // Decided against the value read on press, so either delivery order of a
  // tap and the release underneath it lands the same way.
  function dismissUnlessChanged(atPress) {
    shownChip = Model.chipAfterRelease(shownChip, atPress)
  }

  onHoveredChanged: if (!hovered) dismissChips()

  height: Style.space(18)

  // Keyed to local midnight, not the ticking clock, so the sun and the
  // Repeaters below rebuild once a day rather than once a second.
  readonly property double dayMs: ready ? Sun.localMidnightMs(nowMs, offsetMinutes) : 0

  readonly property var sun: {
    if (!ready || !place || place.lat === undefined || place.lon === undefined) return null
    // Local noon: the instant furthest from either edge of the day.
    return Sun.sunTimes(place.lat, place.lon, dayMs + 43200000, offsetMinutes)
  }

  // Empty in polar day and night, when the sun does not cross the horizon.
  readonly property var sunMarks: {
    if (!sun || sun.kind !== "normal") return []
    var out = []
    var up = Sun.eventMark(sun.riseMinutes)
    var down = Sun.eventMark(sun.setMinutes)
    if (up !== null) out.push({ x: up, minutes: sun.riseMinutes, rising: true, name: "Sunrise" })
    if (down !== null) out.push({ x: down, minutes: sun.setMinutes, rising: false, name: "Sunset" })
    return out
  }

  // Read from the band that is drawn, so the sun never sits in the dark.
  readonly property bool litNow: sun ? Sun.litAt(sun, ready ? progress * 1440 : 0)
                                     : (ready && fallbackLit)

  Rectangle {
    id: track
    visible: strip.ready
    anchors.left: parent.left
    anchors.right: parent.right
    anchors.verticalCenter: parent.verticalCenter
    height: strip.trackHeight
    radius: height / 2
    color: Util.alpha(strip.foreground, 0.10)

    // Polar night has no band at all, rather than a zero-width one.
    Repeater {
      model: strip.sun ? Sun.litSpans(strip.sun)
                       : [{ x0: Model.daylightStart(), x1: Model.daylightEnd() }]

      Rectangle {
        required property var modelData
        x: parent.width * modelData.x0
        width: Math.max(1, parent.width * (modelData.x1 - modelData.x0))
        height: parent.height
        radius: parent.radius
        color: Util.alpha(strip.foreground, 0.28)
      }
    }

    Rectangle {
      id: nowMarker
      width: Math.max(8, Style.space(10))
      height: width
      radius: width / 2
      x: Math.round(parent.width * (strip.ready ? strip.progress : 0) - width / 2)
      y: (parent.height - height) / 2
      color: strip.litNow ? strip.daylightMarker : "transparent"

      MoonDot {
        anchors.fill: parent
        visible: !strip.litNow
        phase: strip.moonPhase
        color: strip.foreground
      }

      Behavior on x { NumberAnimation { duration: Style.duration(400); easing.type: Easing.OutCubic } }
    }
  }

  // Scrub, or Shift-click the moon to run its phase show. The arrows below are
  // later siblings, so their taps never reach this.
  MouseArea {
    anchors.fill: parent
    cursorShape: Qt.SizeHorCursor
    preventStealing: true
    enabled: strip.ready

    property bool showing: false
    property int chipAtPress: Model.NO_CHIP

    function onMoon(mouse) {
      if (strip.litNow) return false
      return Math.abs(mouse.x - (nowMarker.x + nowMarker.width / 2)) <= nowMarker.width
    }

    function finish() {
      if (!showing) strip.scrubEnded()
      strip.dismissUnlessChanged(chipAtPress)
      showing = false
    }

    onPressed: function(mouse) {
      showing = (mouse.modifiers & Qt.ShiftModifier) !== 0 && onMoon(mouse)
      chipAtPress = strip.shownChip
      if (showing) strip.moonShowRequested()
      else strip.scrubStarted(mouse.x / width)
    }
    onPositionChanged: function(mouse) {
      if (!showing) strip.scrubMoved(mouse.x / width)
    }
    onReleased: finish()
    onCanceled: finish()
  }

  // Sunrise and sunset, just outside the lit band they point at.
  Repeater {
    model: strip.sunMarks

    Item {
      id: arrow
      required property var modelData
      required property int index
      readonly property bool rising: modelData.rising

      // A finger-sized box around a caption-sized glyph, tucked towards the band.
      width: Style.space(14)
      height: Style.space(16)
      anchors.verticalCenter: parent.verticalCenter
      x: Model.arrowBox(arrow.modelData.x, strip.width, arrow.width, Style.space(3), arrow.rising)

      // Hidden while the now marker stands on it. nowMarker.x, not progress,
      // so it reappears exactly as the eased marker clears.
      readonly property bool covered: {
        var markerX = nowMarker.x
        if (!strip.ready) return false
        return Model.arrowCovered(arrow.x, arrow.width, markerX + nowMarker.width / 2,
                                  nowMarker.width, Style.space(4))
      }

      // Gone rather than faded, so a hidden arrow is also untappable.
      opacity: strip.hovered && !arrow.covered ? 1 : 0
      visible: opacity > 0
      Behavior on opacity { NumberAnimation { duration: Style.duration(160) } }

      // Sunrise sits a little high and sunset a little low: a cue that needs no reading.
      transform: Translate { y: arrow.rising ? -Style.space(2) : Style.space(2) }

      onCoveredChanged: if (arrow.covered && strip.shownChip === arrow.index) strip.dismissChips()

      Text {
        anchors.centerIn: parent
        textFormat: Text.PlainText
        text: arrow.rising ? "\u2191" : "\u2193"
        color: arrowHover.hovered || strip.shownChip === arrow.index ? strip.foreground : strip.fainter
        font.family: strip.fontFamily
        font.pixelSize: Style.font.caption
      }

      HoverHandler {
        id: arrowHover
        cursorShape: Qt.PointingHandCursor
      }

      TapHandler {
        // Read on press, so a dismissal that already ran underneath cannot
        // make an open chip look shut.
        property int atPress: Model.NO_CHIP
        onPressedChanged: if (pressed) atPress = strip.shownChip
        onTapped: strip.shownChip = Model.chipAfterTap(atPress, arrow.index)
      }

      PanelToolTip {
        visible: strip.shownChip === arrow.index
        delay: 0
        closePolicy: Popup.NoAutoClose
        text: arrow.modelData.name + " " + Model.formatMinuteOfDay(arrow.modelData.minutes, strip.hour24)
        fontFamily: strip.fontFamily
      }
    }
  }
}
