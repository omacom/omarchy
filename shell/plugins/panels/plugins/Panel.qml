import QtQuick
import QtQuick.Layouts
import QtQuick.Controls as Controls
import Quickshell
import Quickshell.Hyprland
import qs.Commons
import qs.Ui

Item {
  id: root
  property var shell: null
  property var manifest: null
  property bool opened: false
  property bool confirmYolo: false
  readonly property alias model: manager

  function open(payloadJson) {
    let payload = {}
    try { payload = JSON.parse(payloadJson || "{}") || {} } catch (e) {}
    opened = true
    confirmYolo = false
    if (!manager.load(payload.add) && manager.busy) manager.error = "Wait for the current action to finish."
  }
  function close() { manager.abandoned = true; opened = false }
  function dismiss() {
    if (shell) shell.hide("omarchy.plugins")
    else close()
  }
  function review(id, stage) {
    if (shell) {
      shell.summon("omarchy.plugin-review", JSON.stringify({id: id, stage: stage || ""}))
      dismiss()
    }
  }

  Model {
    id: manager
    onInstalled: (id, sandboxed) => { if (sandboxed) root.review(id) }
    onStaged: (id, stage) => root.review(id, stage)
  }

  KeyboardPanel {
    id: panel
    objectName: "plugin-manager-window"
    anchorItem: null
    bar: null
    centerOnScreen: true
    owner: QtObject { function close() { root.dismiss() } }
    screen: Quickshell.screens.find(screen => screen.name === Hyprland.focusedMonitor?.name) || Quickshell.screens[0] || null
    open: root.opened
    focusTarget: content
    contentWidth: fittedContentWidth(Style.space(560))
    contentHeight: cappedContentHeight(Math.min(Style.space(620), contentLayout.implicitHeight + padding * 2 + Border.top(borderSpec) + Border.bottom(borderSpec)))

    FocusScope {
      id: content
      anchors.fill: parent
      Keys.onEscapePressed: root.dismiss()

      ColumnLayout {
        id: contentLayout
        anchors.fill: parent
        spacing: Style.spacing.panelGap

        RowLayout {
          Layout.fillWidth: true
          Label { text: manager.adding ? "Add plugin" : "Plugins"; font.pixelSize: Style.font.heading; font.bold: true; Layout.fillWidth: true }
          Button { text: "Close"; focusable: true; implicitHeight: 40; onClicked: root.dismiss() }
        }
        PanelSeparator { foreground: Color.popups.text; Layout.fillWidth: true }

        Controls.ScrollView {
          id: scroll
          Layout.fillWidth: true
          Layout.fillHeight: true
          Layout.preferredHeight: body.implicitHeight
          clip: true
          rightPadding: Style.spacing.rowGap + effectiveScrollBarWidth
          contentWidth: availableWidth
          Controls.ScrollBar.horizontal.policy: Controls.ScrollBar.AlwaysOff
          Controls.ScrollBar.vertical.policy: contentHeight > availableHeight ? Controls.ScrollBar.AlwaysOn : Controls.ScrollBar.AlwaysOff

          Column {
            id: body
            width: scroll.availableWidth
            spacing: Style.spacing.rowGap

            Column {
              visible: manager.adding && !root.confirmYolo
              width: parent.width
              spacing: Style.spacing.rowGap
              enabled: !manager.busy
              Label { text: "Git URL or local repository"; width: parent.width }
              TextField {
                objectName: "plugin-source"
                width: parent.width
                implicitHeight: 40
                text: manager.source
                placeholderText: "https://github.com/owner/plugin"
                onTextChanged: if (manager.source !== text) manager.source = text
              }
              Toggle {
                objectName: "plugin-yolo"
                width: parent.width
                label: "YOLO · run without a sandbox"
                checked: manager.yolo
                onClicked: manager.yolo = !manager.yolo
              }
            }

            Column {
              visible: root.confirmYolo
              width: parent.width
              spacing: Style.spacing.rowGap
              Label { width: parent.width; text: "Do you trust this plugin to execute unsandboxed?"; font.bold: true }
              Label { width: parent.width; text: manager.source; wrapMode: Text.WrapAnywhere }
              Label { width: parent.width; text: "When enabled, it can access your files, accounts and network."; color: Color.urgent }
            }

            Column {
              visible: !manager.adding
              width: parent.width
              spacing: Style.spacing.labelGap
              Label { visible: manager.plugins.length === 0; text: "No plugins installed."; width: parent.width; color: Color.muted }
              Repeater {
                model: manager.plugins
                delegate: Button {
                  required property var modelData
                  objectName: "plugin-row-" + modelData.id
                  width: parent.width
                  implicitHeight: Math.max(64, label.implicitHeight + Style.spacing.rowGap * 2)
                  selected: manager.selectedId === modelData.id
                  focusable: true
                  enabled: !manager.busy
                  onClicked: manager.selectedId = modelData.id
                  Column {
                    id: label
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.margins: Style.spacing.rowGap
                    spacing: Style.spacing.labelGap
                    Label { text: modelData.name || modelData.id; font.bold: true; width: parent.width }
                    Label { text: manager.modeLabel(modelData.executionMode) + " · " + (modelData.enabled ? "Enabled" : modelData.approved ? "Approved · not enabled" : "Disabled"); color: Color.muted; width: parent.width; font.pixelSize: Style.font.bodySmall }
                  }
                }
              }
            }

            Label { visible: !manager.adding && !!manager.selected; text: manager.selected ? manager.selected.id : ""; color: Color.muted; width: parent.width }
            Label { visible: !manager.adding && !!manager.selected?.error; text: manager.selected?.error || ""; color: Color.urgent; width: parent.width }
            Label { visible: manager.confirmRemove; text: "Permanently remove this plugin? Its installed files, saved plugin data, permissions and installation history will be deleted. Original sources and files accessed through permissions are not deleted."; color: Color.urgent; width: parent.width }
            Label { visible: !!manager.error || !!manager.notice || manager.busy; text: manager.error || (manager.busy ? manager.progressText : manager.notice); color: manager.error ? Color.urgent : Color.muted; width: parent.width }
          }
        }

        PanelSeparator { foreground: Color.popups.text; Layout.fillWidth: true }
        Flow {
          Layout.fillWidth: true
          Layout.preferredHeight: childrenRect.height
          spacing: Style.spacing.labelGap
          Button { visible: !root.confirmYolo; text: manager.adding ? "Back" : "Add plugin"; focusable: true; implicitHeight: 40; enabled: !manager.busy; onClicked: { manager.setAdding(!manager.adding) } }
          Button { visible: manager.adding && !root.confirmYolo; text: manager.yolo ? "Clone in YOLO mode" : "Clone & review"; objectName: "plugin-add"; selected: true; focusable: true; implicitHeight: 40; enabled: !manager.busy && !!manager.source.trim(); opacity: enabled ? 1 : 0.4; onClicked: { if (manager.yolo) root.confirmYolo = true; else manager.add() } }
          Button { visible: root.confirmYolo; text: "No"; objectName: "plugin-trust-cancel"; focusable: true; implicitHeight: 40; enabled: !manager.busy; onClicked: { root.confirmYolo = false; manager.trustConfirmed = false } }
          Button { visible: root.confirmYolo; text: "Yes, clone unsandboxed"; objectName: "plugin-trust-confirm"; selected: true; focusable: true; implicitHeight: 40; enabled: !manager.busy; onClicked: { manager.trustConfirmed = true; root.confirmYolo = false; manager.add() } }
          Button { visible: !manager.adding && !!manager.selected?.sandboxed; text: "Review permissions"; focusable: true; implicitHeight: 40; enabled: !manager.busy; onClicked: root.review(manager.selectedId) }
          Button { visible: !manager.adding && !!manager.selected && !manager.selected.sandboxed && !manager.selected.enabled; text: "Enable plugin"; focusable: true; implicitHeight: 40; enabled: !manager.busy && !!manager.selected && !manager.selected.error; onClicked: manager.action("enable") }
          Button { objectName: "plugin-disable"; visible: !manager.adding && (!!manager.selected?.enabled || !!manager.selected?.approved); text: manager.selected?.sandboxed ? "Disable & revoke permissions" : "Disable"; focusable: true; implicitHeight: 40; enabled: !manager.busy; onClicked: manager.action("disable") }
          Button { objectName: "plugin-remove"; visible: !manager.adding && !!manager.selected; text: manager.confirmRemove ? "Remove plugin" : "Remove"; focusable: true; implicitHeight: 40; enabled: !manager.busy; onClicked: manager.action("remove") }
        }
      }
    }
  }
  component Label: Text {
    textFormat: Text.PlainText
    color: Color.popups.text
    font.family: Style.font.family
    font.pixelSize: Style.font.body
    wrapMode: Text.WordWrap
  }
}
