import QtQuick
import QtQuick.Controls
import Quickshell
import qs.Ui
import qs.Commons
import qs.Commons as Commons
import "../../notifications" as Notifications

Panel {
  id: root
  moduleName: "omarchy.notification-center"
  ipcTarget: "omarchy.notification-center"
  implicitWidth: button.implicitWidth
  implicitHeight: button.implicitHeight
  readonly property var notifications: bar?.shell?.firstPartyServiceFor("omarchy.notifications") ?? null
  readonly property var entries: notifications ? notifications.centerEntries : []
  property string selectedNotificationKey: ""
  readonly property int selectedIndex: indexForKey(selectedNotificationKey)

  function indexForKey(key) {
    for (var i = 0; i < entries.length; i++)
      if (entries[i].key === key) return i
    return -1
  }

  function selectedKey() {
    return selectedIndex >= 0 ? selectedNotificationKey : ""
  }

  function moveSelection(delta) {
    if (!entries.length) return
    var index = Math.max(0, Math.min(entries.length - 1, selectedIndex + delta))
    selectedNotificationKey = entries[index].key
  }

  function reconcileSelection() {
    if (selectedIndex < 0) selectedNotificationKey = ""
  }

  function keepSelectionVisible() {
    if (panel.loadedContent) panel.loadedContent.keepSelectionVisible()
  }

  onEntriesChanged: {
    reconcileSelection()
    // Replacing ListView's array model resets its viewport after this signal.
    Qt.callLater(keepSelectionVisible)
  }
  onOpenedChanged: if (opened) selectedNotificationKey = ""

  BarIconButton {
    id: button
    anchors.fill: parent
    bar: root.bar
    text: "\u{f009a}"
    onPressed: root.toggle()

    Rectangle {
      visible: root.entries.length > 0
      width: Style.space(4)
      height: width
      radius: width / 2
      color: root.bar.foreground
      x: parent.width / 2 + Style.bar.iconSize / 2 - width / 2
      y: parent.height / 2 - Style.bar.iconSize / 2
    }
    PanelToolTip {
      visible: button.tooltipHovered
      text: Commons.I18n.t("notifications.centerTitle")
      fontFamily: root.bar.fontFamily
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
      anchors.fill: parent
      implicitHeight: column.implicitHeight
      function keepSelectionVisible() {
        if (root.selectedIndex >= 0) list.positionViewAtIndex(root.selectedIndex, ListView.Contain)
      }
      onCloseRequested: root.close()
      onTabRequested: function(direction) { root.switchPanel(direction) }
      onMoveRequested: function(dx, dy) {
        if (!dy || !root.entries.length) return
        root.moveSelection(dy)
        keepSelectionVisible()
      }
      onActivateRequested: if (root.selectedKey()) root.notifications.restoreCenter(root.selectedKey())
      onDeleteRequested: if (root.selectedKey()) root.notifications.closeToast(root.selectedKey(), "dismissed")

      Column {
        id: column
        width: parent.width
        spacing: Style.space(12)

        Item {
          width: parent.width
          implicitHeight: Math.max(title.implicitHeight, clear.implicitHeight)
          Text {
            id: title
            anchors.left: parent.left
            anchors.right: clear.left
            anchors.verticalCenter: parent.verticalCenter
            textFormat: Text.PlainText
            text: Commons.I18n.t("notifications.centerTitle")
            color: root.bar.foreground
            font.family: root.bar.fontFamily
            font.pixelSize: Style.font.heading
            elide: Text.ElideRight
          }
          PanelActionButton {
            id: clear
            anchors.right: parent.right
            enabled: root.entries.length > 0
            iconText: "\u{f01b4}"
            tooltipText: Commons.I18n.t("notifications.clearCenter")
            foreground: root.bar.foreground
            onClicked: root.notifications.clearCenter()
          }
        }

        Text {
          visible: root.entries.length === 0
          width: parent.width
          textFormat: Text.PlainText
          text: Commons.I18n.t("notifications.centerEmpty")
          color: root.bar.foreground
          font.family: root.bar.fontFamily
          font.pixelSize: Style.font.body
          wrapMode: Text.WordWrap
        }

        ListView {
          id: list
          width: parent.width
          height: Math.min(contentHeight, Math.max(Style.space(100), panel.screenH * 0.65))
          model: root.entries
          spacing: Style.space(10)
          clip: true
          boundsBehavior: Flickable.StopAtBounds
          ScrollBar.vertical: ScrollBar { policy: ScrollBar.AsNeeded }

          delegate: Column {
            id: entry
            required property var modelData
            required property int index
            width: ListView.view.width
            spacing: Style.space(2)

            Text {
              width: parent.width
              textFormat: Text.PlainText
              text: String(entry.modelData.app || "")
              color: root.bar.foreground
              font.family: root.bar.fontFamily
              font.pixelSize: Style.font.caption
              elide: Text.ElideRight
            }

            Notifications.Toast {
              width: entry.width
              cardWidth: entry.width
              row: entry.modelData
              centerMode: true
              hovered: true
              paused: true
              expanded: true
              sole: true
              selected: root.selectedIndex === entry.index
              actions: root.notifications ? root.notifications.actionsOf(row.key, root.notifications.refsRevision) : []
              now: Date.now()
              onShelved: root.notifications.restoreCenter(row.key)
              onDismissed: root.notifications.closeToast(row.key, "dismissed")
              onActionInvoked: function(identifier) { root.notifications.invokeAction(row.key, identifier) }
              onExecInvoked: function(index) { root.notifications.runExecAction(row.key, index) }
              onCodeCopied: function(code) { root.notifications.copyCode(code, row.key) }
              onActivated: { root.notifications.activate(row.key); root.close() }
            }

            Row {
              anchors.right: parent.right
              PanelActionButton {
                iconText: "\u{f0450}"
                tooltipText: Commons.I18n.t("notifications.restoreCenter")
                foreground: root.bar.foreground
                onClicked: root.notifications.restoreCenter(entry.modelData.key)
              }
              PanelActionButton {
                iconText: "\u{f0156}"
                tooltipText: Commons.I18n.t("notifications.dismissCenter")
                foreground: root.bar.foreground
                onClicked: root.notifications.closeToast(entry.modelData.key, "dismissed")
              }
            }
          }
        }
      }
    }
  }
}
