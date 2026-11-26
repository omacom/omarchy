import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

ApplicationWindow {
  id: win
  required property var backend
  required property var appearance
  readonly property var v: backend.view
  readonly property var colors: appearance.colors
  readonly property color bg: colors.background || "#1c2028"
  readonly property color fg: colors.foreground || "#e7e9ef"
  readonly property color panel: colors.lighter_background || Qt.tint(bg, Qt.alpha(fg, 0.06))
  readonly property color accent: colors.accent || "#8bb2ec"
  readonly property color secondary: Qt.tint(bg, Qt.alpha(fg, 0.82))
  readonly property color edge: Qt.tint(bg, Qt.alpha(fg, 0.2))
  readonly property color outline: Qt.tint(bg, Qt.alpha(fg, 0.42))
  readonly property color hover: Qt.tint(bg, Qt.alpha(fg, 0.08))
  readonly property color pressed: Qt.tint(bg, Qt.alpha(fg, 0.14))
  readonly property color danger: colors.red || "#c25464"
  readonly property color success: colors.green || accent
  // Pick whichever text color has higher WCAG contrast against the theme accent.
  function linearChannel(value) {
    return value <= 0.04045 ? value / 12.92 : Math.pow((value + 0.055) / 1.055, 2.4)
  }
  function accentText(fill) {
    const luminance = 0.2126 * linearChannel(fill.r) + 0.7152 * linearChannel(fill.g) + 0.0722 * linearChannel(fill.b)
    return luminance > 0.179 ? "#000000" : "#ffffff"
  }
  readonly property color accentForeground: accentText(accent)
  // Follows the desktop's corner rounding, which is often square.
  readonly property real radius: Math.max(0, Number(appearance.cornerRadius) || 0)
  function corner(size) { return Math.min(radius, size / 2) }
  function t(key) { return appearance.strings[key] || key }

  property bool closePending: false
  onClosing: function(event) {
    if (v.page === "working") {
      event.accepted = false
      closePending = true
    }
  }
  onVChanged: {
    if (closePending && v.page !== "working") {
      closePending = false
      Qt.callLater(win.close)
    }
  }

  width: 484
  height: 590
  minimumWidth: 350
  minimumHeight: 360
  visible: true
  title: t("fingerprintApp.appTitle")
  color: bg
  palette.window: bg
  palette.windowText: fg
  palette.text: fg
  palette.base: panel
  palette.highlight: accent
  palette.highlightedText: accentForeground

  component Heading: Label {
    textFormat: Text.PlainText
    Layout.fillWidth: true
    font.pixelSize: 24
    font.weight: Font.DemiBold
    color: win.fg
    wrapMode: Text.Wrap
    Accessible.role: Accessible.Heading
  }
  component Note: Label {
    textFormat: Text.PlainText
    Layout.fillWidth: true
    font.pixelSize: 14
    color: win.secondary
    wrapMode: Text.Wrap
  }
  component Section: Label {
    textFormat: Text.PlainText
    Layout.fillWidth: true
    Layout.bottomMargin: 8
    font.pixelSize: 13
    font.weight: Font.DemiBold
    color: win.secondary
    elide: Text.ElideRight
    Accessible.role: Accessible.Heading
  }
  component Rule: Rectangle {
    Layout.fillWidth: true
    implicitHeight: 1
    color: win.edge
  }
  component FocusRing: Rectangle {
    anchors.fill: parent
    anchors.margins: -3
    radius: parent.radius > 0 ? parent.radius + 3 : 0
    color: "transparent"
    border.width: 2
    border.color: win.fg
  }
  component Action: Button {
    id: button
    property bool primary: false
    property bool danger: false
    implicitHeight: primary ? 40 : 34
    leftPadding: primary ? 18 : 12
    rightPadding: leftPadding
    opacity: enabled ? 1 : 0.5
    hoverEnabled: true
    contentItem: Text {
      text: button.text
      color: button.primary ? win.accentText(button.background.color) : button.danger ? win.danger : win.fg
      font.pixelSize: 14
      font.weight: button.primary ? Font.DemiBold : Font.Medium
      elide: Text.ElideRight
      verticalAlignment: Text.AlignVCenter
      horizontalAlignment: Text.AlignHCenter
    }
    background: Rectangle {
      radius: win.corner(height)
      color: button.primary
        ? (button.down ? Qt.darker(win.accent, 1.15) : button.hovered ? Qt.lighter(win.accent, 1.08) : win.accent)
        : (button.down ? win.pressed : button.hovered ? win.hover : "transparent")
      border.width: button.primary ? 0 : 1
      border.color: button.danger ? Qt.tint(win.bg, Qt.alpha(win.danger, 0.75)) : win.outline
      FocusRing { visible: button.visualFocus }
    }
  }
  component EditButton: Button {
    id: edit
    implicitWidth: 34
    implicitHeight: 34
    padding: 0
    hoverEnabled: true
    opacity: enabled ? 1 : 0.5
    ToolTip.text: Accessible.name
    ToolTip.visible: hovered
    ToolTip.delay: 500
    contentItem: Item {
      Canvas {
        anchors.centerIn: parent
        width: 16
        height: 16
        property color stroke: win.fg
        onStrokeChanged: requestPaint()
        onPaint: {
          const c = getContext("2d")
          c.reset()
          c.lineWidth = 1.5
          c.lineJoin = "round"
          c.lineCap = "round"
          c.strokeStyle = stroke
          c.beginPath()
          c.moveTo(2.75, 13.25)
          c.lineTo(3.4, 10.4)
          c.lineTo(10.6, 3.2)
          c.lineTo(12.8, 5.4)
          c.lineTo(5.6, 12.6)
          c.closePath()
          c.moveTo(9.1, 4.7)
          c.lineTo(11.3, 6.9)
          c.stroke()
        }
      }
    }
    background: Rectangle {
      radius: win.corner(height)
      color: edit.down ? win.pressed : edit.hovered ? win.hover : "transparent"
      border.width: 1
      border.color: win.outline
      FocusRing { visible: edit.visualFocus }
    }
  }
  component Setting: RowLayout {
    id: row
    required property string label
    required property string description
    required property bool active
    required property bool available
    property bool managed: false
    signal toggle()
    spacing: 16
    Layout.fillWidth: true
    Layout.topMargin: 12
    Layout.bottomMargin: 12
    ColumnLayout {
      Layout.fillWidth: true
      spacing: 3
      Label { Layout.fillWidth: true; textFormat: Text.PlainText; text: row.label; color: win.fg; font.pixelSize: 15; wrapMode: Text.Wrap }
      Note { text: row.description; font.pixelSize: 13 }
    }
    Switch {
      id: control
      padding: 0
      implicitWidth: 42
      implicitHeight: 34
      objectName: row.label
      Accessible.name: row.label
      visible: !row.managed
      enabled: row.available
      checked: row.active
      checkable: false
      onClicked: row.toggle()
      indicator: Rectangle {
        implicitWidth: 42
        implicitHeight: 24
        radius: height / 2
        y: (control.height - height) / 2
        color: control.checked ? win.accent : win.edge
        border.width: control.checked ? 0 : 1
        border.color: win.outline
        FocusRing { visible: control.visualFocus }
        Rectangle {
          x: control.checked !== control.mirrored ? parent.width - width - 4 : 4
          anchors.verticalCenter: parent.verticalCenter
          width: 16; height: 16
          radius: height / 2
          color: control.checked ? win.accentForeground : win.secondary
        }
      }
    }
  }

  ScrollView {
    id: scroll
    LayoutMirroring.enabled: win.appearance.rightToLeft
    LayoutMirroring.childrenInherit: true
    anchors.fill: parent
    contentWidth: availableWidth
    ScrollBar.horizontal.policy: ScrollBar.AlwaysOff
    Loader {
      id: body
      // A readable measure on wide tiled windows; the page scrolls when the window is short.
      width: Math.min(scroll.availableWidth, 560)
      x: Math.round((scroll.availableWidth - width) / 2)
      y: sourceComponent === scanning ? Math.max(0, Math.round((scroll.availableHeight - implicitHeight) / 2)) : 0
      sourceComponent: {
        switch (win.v.page) {
        case "home": case "unavailable": return home
        case "scan": case "matched": case "added": return scanning
        case "edit": return editing
        case "confirm": return confirming
        default: return message
        }
      }
    }
  }
  component Page: ColumnLayout {
    spacing: 12
    // The loader owns the width. The spacers supply the scrollable insets.
    property int inset: Math.min(28, Math.round(width * 0.06))
    Item { Layout.preferredHeight: 24; Layout.fillWidth: true }
  }

  Component {
    id: home
    Page {
      id: hp
      readonly property bool ready: win.v.page === "home"
      RowLayout {
        Layout.fillWidth: true
        Layout.leftMargin: hp.inset; Layout.rightMargin: hp.inset
        spacing: 16
        ColumnLayout {
          Layout.fillWidth: true
          Layout.alignment: Qt.AlignVCenter
          spacing: 4
          Heading {
            font.pixelSize: 28
            text: hp.ready ? win.t(win.v.apple ? "fingerprintApp.touchId" : "fingerprintApp.fingerprints") : win.t("fingerprintApp.setupReader")
          }
          Note { visible: hp.ready && text.length > 0; text: win.v.apple ? win.t("fingerprintApp.builtIn") : win.v.model }
        }
        Fingerprint {
          readonly property int size: Math.round(Math.max(66, Math.min(80, hp.width * 0.165)))
          Layout.preferredWidth: size
          Layout.preferredHeight: size
          Layout.alignment: Qt.AlignVCenter
          compact: true
          ink: win.accent
          foreground: win.secondary
          paper: win.bg
        }
      }
      ColumnLayout {
        Layout.fillWidth: true
        Layout.leftMargin: hp.inset; Layout.rightMargin: hp.inset
        spacing: 12
        ComboBox {
          id: readers
          Layout.fillWidth: true
          visible: win.v.models.length > 1
          model: win.v.models
          currentIndex: win.v.selected
          Accessible.name: win.t("fingerprintApp.fingerprints")
          onActivated: index => win.backend.selectDevice(index)
          background: Rectangle {
            implicitHeight: 36
            radius: win.corner(height)
            color: readers.down ? win.pressed : readers.hovered ? win.hover : "transparent"
            border.width: 1
            border.color: win.outline
            FocusRing { visible: readers.visualFocus }
          }
        }
        Note { visible: text.length > 0; text: win.v.notice }
        Action { visible: !hp.ready; primary: true; text: win.t("fingerprintApp.retry"); onClicked: win.backend.refresh() }
        ColumnLayout {
          Layout.fillWidth: true
          Layout.topMargin: 12
          visible: hp.ready
          spacing: 0
          Section { text: win.t("fingerprintApp.saved") }
          Repeater {
            model: win.v.prints
            delegate: ColumnLayout {
              id: saved
              required property var modelData
              Layout.fillWidth: true
              spacing: 0
              RowLayout {
                Layout.fillWidth: true
                Layout.preferredHeight: 56
                spacing: 8
                Label {
                  textFormat: Text.PlainText
                  text: saved.modelData.label
                  color: win.fg
                  font.pixelSize: 15
                  Layout.fillWidth: true
                  elide: Text.ElideRight
                }
                EditButton {
                  Accessible.name: win.t("fingerprintApp.editNamed").arg(saved.modelData.label)
                  onClicked: win.backend.edit(saved.modelData.slot)
                }
                Action {
                  text: win.t("fingerprintApp.verify")
                  Accessible.name: win.t("fingerprintApp.verifyNamed").arg(saved.modelData.label)
                  onClicked: win.backend.verify(saved.modelData.slot)
                }
              }
              Rule {}
            }
          }
          Label {
            visible: !win.v.prints.length
            Layout.fillWidth: true
            Layout.preferredHeight: 56
            textFormat: Text.PlainText
            text: win.t("fingerprintApp.empty")
            color: win.secondary
            font.pixelSize: 15
            verticalAlignment: Text.AlignVCenter
            elide: Text.ElideRight
          }
          Rule { visible: !win.v.prints.length }
        }
        Action {
          visible: hp.ready && !win.v.full
          Layout.topMargin: 4
          enabled: win.v.canEnroll
          primary: true
          text: win.t("fingerprintApp.add")
          onClicked: win.backend.enroll()
        }
        Note { visible: hp.ready && win.v.full; text: win.t("fingerprintApp.full").arg(win.v.capacity) + " " + win.t("fingerprintApp.replace") }
        Note { visible: hp.ready && !win.v.full && !win.v.canEnroll; text: win.t("fingerprintApp.unlockNeedsShell") }
        ColumnLayout {
          Layout.fillWidth: true
          Layout.topMargin: 12
          visible: hp.ready || win.v.sudoState === "enabled"
          spacing: 0
          Section { text: win.t("fingerprintApp.authentication") }
          Setting {
            id: unlock
            visible: hp.ready && win.v.prints.length > 0
            label: win.t("fingerprintApp.useUnlock"); description: win.t(win.v.lockSupported ? "fingerprintApp.password" : "fingerprintApp.unlockNeedsShell")
            active: win.v.unlockOn; available: win.v.lockSupported
            onToggle: win.backend.toggleUnlock()
          }
          Rule { visible: unlock.visible }
          Setting {
            label: win.t("fingerprintApp.useSudo")
            description: win.t(managed ? "fingerprintApp.sudoCustom" : !active && !win.v.prints.length ? "fingerprintApp.sudoEnroll" : "fingerprintApp.sudoScope")
            active: win.v.sudoState === "enabled"; managed: win.v.sudoState === "custom"
            available: active || win.v.prints.length > 0
            onToggle: win.backend.toggleSudo()
          }
          Rule {}
        }
        Action { visible: !hp.ready || win.v.consent; Layout.topMargin: 4; text: win.t("fingerprintApp.prepare"); onClicked: win.backend.prepare() }
        Action { Layout.alignment: Qt.AlignRight; Layout.topMargin: 8; text: win.t("fingerprintApp.done"); onClicked: win.close() }
      }
      Item { Layout.preferredHeight: 16 }
    }
  }

  component NameEditor: ColumnLayout {
    id: editor
    property bool added: false
    Layout.fillWidth: true
    spacing: 8
    Label {
      Layout.fillWidth: true
      textFormat: Text.PlainText
      text: win.t("fingerprintApp.name")
      color: win.secondary
      font.pixelSize: 13
      font.weight: Font.DemiBold
      elide: Text.ElideRight
    }
    TextField {
      id: nameInput
      Layout.fillWidth: true
      implicitHeight: 40
      leftPadding: 12
      rightPadding: 12
      text: win.v.label
      maximumLength: 64
      readOnly: !win.v.canRename
      color: win.fg
      selectionColor: win.accent
      selectedTextColor: win.accentForeground
      font.pixelSize: 15
      Accessible.name: win.t("fingerprintApp.name")
      Component.onCompleted: { forceActiveFocus(); selectAll() }
      onAccepted: win.backend.saveName(text)
      background: Rectangle {
        radius: win.corner(height)
        color: win.panel
        border.width: nameInput.activeFocus ? 2 : 1
        border.color: nameInput.activeFocus ? win.fg : win.outline
      }
    }
    RowLayout {
      Layout.fillWidth: true
      Layout.topMargin: 8
      spacing: 8
      Item { Layout.fillWidth: true }
      Action { visible: !editor.added; text: win.t("fingerprintApp.cancel"); onClicked: win.backend.refresh() }
      Action { primary: true; text: win.t(editor.added ? "fingerprintApp.done" : "fingerprintApp.save"); onClicked: win.backend.saveName(nameInput.text) }
    }
  }
  Component {
    id: scanning
    Page {
      id: sp
      readonly property bool complete: win.v.page === "added" || win.v.page === "matched"
      ColumnLayout {
        Layout.fillWidth: true; Layout.leftMargin: sp.inset; Layout.rightMargin: sp.inset
        spacing: 0
        Label {
          Layout.fillWidth: true
          horizontalAlignment: Text.AlignHCenter
          textFormat: Text.PlainText
          text: win.t(win.v.mode === "Enroll" ? "fingerprintApp.enrollTitle" : "fingerprintApp.verifyTitle")
          color: win.secondary
          font.pixelSize: 14
          font.weight: Font.DemiBold
          wrapMode: Text.Wrap
          Accessible.role: Accessible.Heading
        }
        Note { visible: text.length > 0; Layout.topMargin: 2; horizontalAlignment: Text.AlignHCenter; text: win.v.label }
        Rectangle {
          // The reader's contact and result change the illustration inside the sensor area.
          readonly property int size: Math.round(Math.max(156, Math.min(200, sp.width * 0.42)))
          Layout.alignment: Qt.AlignHCenter
          Layout.topMargin: 20
          Layout.preferredWidth: size
          Layout.preferredHeight: size
          radius: win.corner(size)
          color: win.panel
          Fingerprint {
            anchors.fill: parent
            anchors.margins: Math.round(parent.width * 0.09)
            ink: sp.complete ? win.success : win.accent
            foreground: win.fg
            paper: win.panel
            complete: sp.complete; contact: win.v.contact; samples: win.v.samples
          }
        }
        Heading {
          Layout.topMargin: 20
          horizontalAlignment: Text.AlignHCenter
          text: sp.complete ? win.t(win.v.page === "added" ? "fingerprintApp.added" : "fingerprintApp.matched") : win.v.prompt
          onTextChanged: function(value) { Accessible.announce(value, Accessible.Polite) }
        }
        Note {
          visible: !sp.complete && text.length > 0
          Layout.topMargin: 6
          horizontalAlignment: Text.AlignHCenter
          text: win.v.samples ? win.t("fingerprintApp.scans").arg(win.v.samples) : win.v.mode === "Enroll" && !win.v.swipe ? win.t("fingerprintApp.angle") : ""
        }
        Loader { Layout.fillWidth: true; Layout.topMargin: 24; active: win.v.page === "added"; visible: active; sourceComponent: NameEditor { added: true } }
        Action {
          visible: win.v.page !== "added"
          Layout.alignment: Qt.AlignHCenter
          Layout.topMargin: 24
          primary: sp.complete
          text: win.t(sp.complete ? "fingerprintApp.backToSaved" : "fingerprintApp.cancel")
          onClicked: win.backend.refresh()
        }
      }
      Item { Layout.preferredHeight: 16 }
    }
  }
  Component {
    id: editing
    Page {
      id: ep
      ColumnLayout {
        Layout.fillWidth: true; Layout.leftMargin: ep.inset; Layout.rightMargin: ep.inset
        spacing: 20
        Heading { text: win.t("fingerprintApp.edit") }
        NameEditor {}
        Rule {}
        Action { text: win.t("fingerprintApp.remove"); danger: true; onClicked: win.backend.confirmRemove() }
      }
      Item { Layout.preferredHeight: 16 }
    }
  }
  Component {
    id: confirming
    Page {
      id: cp
      ColumnLayout {
        Layout.fillWidth: true; Layout.leftMargin: cp.inset; Layout.rightMargin: cp.inset
        spacing: 12
        Heading { text: win.t("fingerprintApp.confirmRemove").arg(win.v.label) }
        Note { text: win.t("fingerprintApp.removeBody") }
        RowLayout {
          Layout.fillWidth: true
          Layout.topMargin: 12
          spacing: 8
          Item { Layout.fillWidth: true }
          Action { text: win.t("fingerprintApp.cancel"); Component.onCompleted: forceActiveFocus(); onClicked: win.backend.refresh() }
          Action { danger: true; text: win.t("fingerprintApp.removeConfirm"); onClicked: win.backend.remove() }
        }
      }
      Item { Layout.preferredHeight: 16 }
    }
  }
  Component {
    id: message
    Page {
      id: mp
      ColumnLayout {
        Layout.fillWidth: true; Layout.leftMargin: mp.inset; Layout.rightMargin: mp.inset
        spacing: 12
        Heading { text: win.v.page === "loading" ? win.t("fingerprintApp.appTitle") : win.v.page === "removing" ? win.t("fingerprintApp.removing") : win.v.title }
        Note { text: win.v.page === "loading" ? win.t("fingerprintApp.reading") : win.v.notice }
        Note { visible: win.closePending; text: win.t("fingerprintApp.finishBeforeClosing") }
        Flow {
          Layout.fillWidth: true
          Layout.topMargin: 12
          visible: win.v.page === "failed"
          spacing: 8
          Action { visible: win.v.mode === "Verify"; text: win.t("fingerprintApp.retryVerify"); primary: true; onClicked: win.backend.retry() }
          Action { text: win.t("fingerprintApp.backToSaved"); onClicked: win.backend.refresh() }
        }
      }
      Item { Layout.preferredHeight: 16 }
    }
  }
}
