import QtQuick
import Quickshell
import Quickshell.Wayland
import qs.Commons
import qs.Ui

// The countdown for the last minutes: a small card at the bottom of the
// screen that appears once the time drops below five minutes, and during the
// grace period counts down to the lock. Visual only; it never takes input.
Item {
  id: root

  property var service: null   // injected by the shell for the plugin's own panel

  readonly property bool connected: service ? service.connected === true : false
  // Never in together mode: nothing counts down there.
  readonly property bool together: service ? service.philosophy === "together" : false
  readonly property string phase: service ? String(service.phase) : ""
  readonly property bool graceToLock: (phase === "empty" || phase === "bedtime")
    && service && service.lockInSeconds !== null && !service.locked
  readonly property bool lastMinutes: phase === "running" && service
    && service.remainingSeconds > 0 && service.remainingSeconds <= 300
  readonly property bool opened: connected && !together && (lastMinutes || graceToLock)

  readonly property int secondsLeft: {
    if (!service) return 0
    if (graceToLock) return Math.max(0, Number(service.lockInSeconds) || 0)
    return service.remainingSeconds
  }

  readonly property string headline: {
    var mm = Math.floor(secondsLeft / 60)
    var ss = secondsLeft % 60
    return mm + ":" + (ss < 10 ? "0" : "") + ss
  }

  readonly property string caption: {
    if (graceToLock) {
      if (phase !== "bedtime") return "Time is up. The screen is about to lock."
      var label = service ? String(service.blockedLabel || "").trim() : ""
      return (label === "" ? "Blocked" : label) + ". The screen is about to lock."
    }
    return "screen time left"
  }

  readonly property bool lightTheme: {
    var bg = Color.background
    return (0.299 * bg.r + 0.587 * bg.g + 0.114 * bg.b) > 0.5
  }
  readonly property color urgentColor: lightTheme ? "#B03434" : "#E06C6C"
  readonly property bool urgent: graceToLock || secondsLeft <= 60

  readonly property int pad: Style.space(16)

  PanelWindow {
    visible: root.opened
    anchors { top: true; bottom: true; left: true; right: true }
    color: "transparent"
    WlrLayershell.namespace: "screen-time-countdown"
    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.None
    exclusionMode: ExclusionMode.Ignore
    // Visual-only surface: an empty input region so it never blocks a click.
    mask: Region {}

    BorderSurface {
      id: card
      width: card.borderLeft + root.pad + content.implicitWidth + root.pad + card.borderRight
      height: card.borderTop + root.pad + content.implicitHeight + root.pad + card.borderBottom
      anchors.horizontalCenter: parent.horizontalCenter
      anchors.bottom: parent.bottom
      anchors.bottomMargin: Style.space(67)
      color: Util.alpha(Color.background, 0.97)
      borderSpec: Border.surfaceSpec("popups", "border", Color.popups.border, Math.max(1, Style.space(2)))
      radius: Style.cornerRadius
      opacity: root.opened ? 1 : 0

      Row {
        id: content
        anchors.centerIn: parent
        spacing: Style.space(12)

        Text {
          textFormat: Text.PlainText
          anchors.verticalCenter: parent.verticalCenter
          text: "\uf254"
          font.family: Style.font.family
          font.pixelSize: Style.font.displayLarge
          color: root.urgent ? root.urgentColor : Color.popups.text
        }

        Column {
          anchors.verticalCenter: parent.verticalCenter
          spacing: Style.space(2)

          Text {
            textFormat: Text.PlainText
            text: root.headline
            font.family: Style.font.family
            font.bold: true
            font.pixelSize: Style.font.displayLarge
            color: root.urgent ? root.urgentColor : Color.popups.text
          }

          Text {
            textFormat: Text.PlainText
            text: root.caption
            font.family: Style.font.family
            font.pixelSize: Style.font.caption
            color: Util.alpha(Color.popups.text, 0.7)
          }
        }
      }
    }
  }
}
