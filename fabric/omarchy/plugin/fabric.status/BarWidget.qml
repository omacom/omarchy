import QtQuick
import Quickshell
import Quickshell.Io
import qs.Commons
import qs.Commons as Commons
import qs.Ui

// Fabric bar widget. It never polls and never starts a process while idle: the
// `ofab console` user service rewrites $XDG_RUNTIME_DIR/omarchy-fabric/status.json
// on every fabric event, and this widget watches that file.
BarWidget {
  id: root
  moduleName: "fabric.status"
  implicitWidth: button.implicitWidth
  implicitHeight: button.implicitHeight

  property var fabricStatus: ({ connected: false, pending: [], frozen: null })
  property bool popupOpen: false
  readonly property var pendingList: root.fabricStatus.pending || []
  readonly property int pendingCount: root.pendingList.length
  readonly property bool frozen: !!root.fabricStatus.frozen
  readonly property bool connected: !!root.fabricStatus.connected

  function close() { root.popupOpen = false }

  // The status file is written by our own service, but treat it as untrusted:
  // approval ids must match the fabric's fixed alphabet before they reach a command.
  function safeId(id) {
    var text = String(id)
    return /^[A-HJ-NP-Z2-9]{6}$/.test(text) ? text : ""
  }

  function clip(value, max) {
    var text = String(value === undefined || value === null ? "" : value)
    return text.length > max ? text.slice(0, max - 1) + "…" : text
  }

  function apply(text) {
    var parsed = null
    try { parsed = JSON.parse(text || "{}") } catch (e) { parsed = null }
    if (!parsed || typeof parsed !== "object") parsed = { connected: false, pending: [] }
    if (!Array.isArray(parsed.pending)) parsed.pending = []
    parsed.pending = parsed.pending.slice(0, 20)
    root.fabricStatus = parsed
  }

  Translations { id: strings; directory: Qt.resolvedUrl("i18n") }

  FileView {
    id: statusFile
    path: Quickshell.env("XDG_RUNTIME_DIR") + "/omarchy-fabric/status.json"
    watchChanges: true
    printErrors: false
    onFileChanged: reload()
    onLoaded: root.apply(text())
    onLoadFailed: root.apply("")
  }

  WidgetButton {
    id: button
    anchors.fill: parent
    bar: root.bar
    text: root.frozen ? "󰒎" : (root.pendingCount > 0 ? "󰒍 " + Commons.I18n.formatNumber(root.pendingCount) : "󰒍")
    active: root.frozen || root.pendingCount > 0
    tooltipText: !root.connected ? strings.t("tooltip.disconnected")
      : root.frozen ? strings.t("tooltip.frozen")
      : root.pendingCount > 0 ? strings.tn("tooltip.pending", root.pendingCount).arg(Commons.I18n.formatNumber(root.pendingCount))
      : strings.t("tooltip.idle")
    onPressed: function(mouseButton) {
      if (mouseButton === Qt.RightButton) {
        root.bar.run("omarchy-launch-floating-terminal-with-presentation 'ofab status; ofab approvals'")
      } else {
        root.popupOpen = !root.popupOpen
      }
    }
  }

  PopupCard {
    id: popup
    anchorItem: root
    bar: root.bar
    owner: root
    open: root.popupOpen
    contentWidth: popup.fittedContentWidth(Style.space(360))
    contentHeight: popup.fittedContentHeight(column.implicitHeight)

    Column {
      id: column
      width: parent.width
      spacing: Style.space(8)

      Text {
        textFormat: Text.PlainText
        text: strings.t("title")
        color: Commons.Color.popups.text
        font.family: Style.font.family
        font.pixelSize: Style.font.subtitle
        font.bold: true
      }

      Text {
        visible: root.pendingCount === 0
        width: column.width
        wrapMode: Text.Wrap
        textFormat: Text.PlainText
        text: !root.connected ? strings.t("tooltip.disconnected") : root.frozen ? strings.t("popup.frozen") : strings.t("popup.none")
        color: Commons.Color.popups.text
        font.family: Style.font.family
        font.pixelSize: Style.font.body
      }

      Repeater {
        model: root.pendingList
        delegate: Column {
          required property var modelData
          width: column.width
          spacing: Style.space(2)

          Text {
            width: parent.width
            wrapMode: Text.Wrap
            textFormat: Text.PlainText
            text: root.clip(modelData.summary, 140)
            color: Commons.Color.popups.text
            font.family: Style.font.family
            font.pixelSize: Style.font.body
            font.bold: true
          }

          Text {
            width: parent.width
            wrapMode: Text.Wrap
            textFormat: Text.PlainText
            text: root.clip(modelData.tier, 4) + " · " + root.clip(modelData.reason, 160)
            color: Commons.Color.popups.text
            opacity: 0.7
            font.family: Style.font.family
            font.pixelSize: Style.font.body
          }

          Row {
            spacing: Style.space(16)

            Text {
              visible: modelData.requires !== "presence"
              textFormat: Text.PlainText
              text: strings.t("action.approve")
              color: Commons.Color.popups.text
              font.family: Style.font.family
              font.pixelSize: Style.font.body
              font.underline: true
              MouseArea {
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                onClicked: {
                  var id = root.safeId(modelData.id)
                  if (id) root.bar.run("ofab approve " + id)
                }
              }
            }

            Text {
              visible: modelData.requires === "presence"
              textFormat: Text.PlainText
              text: strings.t("action.presence")
              color: Commons.Color.popups.text
              opacity: 0.7
              font.family: Style.font.family
              font.pixelSize: Style.font.body
            }

            Text {
              textFormat: Text.PlainText
              text: strings.t("action.deny")
              color: Commons.Color.popups.text
              font.family: Style.font.family
              font.pixelSize: Style.font.body
              font.underline: true
              MouseArea {
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                onClicked: {
                  var id = root.safeId(modelData.id)
                  if (id) root.bar.run("ofab deny " + id)
                }
              }
            }
          }
        }
      }

      Text {
        visible: root.connected
        textFormat: Text.PlainText
        text: root.frozen ? strings.t("action.thaw") : strings.t("action.freeze")
        color: Commons.Color.popups.text
        font.family: Style.font.family
        font.pixelSize: Style.font.body
        font.underline: true
        MouseArea {
          anchors.fill: parent
          cursorShape: Qt.PointingHandCursor
          onClicked: root.bar.run(root.frozen ? "ofab thaw" : "ofab freeze from the bar")
        }
      }
    }
  }
}
