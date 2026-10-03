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
  // "idle", "waiting", "scanning", "matched" or "rejected", from the service.
  property string fingerprintState: "idle"
  property string fingerprintStatusText: ""
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
  // Looping fingerprint animations pause with the video feed: while the display
  // is blanked or power saver is on, nobody needs the lock redrawing.
  readonly property bool animateFingerprint: !displaysBlank && !powerSaverActive
  property string passwordText: ""
  property bool syncingPasswordText: false

  readonly property string placeholderText: "Enter Password"
  readonly property int fieldWidth: 381
  readonly property int fieldHeight: 67
  readonly property int outlineThickness: 3
  readonly property int fieldFontSize: Math.round(Style.font.heading * 1.125)
  readonly property int passwordDotFontSize: Math.round(Style.font.heading * 1.33)
  readonly property int passwordDotLetterSpacing: Math.round(Style.font.heading * 0.19)
  // Space to keep clear on each side of the field for the fingerprint icon
  // (icon width plus a gap) so the centered dots never run under it.
  readonly property real fingerprintReserve: fingerprintConfigured ? Math.round(fingerprintIcon.width + 12) : 0
  readonly property int fingerprintIconSize: Math.round(fieldFontSize * 1.35)
  // Shrink the dots to fit once the password outgrows the field, so every
  // keystroke stays visible — otherwise long passwords clip with no feedback.
  readonly property real passwordDotScale: dotMetrics.advanceWidth > 0
    ? Math.min(1, (passwordInput.width - 4) / dotMetrics.advanceWidth)
    : 1
  readonly property bool showPasswordCursor: inputEnabled && !authenticatingPassword && failureMessage.length === 0
  // Fingerprint feedback uses the theme's core accent and urgent colors, not
  // the lock tokens: themes may set every lock token to one color, and then a
  // rejected read would look exactly like a scan.
  readonly property color fingerprintAccent: Color.accent
  readonly property color fingerprintError: Color.urgent
  // Target color of the fingerprint icon; the icon eases toward it.
  readonly property color fingerprintIconColor: fingerprintState === "rejected" ? fingerprintError
    : (fingerprintState === "scanning" || fingerprintState === "matched") ? fingerprintAccent
    : Color.lock.placeholder
  // Glyph swaps in for the verdict: a check on a match, a cross on a miss.
  readonly property string fingerprintGlyph: fingerprintState === "matched" ? "󰄬"
    : fingerprintState === "rejected" ? "󰅖"
    : "󰈷"
  // Glow around the field while a finger is being read and for the verdict.
  readonly property color fieldGlowColor: fingerprintState === "rejected" ? fingerprintError : fingerprintAccent
  readonly property real fieldGlowStrength: fingerprintState === "matched" ? 1.0
    : fingerprintState === "rejected" ? 0.85
    : fingerprintState === "scanning" ? 0.7
    : 0
  readonly property color fingerprintStatusColor: fingerprintState === "rejected" ? fingerprintError
    : fingerprintState === "waiting" ? Color.lock.placeholder
    : Color.lock.text
  readonly property bool errorState: failureMessage.length > 0 || fingerprintState === "rejected"
  readonly property var activeBorderSpec: Border.surfaceSpec("lock", "border-active", Color.lock.borderActive, root.outlineThickness, "border-alpha")
  readonly property var inputBorderSpec: failureMessage.length > 0
    ? Border.surfaceSpec("lock", "border-error", Color.lock.borderError, root.outlineThickness, "border-alpha")
    : fingerprintState === "rejected"
      ? { color: fingerprintError, widths: activeBorderSpec.widths, gradient: { colors: [], angle: 0, enabled: false } }
      : activeBorderSpec

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

  onPasswordTextChanged: syncPasswordText()
  onFingerprintStateChanged: {
    if (fingerprintState === "rejected") fieldShake.restart()
  }
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
      objectName: "lockWallpaper"
      anchors.fill: parent
      path: root.loadBackground ? (root.video ? root.videoPosterPath : root.backgroundPath) : ""
      version: root.backgroundVersion
      // Decode only once sized, at the lock's own size: an unsized first
      // request decoded the file at its native resolution, then again once
      // sized. That size is what the lock service keeps decoded ahead of the
      // lock, so the first frame has the wallpaper.
      cached: true
      constrainDecode: true
      decodeSize: Qt.size(width, height)
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

    // Reader status under the field: ready, identifying, or a rejected read.
    // A pill in the field's own color keeps it legible on any wallpaper.
    Rectangle {
      id: fingerprintStatus
      objectName: "fingerprintStatus"
      readonly property bool shown: root.fingerprintConfigured && root.fingerprintStatusText.length > 0
      readonly property string text: root.fingerprintStatusText
      readonly property color textColor: root.fingerprintStatusColor
      anchors.horizontalCenter: parent.horizontalCenter
      anchors.top: parent.verticalCenter
      anchors.topMargin: root.fieldHeight / 2 + 18
      width: Math.min(parent.width - 32, statusLabel.implicitWidth + 32)
      height: statusLabel.implicitHeight + 12
      radius: height / 2
      color: Color.lock.background
      opacity: shown ? 1 : 0
      visible: opacity > 0

      // Keep the last message while the pill fades out; the label's Behavior
      // cross-fades each new one in instead of swapping it in place.
      onTextChanged: if (text.length > 0) statusLabel.text = text

      Behavior on opacity { NumberAnimation { duration: 200; easing.type: Easing.OutCubic } }
      Behavior on width { NumberAnimation { duration: 180; easing.type: Easing.OutCubic } }

      Text {
        id: statusLabel
        anchors.centerIn: parent
        width: Math.min(implicitWidth, parent.width - 32)
        textFormat: Text.PlainText
        elide: Text.ElideRight
        horizontalAlignment: Text.AlignHCenter
        color: fingerprintStatus.textColor
        font.family: Style.font.family
        font.pixelSize: Math.round(root.fieldFontSize * 0.65)
        Component.onCompleted: text = fingerprintStatus.text

        Behavior on color { ColorAnimation { duration: 150 } }
        Behavior on text {
          SequentialAnimation {
            NumberAnimation { target: statusLabel; property: "opacity"; to: 0; duration: 90 }
            PropertyAction {}
            NumberAnimation { target: statusLabel; property: "opacity"; to: 1; duration: 140 }
          }
        }
      }
    }

    // Soft glow behind the field: accent while scanning or on a match, error
    // color on a rejected read.
    RectangularShadow {
      id: fieldGlow
      // Fades between states; the scan pulse multiplies on top, so the fade is
      // not restarted on every pulse frame.
      property real level: root.fieldGlowStrength
      anchors.fill: inputField
      radius: Style.cornerRadius
      blur: 28
      spread: 2
      color: root.fieldGlowColor
      opacity: level * glowPulse.factor
      visible: opacity > 0
      transform: Translate { x: fieldShift.x }

      Behavior on color { ColorAnimation { duration: 150 } }
      Behavior on level { NumberAnimation { duration: 220; easing.type: Easing.OutCubic } }
    }

    // Breathes the glow while the finger is being matched.
    QtObject {
      id: glowPulse
      property real factor: 1
      property SequentialAnimation animation: SequentialAnimation {
        running: root.fingerprintState === "scanning" && root.animateFingerprint
        loops: Animation.Infinite
        NumberAnimation { target: glowPulse; property: "factor"; to: 0.55; duration: 450; easing.type: Easing.InOutSine }
        NumberAnimation { target: glowPulse; property: "factor"; to: 1; duration: 450; easing.type: Easing.InOutSine }
        onRunningChanged: if (!running) glowPulse.factor = 1
      }
    }

    // Side-to-side shake of the whole field on a rejected read.
    SequentialAnimation {
      id: fieldShake
      NumberAnimation { target: fieldShift; property: "x"; to: -10; duration: 50; easing.type: Easing.OutQuad }
      NumberAnimation { target: fieldShift; property: "x"; to: 9; duration: 70; easing.type: Easing.InOutQuad }
      NumberAnimation { target: fieldShift; property: "x"; to: -6; duration: 70; easing.type: Easing.InOutQuad }
      NumberAnimation { target: fieldShift; property: "x"; to: 4; duration: 70; easing.type: Easing.InOutQuad }
      NumberAnimation { target: fieldShift; property: "x"; to: 0; duration: 60; easing.type: Easing.OutQuad }
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
      transform: Translate { id: fieldShift }

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
        text: root.authenticatingPassword ? "Checking…" : (root.failureMessage.length > 0 ? root.failureMessage : root.placeholderText)
        visible: passwordInput.text.length === 0
        color: root.authenticatingPassword ? Color.lock.text : (root.failureMessage.length > 0 ? Color.lock.textError : Color.lock.placeholder)
        font.family: Style.font.family
        font.pixelSize: root.fieldFontSize
        font.italic: !root.authenticatingPassword && root.failureMessage.length > 0
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
        elide: Text.ElideRight
      }

      // Shimmer running along the bottom border while a finger is matched,
      // so the second or so of matching reads as progress.
      Item {
        objectName: "fingerprintSweep"
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        height: Math.max(2, inputField.borderBottom)
        clip: true
        visible: root.fingerprintState === "scanning"

        Rectangle {
          id: sweepHighlight
          width: inputField.width * 0.4
          height: parent.height
          x: -width
          gradient: Gradient {
            orientation: Gradient.Horizontal
            GradientStop { position: 0.0; color: "transparent" }
            GradientStop { position: 0.5; color: Qt.lighter(root.fingerprintAccent, 1.5) }
            GradientStop { position: 1.0; color: "transparent" }
          }

          NumberAnimation on x {
            running: root.fingerprintState === "scanning" && root.animateFingerprint
            loops: Animation.Infinite
            from: -sweepHighlight.width
            to: inputField.width
            duration: 900
            easing.type: Easing.InOutSine
          }
        }
      }

      // Fingerprint hint pinned inside the field's right edge when a sensor is
      // enrolled, so the user knows they can touch to unlock instead of typing.
      // Matches hyprlock, which draws its fingerprint icon in the same spot.
      Text {
        id: fingerprintIcon
        objectName: "fingerprintIndicator"
        anchors.right: parent.right
        anchors.rightMargin: inputField.borderRight + 16
        anchors.verticalCenter: parent.verticalCenter
        // Fixed to the fingerprint glyph's width so swapping in the check or
        // cross never shifts the password dots.
        width: fingerprintGlyphMetrics.advanceWidth
        visible: root.fingerprintConfigured
        text: root.fingerprintGlyph
        color: root.fingerprintIconColor
        font.family: Style.font.family
        font.pixelSize: root.fingerprintIconSize
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter

        Behavior on color { ColorAnimation { duration: 150 } }

        // Pop the verdict glyph in: shrink, swap, spring back.
        Behavior on text {
          SequentialAnimation {
            NumberAnimation { target: fingerprintIcon; property: "scale"; to: 0.4; duration: 90; easing.type: Easing.InQuad }
            PropertyAction {}
            NumberAnimation { target: fingerprintIcon; property: "scale"; to: 1; duration: 220; easing.type: Easing.OutBack }
          }
        }

        // Slow breathing while the reader waits for a finger.
        SequentialAnimation on opacity {
          running: root.fingerprintState === "waiting" && root.animateFingerprint
          loops: Animation.Infinite
          NumberAnimation { to: 0.4; duration: 1200; easing.type: Easing.InOutSine }
          NumberAnimation { to: 1.0; duration: 1200; easing.type: Easing.InOutSine }
          onRunningChanged: if (!running) fingerprintIcon.opacity = 1
        }
      }

      TextMetrics {
        id: fingerprintGlyphMetrics
        font.family: Style.font.family
        font.pixelSize: root.fingerprintIconSize
        text: "󰈷"
      }
    }
  }
}
