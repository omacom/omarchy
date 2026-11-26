import QtQuick
import QtQuick.Controls as Controls
import QtQuick.Layouts
import qs.Commons
import qs.Commons as Commons
import qs.Ui
import "EnrollmentModel.js" as Model

FocusScope {
  id: view
  property string initialReader: ""
  signal closeRequested()
  signal addRequested(string reader, string finger)
  readonly property bool authorizing: ctl.authorizing
  // Enrollment and management share the same dark layer over the desktop.
  readonly property color ink: Qt.rgba(1, 1, 1, 0.86)
  readonly property color muted: Qt.rgba(1, 1, 1, 0.64)
  property string selected: ""
  property bool confirming: false
  property bool renaming: false
  readonly property bool verifying: ctl.action === "verify"
  readonly property var entry: ctl.state.prints.find(p => p.slot === selected)
  readonly property bool hasPrints: ctl.state.prints.length > 0

  function label(entry) {
    return entry.name || Commons.I18n.t("fingerprint.numbered").arg(Commons.I18n.formatNumber(entry.number))
  }
  function reveal(item) {
    if (item.parent === footer) return
    const flick = scroll.contentItem
    const y = item.mapToItem(flick.contentItem, 0, 0).y
    if (y < flick.contentY) flick.contentY = Math.max(0, y)
    else if (y + item.height > flick.contentY + flick.height)
      flick.contentY = Math.min(flick.contentHeight - flick.height, y + item.height - flick.height)
  }
  function back() {
    if (confirming) confirming = false
    else if (renaming) renaming = false
    else selected = ""
    forceActiveFocus()
    ctl.notice = ""
  }

  component Action: Button {
    onActiveFocusChanged: if (activeFocus) view.reveal(this)
    opacity: enabled ? 1 : 0.55
    focusable: true
    foreground: view.ink
    accent: view.ink
    borderSpec: activeFocus ? Border.flat(view.muted, 1) : Border.none()
    color: hot || activeFocus ? Qt.rgba(1, 1, 1, 0.07) : "transparent"
    Layout.alignment: Qt.AlignHCenter
    Accessible.role: Accessible.Button
    Accessible.name: text
    Accessible.onPressAction: if (enabled) clicked()
  }
  component Setting: Controls.AbstractButton {
    id: setting
    required property string label
    property string description: ""
    Layout.fillWidth: true
    implicitHeight: Math.max(Style.space(36), contentItem.implicitHeight + 2 * verticalPadding)
    horizontalPadding: Style.space(12)
    verticalPadding: Style.space(6)
    focusPolicy: Qt.StrongFocus
    opacity: enabled ? 1 : 0.55
    onActiveFocusChanged: if (activeFocus) view.reveal(this)
    Keys.onReturnPressed: if (enabled) clicked()
    Keys.onEnterPressed: if (enabled) clicked()
    Accessible.role: Accessible.CheckBox
    Accessible.name: label
    Accessible.description: description
    Accessible.checkable: true
    Accessible.checked: checked
    Accessible.onToggleAction: if (enabled) clicked()

    background: Rectangle {
      color: setting.hovered || setting.activeFocus ? Qt.rgba(1, 1, 1, 0.07) : "transparent"
      border.width: setting.activeFocus ? 1 : 0
      border.color: view.muted
    }
    HoverHandler { cursorShape: Qt.PointingHandCursor }
    contentItem: RowLayout {
      spacing: Style.space(12)
      ColumnLayout {
        Layout.fillWidth: true
        spacing: Style.space(3)
        Line {
          text: setting.label
          horizontalAlignment: Text.AlignLeft
          color: view.ink
        }
        Line {
          visible: setting.description !== ""
          text: setting.description
          horizontalAlignment: Text.AlignLeft
          font.pixelSize: Style.font.caption
        }
      }
      Line {
        Layout.fillWidth: false
        text: setting.checked ? Commons.I18n.t("fingerprint.on") : Commons.I18n.t("fingerprint.off")
        color: setting.checked ? view.ink : view.muted
      }
      ToggleSwitch {
        interactive: false
        foreground: view.ink
        accent: Commons.Color.accent
        checked: setting.checked
        trackHeight: Style.space(16)
      }
    }
  }
  component Line: Text {
    Layout.fillWidth: true
    textFormat: Text.PlainText
    wrapMode: Text.Wrap
    horizontalAlignment: Text.AlignHCenter
    color: view.muted
    font.family: Style.font.family
    font.pixelSize: Style.font.body
  }

  focus: true
  Keys.onEscapePressed: {
    if (ctl.action === "verify") ctl.cancelVerify()
    else if (ctl.busy || selected === "") closeRequested()
    else back()
  }

  Management {
    id: ctl
    reader: view.initialReader
    onRenamed: { view.renaming = false; view.forceActiveFocus() }
    onRefreshed: {
      if (!view.entry) {
        view.selected = ""
        view.confirming = false
        editor.text = ""
      }
      if (!view.entry || !state.canRename) view.renaming = false
    }
  }

  Item {
    id: stage
    anchors.centerIn: parent
    width: Math.min(parent.width - Style.space(32), Style.space(396))
    readonly property real topGap: view.verifying ? Style.space(28) : Style.space(10)
    readonly property real bottomGap: view.verifying ? 0 : Style.space(12)
    readonly property real availableHeight: Math.max(0, parent.height - Style.space(24))
    height: Math.min(availableHeight, header.height + topGap + content.implicitHeight + bottomGap + footer.implicitHeight)

    Column {
      id: header
      width: parent.width
      spacing: Style.space(12)

      FingerprintArt {
        anchors.horizontalCenter: parent.horizontalCenter
        // Reserve the instruction and exit action first on short screens.
        readonly property real available: stage.availableHeight - footer.implicitHeight - stage.topGap
        readonly property real controlsHeight: heading.implicitHeight + header.spacing + content.implicitHeight + stage.bottomGap
        readonly property real preferred: view.verifying ? Style.space(264) : Style.space(150)
        width: Math.max(0, Math.min(preferred, parent.width, view.verifying ? available : Math.max(Style.space(40), available - controlsHeight)))
        height: width
        filled: view.verifying || !!view.entry ? 1 : 0
      }

      Line {
        id: heading
        width: parent.width
        visible: !view.verifying
        text: view.entry ? view.label(view.entry) : Commons.I18n.t("fingerprint.saved")
        font.pixelSize: Style.font.heading
      }
    }

    Controls.ScrollView {
      id: scroll
      anchors { top: header.bottom; left: parent.left; right: parent.right; bottom: footer.top }
      anchors.topMargin: stage.topGap
      anchors.bottomMargin: stage.bottomGap
      contentWidth: availableWidth
      clip: true
      ColumnLayout {
        id: content
        width: scroll.availableWidth
        spacing: Style.space(10)

        ColumnLayout {
          visible: !view.entry && !view.verifying
          Layout.fillWidth: true
          spacing: Style.space(2)
          Repeater {
            model: ctl.state.readers.length > 1 || !ctl.state.reader ? ctl.state.readers : []
            Action {
              required property var modelData
              Layout.fillWidth: true
              text: modelData.name
              selected: modelData.token === ctl.state.reader
              enabled: !ctl.busy
              onClicked: { ctl.notice = ""; ctl.refresh(modelData.token) }
            }
          }
          Repeater {
            model: ctl.state.prints
            Action {
              required property var modelData
              Layout.fillWidth: true
              text: view.label(modelData)
              leftAlign: true
              enabled: !ctl.busy
              Text {
                anchors { right: parent.right; rightMargin: Style.space(12); verticalCenter: parent.verticalCenter }
                text: view.LayoutMirroring.enabled ? "‹" : "›"
                color: view.muted
                font.family: Style.font.family
                font.pixelSize: Style.font.heading
                Accessible.ignored: true
              }
              // Leave the trailing chevron clear when a long name elides.
              horizontalPadding: Style.space(40)
              leftPadding: Style.space(12)
              onClicked: {
                view.selected = modelData.slot
                editor.text = modelData.name
                ctl.notice = ""
                view.forceActiveFocus()
              }
            }
          }
          Action {
            Layout.fillWidth: true
            leftAlign: true
            iconText: "+"
            text: Commons.I18n.t("fingerprint.add")
            enabled: !ctl.busy && ctl.state.reader !== "" && ctl.state.prints.length < ctl.state.capacity
            onClicked: view.addRequested(ctl.state.reader, Model.suggestFinger(ctl.state.prints.map(p => p.slot)))
          }
          Rectangle {
            Layout.fillWidth: true
            Layout.topMargin: Style.space(7)
            Layout.bottomMargin: Style.space(4)
            implicitHeight: 1
            color: Qt.rgba(1, 1, 1, 0.16)
          }
          Setting {
            label: Commons.I18n.t("fingerprint.unlockSetting")
            checked: ctl.state.lock
            enabled: !ctl.busy && (checked || view.hasPrints)
            onClicked: ctl.changeLock(!checked)
          }
          Setting {
            label: Commons.I18n.t("fingerprint.sudoSetting")
            description: ctl.state.sudo === "custom" ? Commons.I18n.t("fingerprint.customSudo") : Commons.I18n.t("fingerprint.sudoScope")
            checked: ctl.state.sudo === "on"
            enabled: !ctl.busy && ctl.state.sudo !== "custom" && (checked || view.hasPrints)
            onClicked: ctl.changeSudo(!checked)
          }
        }

        ColumnLayout {
          visible: !!view.entry && !view.confirming && !view.verifying
          Layout.fillWidth: true
          enabled: !ctl.busy
          ColumnLayout {
            visible: view.renaming
            Layout.fillWidth: true
            TextField {
              id: editor
              Layout.fillWidth: true
              foreground: view.ink
              accent: view.ink
              onActiveFocusChanged: if (activeFocus) view.reveal(this)
              maximumLength: 64
              placeholderText: Commons.I18n.t("fingerprint.name")
              Accessible.name: placeholderText
              onAccepted: save.clicked()
            }
            Action {
              id: save
              text: Commons.I18n.t("fingerprint.saveName")
              onClicked: ctl.run("rename", [ctl.helper, "rename", ctl.state.reader, view.selected, editor.text])
            }
          }
          GridLayout {
            visible: !view.renaming
            Layout.alignment: Qt.AlignHCenter
            columnSpacing: Style.space(4)
            rowSpacing: Style.space(2)
            columns: verify.implicitWidth + remove.implicitWidth + (rename.visible ? rename.implicitWidth + columnSpacing : 0) + columnSpacing <= stage.width ? 3 : 1
            Action {
              id: verify
              text: Commons.I18n.t("fingerprint.verifySaved")
              onClicked: ctl.verify(view.selected)
            }
            Action {
              id: rename
              visible: !!ctl.state.canRename
              text: Commons.I18n.t("fingerprint.rename")
              onClicked: {
                ctl.notice = ""
                editor.text = view.entry.name
                view.renaming = true
                editor.forceActiveFocus()
                editor.selectAll()
              }
            }
            Action {
              id: remove
              text: Commons.I18n.t("fingerprint.removeSaved")
              onClicked: { ctl.notice = ""; view.confirming = true }
            }
          }
        }

        Line {
          visible: !!view.entry && view.confirming
          text: view.entry ? Commons.I18n.t("fingerprint.confirmRemove").arg(view.label(view.entry)) : ""
        }
        Action {
          visible: view.confirming
          foreground: "#ff6b6b"
          enabled: !ctl.busy
          text: Commons.I18n.t("fingerprint.removeSaved")
          onClicked: ctl.run("remove", [ctl.helper, "remove", ctl.state.reader, view.selected])
        }
      }
    }

    ColumnLayout {
      id: footer
      anchors { left: parent.left; right: parent.right; bottom: parent.bottom }
      spacing: Style.space(10)
      Line {
        visible: ctl.notice !== ""
        font.pixelSize: view.verifying ? Style.font.heading : Style.font.body
        readonly property var requestedPrint: ctl.action === "verify" && ctl.state.prints.find(p => p.slot === ctl.verifyFinger)
        text: requestedPrint ? Commons.I18n.t("fingerprint.useSaved").arg(view.label(requestedPrint)).arg(ctl.notice) : ctl.notice
      }
      Action {
        text: ctl.action === "verify" ? Commons.I18n.t("common.cancel")
              : view.entry ? Commons.I18n.t("fingerprint.back") : Commons.I18n.t("fingerprint.close")
        enabled: !ctl.busy || ctl.action === "verify"
        onClicked: {
          if (ctl.action === "verify") ctl.cancelVerify()
          else if (view.entry) view.back()
          else view.closeRequested()
        }
      }
    }
  }
}
