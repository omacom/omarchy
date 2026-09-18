import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import QtQuick
import qs.Commons
import qs.Ui
import "ReminderFlowModel.js" as ReminderFlowModel

Item {
  id: root

  property string omarchyPath: Quickshell.env("OMARCHY_PATH")
  property var shell: null
  property var manifest: null

  property bool opened: false
  property string step: "minutes"
  property string minutes: ""
  property string timeLabel: ""
  property string filterText: ""
  property string fontFamily: Style.font.menuFamily
  property var reminders: []
  property int selectedIndex: 0
  property string amendUnit: ""
  property string pendingMessage: ""
  property bool fromManage: false
  property string cancelNotifyLabel: ""

  property color background: Color.menu.background
  property color foreground: Color.menu.text
  property color border: Color.menu.border
  property var borderSpec: Border.surfaceSpec("menu", "border", border, Math.max(1, Style.space(2)))
  property color scrim: Color.menu.scrim
  property color selectedBackground: Color.menu.selectedBackground
  property color selectedText: Color.menu.selectedText
  readonly property int cornerRadius: Style.cornerRadius
  property int contentMargin: Style.spacing.panelPadding
  property int headerHeight: Math.max(Style.space(34), Style.font.title + Style.spacing.controlPaddingY * 2)
  property int rowHeight: Math.max(Style.space(36), Style.font.body + Style.space(16))
  property int hintHeight: Style.font.caption + Style.space(14)
  readonly property bool managing: root.step === "manage"
  readonly property int manageCount: root.reminders.length + 1
  property int cardWidth: Math.min(Style.space(root.managing ? 440 : 300), panel.width - Style.gapsOut * 2)
  property int cardHeight: Math.min(root.managing
    ? root.contentMargin * 2 + root.headerHeight + root.manageCount * root.rowHeight + root.hintHeight + Style.space(8)
    : root.contentMargin * 2 + root.headerHeight, panel.height - Style.gapsOut * 2)
  readonly property string promptText: root.step === "message" ? "Reminder message" : "Minutes or HH:MM"
  readonly property string hintText: {
    if (!root.managing) return ""
    if (root.selectedIndex >= root.reminders.length) return "Enter to set a reminder"
    return "Enter amend  ·  Del cancel  ·  Esc close"
  }

  function open(payloadJson) {
    var payload = ({})
    try { payload = JSON.parse(payloadJson || "{}") } catch (e) { payload = ({}) }
    if (payload.fontFamily) root.fontFamily = payload.fontFamily

    root.opened = true
    root.minutes = ""
    root.timeLabel = ""
    root.filterText = ""
    root.amendUnit = ""
    root.pendingMessage = ""
    root.selectedIndex = 0
    root.cancelNotifyLabel = ""

    if (payload.mode === "manage") {
      root.fromManage = true
      root.step = "manage"
      root.refreshList()
    } else {
      root.fromManage = false
      root.step = "minutes"
    }

    Qt.callLater(function() { keyCatcher.forceActiveFocus() })
  }

  function close() {
    root.opened = false
  }

  function dismiss() {
    root.opened = false
    if (root.shell && typeof root.shell.hide === "function")
      root.shell.hide((root.manifest && root.manifest.id) || "omarchy.reminders")
  }

  function toggle() {
    if (root.opened) root.dismiss()
    else root.open("{}")
  }

  function setFilter(nextFilter) {
    root.filterText = nextFilter
  }

  function refreshList() {
    if (!listProc.running) listProc.running = true
  }

  function loadReminders(raw) {
    root.reminders = ReminderFlowModel.parseList(raw)
    if (root.selectedIndex >= root.manageCount) root.selectedIndex = Math.max(0, root.manageCount - 1)
    if (root.selectedIndex < 0) root.selectedIndex = 0
  }

  function manageItem(index) {
    if (index < 0) return null
    if (index < root.reminders.length) return root.reminders[index]
    if (index === root.reminders.length) return { kind: "new" }
    return null
  }

  function select(delta) {
    if (root.manageCount <= 0) return
    root.selectedIndex = (root.selectedIndex + delta + root.manageCount) % root.manageCount
  }

  function startNew() {
    root.amendUnit = ""
    root.pendingMessage = ""
    root.fromManage = true
    root.minutes = ""
    root.timeLabel = ""
    root.filterText = ""
    root.step = "minutes"
    Qt.callLater(function() { keyCatcher.forceActiveFocus() })
  }

  function startAmend(item) {
    if (!item || item.kind === "new") return
    root.amendUnit = item.unit || ""
    root.pendingMessage = item.message || ""
    root.fromManage = true
    root.minutes = ""
    root.timeLabel = ""
    root.filterText = item.atTime || ""
    root.step = "minutes"
    Qt.callLater(function() { keyCatcher.forceActiveFocus() })
  }

  function activateSelected() {
    var item = root.manageItem(root.selectedIndex)
    if (!item) return
    if (item.kind === "new") root.startNew()
    else root.startAmend(item)
  }

  function cancelUnit(unit, notifyLabel) {
    if (!ReminderFlowModel.validUnit(unit)) return
    root.cancelNotifyLabel = notifyLabel || ""
    cancelProc.command = [root.omarchyPath + "/bin/omarchy-reminder", "cancel", "--quiet", unit]
    cancelProc.running = true
  }

  function cancelSelected() {
    var item = root.manageItem(root.selectedIndex)
    if (!item || item.kind === "new") return
    root.cancelUnit(item.unit, ReminderFlowModel.rowTitle(item))
  }

  function backToManage() {
    root.amendUnit = ""
    root.pendingMessage = ""
    root.filterText = ""
    root.minutes = ""
    root.timeLabel = ""
    root.step = "manage"
    root.refreshList()
    Qt.callLater(function() { keyCatcher.forceActiveFocus() })
  }

  function submit() {
    var selection = root.filterText

    if (root.step === "minutes") {
      var parsed = ReminderFlowModel.parseWhen(selection)

      if (!selection.trim()) {
        if (root.fromManage) root.backToManage()
        else root.dismiss()
        return
      }

      if (!parsed) {
        Quickshell.execDetached([root.omarchyPath + "/bin/omarchy-notification-send", "Invalid reminder", "Enter minutes (15) or a time (17:00)"])
        return
      }

      root.minutes = parsed.minutes
      root.timeLabel = parsed.displayTime || ""
      root.step = "message"
      root.filterText = root.pendingMessage
      root.pendingMessage = ""
      Qt.callLater(function() { keyCatcher.forceActiveFocus() })
      return
    }

    if (root.step === "message") {
      var args = [root.omarchyPath + "/bin/omarchy-reminder"].concat(ReminderFlowModel.reminderArgs(root.minutes, selection, root.timeLabel))
      var replacing = root.amendUnit
      root.dismiss()
      Quickshell.execDetached(args)
      if (replacing) root.cancelUnit(replacing, "")
    }
  }

  Process {
    id: listProc
    command: ["omarchy-reminder", "show", "--json"]
    stdout: StdioCollector {
      waitForEnd: true
      onStreamFinished: root.loadReminders(text)
    }
  }

  Process {
    id: cancelProc
    onExited: function() {
      if (root.cancelNotifyLabel) {
        Quickshell.execDetached([root.omarchyPath + "/bin/omarchy-notification-send", "-g", "󰢌", "Reminder cancelled", root.cancelNotifyLabel])
        root.cancelNotifyLabel = ""
      }
      if (root.opened && root.managing) root.refreshList()
    }
  }

  PanelWindow {
    id: panel
    visible: root.opened
    anchors { top: true; bottom: true; left: true; right: true }
    color: "transparent"
    WlrLayershell.namespace: "omarchy-reminders"
    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.Exclusive
    exclusionMode: ExclusionMode.Ignore

    Rectangle {
      anchors.fill: parent
      color: root.scrim
    }

    MouseArea {
      anchors.fill: parent
      onClicked: root.dismiss()
    }

    BorderSurface {
      id: card
      width: root.cardWidth
      height: root.cardHeight
      radius: root.cornerRadius
      anchors.centerIn: parent
      color: root.background
      borderSpec: root.borderSpec
      padding: root.contentMargin

      MouseArea { anchors.fill: parent; onClicked: {} }

      Item {
        id: keyCatcher
        anchors.fill: parent
        focus: true

        Keys.priority: Keys.BeforeItem
        Keys.onPressed: function(event) {
          if (root.managing) {
            if (event.key === Qt.Key_Escape) {
              root.dismiss()
              event.accepted = true
            } else if (event.key === Qt.Key_Up) {
              root.select(-1)
              event.accepted = true
            } else if (event.key === Qt.Key_Down) {
              root.select(1)
              event.accepted = true
            } else if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
              root.activateSelected()
              event.accepted = true
            } else if (event.key === Qt.Key_Delete || event.key === Qt.Key_Backspace) {
              root.cancelSelected()
              event.accepted = true
            } else if (event.text === "n" || event.text === "N") {
              root.startNew()
              event.accepted = true
            } else if (event.text === "x" || event.text === "X") {
              root.cancelSelected()
              event.accepted = true
            }
            return
          }

          if (event.key === Qt.Key_Escape) {
            if (root.filterText) root.setFilter("")
            else if (root.fromManage) root.backToManage()
            else root.dismiss()
            event.accepted = true
          } else if (Util.editsFilter(event, root.filterText)) {
            root.setFilter(Util.editedFilter(event, root.filterText))
            event.accepted = true
          } else if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
            root.submit()
            event.accepted = true
          } else {
            var ch = ReminderFlowModel.typedChar(event.key, event.modifiers, event.nativeScanCode, event.text)
            if (ch) {
              root.setFilter(root.filterText + ch)
              event.accepted = true
            }
          }
        }
      }

      Item {
        anchors.fill: parent
        anchors.topMargin: card.contentTopInset
        anchors.rightMargin: card.contentRightInset
        anchors.bottomMargin: card.contentBottomInset
        anchors.leftMargin: card.contentLeftInset

        Text {
          visible: !root.managing
          textFormat: Text.PlainText
          anchors.left: parent.left
          anchors.right: parent.right
          anchors.verticalCenter: parent.verticalCenter
          text: root.filterText || (root.promptText + "...")
          color: root.foreground
          opacity: root.filterText ? 1 : 0.58
          font.family: root.fontFamily
          font.pixelSize: Style.font.heading
          elide: Text.ElideRight
        }

        Column {
          visible: root.managing
          anchors.fill: parent
          spacing: 0

          Text {
            width: parent.width
            height: root.headerHeight
            textFormat: Text.PlainText
            text: "Reminders"
            color: root.foreground
            font.family: root.fontFamily
            font.pixelSize: Style.font.title
            verticalAlignment: Text.AlignVCenter
            elide: Text.ElideRight
          }

          Repeater {
            model: root.manageCount

            Rectangle {
              required property int index
              readonly property var item: root.manageItem(index)
              readonly property bool isNew: !!(item && item.kind === "new")
              readonly property bool selected: index === root.selectedIndex

              width: parent.width
              height: root.rowHeight
              radius: root.cornerRadius
              color: selected ? root.selectedBackground : "transparent"

              Text {
                id: titleLabel
                textFormat: Text.PlainText
                anchors.left: parent.left
                anchors.leftMargin: Style.space(8)
                anchors.right: metaLabel.left
                anchors.rightMargin: Style.space(12)
                anchors.verticalCenter: parent.verticalCenter
                text: isNew ? "New reminder" : ReminderFlowModel.rowTitle(item)
                color: selected ? root.selectedText : root.foreground
                opacity: isNew && !selected ? 0.58 : 1
                font.family: root.fontFamily
                font.pixelSize: Style.font.body
                elide: Text.ElideRight
              }

              Text {
                id: metaLabel
                visible: !isNew
                textFormat: Text.PlainText
                anchors.right: cancelHit.left
                anchors.rightMargin: Style.space(8)
                anchors.verticalCenter: parent.verticalCenter
                text: ReminderFlowModel.rowMeta(item)
                color: selected ? root.selectedText : root.foreground
                opacity: 0.62
                font.family: root.fontFamily
                font.pixelSize: Style.font.caption
              }

              Text {
                id: cancelHit
                visible: !isNew
                textFormat: Text.PlainText
                anchors.right: parent.right
                anchors.rightMargin: Style.space(8)
                anchors.verticalCenter: parent.verticalCenter
                width: visible ? implicitWidth : 0
                text: "✕"
                color: selected ? root.selectedText : root.foreground
                opacity: cancelMouse.containsMouse ? 1 : 0.45
                font.family: root.fontFamily
                font.pixelSize: Style.font.body

                MouseArea {
                  id: cancelMouse
                  anchors.fill: parent
                  anchors.margins: -Style.space(6)
                  hoverEnabled: true
                  cursorShape: Qt.PointingHandCursor
                  onClicked: {
                    root.selectedIndex = index
                    root.cancelSelected()
                  }
                }
              }

              MouseArea {
                anchors.fill: parent
                z: -1
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onEntered: root.selectedIndex = index
                onClicked: {
                  root.selectedIndex = index
                  if (isNew) root.startNew()
                }
                onDoubleClicked: {
                  root.selectedIndex = index
                  if (!isNew) root.startAmend(item)
                }
              }
            }
          }

          Text {
            width: parent.width
            height: root.hintHeight
            textFormat: Text.PlainText
            text: root.hintText
            color: root.foreground
            opacity: 0.5
            font.family: root.fontFamily
            font.pixelSize: Style.font.caption
            verticalAlignment: Text.AlignVCenter
            elide: Text.ElideRight
          }
        }
      }
    }
  }
}
