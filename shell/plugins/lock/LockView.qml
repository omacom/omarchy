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
  // Set by the service for the fade between a successful unlock and release.
  property bool unlocking: false
  // False while the lock is coming up; flipping it to true blurs the wallpaper
  // and fades the content in.
  property bool revealed: true
  // Set once the compositor renders the desktop under the lock during an
  // unlock: the whole view fades out to reveal it. Turning it off is instant,
  // so a cancelled unlock never lingers see-through.
  property bool seeThrough: false
  // Set while the lock comes up over the live desktop: the view starts fully
  // transparent and fades in once revealed, without waiting for the wallpaper,
  // so the desktop shows only for the fade. Clearing it snaps the view opaque.
  property bool fadeFromDesktop: false

  signal lockFadeInFinished()

  function syncDesktopFade() {
    if (!fadeFromDesktop) {
      desktopFadeIn.stop()
      if (!seeThrough) opacity = 1
      return
    }
    if (revealed) {
      if (!desktopFadeIn.running && opacity < 1) desktopFadeIn.restart()
      else if (opacity >= 1) lockFadeInFinished()
    } else {
      desktopFadeIn.stop()
      opacity = 0
    }
  }

  onFadeFromDesktopChanged: syncDesktopFade()
  onRevealedChanged: syncDesktopFade()

  NumberAnimation {
    id: desktopFadeIn
    target: root
    property: "opacity"
    to: 1
    duration: 500
    easing.type: Easing.InOutQuad
    onFinished: root.lockFadeInFinished()
  }

  onSeeThroughChanged: {
    if (seeThrough) {
      seeThroughFade.restart()
    } else {
      seeThroughFade.stop()
      opacity = 1
    }
  }

  NumberAnimation {
    id: seeThroughFade
    target: root
    property: "opacity"
    to: 0
    duration: 300
    easing.type: Easing.InOutQuad
  }
  // The surface, and so its wallpaper, is created when the lock is taken and
  // takes a moment to decode; revealing before then would animate over an
  // empty background. The fallback keeps a slow or missing image from
  // holding the lock content back.
  readonly property bool backgroundSettled: !loadBackground || backgroundPath === ""
    || wallpaper.ready
    || revealFallback.expired
  readonly property bool contentHidden: unlocking || !revealed || !backgroundSettled
  // Only animate toward visible, or out on unlock; hiding for a new lock is
  // instant so the reveal always starts from the sharp wallpaper.
  readonly property bool animateTransition: revealed || unlocking
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

  readonly property string placeholderText: "Enter Password"
  readonly property int fieldWidth: 381
  readonly property int fieldHeight: 67
  readonly property int outlineThickness: 3
  readonly property int fieldFontSize: Math.round(Style.font.heading * 1.125)
  readonly property int passwordDotFontSize: Math.round(Style.font.heading * 1.33)
  readonly property int passwordDotLetterSpacing: Math.round(Style.font.heading * 0.19)
  // Space to keep clear on each side of the field for the fingerprint icon
  // (icon width plus a gap) so the centered dots never run under it.
  readonly property real fingerprintReserve: fingerprintConfigured ? Math.round(fingerprintIcon.implicitWidth + 12) : 0
  // Shrink the dots to fit once the password outgrows the field, so every
  // keystroke stays visible — otherwise long passwords clip with no feedback.
  readonly property real passwordDotScale: dotMetrics.advanceWidth > 0
    ? Math.min(1, (passwordInput.width - 4) / dotMetrics.advanceWidth)
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

  onPasswordTextChanged: syncPasswordText()
  onInputEnabledChanged: {
    if (inputEnabled) Qt.callLater(forcePasswordFocus)
  }
  Component.onCompleted: {
    syncDesktopFade()
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

    Timer {
      id: revealFallback
      property bool expired: false
      interval: 700
      running: root.revealed && !root.unlocking
      onTriggered: expired = true
      onRunningChanged: if (!running) expired = false
    }

    MultiEffect {
      anchors.fill: wallpaper
      source: wallpaper
      autoPaddingEnabled: false
      blurEnabled: root.loadBackground && wallpaper.ready
      // Unblur during the unlock fade so the wallpaper meets the desktop's.
      blur: root.contentHidden ? 0 : 1.0
      blurMax: 128
      blurMultiplier: 1.25
      contrast: root.contentHidden ? 0 : -0.08

      Behavior on blur { enabled: root.animateTransition; NumberAnimation { duration: root.unlocking ? 300 : 550; easing.type: Easing.OutCubic } }
      Behavior on contrast { enabled: root.animateTransition; NumberAnimation { duration: root.unlocking ? 300 : 550; easing.type: Easing.OutCubic } }
    }

    // Fades the wallpaper up from the background color as the lock comes up,
    // instead of it popping in once decoded.
    Rectangle {
      anchors.fill: parent
      color: Color.background
      // Fading in over the desktop, a decoded wallpaper needs no cover: the whole
      // view fades instead.
      opacity: root.unlocking || (root.backgroundSettled && (root.revealed || root.fadeFromDesktop)) ? 0 : 1
      Behavior on opacity { enabled: root.animateTransition; NumberAnimation { duration: 450; easing.type: Easing.OutQuad } }
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

    // Everything drawn over the wallpaper; fades and settles back on unlock.
    Item {
      id: lockContent
      objectName: "lockContent"
      anchors.fill: parent
      opacity: root.contentHidden ? 0 : 1
      // Settles in from slightly large on lock, shrinks away on unlock.
      scale: root.unlocking ? 0.94 : !root.revealed ? 1.06 : 1

      Behavior on opacity {
        enabled: root.animateTransition
        NumberAnimation { duration: root.unlocking ? 260 : 500; easing.type: root.unlocking ? Easing.InCubic : Easing.OutCubic }
      }
      Behavior on scale {
        enabled: root.animateTransition
        NumberAnimation { duration: root.unlocking ? 300 : 600; easing.type: root.unlocking ? Easing.InCubic : Easing.OutBack }
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

        // Fingerprint hint pinned inside the field's right edge when a sensor is
        // enrolled, so the user knows they can touch to unlock instead of typing.
        // Matches hyprlock, which draws its fingerprint icon in the same spot.
        Text {
          id: fingerprintIcon
          objectName: "fingerprintIndicator"
          anchors.right: parent.right
          anchors.rightMargin: inputField.borderRight + 18
          anchors.verticalCenter: parent.verticalCenter
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
