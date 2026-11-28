import QtQuick
import qs.Commons
import qs.Commons as Commons
import qs.Ui as Ui
import "EnrollmentModel.js" as Model

// A big fingerprint on a dark scrim with one status line under it. It arrives
// as a scratchy transmission, then lights up along its ridges from the core
// outward, a little further for every touch the reader accepts.
Item {
  id: view

  required property var ctl

  signal closeRequested()

  // The scrim is near-black whatever the theme, so this palette is fixed.
  readonly property color onScrimDim: Qt.rgba(1, 1, 1, 0.6)
  readonly property color onScrimUrgent: "#ff6b6b"
  readonly property color tone: ctl.phase === "failed" ? onScrimUrgent : Commons.Color.accent

  readonly property string retryText: Model.retryText(ctl.hint, Commons.I18n)

  readonly property string failureText: {
    switch (ctl.failure) {
    case "no-reader": return Commons.I18n.t("fingerprint.failNoReader")
    case "duplicate": return Commons.I18n.t("fingerprint.failDuplicate")
    case "full": return Commons.I18n.t("fingerprint.failFull")
    case "disconnected": return Commons.I18n.t("fingerprint.failDisconnected")
    case "enroll": return Commons.I18n.t("fingerprint.failEnroll")
    case "no-match": return Commons.I18n.t("fingerprint.failNoMatch")
    case "denied": return Commons.I18n.t("fingerprint.failDenied")
    }
    return Commons.I18n.t("fingerprint.failStopped")
  }

  readonly property string statusText: {
    var swipe = ctl.scanType === "swipe"
    switch (ctl.phase) {
    case "full": return Commons.I18n.t("fingerprint.allEnrolled")
    case "setup": return Commons.I18n.t("fingerprint.preparing")
    case "enroll":
      if (retryText !== "") return retryText
      if (swipe) return ctl.stage === 0 ? Commons.I18n.t("fingerprint.swipe") : Commons.I18n.t("fingerprint.swipeAgain")
      return ctl.stage === 0 ? Commons.I18n.t("fingerprint.touch") : Commons.I18n.t("fingerprint.touchAgain")
    case "verify":
      if (retryText !== "") return retryText
      return swipe ? Commons.I18n.t("fingerprint.verifySwipe") : Commons.I18n.t("fingerprint.verifyTouch")
    case "secure": return Commons.I18n.t("fingerprint.secure")
    case "done": return Commons.I18n.t("fingerprint.done")
    case "failed": return failureText
    }
    return ""
  }

  // The scratchy transmission: noise is 1 at its worst and 0 when the picture
  // holds, redrawn on every frame of the timer. The panel opens on it settling,
  // and signs off on it breaking up again once a finger is registered. Both
  // are skipped with animations off.
  property real noise: 0
  property int frame: 0
  property bool signingOff: false

  signal signedOff()

  function transmit() {
    forceActiveFocus()
    settle()
    if (Style.duration(1) > 0) noise = 1
  }

  function settle() {
    farewell.stop()
    signingOff = false
    noise = 0
  }

  Timer {
    interval: 45
    repeat: true
    running: view.noise > 0 || view.signingOff
    onTriggered: {
      view.frame++
      if (view.signingOff) {
        view.noise = Math.min(1, view.noise + 0.06)
        if (view.noise === 1) {
          view.signingOff = false
          view.signedOff()
        }
      } else {
        view.noise = Math.max(0, view.noise - 0.045)
      }
    }
  }

  // Leaves the result up long enough to read before signing off.
  Timer {
    id: farewell
    interval: 1400
    onTriggered: {
      if (Style.duration(1) <= 0) view.signedOff()
      else view.signingOff = true
    }
  }

  Connections {
    target: view.ctl
    function onPhaseChanged() {
      if (view.ctl.phase === "done") farewell.restart()
      else farewell.stop()
    }
  }

  focus: true
  Keys.onEscapePressed: view.closeRequested()
  // Enter follows the same recovery action as the button for a managed add.
  Keys.onReturnPressed: if (view.ctl.phase === "failed") view.ctl.resumeAfterFailure()
  Keys.onEnterPressed: if (view.ctl.phase === "failed") view.ctl.resumeAfterFailure()

  Column {
    id: stack
    anchors.centerIn: parent
    spacing: Style.space(28)

    Item {
      id: stage

      readonly property int bandCount: 14

      anchors.horizontalCenter: parent.horizontalCenter
      width: backButton.visible ? Math.max(0, Math.min(whorl.implicitWidth, view.width - Style.space(32),
                 view.height - statusLine.implicitHeight - backButton.implicitHeight - 2 * stack.spacing - Style.space(32)))
             : whorl.implicitWidth
      height: width

      FingerprintArt {
        id: whorl
        anchors.fill: parent
        tone: view.tone
        filled: view.ctl.phase === "failed" ? 1 : view.ctl.progress
      }

      // The transmission: while it settles, the print is shown as bands torn
      // sideways, dropping out and coming back, under a scatter of scratches.
      Repeater {
        model: view.noise > 0 ? stage.bandCount : 0

        ShaderEffectSource {
          required property int index
          readonly property real band: stage.height / stage.bandCount

          sourceItem: whorl
          hideSource: true
          sourceRect: Qt.rect(0, index * band, stage.width, band)
          y: index * band
          width: stage.width
          height: band
          x: { view.frame; return (Math.random() - 0.5) * (Math.random() < 0.35 ? 2.4 : 0.5) * Style.space(70) * view.noise }
          opacity: { view.frame; return Math.random() < view.noise * 0.5 ? 0.15 : 1 }
        }
      }

      Repeater {
        model: view.noise > 0 ? 18 : 0

        Rectangle {
          x: { view.frame; return -Style.space(120) + Math.random() * (stage.width + Style.space(160)) }
          y: { view.frame; return Math.random() * stage.height }
          width: { view.frame; return Style.space(6) + Math.random() * Style.space(90) }
          height: Math.max(1, Style.space(1))
          color: "white"
          opacity: { view.frame; return Math.random() * 0.5 * view.noise }
        }
      }
    }

    Text {
      id: statusLine
      textFormat: Text.PlainText
      anchors.horizontalCenter: parent.horizontalCenter
      width: Math.min(view.width - Style.space(48), Style.space(520))
      // Hold the line's height while it is empty, so the print never shifts.
      text: view.statusText !== "" ? view.statusText : " "
      opacity: { view.frame; return view.noise > 0 && Math.random() < 0.5 ? 0.3 : 1 }
      color: view.ctl.phase === "failed" ? view.onScrimUrgent : view.onScrimDim
      font.family: Style.font.family
      font.pixelSize: Style.font.heading
      horizontalAlignment: Text.AlignHCenter
      wrapMode: Text.Wrap
    }

    Ui.Button {
      id: backButton
      anchors.horizontalCenter: parent.horizontalCenter
      visible: view.ctl.phase === "failed" && !!view.ctl.managedReader
      text: Commons.I18n.t("fingerprint.backToSaved")
      foreground: "white"
      bordered: true
      focusable: true
      Accessible.role: Accessible.Button
      Accessible.name: text
      Accessible.onPressAction: clicked()
      onClicked: view.ctl.resumeAfterFailure()
    }
  }
}
