import QtQuick
import qs.Commons
import qs.Commons as Commons
import "GlobeModel.js" as Solar

// "World [globe] Clock" under an arched caption. The little globe is the door
// into globe mode and, once the big globe has left it, the cross back out.
Column {
  id: hero

  property string caption: ""
  property color captionColor: dim
  property bool captionClickable: false
  property color foreground: Commons.Color.foreground
  property color dim: Qt.darker(foreground, 1.55)
  property string fontFamily: Style.font.family

  // 0 is the list, 1 is the globe filling the panel.
  property real zoom: 0
  property bool globeEnabled: true
  property real bigGlobeOpacity: 0

  // Where the little globe rests, and the city it marks.
  property real restLon: 0
  property bool markerShown: false
  property real markerLat: 0
  property real markerLon: 0

  readonly property Item icon: heroIcon
  readonly property bool iconHovered: heroMouse.containsMouse
  readonly property real spin: heroIcon.spin

  signal captionClicked()
  signal globeClicked(bool slow)

  // Three turns that land on `lon`; null replays the last endpoints.
  function spinOpening(lon) {
    globeSpin.stop()
    if (lon !== null) {
      globeSpin.from = lon - 1080
      globeSpin.to = lon
    }
    globeSpin.restart()
  }

  // `from` is passed in: once the focus changes, the rest binding has already moved spin.
  function turn(from, lon) {
    globeSpin.stop()
    focusSpin.from = from
    focusSpin.to = from + Solar.shortestTurn(from, lon)
    focusSpin.restart()
  }

  spacing: Style.space(2)

  ArcText {
    width: parent.width
    text: hero.caption
    rise: Style.space(6)
    color: hero.captionColor
    fontFamily: hero.fontFamily
    pixelSize: Style.font.caption

    MouseArea {
      anchors.fill: parent
      enabled: hero.captionClickable
      cursorShape: Qt.PointingHandCursor
      onClicked: hero.captionClicked()
    }
  }

  Row {
    anchors.horizontalCenter: parent.horizontalCenter
    spacing: Style.space(9)

    TitleWord { text: "World" }

    Item {
      id: heroIcon
      anchors.verticalCenter: parent.verticalCenter
      implicitWidth: Math.round(Style.font.display * 1.3)
      implicitHeight: Math.round(Style.font.display * 1.3)

      // Degrees of longitude facing the viewer; the globe draws the spin itself.
      property real spin: 0

      Binding {
        target: heroIcon
        property: "spin"
        value: hero.restLon
        when: !globeSpin.running && !focusSpin.running
        restoreMode: Binding.RestoreNone
      }

      rotation: Solar.AXIAL_TILT

      Text {
        anchors.centerIn: parent
        textFormat: Text.PlainText
        text: "\u00d7"
        color: heroMouse.containsMouse ? hero.foreground : hero.dim
        font.family: hero.fontFamily
        font.pixelSize: Math.round(heroIcon.width * 0.8)
        // The globe leans with the earth; the cross stays upright.
        rotation: -Solar.AXIAL_TILT
        opacity: Util.clamp((hero.zoom - 0.2) / 0.35, 0, 1)
        visible: opacity > 0
      }

      MiniGlobe {
        anchors.fill: parent
        opacity: 1 - hero.bigGlobeOpacity
        visible: opacity > 0
        spin: heroIcon.spin
        // Full strength: at this size a dimmed globe reads as washed out.
        color: hero.foreground
        bold: true
        showMarker: hero.markerShown
        markerLat: hero.markerLat
        markerLon: hero.markerLon
      }

      // A MouseArea rather than a TapHandler: only mouse events carry the
      // Shift modifier that asks for slow motion.
      MouseArea {
        id: heroMouse
        anchors.fill: parent
        enabled: hero.globeEnabled
        hoverEnabled: true
        acceptedButtons: Qt.LeftButton
        cursorShape: Qt.PointingHandCursor
        onClicked: function(mouse) {
          hero.globeClicked((mouse.modifiers & Qt.ShiftModifier) !== 0)
        }
      }

      NumberAnimation {
        id: globeSpin
        target: heroIcon
        property: "spin"
        duration: Style.duration(1250)
        easing.type: Easing.OutQuart
      }

      NumberAnimation {
        id: focusSpin
        target: heroIcon
        property: "spin"
        duration: Style.duration(700)
        easing.type: Easing.OutCubic
      }
    }

    TitleWord { text: "Clock" }
  }

  component TitleWord: Text {
    anchors.verticalCenter: parent.verticalCenter
    textFormat: Text.PlainText
    color: hero.foreground
    font.family: hero.fontFamily
    font.pixelSize: Style.font.title
    font.weight: Font.DemiBold
  }
}
