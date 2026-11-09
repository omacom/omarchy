import QtQuick
import QtQuick.Layouts
import qs.Ui
import qs.Commons
import qs.Commons as Commons
import "Model.js" as Model

// Native view for editing one saved NetworkManager profile, plus the profile
// picker shown when a duplicate SSID names more than one. It holds the editable
// values in `form`, seeded from `fields` (Model.editorDefaults) each time a
// profile is read back, and emits the whole form on save() so the panel owns the
// nmcli write and the changed-keys diff. The form never carries the stored
// secret: the passphrase starts blank, and blank means "keep the saved one", so
// a value only leaves the field when the user types a new one.
//
// Nothing here decides what changed or how to write it; `Model.validateEditor`
// gates Save, `Model.changedModArgs` and the panel do the rest.
Column {
  id: root

  property var fields: null
  property bool busy: false
  property string error: ""
  property string title: ""
  // The security is not editable, so whether the passphrase/identity fields
  // belong on screen is decided by the panel and passed in.
  property bool hasPsk: false
  property bool enterprise: false
  // Profile picker: shown before the form while the user chooses which of
  // several same-named profiles to edit.
  property bool picking: false
  property var choices: []
  property color foreground: Commons.Color.foreground
  property string fontFamily: Style.font.family

  signal save(var form)
  signal cancel()
  signal choose(string uuid)

  spacing: Style.space(10)

  // English copy for the strings without a catalog key yet. Kept together so
  // the i18n extraction pass and the follow-up swap each one for
  // Commons.I18n.t("network.…"); the existing network.passphrase/identity/
  // gateway/automatic keys are reused below.
  readonly property var copy: ({
    cancel: "Cancel",
    save: "Save",
    passphraseNote: "Leave blank to keep the saved passphrase",
    autoConnect: "Connect automatically",
    priority: "Auto-connect priority",
    ipv4Method: "IPv4 method",
    manual: "Manual",
    address: "Address (CIDR)",
    metered: "Metered",
    meteredUnknown: "Unknown",
    meteredYes: "Yes",
    meteredNo: "No",
    chooseProfile: "Choose a saved profile"
  })

  // Editable values. Unknown/Yes/No and Automatic/Manual are stored as the
  // strings nmcli uses so a change compares directly against the prefill.
  property var form: ({
    autoConnect: true,
    priority: 0,
    metered: "unknown",
    ipv4Method: "auto",
    address: "",
    gateway: "",
    identity: "",
    password: ""
  })

  readonly property var validation: Model.validateEditor(form)
  readonly property bool canSave: !!fields && validation.ok && !busy
  readonly property bool manual: form.ipv4Method === "manual"
  readonly property string message: error !== "" ? error : (validation.ok ? "" : validation.error)

  onFieldsChanged: {
    if (!fields) return
    form = {
      autoConnect: fields.autoConnect,
      priority: fields.priority,
      metered: fields.metered,
      ipv4Method: fields.ipv4Method,
      address: fields.address,
      gateway: fields.gateway,
      identity: fields.identity,
      password: ""
    }
  }

  // Copy-on-write so every control's edit re-evaluates the form bindings, and
  // the same path a control takes is what a test drives.
  function update(field, value) {
    var next = {}
    for (var key in form) next[key] = form[key]
    next[field] = value
    form = next
  }

  function submit() {
    if (!canSave) return
    save(form)
  }

  // ---------- Profile picker ----------
  Column {
    id: picker
    visible: root.picking
    width: parent.width
    spacing: Style.space(8)

    PanelSectionHeader {
      text: root.copy.chooseProfile
      foreground: root.foreground
      fontFamily: root.fontFamily
    }

    Repeater {
      model: root.choices

      delegate: Button {
        required property var modelData
        width: picker.width
        leftAlign: true
        bordered: true
        active: !!modelData.active
        text: String(modelData.uuid || "").substring(0, 8)
        foreground: root.foreground
        fontFamily: root.fontFamily
        onClicked: root.choose(modelData.uuid)
      }
    }

    Button {
      width: picker.width
      text: root.copy.cancel
      bordered: true
      foreground: root.foreground
      fontFamily: root.fontFamily
      onClicked: root.cancel()
    }
  }

  // ---------- Form ----------
  Column {
    id: editorForm
    visible: !root.picking
    width: parent.width
    spacing: root.spacing

    // Header: profile name · Cancel · Save
    Item {
      width: parent.width
      implicitHeight: Math.max(headerTitle.implicitHeight, headerActions.implicitHeight)

      Text {
        id: headerTitle
        textFormat: Text.PlainText
        text: root.title
        color: root.foreground
        font.family: root.fontFamily
        font.pixelSize: Style.font.subtitle
        font.bold: true
        elide: Text.ElideRight
        anchors.left: parent.left
        anchors.right: headerActions.left
        anchors.rightMargin: Style.space(8)
        anchors.verticalCenter: parent.verticalCenter
      }

      Row {
        id: headerActions
        anchors.right: parent.right
        anchors.verticalCenter: parent.verticalCenter
        spacing: Style.space(6)

        Button {
          text: root.copy.cancel
          bordered: true
          enabled: !root.busy
          foreground: root.foreground
          fontFamily: root.fontFamily
          onClicked: root.cancel()
        }

        Button {
          text: root.copy.save
          active: root.canSave
          opacity: root.canSave ? 1 : 0.5
          foreground: root.foreground
          fontFamily: root.fontFamily
          onClicked: root.submit()
        }
      }
    }

    Text {
      width: parent.width
      visible: root.message !== ""
      textFormat: Text.PlainText
      text: root.message
      color: root.foreground
      opacity: 0.8
      font.family: root.fontFamily
      font.pixelSize: Style.font.caption
      wrapMode: Text.WordWrap
    }

    // Passphrase (PSK/SAE)
    Column {
      width: parent.width
      visible: root.hasPsk
      spacing: Style.space(4)

      Text {
        textFormat: Text.PlainText
        text: Commons.I18n.t("network.passphrase")
        color: Qt.darker(root.foreground, 1.4)
        font.family: root.fontFamily
        font.pixelSize: Style.font.bodySmall
      }

      TextField {
        width: parent.width
        password: true
        placeholderText: root.copy.passphraseNote
        foreground: root.foreground
        enabled: !root.busy
        onTextChanged: if (text !== root.form.password) root.update("password", text)
      }
    }

    // Identity (802.1X)
    Column {
      width: parent.width
      visible: root.enterprise
      spacing: Style.space(4)

      Text {
        textFormat: Text.PlainText
        text: Commons.I18n.t("network.identity")
        color: Qt.darker(root.foreground, 1.4)
        font.family: root.fontFamily
        font.pixelSize: Style.font.bodySmall
      }

      TextField {
        width: parent.width
        text: root.form.identity
        foreground: root.foreground
        enabled: !root.busy
        onTextChanged: if (text !== root.form.identity) root.update("identity", text)
      }
    }

    // Auto-connect
    Item {
      width: parent.width
      implicitHeight: Math.max(autoLabel.implicitHeight, autoSwitch.implicitHeight)

      Text {
        id: autoLabel
        textFormat: Text.PlainText
        text: root.copy.autoConnect
        color: root.foreground
        font.family: root.fontFamily
        font.pixelSize: Style.font.body
        anchors.left: parent.left
        anchors.verticalCenter: parent.verticalCenter
      }

      ToggleSwitch {
        id: autoSwitch
        checked: root.form.autoConnect
        busy: root.busy
        foreground: root.foreground
        anchors.right: parent.right
        anchors.verticalCenter: parent.verticalCenter
        onToggled: root.update("autoConnect", !root.form.autoConnect)
      }
    }

    // Priority
    NumberField {
      label: root.copy.priority
      value: root.form.priority
      from: 0
      to: 9999
      foreground: root.foreground
      fontFamily: root.fontFamily
      onModified: root.update("priority", value)
    }

    // IPv4 method
    Dropdown {
      width: parent.width
      label: root.copy.ipv4Method
      value: root.form.ipv4Method
      options: [
        { value: "auto", label: Commons.I18n.t("network.automatic") },
        { value: "manual", label: root.copy.manual }
      ]
      foreground: root.foreground
      fontFamily: root.fontFamily
      onChanged: root.update("ipv4Method", value)
    }

    // Manual address / gateway
    Column {
      width: parent.width
      visible: root.manual
      spacing: Style.space(4)

      Text {
        textFormat: Text.PlainText
        text: root.copy.address
        color: Qt.darker(root.foreground, 1.4)
        font.family: root.fontFamily
        font.pixelSize: Style.font.bodySmall
      }

      TextField {
        width: parent.width
        placeholderText: "10.0.0.5/24"
        text: root.form.address
        foreground: root.foreground
        enabled: !root.busy
        onTextChanged: if (text !== root.form.address) root.update("address", text)
      }

      Text {
        textFormat: Text.PlainText
        text: Commons.I18n.t("network.gateway")
        color: Qt.darker(root.foreground, 1.4)
        font.family: root.fontFamily
        font.pixelSize: Style.font.bodySmall
      }

      TextField {
        width: parent.width
        placeholderText: "10.0.0.1"
        text: root.form.gateway
        foreground: root.foreground
        enabled: !root.busy
        onTextChanged: if (text !== root.form.gateway) root.update("gateway", text)
      }
    }

    // Metered
    Dropdown {
      width: parent.width
      label: root.copy.metered
      value: root.form.metered
      options: [
        { value: "unknown", label: root.copy.meteredUnknown },
        { value: "yes", label: root.copy.meteredYes },
        { value: "no", label: root.copy.meteredNo }
      ]
      foreground: root.foreground
      fontFamily: root.fontFamily
      onChanged: root.update("metered", value)
    }
  }
}
