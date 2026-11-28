import QtQuick
import Quickshell
import Quickshell.Wayland

// One screen of the splash, laid out as the Omarchy Plymouth theme laid it
// out: the logo centred, the unlock field 40px under it with the lock to its
// left, and the progress bar where the field was. Clicking the eye inside the
// field's right edge (or pressing Tab) toggles showing the password instead of
// dots, and the keyboard in the bottom-right corner (or Shift+Tab) switches
// the layout it is typed in. The boot splash (shell.qml) and the login screen
// (greeter.qml) both draw it, each as its `shell`, which all its screens share:
// `phase`, `progress`, `colors`, `password` (Password.qml), `layouts`
// (Layouts.qml), `submit()`, `dismiss()` and `showPointer()`, and the boot
// splash's `message` too.
PanelWindow {
  id: window

  required property var shell
  readonly property var colors: shell.colors
  readonly property Password password: shell.password
  readonly property Layouts layouts: shell.layouts

  anchors {
    top: true
    bottom: true
    left: true
    right: true
  }
  exclusionMode: ExclusionMode.Ignore
  WlrLayershell.layer: WlrLayer.Overlay
  WlrLayershell.keyboardFocus: WlrKeyboardFocus.Exclusive
  WlrLayershell.namespace: "omarchy-splash"
  color: colors.background

  // The one font the boot image carries (etc/initcpio/install/omarchy-splash),
  // at the same path in the real root for the login screen.
  FontLoader {
    id: mono
    source: "file:///usr/share/fonts/noto/NotoSansMono-Regular.ttf"
  }

  // No cursor over the splash, as over Plymouth's, until the pointer moves
  // while the field is up, for the eye. The compositor hides it again once it
  // rests or a key is typed (shell.qml, greeter.lua). A compositor entering
  // the window under a pointer that stays put doesn't count as a move, nor
  // does one from before the field last came up.
  MouseArea {
    id: pointer

    property point last: Qt.point(NaN, NaN)
    property bool moved: false

    anchors.fill: parent
    acceptedButtons: Qt.NoButton
    hoverEnabled: true
    cursorShape: field.visible && moved ? Qt.ArrowCursor : Qt.BlankCursor
    onPositionChanged: mouse => {
      if (field.visible && !isNaN(last.x) && (mouse.x !== last.x || mouse.y !== last.y)) moved = true
      last = Qt.point(mouse.x, mouse.y)
    }
    onMovedChanged: if (moved) window.shell.showPointer()
  }

  function reveal(shown, held) {
    password.revealHeld = !!held && shown && field.visible
    password.revealed = shown && field.visible
  }

  Logo {
    id: logo
    anchors.centerIn: parent
    // Narrower than the logo on a portrait screen at scale 2.
    width: Math.min(810, parent.width - 80)
    height: width * 19 / 81
    color: window.colors.accent
  }

  Item {
    id: field
    visible: window.shell.phase === "password"
    onVisibleChanged: if (!visible) {
      pointer.moved = false
      window.reveal(false)
    }
    width: 286
    height: 48
    x: (parent.width - width) / 2
    y: logo.y + logo.height + 40

    readonly property color color: window.password.failed ? window.colors.error : window.colors.foreground
    // Where the dots or the shown password stop, 8px before the eye.
    readonly property real contentEnd: width - eye.anchors.rightMargin - eye.width - 8

    Lock {
      anchors.right: parent.left
      anchors.rightMargin: 15
      anchors.verticalCenter: parent.verticalCenter
      height: parent.height * 0.8
      color: field.color
      cutout: window.colors.background
    }

    Rectangle {
      anchors.fill: parent
      color: Qt.rgba(0, 0, 0, 0.05)
      border.width: 2
      border.color: field.color
    }

    Eye {
      id: eye
      anchors.right: parent.right
      anchors.rightMargin: 16
      anchors.verticalCenter: parent.verticalCenter
      height: 14
      color: field.color
      // The field's own shade, over which it is drawn.
      cutout: Qt.tint(window.colors.background, Qt.rgba(0, 0, 0, 0.05))
      crossed: !window.password.revealed

      MouseArea {
        anchors.fill: parent
        anchors.margins: -8
        onClicked: window.reveal(!window.password.revealed)
      }
    }

    // The shown password, each character over its dot (Noto Sans Mono at 20px
    // advances 12px, the dots' pitch), its end in view once it outgrows them.
    Item {
      x: 18
      width: field.contentEnd - x
      height: parent.height
      clip: true
      visible: window.password.revealed

      Text {
        id: shown
        x: Math.min(0, parent.width - width)
        anchors.verticalCenter: parent.verticalCenter
        text: window.password.text
        textFormat: Text.PlainText
        font.family: mono.name
        font.pixelSize: 20
        color: window.colors.foreground
      }
    }

    Repeater {
      // As many as fit, the first ending 27px in (none while the field is
      // still being laid out).
      model: window.password.revealed ? 0 : Math.max(0, Math.min(Math.floor((field.contentEnd - 27) / 12) + 1, [...window.password.text].length))

      Rectangle {
        required property int index
        x: 20 + index * 12
        y: (field.height - height) / 2
        width: 7
        height: 7
        radius: 3.5
        color: window.colors.foreground
      }
    }
  }

  // The layout the password is typed in, while there is another to switch to,
  // which a click, tap or Shift+Tab does.
  Item {
    id: layoutIndicator
    anchors.right: parent.right
    anchors.bottom: parent.bottom
    anchors.margins: 32
    width: toggle.width
    height: toggle.height
    visible: field.visible && window.layouts.count > 1

    property color tint: window.colors.foreground

    ColorAnimation {
      id: layoutFlash
      target: layoutIndicator
      property: "tint"
      from: window.colors.accent
      to: window.colors.foreground
      duration: 450
      easing.type: Easing.OutQuad
    }

    Connections {
      target: window.layouts
      function onIndexChanged() {
        if (field.visible) layoutFlash.restart()
      }
    }

    Row {
      id: toggle
      spacing: 10

      Text {
        anchors.verticalCenter: parent.verticalCenter
        text: window.layouts.label
        textFormat: Text.PlainText
        font.family: mono.name
        font.pixelSize: 16
        color: layoutIndicator.tint
      }

      Keyboard {
        anchors.verticalCenter: parent.verticalCenter
        height: 14
        color: layoutIndicator.tint
      }
    }

    MouseArea {
      anchors.fill: parent
      anchors.margins: -8
      onClicked: {
        window.layouts.next()
        window.password.touchReveal()
      }
    }
  }

  Rectangle {
    visible: window.shell.phase === "progress"
    width: 300
    height: 10
    x: (parent.width - width) / 2
    y: field.y + (field.height - height) / 2
    color: Qt.tint(window.colors.background, Qt.alpha(window.colors.foreground, 0.1))

    Rectangle {
      width: Math.max(1, Math.round(parent.width * window.shell.progress))
      height: parent.height
      color: window.colors.foreground
    }
  }

  // A boot hook's message, under the field or the bar.
  Text {
    x: (parent.width - width) / 2
    y: field.y + field.height + 24
    width: Math.min(implicitWidth, parent.width - 80)
    text: window.shell.message ?? ""
    textFormat: Text.PlainText
    elide: Text.ElideRight
    font.family: mono.name
    font.pixelSize: 16
    color: window.colors.foreground
  }

  // Keys arrive through an invisible TextInput rather than a plain Item
  // because Qt runs dead-key compose only for an item that takes an input
  // method; composed text lands in `text`. Every key event is handled here,
  // so the TextInput never edits on its own.
  TextInput {
    width: 1
    height: 1
    opacity: 0
    focus: true
    echoMode: TextInput.Password

    onTextChanged: {
      if (text === "") return
      window.password.append(text)
      text = ""
    }

    // Plymouth's line editing, but for Ctrl+C and Ctrl+D, which clear rather
    // than cancel the prompt (that dropped Plymouth's boot to the emergency
    // shell). Alt+F8 is the Windows sign-in screen's shortcut; Qt's key repeat
    // releases F8 too. Tab toggles visibility and Shift+Tab cycles layouts
    // when more than one is configured. Escape (or Ctrl+[) is the shell's to
    // handle.
    Keys.onReleased: event => {
      if (event.key === Qt.Key_F8 && !event.isAutoRepeat && window.password.revealHeld) {
        window.reveal(false)
      }
    }
    Keys.onPressed: event => {
      event.accepted = true
      const action = window.password.actionForKey(
        event.key, event.modifiers, event.text, event.isAutoRepeat,
        field.visible, window.layouts.count
      )
      if (action === "toggleReveal") {
        window.reveal(!window.password.revealed)
      } else if (action === "nextLayout") {
        window.layouts.next()
        window.password.touchReveal()
      } else if (action === "reveal") {
        window.reveal(true, true)
      } else if (action === "dismiss") {
        window.shell.dismiss()
      } else if (action === "submit") {
        window.shell.submit()
      } else if (action === "removeLast") {
        window.password.removeLast()
      } else if (action === "clear") {
        window.password.clear()
      } else if (action === "append") {
        window.password.append(event.text)
      }
    }
  }
}
