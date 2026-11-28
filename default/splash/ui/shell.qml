import QtQuick
import Quickshell
import Quickshell.I3
import Quickshell.Io

// The boot splash and drive-unlock prompt. It runs in the initramfs under sway
// (see etc/initcpio/hooks/omarchy-splash) and replaces Plymouth, so it draws
// what the Omarchy Plymouth theme drew: the logo, the unlock field and the
// progress bar.
//
// The initramfs's `plymouth` stand-in (default/splash/plymouth) asks for the
// password by writing $run/request. This shell runs the command the request
// names with the password on stdin, as Plymouth's client did, through
// default/splash/answer, which reports the exit status back.
ShellRoot {
  id: root

  // switch_root deletes these files under the running splash. A reload
  // without them fails, and Quickshell then answers no IPC, so stop couldn't
  // ask where the progress bar is.
  settings.watchFiles: false

  readonly property string run: "/run/omarchy-splash"

  // splash: logo only. password: the unlock field. progress: after Enter.
  property string phase: "splash"
  readonly property Password password: Password {
    editable: root.phase === "password"
  }

  // The layouts the session exported, which sway switches between at a click
  // (Splash.qml).
  readonly property Layouts layouts: Layouts {
    layout: Quickshell.env("OMARCHY_SPLASH_XKBLAYOUT") ?? ""
    variant: Quickshell.env("OMARCHY_SPLASH_XKBVARIANT") ?? ""
    onIndexChanged: I3.dispatch(`input type:keyboard xkb_switch_layout ${index}`)
  }

  property int requestId: 0
  property int submittedId: 0
  property var requestCommand: []
  property real progress: 0
  // A boot hook's message, such as a snapshot restore's (see plymouth).
  property string message: ""

  // The theme's colors, which systemd-stub handed over from the ESP.
  readonly property var colors: theme.colors

  // Only once: each `seat` command configures sway's devices anew.
  property bool pointerShown: false

  function showPointer() {
    if (pointerShown) return
    pointerShown = true
    centerPointer()
    I3.dispatch("seat * hide_cursor 3000")
  }

  // To the middle of the top-left screen. `cursor set` counts from the
  // layout's top-left, where sway starts the pointer, and as a move, which
  // would show it: so only once it has moved.
  function centerPointer() {
    const screens = Array.from(Quickshell.screens)
    if (screens.length === 0) return
    const left = Math.min(...screens.map(s => s.x))
    const top = Math.min(...screens.map(s => s.y))
    const screen = screens.find(s => s.x === left && s.y === top) ?? screens[0]
    I3.dispatch(`seat * cursor set ${Math.round(screen.x - left + screen.width / 2)} ${Math.round(screen.y - top + screen.height / 2)}`)
  }

  function submit() {
    if (phase !== "password" || requestId === submittedId) return
    submittedId = requestId
    unlock.pending = password.take()
    phase = "progress"
    fakeProgress.restart()
    unlock.command = ["/usr/lib/omarchy-splash/answer", String(requestId)].concat(requestCommand)
    unlock.running = true
  }

  // Escape (or Ctrl+[) switches Plymouth to its text view. Here it ends the
  // splash for the rest of the boot, and `plymouth ask-for-password` moves the
  // prompt to the console, once an unlock under way (see answer) has failed.
  function dismiss() {
    dismissedFile.setText("1\n")
    Qt.quit()
  }

  function readRequest() {
    const fields = {}
    for (const line of requestFile.text().split("\n")) {
      const split = line.indexOf("=")
      if (split > 0) fields[line.slice(0, split)] = line.slice(split + 1)
    }
    const id = parseInt(fields.id, 10)
    if (!(id > requestId) || !fields.command) return
    requestId = id
    // Plymouth's client splits the command on spaces and runs it without a
    // shell.
    requestCommand = fields.command.split(" ").filter(argument => argument.length > 0)
    if (unlock.running) return
    if (parseInt(answeringFile.text(), 10) === id) {
      // The splash this one replaced (see session) is unlocking with the
      // password already typed for this request.
      submittedId = id
      phase = "progress"
      fakeProgress.restart()
    } else {
      phase = "password"
    }
  }

  SplashColors {
    id: theme
    path: root.run + "/colors"
  }

  FileView {
    id: requestFile
    path: root.run + "/request"
    watchChanges: true
    printErrors: false
    onFileChanged: reload()
    onLoaded: root.readRequest()
  }

  FileView {
    path: root.run + "/message"
    watchChanges: true
    printErrors: false
    onFileChanged: reload()
    onLoaded: root.message = text().trim()
  }

  // The request an unlock attempt is running for (see answer), as it was when
  // this splash started: only one started before it can be answering a
  // request this one has not seen.
  FileView {
    id: answeringFile
    path: root.run + "/answering"
    blockLoading: true
    printErrors: false
  }

  FileView {
    id: readyFile
    path: root.run + "/ready"
    preload: false
    printErrors: false
  }

  // Tells the session not to start the splash again (see session).
  FileView {
    id: dismissedFile
    path: root.run + "/dismissed"
    preload: false
    blockWrites: true
    printErrors: false
  }

  Process {
    id: unlock

    property string pending: ""

    stdinEnabled: true
    onStarted: {
      write(pending)
      pending = ""
      stdinEnabled = false
    }
    onExited: exitCode => {
      stdinEnabled = true
      if (exitCode === 0 && root.requestId === root.submittedId) {
        root.settle()
        return
      }
      // A wrong password, or another volume's request that came meanwhile.
      root.password.failed = exitCode !== 0
      root.phase = "password"
    }
  }

  // Fake progress, since nothing reports how far boot has got: ease out to
  // 70% over 4.4 seconds from Enter. The unlock carries the bar on to its
  // share (settle), and the startup cover takes the rest.
  NumberAnimation {
    id: fakeProgress
    target: root
    property: "progress"
    from: 0
    to: 0.7
    duration: 4400
    easing.type: Easing.OutQuad
  }

  // The disk is unlocked, and the splash is stopped about 1.2 seconds later,
  // once the real root has started. By then the bar goes on from its pace to
  // the unlock's share, 65%, easing down to a stop, and the startup cover's
  // bar starts where it stops.
  function settle() {
    const to = fakeProgress.to
    // The pace on fakeProgress's curve at its current value, per second.
    const pace = fakeProgress.running ? 2 * to * Math.sqrt(Math.max(0, 1 - progress / to)) / (fakeProgress.duration / 1000) : 0
    fakeProgress.stop()
    const time = settling.duration / 1000
    // Easing down from the pace covers half of pace * time, which after a slow
    // unlock can be past 65%.
    const rest = Math.max(0.65, progress + pace * time / 2)
    if (rest - progress < 0.001) return
    // A cubic from that pace to a stop: its first control point sets the
    // starting slope, here at most 2, which keeps it from overshooting.
    const slope = pace * time / (rest - progress)
    settling.to = rest
    settling.easing.bezierCurve = [1 / 3, slope / 3, 2 / 3, 1, 1, 1]
    settling.restart()
  }

  NumberAnimation {
    id: settling
    target: root
    property: "progress"
    duration: 1100
    easing.type: Easing.BezierSpline
    easing.bezierCurve: [1 / 3, 0, 2 / 3, 1, 1, 1]
  }

  // Where the bar is, for the startup cover's bar to start there (see stop),
  // or "none" while no bar shows. Quickshell's IPC socket is in the runtime
  // directory under $run, so it answers in the real root too, where the
  // splash can open no new path.
  IpcHandler {
    target: "splash"

    function progress(): string {
      return root.phase === "progress" ? String(root.progress) : "none"
    }
  }

  Variants {
    model: Quickshell.screens

    Splash {
      required property var modelData
      screen: modelData
      shell: root
    }
  }

  Component.onCompleted: readyFile.setText("1\n")
}
