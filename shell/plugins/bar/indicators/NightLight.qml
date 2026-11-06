import QtQuick
import qs.Commons
import qs.Commons as Commons
import qs.Ui

Panel {
  id: root

  readonly property var nightlightService: bar?.shell?.firstPartyServiceFor("omarchy.nightlight")
  readonly property bool active: nightlightService ? nightlightService.enabled : false
  readonly property var modeOptions: ["daylight", "nightlight", "sunset"]
  readonly property string mode: nightlightService && nightlightService.scheduled
    ? "sunset"
    : (root.active ? "nightlight" : "daylight")
  property string indicatorBlock: "single"
  property var indicatorHost: null
  property var activeOverride: null
  property int cursorIndex: 0

  manageIpc: false
  implicitWidth: indicator.implicitWidth
  implicitHeight: indicator.implicitHeight
  visible: indicator.visible

  function switchPanel(direction) {
    if (bar && typeof bar.switchPanelFrom === "function")
      return bar.switchPanelFrom(indicatorHost || root, direction)
    return false
  }

  function toggleTemperature() {
    if (root.nightlightService) root.nightlightService.setNightlight(!root.active)
  }

  function triggerPress(button) {
    if (button === Qt.RightButton) root.toggle()
    else indicator.triggerPress(button)
  }

  function openSettings() {
    Qt.callLater(function() { root.toggle() })
  }

  function selectMode(mode) {
    if (!root.nightlightService) return
    if (mode === "sunset") root.nightlightService.setScheduleEnabled(true)
    else root.nightlightService.setNightlight(mode === "nightlight")
  }

  function moveCursor(delta) {
    cursorIndex = Math.max(0, Math.min(modeOptions.length - 1, cursorIndex + delta))
  }

  onOpenedChanged: {
    if (opened) cursorIndex = Math.max(0, modeOptions.indexOf(mode))
  }

  BarIndicator {
    id: indicator

    anchors.fill: parent
    bar: root.bar
    moduleName: root.moduleName
    settings: root.settings
    indicatorBlock: root.indicatorBlock
    indicatorHost: root.indicatorHost
    activeOverride: root.opened ? null : root.activeOverride
    alwaysRevealInactive: true
    active: root.active
    activeText: "󰔎"
    inactiveText: "󰔎"
    activeTooltipText: I18n.t("nightlight.tooltip").arg(I18n.t("bar.dayLight"))
    inactiveTooltipText: I18n.t("nightlight.tooltip").arg(I18n.t("bar.nightLight"))

    onPressed: function(button) {
      if (button === Qt.RightButton) root.toggle()
      else root.toggleTemperature()
    }
  }

  MouseArea {
    anchors.fill: indicator
    acceptedButtons: Qt.RightButton
    cursorShape: Qt.PointingHandCursor
    onClicked: root.openSettings()
  }

  KeyboardPanel {
    id: panel
    anchorItem: indicator
    owner: root
    bar: root.bar
    open: root.opened
    focusTarget: panel.loadedContent
    contentWidth: panel.fittedContentWidth(Style.space(360))
    contentHeight: panel.fittedContentHeight(panel.loadedContentHeight)

    content: PanelKeyCatcher {
      id: keyCatcher
      anchors.fill: parent
      implicitHeight: column.implicitHeight
      onMoveRequested: function(dx, dy) { root.moveCursor(dx !== 0 ? dx : dy) }
      onActivateRequested: root.selectMode(root.modeOptions[root.cursorIndex])
      onCloseRequested: root.close()
      onTabRequested: function(direction) { root.switchPanel(direction) }

      Column {
        id: column
        anchors.left: parent.left
        anchors.right: parent.right
        spacing: Style.space(14)

        PanelHero {
          title: I18n.t("bar.nightLight")
          meta: root.mode === "sunset"
            ? I18n.t("nightlight.followSun")
            : (root.mode === "nightlight" ? I18n.t("nightlight.warmDisplay") : I18n.t("nightlight.daylightDisplay"))
          detail: root.mode === "sunset" && root.nightlightService
            ? root.nightlightService.scheduleTimezone
            : ""
          foreground: root.barForeground
          fontFamily: root.bar ? root.bar.fontFamily : Style.font.family
          iconComponent: Component {
            Text {
              text: "󰔎"
              color: root.barForeground
              font.family: root.bar ? root.bar.fontFamily : Style.font.family
              font.pixelSize: Style.font.display
            }
          }
        }

        PanelSeparator {
          foreground: root.barForeground
        }

        Column {
          width: parent.width
          spacing: Style.space(8)

          PanelSectionHeader {
            text: I18n.t("nightlight.mode")
            foreground: root.barForeground
            fontFamily: root.bar ? root.bar.fontFamily : Style.font.family
          }

          ButtonGroup {
            options: [
              { value: "daylight", label: I18n.t("nightlight.daylight") },
              { value: "nightlight", label: I18n.t("bar.nightLight") },
              { value: "sunset", label: I18n.t("nightlight.sunset") }
            ]
            value: root.mode
            cursorIndex: root.cursorIndex
            foreground: root.barForeground
            background: Commons.Color.popups.background
            accent: Commons.Color.accent
            fontFamily: root.bar ? root.bar.fontFamily : Style.font.family
            focusable: false
            onChanged: function(value) { root.selectMode(value) }
            onHovered: function(index, hovered) { if (hovered) root.cursorIndex = index }
          }
        }

        Text {
          visible: root.mode === "sunset" && root.nightlightService && root.nightlightService.nextEventAt !== ""
          width: parent.width
          textFormat: Text.PlainText
          text: {
            if (!root.nightlightService || root.nightlightService.nextEventAt === "") return ""
            var time = new Date(root.nightlightService.nextEventAt).toLocaleString(Qt.locale(I18n.formatLocale), I18n.t("nightlight.eventTimeFormat"))
            return root.nightlightService.nextEvent === "sunrise"
              ? I18n.t("nightlight.nextSunrise").arg(time)
              : I18n.t("nightlight.nextSunset").arg(time)
          }
          color: Qt.darker(root.barForeground, 1.4)
          font.family: root.bar ? root.bar.fontFamily : Style.font.family
          font.pixelSize: Style.font.bodySmall
          horizontalAlignment: Text.AlignHCenter
        }
      }
    }
  }
}
