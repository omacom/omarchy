import QtQuick
import qs.Commons
import qs.Commons as Commons
import qs.Ui

// The tour's opening frame: omarchy.org's grid-snapped pixel constellation,
// the 5-band stepped OMARCHY wordmark with a single glint, staggered hero-rise
// copy, and two clear paths on.
Item {
  id: root

  property color foreground: Commons.Color.menu.text
  property color accent: Commons.Color.accent
  property color surface: Commons.Color.menu.background
  // Keyboard focus: 0 = Get started, 1 = Skip.
  property int cursor: 0
  property bool introDone: false

  signal started()
  signal skipped()

  function play() {
    introDone = false
    intro.restart()
  }

  function activate() {
    if (cursor === 1) skipped()
    else started()
  }

  // Grid-snapped pixel field aligned directly to the wordmark's 81-column grid.
  PixelField {
    id: field
    anchors.fill: parent
    cellSize: wordmark.width / 81
    originX: main.x + wordmark.x
    originY: main.y + wordmark.y
    dimColor: wordmark.bandDim
    midColor: wordmark.bandMid
    litColor: wordmark.bandLit
    hoverColor: wordmark.bandCrest
    opacity: Style.reduceMotion ? 1 : wordmark.reveal
  }

  HoverHandler {
    onHoveredChanged: field.pointerInside = hovered
    onPointChanged: {
      field.pointerX = point.position.x
      field.pointerY = point.position.y
    }
  }

  Column {
    id: main
    anchors.centerIn: parent
    width: Math.min(parent.width - Style.space(64), Style.space(520))
    spacing: Style.space(30)

    Wordmark {
      id: wordmark
      width: Math.min(parent.width, Style.space(454))
      anchors.horizontalCenter: parent.horizontalCenter
      color: root.foreground
      accent: root.accent
      surface: root.surface
    }

    Column {
      width: parent.width
      spacing: Style.space(26)

      Column {
        width: parent.width
        spacing: Style.space(8)

        Text {
          id: titleText
          property real rise: Style.reduceMotion ? 1 : 0
          textFormat: Text.PlainText
          text: Commons.I18n.t("setup.splashTitle")
          color: root.foreground
          font.family: Style.font.menuFamily
          font.pixelSize: Style.font.heading
          font.bold: true
          horizontalAlignment: Text.AlignHCenter
          wrapMode: Text.WordWrap
          width: parent.width
          opacity: rise
          transform: Translate { y: (1 - titleText.rise) * Style.space(12) }
        }

        Text {
          id: bodyText
          property real rise: Style.reduceMotion ? 1 : 0
          textFormat: Text.PlainText
          text: Commons.I18n.t("setup.splashBody")
          color: Util.alpha(root.foreground, 0.68)
          font.family: Style.font.menuFamily
          font.pixelSize: Style.font.body
          lineHeight: 1.4
          wrapMode: Text.WordWrap
          horizontalAlignment: Text.AlignHCenter
          width: parent.width
          opacity: rise
          transform: Translate { y: (1 - bodyText.rise) * Style.space(12) }
        }
      }

      Row {
        id: ctaRow
        property real rise: Style.reduceMotion ? 1 : 0
        anchors.horizontalCenter: parent.horizontalCenter
        spacing: Style.space(12)
        opacity: rise
        transform: Translate { y: (1 - ctaRow.rise) * Style.space(12) }

        SetupButton {
          text: Commons.I18n.t("setup.start")
          primary: true
          hasCursor: root.cursor === 0
          foreground: root.foreground
          accent: root.accent
          surface: root.surface
          onClicked: root.started()
        }

        SetupButton {
          text: Commons.I18n.t("setup.skip")
          hasCursor: root.cursor === 1
          foreground: root.foreground
          accent: root.accent
          surface: root.surface
          onClicked: root.skipped()
        }
      }
    }
  }

  Text {
    textFormat: Text.PlainText
    text: Commons.I18n.t("setup.splashHint")
    color: Util.alpha(root.foreground, 0.42)
    font.family: Style.font.menuFamily
    font.pixelSize: Style.font.bodySmall
    horizontalAlignment: Text.AlignHCenter
    anchors.left: parent.left
    anchors.right: parent.right
    anchors.bottom: parent.bottom
    anchors.bottomMargin: Style.space(6)
    opacity: ctaRow.rise
  }

  // Title reveal seen once at first login, using omarchy.org's 90ms hero-rise
  // stagger. Every key and button responds from frame 0, and reduced motion
  // rests immediately on the finished frame.
  SequentialAnimation {
    id: intro

    PropertyAction { target: wordmark; property: "glint"; value: 0 }
    PropertyAction { target: titleText; property: "rise"; value: Style.reduceMotion ? 1 : 0 }
    PropertyAction { target: bodyText; property: "rise"; value: Style.reduceMotion ? 1 : 0 }
    PropertyAction { target: ctaRow; property: "rise"; value: Style.reduceMotion ? 1 : 0 }
    ParallelAnimation {
      NumberAnimation { target: wordmark; property: "reveal"; from: 0; to: 1; duration: Style.duration(560) }
      SequentialAnimation {
        PauseAnimation { duration: Style.duration(200) }
        NumberAnimation { target: titleText; property: "rise"; to: 1; duration: Style.duration(240); easing.type: Easing.Bezier; easing.bezierCurve: Style.easeOut }
      }
      SequentialAnimation {
        PauseAnimation { duration: Style.duration(290) }
        NumberAnimation { target: bodyText; property: "rise"; to: 1; duration: Style.duration(240); easing.type: Easing.Bezier; easing.bezierCurve: Style.easeOut }
      }
      SequentialAnimation {
        PauseAnimation { duration: Style.duration(380) }
        NumberAnimation { target: ctaRow; property: "rise"; to: 1; duration: Style.duration(240); easing.type: Easing.Bezier; easing.bezierCurve: Style.easeOut }
      }
    }
    NumberAnimation {
      target: wordmark
      property: "glint"
      from: 0
      to: 1
      duration: Style.duration(760)
      easing.type: Easing.Bezier
      easing.bezierCurve: Style.easeOut
    }
    onFinished: root.introDone = true
  }

  // Calm recurring diagonal sheen across the wordmark while lingering on Splash.
  SequentialAnimation {
    id: ambientGlint
    loops: Animation.Infinite
    running: root.visible && root.introDone && !Style.reduceMotion

    PauseAnimation { duration: Style.duration(3600) }
    NumberAnimation {
      target: wordmark
      property: "glint"
      from: 0
      to: 1
      duration: Style.duration(920)
      easing.type: Easing.Bezier
      easing.bezierCurve: Style.easeOut
    }
    PropertyAction { target: wordmark; property: "glint"; value: 0 }
  }
}
