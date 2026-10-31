import QtQuick
import qs.Commons
import qs.Commons as Commons
import qs.Ui

BarIndicator {
  id: root

  readonly property var idleService: bar?.shell?.firstPartyServiceFor("omarchy.idle")

  active: idleService ? idleService.stayAwake : false
  activeText: ""
  inactiveText: ""
  activeTooltipText: idleService && idleService.stayAwakeUntil > 0
    ? I18n.t("bar.stayAwakeUntil").arg(Qt.formatTime(new Date(idleService.stayAwakeUntil), Qt.locale(), Locale.ShortFormat)) + "\n" + I18n.t("bar.stayAwakeDurationHint")
    : I18n.t("bar.allowIdleLock") + "\n" + I18n.t("bar.stayAwakeDurationHint")
  inactiveTooltipText: I18n.t("bar.stayAwake") + "\n" + I18n.t("bar.stayAwakeDurationHint")

  function toggle() {
    if (root.idleService) root.idleService.setIdleEnabled(root.active)
  }

  function close() { durationPopup.open = false }

  onPressed: function(button) {
    if (button === Qt.RightButton) durationPopup.open = !durationPopup.open
    else if (button === Qt.LeftButton) {
      root.close()
      root.toggle()
    }
  }

  KeyboardPanel {
    id: durationPopup
    anchorItem: root
    owner: root
    bar: root.bar
    focusTarget: durationPopup.loadedContent
    contentWidth: fittedContentWidth(Style.space(232))
    contentHeight: fittedContentHeight(loadedContentHeight)
    onOpenChanged: if (open && loadedContent) loadedContent.currentIndex = 0

    content: PanelKeyCatcher {
      id: keys
      implicitHeight: options.implicitHeight
      property int currentIndex: 0

      function moveChoice(direction) {
        currentIndex = (currentIndex + direction + choices.count + 1) % (choices.count + 1)
      }

      onMoveRequested: function(dx, dy) { if (dy) moveChoice(dy) }
      onTabRequested: function(direction) { moveChoice(direction) }
      onActivateRequested: {
        var button = currentIndex === choices.count ? turnOff : choices.itemAt(currentIndex)
        if (button) button.clicked()
      }
      onCloseRequested: root.close()

      Column {
        id: options
        width: parent.width
        spacing: Style.spacing.labelGap

        Text {
          text: I18n.t("bar.stayAwake")
          textFormat: Text.PlainText
          color: Commons.Color.popups.text
          font.family: root.fontFamily
          font.pixelSize: Style.font.body
          font.bold: true
          leftPadding: Style.spacing.controlPaddingX
          height: implicitHeight + Style.space(8)
        }

        Repeater {
          id: choices
          model: [
            { label: I18n.t("bar.stayAwake30Minutes"), seconds: 1800 },
            { label: I18n.t("bar.stayAwake1Hour"), seconds: 3600 },
            { label: I18n.t("bar.stayAwake3Hours"), seconds: 10800 },
            { label: I18n.t("bar.stayAwake8Hours"), seconds: 28800 },
            { label: I18n.t("bar.stayAwakeIndefinitely"), seconds: 0 }
          ]

          Button {
            required property var modelData
            required property int index
            width: options.width
            text: modelData.label
            foreground: Commons.Color.popups.text
            leftAlign: true
            hasCursor: keys.currentIndex === index
            onHovered: function(hovered) { if (hovered) keys.currentIndex = index }
            onClicked: {
              root.close()
              if (root.idleService) {
                if (modelData.seconds > 0) root.idleService.stayAwakeFor(modelData.seconds)
                else root.idleService.setIdleEnabled(false)
              }
            }
          }
        }

        PanelSeparator { foreground: Commons.Color.popups.text }

        Button {
          id: turnOff
          width: options.width
          text: I18n.t("bar.stayAwakeTurnOff")
          foreground: Commons.Color.popups.text
          leftAlign: true
          hasCursor: keys.currentIndex === choices.count
          onHovered: function(hovered) { if (hovered) keys.currentIndex = choices.count }
          onClicked: {
            root.close()
            if (root.idleService) root.idleService.setIdleEnabled(true)
          }
        }
      }
    }
  }
}
