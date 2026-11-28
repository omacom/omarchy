import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Services.Greetd

// The login screen. greetd runs it as the greeter user under Hyprland
// (default/splash/greeter) on the boot splash's own window: the logo and the
// password field, for the one user greetd's configuration names
// (omarchy-system-login writes it). greetd checks the password through PAM and
// starts that user's session.
ShellRoot {
  id: root

  readonly property string user: Quickshell.env("OMARCHY_GREETER_USER") ?? ""
  // default/splash/login-session, which autologin starts too.
  readonly property var session: ["/usr/share/omarchy/default/splash/login-session"]

  // password: the field. progress: while greetd checks it and starts the
  // session.
  property string phase: "password"
  readonly property Password password: Password {
    editable: root.phase === "password"
  }
  property real progress: 0
  property string pending: ""

  // The layouts default/splash/greeter exported, which Hyprland switches
  // between at a click (Splash.qml).
  readonly property Layouts layouts: Layouts {
    layout: Quickshell.env("OMARCHY_SPLASH_XKBLAYOUT") ?? ""
    variant: Quickshell.env("OMARCHY_SPLASH_XKBVARIANT") ?? ""
    onIndexChanged: {
      switchLayout.command = ["hyprctl", "switchxkblayout", "all", String(index)]
      switchLayout.running = true
    }
  }

  // switchxkblayout is a hyprctl command rather than a dispatcher. A click
  // while one runs has the latest start once it ends, so they land in order.
  Process {
    id: switchLayout
  }

  readonly property var colors: theme.colors

  // There is no console to fall back to here, as there is at boot.
  function dismiss() {
    password.clear()
  }

  function submit() {
    if (phase !== "password") return
    pending = password.take()
    phase = "progress"
    fakeProgress.restart()
    Greetd.createSession(user)
  }

  // Hyprland hides its pointer (greeter.lua) until it has moved with the field
  // up (Splash.qml); then it shows until it rests 3 seconds or a key is typed.
  function showPointer() {
    pointerOn.running = true
  }

  Process {
    id: pointerOn
    command: ["hyprctl", "eval", "hl.config({ cursor = { invisible = false } })"]
  }

  function refuse() {
    pending = ""
    password.failed = true
    phase = "password"
    fakeProgress.stop()
    progress = 0
  }

  Connections {
    target: Greetd

    function onAuthMessage(message, error, responseRequired, echoResponse) {
      if (!responseRequired) return
      // PAM asks for the password once. Anything it asks after that (a new
      // password for an expired one, say) has no answer here.
      if (root.pending === "") {
        Greetd.cancelSession()
        root.refuse()
        return
      }
      Greetd.respond(root.pending)
      root.pending = ""
    }

    function onReadyToLaunch() {
      Greetd.launch(root.session, [], true)
    }

    function onAuthFailure(message) {
      root.refuse()
    }

    function onError(error) {
      console.warn("greetd:", error)
      root.refuse()
    }
  }

  SplashColors {
    id: theme
    path: "/var/lib/omarchy/login/colors"
  }

  NumberAnimation {
    id: fakeProgress
    target: root
    property: "progress"
    from: 0
    to: 0.7
    duration: 15000
    easing.type: Easing.OutQuad
  }

  Variants {
    model: Quickshell.screens

    Splash {
      required property var modelData
      screen: modelData
      shell: root
    }
  }
}
