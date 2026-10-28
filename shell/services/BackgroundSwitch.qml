import QtQuick
import Quickshell
import Quickshell.Io
import qs.Commons

// Sequence a background change around an intro. The outgoing frame is held
// under BackgroundIntro's cover, the link moves once that cover is on screen,
// the new still goes in beneath it, OWE plays the clip, and the cover fades
// once the clip is moving, or opens with the ordinary cut onto a still without
// one. Each step waits on the event that allows it, so the commands that
// start a change only hand it over.
Item {
  id: root

  property var intro: null
  readonly property var backgroundService: intro ? intro.backgroundService : null
  readonly property string home: Quickshell.env("HOME")
  readonly property string backgroundLink: home + "/.local/state/omarchy/current/background"
  readonly property string transitionCache: home + "/.cache/omarchy/background-transitions"
  readonly property string themeSetLock: (Quickshell.env("XDG_RUNTIME_DIR") || "/tmp") + "/omarchy-theme-set.lock"

  // The change in progress, named by its cover's token.
  property string token: ""
  property string still: ""
  property string clip: ""
  // Null until OWE has tried to prepare the clip; false when there is none.
  property var prepared: false
  property bool linked: false
  property bool started: false
  property int serial: 0
  // Snapshots this service or a theme switch made for a cover, removed once
  // nothing shows them.
  property var ownedCovers: []
  // A selection made while an earlier change is still covered or revealing
  // waits for it, since its outgoing frame would miss that change's cover.
  property string queuedPath: ""
  // A theme switch reloads Hyprland once no intro plays: a reload pauses
  // video presentation.
  property bool reloadPending: false

  readonly property bool busy: !!intro && (intro.themeToken !== "" || intro.revealing)

  function displayedStill() {
    var path = backgroundService ? (backgroundService.displayedBackground || backgroundService.currentBackground) : ""
    return path && !Util.isVideoPath(path) ? path : ""
  }

  // A selection from the background picker or omarchy-theme-bg-set.
  function switchTo(path) {
    path = String(path || "").trim()
    if (!path || !intro || !backgroundService) return "unavailable"
    if (busy || resolveProc.running || snapshotProc.running) {
      queuedPath = path
    } else {
      resolveProc.path = path
      resolveProc.command = ["omarchy-theme-bg-boot-intro", "--resolve-enabled", path]
      resolveProc.running = true
    }
    return "ok"
  }

  function resolved(path, clipPath) {
    if (path === backgroundService.currentBackground) return
    // A playing intro hides the shell's background, so even a still without
    // an intro of its own has to come in under the cover.
    if (!clipPath && !backgroundService.suspended) {
      Quickshell.execDetached(["ln", "-nsf", path, backgroundLink])
      backgroundService.setBackground(path, false)
      return
    }
    begin(path, clipPath)
  }

  function begin(path, clipPath) {
    serial += 1
    token = "background-" + serial
    still = path
    clip = clipPath
    prepared = clipPath ? null : false
    linked = false
    started = false
    if (backgroundService.suspended) {
      // A playing video shows a frame only OWE can capture. It is taken
      // before the clip is prepared into the same renderer.
      snapshotProc.forToken = token
      snapshotProc.file = transitionCache + "/previous-" + serial + ".ppm"
      snapshotProc.command = ["bash", "-c", 'mkdir -p "$1" && exec owe render "$2"', "_", transitionCache,
                              JSON.stringify({ cmd: "snapshot", path: snapshotProc.file })]
      snapshotProc.running = true
    } else {
      cover(displayedStill())
    }
  }

  function cover(path) {
    intro.prepareTheme(path, token, "", "")
    advance()
  }

  // A theme switch has put up its cover and repointed the link itself; the
  // rest is the same as a background change, plus Hyprland's reload.
  function play(tok, stillPath, clipPath, preparedFlag) {
    reloadPending = true
    if (!intro || tok !== intro.themeToken) return "superseded"
    token = tok
    still = stillPath
    clip = clipPath
    prepared = clipPath ? preparedFlag === "true" : false
    linked = false
    started = false
    own(intro.themeBackground)
    advance()
    return "ok"
  }

  function own(path) {
    if (path && path.indexOf(transitionCache + "/") === 0 && ownedCovers.indexOf(path) === -1)
      ownedCovers = ownedCovers.concat([path])
  }

  function advance() {
    if (!token || !intro || token !== intro.themeToken) return
    // OWE decodes the clip offscreen while the cover goes up.
    if (prepared === null) {
      if (!prepareProc.running && prepareProc.forToken !== token) {
        prepareProc.forToken = token
        prepareProc.command = ["owe", "intro-prepare", clip]
        prepareProc.running = true
      }
      return
    }
    var coverStatus = intro.themeCoverStatus(token)
    if (coverStatus === "loading") return
    // Moving the link cancels a playing intro and hands the desktop back to
    // the shell, so it waits for the cover.
    if (!linked) {
      if (!linkProc.running) {
        linkProc.forToken = token
        linkProc.command = ["ln", "-nsf", still, backgroundLink]
        linkProc.running = true
      }
      return
    }
    // An earlier clip ends once the link has moved on from it.
    if (started || playProc.running) return
    started = true
    // The shell holds the new still before OWE hands the desktop back, so the
    // old one cannot flash between the clip and the still.
    backgroundService.setBackground(still, true)
    if (clip && coverStatus !== "error") {
      playProc.forToken = token
      playProc.command = prepared
        ? ["owe", "intro", "--start", "first-frame", "--refresh", clip]
        : ["bash", "-c", 'owe refresh >/dev/null && exec owe intro --start first-frame "$1"', "_", clip]
      playProc.running = true
    } else {
      intro.finishTheme(token, !clip)
    }
  }

  function settle() {
    if (busy) return
    if (reloadPending && !playProc.running) {
      reloadPending = false
      Quickshell.execDetached(["flock", themeSetLock, "omarchy-restart-hyprctl"])
    }
    var kept = []
    for (var path of ownedCovers) {
      if (path === intro.themeBackground) kept.push(path)
      else Quickshell.execDetached(["rm", "-f", path])
    }
    ownedCovers = kept
    if (queuedPath && !resolveProc.running) {
      var next = queuedPath
      queuedPath = ""
      switchTo(next)
    }
  }

  Connections {
    target: root.intro
    function onCoverPresented() { root.advance() }
    function onThemeTokenChanged() { root.settle() }
    function onRevealingChanged() { root.settle() }
  }

  Process {
    id: resolveProc
    property string path: ""
    stdout: StdioCollector { id: resolveOut }
    onExited: {
      root.resolved(path, String(resolveOut.text || "").trim())
      root.settle()
    }
  }

  Process {
    id: snapshotProc
    property string forToken: ""
    property string file: ""
    onExited: function(exitCode) {
      if (forToken !== root.token) {
        Quickshell.execDetached(["rm", "-f", file])
      } else if (exitCode === 0) {
        root.own(file)
        root.cover(file)
      } else {
        root.cover(root.displayedStill())
      }
    }
  }

  Process {
    id: prepareProc
    property string forToken: ""
    onExited: function(exitCode) {
      if (forToken === root.token) root.prepared = exitCode === 0
      root.advance()
    }
  }

  Process {
    id: linkProc
    property string forToken: ""
    onExited: {
      if (forToken === root.token) root.linked = true
      root.advance()
    }
  }

  Process {
    id: playProc
    property string forToken: ""
    onExited: {
      // Played or not, the cover then fades to the still beneath it.
      if (root.intro) root.intro.finishTheme(forToken)
      root.advance()
      root.settle()
    }
  }
}
