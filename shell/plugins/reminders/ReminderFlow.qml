import Quickshell
import Quickshell.Wayland
import QtQuick
import qs.Commons
import qs.Commons as Commons
import qs.Ui
import "ReminderFlowModel.js" as ReminderFlowModel

Item {
  id: root

  property string omarchyPath: Quickshell.env("OMARCHY_PATH")
  property var shell: null
  property var manifest: null

  property bool opened: false
  property string step: "when"
  property var when: null
  property string filterText: ""
  property date now: new Date()
  property string fontFamily: Style.font.menuFamily

  property color background: Commons.Color.menu.background
  property color foreground: Commons.Color.menu.text
  property color border: Commons.Color.menu.border
  property var borderSpec: Border.surfaceSpec("menu", "border", border, Math.max(1, Style.space(2)))
  property color scrim: Commons.Color.menu.scrim
  readonly property int cornerRadius: Style.cornerRadius
  property int contentMargin: Style.spacing.panelPadding
  property int headerHeight: Math.max(Style.space(34), Style.font.title + Style.spacing.controlPaddingY * 2)
  property int cardWidth: Math.min(Style.space(300), panel.width - Style.gapsOut * 2)
  property int hintHeight: Style.font.body + Style.spacing.controlPaddingY * 2
  property int cardHeight: Math.min(contentMargin * 2 + headerHeight + hintHeight, panel.height - Style.gapsOut * 2)
  readonly property string promptText: root.step === "message" ? I18n.t("reminders.messagePrompt") : I18n.t("reminders.whenPrompt")
  readonly property var pendingWhen: root.step === "message" ? root.when : ReminderFlowModel.parseWhen(root.filterText)
  readonly property string hintText: {
    if (root.pendingWhen) return ReminderFlowModel.describe(root.pendingWhen, root.now, I18n.t)
    return root.filterText.trim()
      ? I18n.t("reminders.notRecognized").arg(I18n.t("reminders.examples"))
      : I18n.t("reminders.examples")
  }

  function open(payloadJson) {
    var payload = ({})
    try { payload = JSON.parse(payloadJson || "{}") } catch (e) { payload = ({}) }
    if (payload.fontFamily) root.fontFamily = payload.fontFamily

    root.opened = true
    root.step = "when"
    root.when = null
    root.filterText = ""
    root.now = new Date()

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

  function submit() {
    var selection = root.filterText

    if (root.step === "when") {
      if (!selection.trim()) {
        root.dismiss()
        return
      }

      var nextWhen = ReminderFlowModel.parseWhen(selection)
      if (!nextWhen) {
        Quickshell.execDetached([
          root.omarchyPath + "/bin/omarchy-notification-send",
          I18n.t("reminders.invalidTitle"),
          I18n.t("reminders.invalidBody").arg(I18n.t("reminders.examples"))
        ])
        return
      }

      root.when = nextWhen
      root.step = "message"
      root.filterText = ""
      Qt.callLater(function() { keyCatcher.forceActiveFocus() })
      return
    }

    if (root.step === "message") {
      var args = [root.omarchyPath + "/bin/omarchy-reminder"].concat(ReminderFlowModel.scheduleArgs(root.when, selection, new Date()))
      root.dismiss()
      Quickshell.execDetached(args)
    }
  }

  Timer {
    interval: 15000
    repeat: true
    running: root.opened
    onTriggered: root.now = new Date()
  }

  OverlayWindow {
    id: panel
    shown: root.opened
    WlrLayershell.namespace: "omarchy-reminders"

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
          if (event.key === Qt.Key_Escape) {
            if (root.filterText) root.setFilter("")
            else root.dismiss()
            event.accepted = true
          } else if (Util.editsFilter(event, root.filterText)) {
            root.setFilter(Util.editedFilter(event, root.filterText))
            event.accepted = true
          } else if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
            root.submit()
            event.accepted = true
          } else if (event.text && event.text.length === 1 && event.text.charCodeAt(0) >= 32 && event.text.charCodeAt(0) !== 127) {
            root.setFilter(root.filterText + event.text)
            event.accepted = true
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
          textFormat: Text.PlainText
          anchors.left: parent.left
          anchors.right: parent.right
          anchors.top: parent.top
          height: root.headerHeight
          verticalAlignment: Text.AlignVCenter
          text: root.filterText || root.promptText
          color: root.foreground
          opacity: root.filterText ? 1 : 0.58
          font.family: root.fontFamily
          font.pixelSize: Style.font.heading
          elide: Text.ElideRight
        }

        Text {
          textFormat: Text.PlainText
          anchors.left: parent.left
          anchors.right: parent.right
          anchors.bottom: parent.bottom
          height: root.hintHeight
          verticalAlignment: Text.AlignVCenter
          text: root.hintText
          color: root.foreground
          opacity: 0.58
          font.family: root.fontFamily
          font.pixelSize: Style.font.body
          elide: Text.ElideRight
        }
      }
    }
  }
}
