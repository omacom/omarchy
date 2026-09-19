import QtQuick
import QtQuick.Effects
import qs.Commons
import qs.Ui

Item {
  id: root

  property string backgroundPath: ""
  property int backgroundVersion: 0
  property bool fingerprintConfigured: false
  property bool facePamConfigured: false
  property bool faceAuthenticating: false
  property bool authenticatingPassword: false
  property real facePulseOpacity: 1.0
  property string failureMessage: ""
  property int failedAttempts: 0
  property bool inputEnabled: true
  property bool loadBackground: true
  // A locked session blanks the displays after a few seconds. Nothing is
  // visible from then until the user wakes it, so a video must not keep
  // decoding through what is usually the longest part of a lock.
  property bool displaysBlank: false
  property bool powerSaverActive: false
  property string passwordText: ""
  property bool syncingPasswordText: false

  readonly property string placeholderText: "Enter Password"
  readonly property int fieldWidth: 381
  readonly property int fieldHeight: 67
  readonly property int outlineThickness: 3
  readonly property int fieldFontSize: Math.round(Style.font.heading * 1.125)
  readonly property int passwordDotFontSize: Math.round(Style.font.heading * 1.33)
  readonly property int passwordDotLetterSpacing: Math.round(Style.font.heading * 0.19)
  // Space to keep clear on each side of the field for auth indicators (icons
  // plus gaps) so centered dots never run under them. Measured from the
  // actual glyphs — they scale with the field font.
  readonly property real fingerprintReserve: (fingerprintConfigured ? Math.round(fingerprintIcon.implicitWidth + 8) : 0)
    + (facePamConfigured ? Math.round(faceIcon.implicitWidth + 8) : 0)
  // Shrink the dots to fit once the password outgrows the field, so every
  // keystroke stays visible — otherwise long passwords clip with no feedback.
  readonly property real passwordDotScale: dotMetrics.advanceWidth > 0
    ? Math.min(1, (passwordInput.width - 4) / dotMetrics.advanceWidth)
    : 1

  SequentialAnimation on facePulseOpacity {
    running: root.faceAuthenticating
    loops: Animation.Infinite
    NumberAnimation { from: 0.3; to: 1.0; duration: 500; easing.type: Easing.InOutQuad }
    NumberAnimation { from: 1.0; to: 0.3; duration: 500; easing.type: Easing.InOutQuad }
  }
  readonly property bool showPasswordCursor: inputEnabled && !authenticatingPassword && failureMessage.length === 0
  readonly property bool errorState: failureMessage.length > 0
  readonly property var inputBorderSpec: errorState
    ? Border.surfaceSpec("lock", "border-error", Color.lock.borderError, root.outlineThickness, "border-alpha")
    : Border.surfaceSpec("lock", "border-active", Color.lock.borderActive, root.outlineThickness, "border-alpha")

  signal submitPassword(string password)
  signal passwordTextEdited(string password)
  signal clearFailureRequested()
  signal wakeRequested()

  function forcePasswordFocus() {
    passwordInput.forceActiveFocus()
  }

  function clearPassword() {
    passwordTextEdited("")
  }

  function syncPasswordText() {
    if (passwordInput.text === passwordText) return
    syncingPasswordText = true
    passwordInput.text = passwordText
    syncingPasswordText = false
  }

  onPasswordTextChanged: syncPasswordText()
  onInputEnabledChanged: {
    if (inputEnabled) Qt.callLater(forcePasswordFocus)
  }
  Component.onCompleted: {
    syncPasswordText()
    if (inputEnabled) Qt.callLater(forcePasswordFocus)
  }

  // Measures the masked password at full size; passwordDotScale compares this
  // against the field width to decide how far the dots must shrink to fit.
  TextMetrics {
    id: dotMetrics
    font.family: Style.font.family
    font.pixelSize: root.passwordDotFontSize
    font.letterSpacing: root.passwordDotLetterSpacing
    text: "●".repeat(passwordInput.text.length)
  }

  Rectangle {
    anchors.fill: parent
    color: Color.background

    BackgroundMedia {
      id: wallpaper
      anchors.fill: parent
      path: root.loadBackground ? root.backgroundPath : ""
      version: root.backgroundVersion
      playbackEnabled: root.loadBackground && !root.displaysBlank && !root.powerSaverActive
    }

    MultiEffect {
      anchors.fill: wallpaper
      source: wallpaper.video ? null : wallpaper
      visible: !wallpaper.video
      autoPaddingEnabled: false
      blurEnabled: root.loadBackground && wallpaper.ready
      blur: 1.0
      blurMax: 128
      blurMultiplier: 1.25
      contrast: -0.08
    }

    // Qt's video output cannot be sampled by MultiEffect on every renderer.
    // Keep video wallpapers visible and darken them slightly for legibility.
    Rectangle {
      anchors.fill: wallpaper
      visible: wallpaper.video
      color: "#22000000"
    }

    MouseArea {
      anchors.fill: parent
      hoverEnabled: true
      onClicked: { root.wakeRequested(); root.forcePasswordFocus() }
      onPositionChanged: root.wakeRequested()
    }

    BorderSurface {
      id: inputField
      width: root.fieldWidth
      height: root.fieldHeight
      anchors.centerIn: parent
      color: Color.lock.background
      borderSpec: root.inputBorderSpec
      radius: Style.cornerRadius
      clip: true

      TextInput {
        id: passwordInput
        anchors.fill: parent
        anchors.topMargin: inputField.borderTop
        // Reserve the fingerprint icon's width on both sides so the centered
        // dots stay symmetric and never slide under the icon as they grow.
        anchors.rightMargin: inputField.borderRight + 18 + root.fingerprintReserve
        anchors.bottomMargin: inputField.borderBottom
        anchors.leftMargin: inputField.borderLeft + 18 + root.fingerprintReserve
        verticalAlignment: TextInput.AlignVCenter
        horizontalAlignment: TextInput.AlignHCenter
        activeFocusOnPress: true
        clip: true
        enabled: root.inputEnabled && !root.authenticatingPassword
        readOnly: root.authenticatingPassword
        echoMode: TextInput.Password
        passwordCharacter: "\u25CF"
        passwordMaskDelay: 0
        color: Color.lock.text
        selectionColor: Color.lock.selection
        selectedTextColor: Color.lock.text
        font.family: Style.font.family
        font.pixelSize: text.length > 0 ? Math.max(1, Math.floor(root.passwordDotFontSize * root.passwordDotScale)) : root.fieldFontSize
        font.letterSpacing: text.length > 0 ? root.passwordDotLetterSpacing * root.passwordDotScale : 0
        cursorVisible: activeFocus && root.showPasswordCursor && text.length > 0
        cursorDelegate: Rectangle {
          width: 2
          color: Color.lock.text
          visible: passwordInput.cursorVisible
        }

        onTextChanged: {
          if (!root.syncingPasswordText) root.passwordTextEdited(text)
          if (text.length > 0) {
            root.wakeRequested()
          }
          if (text.length > 0 && root.failureMessage.length > 0) root.clearFailureRequested()
        }

        onAccepted: {
          var submitted = root.passwordText
          root.passwordTextEdited("")
          if (submitted.length > 0) root.submitPassword(submitted)
        }

        Keys.onPressed: function(event) {
          root.wakeRequested()
          if (event.key === Qt.Key_Escape || (event.modifiers & Qt.ControlModifier && event.key === Qt.Key_U)) {
            root.passwordTextEdited("")
            event.accepted = true
          }
        }
      }

      Text {
        textFormat: Text.PlainText
        anchors.fill: passwordInput
        // Failure text wins over both scanning states so error styling stays
        // coherent even while a parallel face scan is running.
        text: root.failureMessage.length > 0 ? root.failureMessage : (root.authenticatingPassword ? "Checking…" : (root.faceAuthenticating ? "Scanning face…" : root.placeholderText))
        visible: passwordInput.text.length === 0
        color: root.failureMessage.length > 0 ? Color.lock.textError : (root.faceAuthenticating || root.authenticatingPassword ? Color.lock.text : Color.lock.placeholder)
        font.family: Style.font.family
        font.pixelSize: root.fieldFontSize
        font.italic: root.failureMessage.length > 0
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
        elide: Text.ElideRight
      }

      // Biometric indicators pinned inside the field's right edge.
      Row {
        id: biometricIndicators
        anchors.right: parent.right
        anchors.rightMargin: inputField.borderRight + 14
        anchors.verticalCenter: parent.verticalCenter
        spacing: 8

        Text {
          id: faceIcon
          objectName: "faceIndicator"
          visible: root.facePamConfigured
          text: "󰄀"
          color: root.faceAuthenticating ? (Color.accent || Color.lock.text) : Color.lock.placeholder
          opacity: root.faceAuthenticating ? root.facePulseOpacity : 0.6
          font.family: Style.font.family
          font.pixelSize: Math.round(root.fieldFontSize * 1.1)
          horizontalAlignment: Text.AlignHCenter
          verticalAlignment: Text.AlignVCenter
        }

        Text {
          id: fingerprintIcon
          objectName: "fingerprintIndicator"
          visible: root.fingerprintConfigured
          text: "󰈷"
          color: Color.lock.placeholder
          font.family: Style.font.family
          font.pixelSize: Math.round(root.fieldFontSize * 1.1)
          horizontalAlignment: Text.AlignHCenter
          verticalAlignment: Text.AlignVCenter
        }
      }
    }
  }
}
