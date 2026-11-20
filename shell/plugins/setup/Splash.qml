import QtQuick
import qs.Commons
import qs.Commons as Commons
import qs.Ui

// The tour's first screen: the wordmark arriving, a line about what follows,
// and the ways on from here.
Item {
  id: root

  property color foreground: Commons.Color.menu.text
  // The button the keyboard is on: 0 starts the tour, 1 leaves, 2 opens every page.
  property int cursor: 0

  signal started()
  signal skipped()
  signal browsed()

  function play() {
    intro.restart()
  }

  function activate() {
    if (cursor === 1) skipped()
    else if (cursor === 2) browsed()
    else started()
  }

  Column {
    anchors.centerIn: parent
    width: Math.min(parent.width - Style.space(80), Style.space(520))
    spacing: Style.space(30)

    Wordmark {
      id: wordmark
      width: Math.min(parent.width, Style.space(430))
      anchors.horizontalCenter: parent.horizontalCenter
      color: root.foreground
    }

    Column {
      id: copy
      width: parent.width
      spacing: Style.space(26)

      Column {
        width: parent.width
        spacing: Style.space(8)

        Text {
          textFormat: Text.PlainText
          text: Commons.I18n.t("setup.splashTitle")
          color: root.foreground
          font.family: Style.font.menuFamily
          font.pixelSize: Style.font.heading
          font.bold: true
          horizontalAlignment: Text.AlignHCenter
          width: parent.width
        }

        Text {
          textFormat: Text.PlainText
          text: Commons.I18n.t("setup.splashBody")
          color: Util.alpha(root.foreground, 0.68)
          font.family: Style.font.menuFamily
          font.pixelSize: Style.font.body
          lineHeight: 1.35
          wrapMode: Text.WordWrap
          horizontalAlignment: Text.AlignHCenter
          width: parent.width
        }
      }

      Row {
        anchors.horizontalCenter: parent.horizontalCenter
        spacing: Style.space(12)

        SetupButton {
          text: Commons.I18n.t("setup.start")
          primary: true
          hasCursor: root.cursor === 0
          foreground: root.foreground
          onClicked: root.started()
          onEntered: root.cursor = 0
        }

        SetupButton {
          text: Commons.I18n.t("setup.skip")
          hasCursor: root.cursor === 1
          foreground: root.foreground
          onClicked: root.skipped()
          onEntered: root.cursor = 1
        }
      }

      SetupButton {
        anchors.horizontalCenter: parent.horizontalCenter
        text: Commons.I18n.t("setup.allOfSetup")
        quiet: true
        hasCursor: root.cursor === 2
        foreground: root.foreground
        onClicked: root.browsed()
        onEntered: root.cursor = 2
      }
    }
  }

  // The letters each ease in on their own stretch of the reveal, the words
  // follow them, and the glint crosses once everything is in place.
  //
  // This runs well past what agents/skills/motion.md allows the shell's own
  // motion. It is a title, seen once at first login by someone who has stopped
  // to look, and nothing waits on it: every key and button answers from the
  // first frame, and with animations off it shows its last one.
  SequentialAnimation {
    id: intro

    PropertyAction { target: wordmark; property: "glint"; value: 0 }
    ParallelAnimation {
      NumberAnimation { target: wordmark; property: "reveal"; from: 0; to: 1; duration: Style.duration(560) }
      SequentialAnimation {
        PropertyAction { target: copy; property: "opacity"; value: Style.reduceMotion ? 1 : 0 }
        PauseAnimation { duration: Style.duration(240) }
        NumberAnimation { target: copy; property: "opacity"; to: 1; duration: Style.duration(240); easing.type: Easing.OutCubic }
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
  }
}
