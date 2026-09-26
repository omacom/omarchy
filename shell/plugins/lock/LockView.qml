import QtQuick
import QtQuick.Effects
import qs.Commons
import qs.Ui

Item {
  id: root

  property string backgroundPath: ""
  property string videoPosterPath: ""
  property int backgroundVersion: 0
  property bool fingerprintConfigured: false
  property bool authenticatingPassword: false
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
  property bool passwordVisible: false

  readonly property string placeholderText: "Enter Password"
  readonly property int fieldWidth: 381
  readonly property int fieldHeight: 67
  readonly property int outlineThickness: 3
  readonly property int fieldFontSize: Math.round(Style.font.heading * 1.125)
  readonly property int passwordDotFontSize: Math.round(Style.font.heading * 1.33)
  readonly property int passwordDotLetterSpacing: Math.round(Style.font.heading * 0.19)
  readonly property string statusText: authenticatingPassword ? "Checking…" : (errorState ? failureMessage : placeholderText)
  readonly property bool statusItalic: !authenticatingPassword && errorState
  // The status line shares the field with the icons, so a long failure message
  // can outgrow the space left for it. Shrink it to fit rather than elide the
  // attempt count away, and keep the placeholder whole at large text sizes too.
  // The floor stops the shrink where the message stops being readable; past
  // that point elide is the honest answer.
  readonly property int statusMinFontSize: 10
  readonly property real statusTextScale: statusMetrics.advanceWidth > 0 && statusTextNode.width > 0
    ? Math.min(1, statusTextNode.width / statusMetrics.advanceWidth)
    : 1
  readonly property int statusFontSize: Math.max(Math.min(statusMinFontSize, fieldFontSize), Math.floor(fieldFontSize * statusTextScale))
  // Space to keep clear on each side of the field for the fingerprint icon
  // and the password-visibility toggle (icon widths plus gaps) so the
  // centered dots never run under them.
  readonly property real fingerprintReserve: fingerprintConfigured ? Math.round(fingerprintIcon.implicitWidth + 12) : 0
  readonly property real visibilityToggleReserve: Math.round(visibilityToggle.implicitWidth + 12)
  readonly property real rightIconsReserve: fingerprintReserve + visibilityToggleReserve
  // Shrink the dots to fit once the password outgrows the field, so every
  // keystroke stays visible — otherwise long passwords clip with no feedback.
  readonly property real passwordDotScale: dotMetrics.advanceWidth > 0
    ? Math.min(1, (passwordInput.width - 4) / dotMetrics.advanceWidth)
    : 1
  // A revealed password renders at the field font size, so a long one has to
  // shrink for the same reason the dots do: both ends of it have to be readable.
  readonly property real plainTextScale: plainMetrics.advanceWidth > 0
    ? Math.min(1, (passwordInput.width - 4) / plainMetrics.advanceWidth)
    : 1
  readonly property bool showPasswordCursor: inputEnabled && !authenticatingPassword && failureMessage.length === 0
  readonly property bool errorState: failureMessage.length > 0
  readonly property var inputBorderSpec: errorState
    ? Border.surfaceSpec("lock", "border-error", Color.lock.borderError, root.outlineThickness, "border-alpha")
    : Border.surfaceSpec("lock", "border-active", Color.lock.borderActive, root.outlineThickness, "border-alpha")

  readonly property bool video: Util.isVideoPath(root.backgroundPath)
  readonly property bool feedActive: root.video && root.loadBackground && !root.displaysBlank && !root.powerSaverActive

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

  onPasswordTextChanged: {
    syncPasswordText()
    if (passwordText.length === 0) passwordVisible = false
  }
  onInputEnabledChanged: {
    if (inputEnabled) Qt.callLater(forcePasswordFocus)
  }
  // The display blanks after a few idle seconds and the revealed text would
  // still be sitting there when it wakes.
  onDisplaysBlankChanged: if (displaysBlank) passwordVisible = false
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

  // Measures the status line at full size; statusTextScale compares this against
  // the width the line actually gets, which the icon reserve takes out of.
  TextMetrics {
    id: statusMetrics
    font.family: Style.font.family
    font.italic: root.statusItalic
    font.pixelSize: root.fieldFontSize
    text: root.statusText
  }

  // Measures a revealed password at full size, the way dotMetrics measures the
  // dots. Never rendered, so holding the text here exposes nothing.
  TextMetrics {
    id: plainMetrics
    font.family: Style.font.family
    font.pixelSize: root.fieldFontSize
    text: passwordInput.text
  }

  Rectangle {
    anchors.fill: parent
    color: Color.background

    BackgroundMedia {
      id: wallpaper
      objectName: "lockWallpaper"
      anchors.fill: parent
      path: root.loadBackground ? (root.video ? root.videoPosterPath : root.backgroundPath) : ""
      version: root.backgroundVersion
    }

    MultiEffect {
      anchors.fill: wallpaper
      source: wallpaper
      autoPaddingEnabled: false
      blurEnabled: root.loadBackground && wallpaper.ready
      blur: 1.0
      blurMax: 128
      blurMultiplier: 1.25
      contrast: -0.08
    }

    // The cached poster stays behind the feed when policy pauses playback,
    // the module is unavailable, or a new connection has not received a frame.
    Loader {
      id: feedLoader
      objectName: "lockFeedLoader"
      anchors.fill: parent
      active: root.feedActive
      source: "LockFeedSurface.qml"
      visible: status === Loader.Ready
    }

    // The feed item cannot be sampled by MultiEffect on every renderer.
    // Keep video wallpapers visible and darken them slightly for legibility.
    Rectangle {
      anchors.fill: feedLoader
      visible: root.video
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
        objectName: "passwordInput"
        anchors.fill: parent
        anchors.topMargin: inputField.borderTop
        // Reserve both icons' width on each side so the centered dots
        // stay symmetric and never slide under the icons as they grow.
        anchors.rightMargin: inputField.borderRight + 18 + root.rightIconsReserve
        anchors.bottomMargin: inputField.borderBottom
        anchors.leftMargin: inputField.borderLeft + 18 + root.rightIconsReserve
        verticalAlignment: TextInput.AlignVCenter
        horizontalAlignment: TextInput.AlignHCenter
        activeFocusOnPress: true
        // Qt refuses a copy only while echoMode is Password, so revealing turns
        // that guard off for the clipboard and the primary selection alike.
        // This drops the selection the primary copy reads; Keys covers the rest.
        selectByMouse: false
        clip: true
        enabled: root.inputEnabled && !root.authenticatingPassword
        readOnly: root.authenticatingPassword
        echoMode: root.passwordVisible ? TextInput.Normal : TextInput.Password
        // Qt adds ImhNoAutoUppercase itself only while echoMode is not Normal,
        // so revealed mode needs it spelled out or an IME upper-cases the first letter.
        inputMethodHints: Qt.ImhSensitiveData | Qt.ImhNoPredictiveText | Qt.ImhNoAutoUppercase
        passwordCharacter: "\u25CF"
        passwordMaskDelay: 0
        color: Color.lock.text
        selectionColor: Color.lock.selection
        selectedTextColor: Color.lock.text
        font.family: Style.font.family
        font.pixelSize: text.length === 0
          ? root.fieldFontSize
          : (root.passwordVisible
            ? Math.max(1, Math.floor(root.fieldFontSize * root.plainTextScale))
            : Math.max(1, Math.floor(root.passwordDotFontSize * root.passwordDotScale)))
        font.letterSpacing: text.length > 0 && !root.passwordVisible ? root.passwordDotLetterSpacing * root.passwordDotScale : 0
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
          } else if (event.matches(StandardKey.Copy) || event.matches(StandardKey.Cut)) {
            // Keyboard selection still works, so without this a shortcut would
            // put the password on the regular clipboard and from there in
            // clipboard history.
            event.accepted = true
          }
        }
      }

      Text {
        id: statusTextNode
        objectName: "passwordStatusText"
        textFormat: Text.PlainText
        anchors.fill: passwordInput
        text: root.statusText
        visible: passwordInput.text.length === 0
        color: root.authenticatingPassword ? Color.lock.text : (root.errorState ? Color.lock.textError : Color.lock.placeholder)
        font.family: Style.font.family
        font.pixelSize: root.statusFontSize
        font.italic: root.statusItalic
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
        elide: Text.ElideRight
      }

      // Fingerprint hint pinned inside the field's right edge when a sensor is
      // enrolled, so the user knows they can touch to unlock instead of typing.
      // Matches hyprlock, which draws its fingerprint icon in the same spot.
      Text {
        id: fingerprintIcon
        objectName: "fingerprintIndicator"
        anchors.right: parent.right
        anchors.rightMargin: inputField.borderRight + 18 + root.visibilityToggleReserve
        anchors.verticalCenter: parent.verticalCenter
        visible: root.fingerprintConfigured
        text: "󰈷"
        color: Color.lock.placeholder
        font.family: Style.font.family
        font.pixelSize: Math.round(root.fieldFontSize * 1.1)
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
      }

      // Toggles masking on the password field. Pinned to the field's right
      // edge, outside the fingerprint icon, so both can coexist.
      Text {
        id: visibilityToggle
        objectName: "passwordVisibilityToggle"
        textFormat: Text.PlainText
        anchors.right: parent.right
        anchors.rightMargin: inputField.borderRight + 18
        anchors.verticalCenter: parent.verticalCenter
        text: root.passwordVisible ? "󰈉" : "󰈈"
        color: toggleArea.containsMouse ? Color.lock.text : Color.lock.placeholder
        font.family: Style.font.family
        font.pixelSize: Math.round(root.fieldFontSize * 1.1)
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter

        MouseArea {
          id: toggleArea
          anchors.fill: parent
          anchors.margins: -6
          hoverEnabled: true
          cursorShape: Qt.PointingHandCursor
          onClicked: {
            root.wakeRequested()
            root.passwordVisible = !root.passwordVisible
            root.forcePasswordFocus()
          }
        }
      }
    }
  }
}
