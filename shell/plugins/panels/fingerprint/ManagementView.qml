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
  readonly property var entry: ctl.state.prints.find(p => p.slot === selected)
  readonly property bool hasPrints: ctl.state.prints.length > 0

  function label(entry) {
    return entry.name || Commons.I18n.t("fingerprint.numbered").arg(Commons.I18n.formatNumber(entry.number))
  }
  function back() {
    confirming = false
    selected = ""
    ctl.notice = ""
  }

  component Action: Button {
    focusable: true
    bordered: true
    Accessible.role: Accessible.Button
    Accessible.name: text
    Accessible.onPressAction: clicked()
  }
  component Setting: Toggle {
    Layout.fillWidth: true
    Accessible.role: Accessible.CheckBox
    Accessible.name: label
    Accessible.checkable: true
    Accessible.checked: checked
    Accessible.onToggleAction: clicked()
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
    if (ctl.busy || selected === "") closeRequested()
    else back()
  }

  Management {
    id: ctl
    onRefreshed: if (!view.entry) { view.selected = ""; view.confirming = false }
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
          text: view.entry ? view.label(view.entry) : Commons.I18n.t("fingerprint.saved")
          font.pixelSize: Style.font.heading
          font.bold: true
        }

        ColumnLayout {
          visible: !view.entry
          Layout.fillWidth: true
          spacing: Style.space(8)
          Repeater {
            model: ctl.state.readers.length > 1 ? ctl.state.readers : []
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
                editor.forceActiveFocus()
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
          visible: !!view.entry && !view.confirming
          Layout.fillWidth: true
          enabled: !ctl.busy
          TextField {
            id: editor
            Layout.fillWidth: true
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
        Line { visible: ctl.notice !== ""; text: ctl.notice }
        Action {
          text: view.entry ? Commons.I18n.t("fingerprint.back") : Commons.I18n.t("fingerprint.close")
          enabled: !ctl.busy
          onClicked: if (view.entry) view.back(); else view.closeRequested()
        }
      }
    }
  }
}
