import QtQuick
import QtQuick.Controls as Controls
import QtQuick.Layouts
import qs.Commons
import qs.Commons as Commons
import qs.Ui
import "EnrollmentModel.js" as Model

FocusScope {
  id: view
  signal closeRequested()
  signal addRequested(string reader, string finger)
  readonly property bool authorizing: ctl.authorizing
  property string selected: ""
  property bool confirming: false
  readonly property bool verifying: ctl.action === "verify"
  readonly property var entry: ctl.state.prints.find(p => p.slot === selected)
  readonly property bool hasPrints: ctl.state.prints.length > 0

  function label(entry) {
    return entry.name || Commons.I18n.t("fingerprint.numbered").arg(Commons.I18n.formatNumber(entry.number))
  }
  function reveal(item) {
    const flick = scroll.contentItem
    const y = item.mapToItem(flick.contentItem, 0, 0).y
    if (y < flick.contentY) flick.contentY = Math.max(0, y)
    else if (y + item.height > flick.contentY + flick.height)
      flick.contentY = Math.min(flick.contentHeight - flick.height, y + item.height - flick.height)
  }
  function back() {
    confirming = false
    selected = ""
    ctl.notice = ""
  }

  component Action: Button {
    onActiveFocusChanged: if (activeFocus) view.reveal(this)
    opacity: enabled ? 1 : 0.55
    focusable: true
    bordered: true
    Accessible.role: Accessible.Button
    Accessible.name: text
    Accessible.onPressAction: if (enabled) clicked()
  }
  component Setting: Toggle {
    Layout.fillWidth: true
    onActiveFocusChanged: if (activeFocus) view.reveal(this)
    opacity: enabled ? 1 : 0.55
    Accessible.role: Accessible.CheckBox
    Accessible.name: label
    Accessible.checkable: true
    Accessible.checked: checked
    Accessible.onToggleAction: if (enabled) clicked()
  }
  component Line: Text {
    Layout.fillWidth: true
    textFormat: Text.PlainText
    wrapMode: Text.Wrap
    color: Commons.Color.foreground
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
    onRefreshed: if (!view.entry) { view.selected = ""; view.confirming = false; editor.text = "" }
  }

  Rectangle {
    anchors.centerIn: parent
    width: Math.min(parent.width - Style.space(32), Style.space(450))
    height: Math.min(parent.height - Style.space(32), content.implicitHeight + 2 * Style.space(24))
    color: Commons.Color.background
    border.color: Commons.Color.foreground
    radius: Style.cornerRadius

    Controls.ScrollView {
      id: scroll
      anchors.fill: parent
      anchors.margins: Style.space(24)
      contentWidth: availableWidth
      clip: true
      ColumnLayout {
        id: content
        width: scroll.availableWidth
        spacing: Style.space(10)

        Line {
          text: view.verifying ? Commons.I18n.t("fingerprint.verifySaved")
                : view.entry ? view.label(view.entry) : Commons.I18n.t("fingerprint.saved")
          font.pixelSize: Style.font.heading
          font.bold: true
        }

        ColumnLayout {
          visible: !view.entry && !view.verifying
          Layout.fillWidth: true
          spacing: Style.space(8)
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
              onClicked: {
                view.selected = modelData.slot
                editor.text = modelData.name
                ctl.notice = ""
                if (editor.visible) editor.forceActiveFocus()
                else view.forceActiveFocus()
              }
            }
          }
          Action {
            text: Commons.I18n.t("fingerprint.add")
            enabled: !ctl.busy && ctl.state.reader !== "" && ctl.state.prints.length < ctl.state.capacity
            onClicked: view.addRequested(ctl.state.reader, Model.suggestFinger(ctl.state.prints.map(p => p.slot)))
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
          TextField {
            id: editor
            Layout.fillWidth: true
            visible: !!ctl.state.canRename
            onActiveFocusChanged: if (activeFocus) view.reveal(this)
            maximumLength: 64
            placeholderText: Commons.I18n.t("fingerprint.name")
            Accessible.name: placeholderText
            onAccepted: save.clicked()
          }
          Action {
            id: save
            visible: !!ctl.state.canRename
            text: Commons.I18n.t("fingerprint.saveName")
            onClicked: ctl.run("rename", [ctl.helper, "rename", ctl.state.reader, view.selected, editor.text])
          }
          Action {
            text: Commons.I18n.t("fingerprint.verifySaved")
            onClicked: ctl.verify(view.selected)
          }
          Action {
            text: Commons.I18n.t("fingerprint.removeSaved")
            onClicked: view.confirming = true
          }
        }

        Line {
          visible: !!view.entry && view.confirming
          text: view.entry ? Commons.I18n.t("fingerprint.confirmRemove").arg(view.label(view.entry)) : ""
        }
        Action {
          visible: view.confirming
          enabled: !ctl.busy
          text: Commons.I18n.t("fingerprint.removeSaved")
          onClicked: ctl.run("remove", [ctl.helper, "remove", ctl.state.reader, view.selected])
        }
        Line {
          visible: ctl.notice !== ""
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
}
