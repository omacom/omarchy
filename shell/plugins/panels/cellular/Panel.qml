import QtQuick
import QtQuick.Layouts
import Quickshell
import qs.Commons
import qs.Commons as Commons
import qs.Ui
import "Model.js" as Model

Panel {
  id: root
  moduleName: "omarchy.cellular"
  ipcTarget: "omarchy.cellular"
  manageIpc: false

  // The shell's one ModemManager watcher. Every monitor's widget reads the
  // same state, and holding it is what starts the watcher.
  readonly property var cellular: bar?.shell?.firstPartyServiceFor("omarchy.cellular") ?? null
  property var heldService: null
  property bool countedOpen: false

  readonly property var view: cellular ? cellular.view : null
  readonly property var status: cellular ? cellular.status : null
  readonly property var bearer: status ? status.bearer : null
  readonly property bool available: !!cellular && cellular.available
  readonly property bool alarm: !!view && view.visual === "alarm"
  readonly property bool hasLink: !!view && (view.kind === "connected" || view.kind === "registered")
  // The switch stays put while the link changes state, showing where it is
  // headed, so the hero does not reflow through connecting/disconnecting.
  readonly property bool dataBusy: !!cellular && (cellular.pendingAction !== "" || (!!view && view.transition !== ""))
  readonly property bool dataOn: {
    if (cellular && cellular.pendingAction !== "") return cellular.pendingAction === "connect"
    if (view && view.transition !== "") return view.transition === "connecting"
    return !!view && view.connected
  }
  readonly property bool canToggleData: hasLink

  readonly property color foreground: bar ? bar.foreground : Commons.Color.foreground
  readonly property color urgent: bar ? bar.urgent : Commons.Color.urgent
  readonly property color dim: Qt.darker(foreground, 1.55)
  readonly property string fontFamily: bar ? bar.fontFamily : Style.font.family

  readonly property string heroMeta: {
    if (!view) return ""
    if (view.roaming) return view.statusText + " · " + Commons.I18n.t("cellular.roaming")
    return view.statusText
  }
  readonly property string stateDetail: {
    if (!view) return ""
    if (view.kind === "sim-missing") return Commons.I18n.t("cellular.simMissingDetail")
    // The unlock command is a technical token and stays as written.
    if (view.kind === "pin-locked") return Commons.I18n.t("cellular.simLockedDetail").arg("mmcli -i any --pin=…")
    if (view.kind === "failed") return Commons.I18n.t("cellular.modemFailedDetail")
    if (view.kind === "disabled") return Commons.I18n.t("cellular.modemOffDetail")
    if (view.kind === "no-modem") return Commons.I18n.t("cellular.noModemDetail")
    return ""
  }

  // The hero's two controls are the panel's keyboard cursor: refresh, then
  // the mobile data switch when there is a network to switch on.
  property bool cursorActive: false
  property int headerIndex: 0
  readonly property int headerCount: canToggleData ? 2 : 1
  readonly property bool refreshHasCursor: cursorActive && headerIndex === 0
  readonly property bool switchHasCursor: cursorActive && headerIndex === 1 && canToggleData

  function syncHold() {
    if (heldService === cellular) return
    if (heldService) {
      if (countedOpen) heldService.panelClosed()
      heldService.release()
    }
    countedOpen = false
    heldService = cellular
    if (heldService) heldService.acquire()
    syncOpen()
  }

  function syncOpen() {
    var shouldCount = opened && !!heldService
    if (shouldCount === countedOpen) return
    countedOpen = shouldCount
    if (shouldCount) heldService.panelOpened()
    else if (heldService) heldService.panelClosed()
  }

  function refresh() {
    if (cellular) cellular.refresh()
  }

  function toggleData() {
    if (cellular && canToggleData) cellular.toggleData()
  }

  function copyToClipboard(value) {
    if (!value) return
    Quickshell.execDetached(["bash", "-c", "printf %s " + Util.shellQuote(value) + " | wl-copy"])
  }

  function moveHeader(delta) {
    headerIndex = Math.max(0, Math.min(headerCount - 1, headerIndex + delta))
  }

  function activateHeader() {
    if (headerIndex === 0) refresh()
    else toggleData()
  }

  function setHeaderCursor(index) {
    cursorActive = true
    headerIndex = index
  }

  function formatBytes(bytes) {
    return bytes < 0 ? "--" : Model.formatBytes(bytes, Commons.I18n.formatNumber)
  }

  // IPC answers stay English; the panel translates at display.
  function statusJson() {
    if (!view || !status) return JSON.stringify({ state: "unavailable" })
    return JSON.stringify({
      state: view.kind,
      operator: status.operatorName,
      technology: view.tech,
      signal: status.signal,
      roaming: view.roaming,
      connected: view.connected,
      iface: cellular.iface
    })
  }

  visible: available
  implicitWidth: available ? button.implicitWidth : 0
  implicitHeight: available ? button.implicitHeight : 0

  onCellularChanged: syncHold()
  onOpenedChanged: {
    syncOpen()
    if (opened) {
      cursorActive = false
      headerIndex = 0
      Qt.callLater(function() { if (panel.loadedContent) panel.loadedContent.forceActiveFocus() })
    }
  }
  onAvailableChanged: if (!available && opened) close()
  onHeaderCountChanged: moveHeader(0)
  Component.onCompleted: syncHold()
  Component.onDestruction: {
    if (!heldService) return
    if (countedOpen) heldService.panelClosed()
    heldService.release()
  }

  ShellIpc {
    target: root.ipcTarget
    function open(): void { root.open() }
    function close(): void { root.close() }
    function show(): void { root.open() }
    function hide(): void { root.close() }
    function toggle(): void { root.toggle() }
    function refresh(): string { root.refresh(); return "ok" }
    function dataOn(): string { if (root.cellular) root.cellular.setData(true); return "ok" }
    function dataOff(): string { if (root.cellular) root.cellular.setData(false); return "ok" }
    function status(): string { return root.statusJson() }
  }

  BarIconButton {
    id: button
    anchors.fill: parent
    bar: root.bar
    active: root.alarm
    dimmed: !!root.view && root.view.visual === "dimmed"
    tooltipText: root.view ? root.view.tooltip : ""
    iconComponent: Component {
      Item {
        CellularIcon {
          x: (parent.width - width) / 2
          y: (parent.height - height) / 2
          iconSize: button.iconSize
          color: root.alarm ? root.urgent : root.barForeground
          level: root.view ? root.view.level : 0
          crossed: !!root.view && root.view.crossed
          badge: root.view ? root.view.badge : ""
        }
      }
    }
    onPressed: function(buttonCode) {
      if (buttonCode === Qt.MiddleButton) root.refresh()
      else root.toggle()
    }
  }

  KeyboardPanel {
    id: panel
    anchorItem: button
    owner: root
    bar: root.bar
    open: root.opened
    focusTarget: panel.loadedContent
    contentWidth: panel.fittedContentWidth(Style.space(380))
    contentHeight: panel.fittedContentHeight(panel.loadedContentHeight)

    content: PanelKeyCatcher {
      id: keyCatcher
      implicitHeight: column.implicitHeight
      anchors.fill: parent
      onMoveRequested: function(dx, dy) {
        if (!root.cursorActive) {
          root.cursorActive = true
          return
        }
        if (dx !== 0) root.moveHeader(dx)
      }
      onActivateRequested: if (root.cursorActive) root.activateHeader()
      onCloseRequested: root.close()
      onTabRequested: function(direction) { root.switchPanel(direction) }
      onTextKey: function(t) {
        if (t === "r" || t === "R") root.refresh()
        else if (t === "t" || t === "T") root.toggleData()
        else if (t === "c" || t === "C") root.copyToClipboard(root.bearer ? root.bearer.ipv4 : "")
      }

      Column {
        id: column
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top
        spacing: Style.space(12)

        Item {
          id: header
          width: parent.width
          implicitHeight: hero.implicitHeight
          // Exposed for the hero's trailingControl, which reaches panel state
          // through `header` rather than through ids of this file.
          readonly property bool refreshCursor: root.refreshHasCursor
          readonly property bool switchCursor: root.switchHasCursor
          readonly property bool switchVisible: root.canToggleData
          readonly property bool switchChecked: root.dataOn
          readonly property bool switchBusy: root.dataBusy
          readonly property string switchHint: root.dataOn ? Commons.I18n.t("cellular.disconnectData") : Commons.I18n.t("cellular.connectData")
          function cursorTo(index) { root.setHeaderCursor(index) }
          function refresh() { root.refresh() }
          function toggleData() { root.toggleData() }

          PanelHero {
            id: hero
            width: parent.width
            title: root.view ? root.view.title : ""
            detail: root.view && root.hasLink ? root.view.tech : ""
            meta: root.heroMeta
            foreground: root.foreground
            fontFamily: root.fontFamily
            iconOpacity: root.view && root.view.visual === "dimmed" ? 0.6 : 1.0
            iconComponent: Component {
              CellularIcon {
                iconSize: Style.font.display
                color: root.alarm ? root.urgent : root.foreground
                level: root.view ? root.view.level : 0
                crossed: !!root.view && root.view.crossed
                badge: root.view ? root.view.badge : ""
              }
            }

            trailingControl: Component {
              Row {
                spacing: Style.space(8)

                PanelActionButton {
                  anchors.verticalCenter: parent.verticalCenter
                  iconText: "󰑐"
                  tooltipText: Commons.I18n.t("cellular.refresh")
                  foreground: hero.foreground
                  fontFamily: hero.fontFamily
                  fontSize: Style.font.subtitle * 1.5
                  hasCursor: header.refreshCursor
                  onHovered: function(on) { if (on) header.cursorTo(0) }
                  onClicked: header.refresh()
                }

                ToggleSwitch {
                  id: dataSwitch
                  anchors.verticalCenter: parent.verticalCenter
                  visible: header.switchVisible
                  checked: header.switchChecked
                  busy: header.switchBusy
                  hasCursor: header.switchCursor
                  foreground: hero.foreground
                  onHovered: function(on) { if (on) header.cursorTo(1) }
                  onToggled: header.toggleData()

                  PanelToolTip {
                    visible: dataSwitch.containsMouse
                    text: header.switchHint
                    fontFamily: hero.fontFamily
                  }
                }
              }
            }
          }
        }

        Text {
          textFormat: Text.PlainText
          visible: text !== ""
          width: parent.width
          text: root.cellular ? root.cellular.lastError : ""
          color: root.urgent
          font.family: root.fontFamily
          font.pixelSize: Style.font.bodySmall
          wrapMode: Text.WordWrap
        }

        Text {
          textFormat: Text.PlainText
          visible: text !== ""
          width: parent.width
          text: root.stateDetail
          color: root.alarm ? root.urgent : root.dim
          font.family: root.fontFamily
          font.pixelSize: Style.font.bodySmall
          wrapMode: Text.WordWrap
        }

        // Link at a glance: what the radio sees, then what data has moved.
        GridLayout {
          visible: !!root.status && root.status.present && root.view.kind !== "no-modem"
          width: parent.width
          columns: 4
          columnSpacing: Style.space(20)
          rowSpacing: Style.spacing.labelGap

          InfoLabel { text: Commons.I18n.t("cellular.signal") }
          DetailValue {
            text: root.status && root.status.signal >= 0
              ? Commons.I18n.t("cellular.percent").arg(Commons.I18n.formatNumber(root.status.signal)) : "--"
          }
          InfoLabel { text: Commons.I18n.t("cellular.technology") }
          DetailValue { text: root.view && root.view.tech !== "" ? root.view.tech : "--" }

          InfoLabel { text: Commons.I18n.t("cellular.registration") }
          DetailValue { text: root.status ? Model.registrationLabel(root.status.registration, Commons.I18n.t) : "--" }
          InfoLabel { text: Commons.I18n.t("cellular.roaming") }
          DetailValue {
            text: !root.status || root.status.registration === "" ? "--"
              : (root.view.roaming ? Commons.I18n.t("cellular.yes") : Commons.I18n.t("cellular.no"))
          }

          InfoLabel { text: Commons.I18n.t("cellular.received") }
          DetailValue { text: root.formatBytes(root.cellular ? root.cellular.rxBytes : -1) }
          InfoLabel { text: Commons.I18n.t("cellular.sent") }
          DetailValue { text: root.formatBytes(root.cellular ? root.cellular.txBytes : -1) }
        }

        PanelSeparator {
          visible: details.visible
          foreground: root.foreground
        }

        // Longer values get a row each.
        GridLayout {
          id: details
          visible: !!root.status && root.status.present
          width: parent.width
          columns: 2
          columnSpacing: Style.space(20)
          rowSpacing: Style.spacing.labelGap

          InfoLabel { text: Commons.I18n.t("cellular.apn") }
          DetailValue { text: root.status && root.status.apn !== "" ? root.status.apn : "--" }

          InfoLabel { text: Commons.I18n.t("cellular.ipAddress") }
          DetailValue {
            text: Model.formatAddress(root.bearer) || "--"
            copyable: !!root.bearer && root.bearer.ipv4 !== ""
            copyValue: root.bearer ? root.bearer.ipv4 : ""
            tooltipText: Commons.I18n.t("cellular.copyIp")
          }

          InfoLabel { text: Commons.I18n.t("cellular.bearer") }
          DetailValue {
            text: {
              if (!root.bearer) return "--"
              if (!root.bearer.connected) return Commons.I18n.t("cellular.bearerDown")
              var uptime = Model.formatUptime(root.bearer.startDate, root.cellular.nowSeconds, Commons.I18n.t, Commons.I18n.formatNumber)
              return uptime !== "" ? Commons.I18n.t("cellular.bearerUp").arg(uptime) : Commons.I18n.t("cellular.connected")
            }
          }

          InfoLabel { text: Commons.I18n.t("cellular.interface") }
          DetailValue { text: root.cellular && root.cellular.iface !== "" ? root.cellular.iface : "--" }

          InfoLabel { text: Commons.I18n.t("cellular.networkCode") }
          DetailValue { text: root.status && root.status.operatorCode !== "" ? root.status.operatorCode : "--" }

          InfoLabel { text: Commons.I18n.t("cellular.modem") }
          DetailValue { text: root.status && root.status.model !== "" ? root.status.model : "--" }
        }
      }
    }
  }

  component DetailValue: InfoValue {
    id: detailValue
    property bool copyable: false
    property string copyValue: text
    property string tooltipText: ""

    Layout.fillWidth: true
    horizontalAlignment: Text.AlignRight
    elide: Text.ElideRight

    MouseArea {
      id: valueMouse
      anchors.fill: parent
      enabled: detailValue.copyable && detailValue.copyValue !== ""
      hoverEnabled: enabled
      cursorShape: enabled ? Qt.PointingHandCursor : Qt.ArrowCursor
      onClicked: root.copyToClipboard(detailValue.copyValue)
    }

    PanelToolTip {
      visible: valueMouse.enabled && valueMouse.containsMouse && detailValue.tooltipText !== ""
      text: detailValue.tooltipText
      fontFamily: root.fontFamily
    }
  }

  component InfoLabel: Text {
    textFormat: Text.PlainText
    color: root.foreground
    opacity: 0.6
    font.family: root.fontFamily
    font.pixelSize: Style.font.bodySmall
  }

  component InfoValue: Text {
    textFormat: Text.PlainText
    color: root.foreground
    font.family: root.fontFamily
    font.pixelSize: Style.font.bodySmall
  }
}
