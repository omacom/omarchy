import QtQuick
import QtQuick.Shapes
import qs.Commons
import qs.Commons as Commons

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

  readonly property string retryText: {
    switch (ctl.hint) {
    case "short": return Commons.I18n.t("fingerprint.retryShort")
    case "center": return Commons.I18n.t("fingerprint.retryCenter")
    case "lift": return Commons.I18n.t("fingerprint.retryLift")
    case "fast": return Commons.I18n.t("fingerprint.retryFast")
    case "nomatch": return Commons.I18n.t("fingerprint.retryNoMatch")
    case "again": return Commons.I18n.t("fingerprint.retryAgain")
    }
    return ""
  }

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
  // Enter tries again after a failure. A finished run signs off by itself.
  Keys.onReturnPressed: if (view.ctl.phase === "failed") view.ctl.begin()
  Keys.onEnterPressed: if (view.ctl.phase === "failed") view.ctl.begin()

  Column {
    anchors.centerIn: parent
    spacing: Style.space(28)

    Item {
      id: stage

      readonly property int bandCount: 14

      anchors.horizontalCenter: parent.horizontalCenter
      width: Style.space(264)
      height: width

    Item {
      id: whorl

      // The print as five ridges on a 24-unit grid, core first, each one the
      // centre line of a ridge of the Material Design fingerprint icon (Apache
      // 2.0), drawn one unit wide, with its length in those units.
      readonly property var ridges: [
        { length: 8.82, path: "M11.94 14.66C11.94 16.25 12.75 17.7 14.1 18.63C14.9 19.17 15.85 19.44 16.92 19.44C17.2 19.44 17.6 19.4 18.05 19.33" },
        { length: 23.25, path: "M9.75 21.29C8.9 20.4 8.45 19.9 7.83 18.8C7.2 17.65 6.84 16.2 6.84 14.66C6.84 11.96 9.15 9.77 12 9.77C14.85 9.77 17.16 11.96 17.16 14.66" },
        { length: 52.72, path: "M14.91 21.5C13.4 21.08 12.4 20.5 11.4 19.5C10.1 18.2 9.39 16.5 9.39 14.66C9.39 13.3 10.55 12.22 11.97 12.22C13.39 12.22 14.55 13.3 14.55 14.66C14.55 16 15.7 17.1 17.13 17.1C18.56 17.1 19.71 16 19.71 14.66C19.71 10.6 16.25 7.33 12 7.33C8.95 7.33 6.2 9.03 4.94 11.65C4.5 12.55 4.3 13.55 4.3 14.66C4.3 15.5 4.4 16.8 5 18.4" },
        { length: 19.81, path: "M3.5 9.22C4.45 7.9 5.65 6.85 7.07 6.1C10.1 4.55 14 4.55 17 6.1C18.4 6.85 19.6 7.9 20.5 9.22" },
        { length: 12.11, path: "M6.2 3.97C7.9 3 9.9 2.5 12.01 2.5C14.1 2.5 15.9 2.95 17.81 3.97" }
      ]
      readonly property real ridgeTotal: {
        var total = 0
        for (var i = 0; i < ridges.length; i++) total += ridges[i].length
        return total
      }
      // How much of the print is lit, 0 to 1, drawn along the ridges from the
      // core outward. Every accepted touch lights the same length of ridge,
      // however many touches this reader asks for.
      property real filled: view.ctl.phase === "failed" ? 1 : view.ctl.progress

      Behavior on filled {
        NumberAnimation { duration: Style.duration(280); easing.type: Easing.OutCubic }
      }

      anchors.fill: parent

      Repeater {
        model: whorl.ridges

        Shape {
          id: ridge
          required property var modelData
          required property int index
          // The length of ridge before this one, and how much of this one is lit.
          readonly property real before: {
            var sum = 0
            for (var i = 0; i < index; i++) sum += whorl.ridges[i].length
            return sum
          }
          readonly property real lit: Math.max(0, Math.min(modelData.length, whorl.filled * whorl.ridgeTotal - before))

          // Drawn on the 24-unit grid and scaled up, stroke and all.
          width: 24
          height: 24
          transform: Scale { xScale: whorl.width / 24; yScale: whorl.height / 24 }
          preferredRendererType: Shape.CurveRenderer

          ShapePath {
            strokeWidth: 1
            strokeColor: Qt.rgba(1, 1, 1, 0.3)
            fillColor: "transparent"
            capStyle: ShapePath.RoundCap
            PathSvg { path: ridge.modelData.path }
          }
          // The lit length, as the first dash of a pattern whose gap outruns
          // the ridge. Dashes are measured in stroke widths, here one unit.
          ShapePath {
            strokeWidth: 1
            strokeColor: ridge.lit > 0.01 ? view.tone : "transparent"
            fillColor: "transparent"
            capStyle: ShapePath.RoundCap
            strokeStyle: ShapePath.DashLine
            dashPattern: [Math.max(0.01, ridge.lit), 1000]
            PathSvg { path: ridge.modelData.path }
          }
        }
      }
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
  }
}
