import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import Quickshell.Widgets
import qs.Commons
import qs.Commons as Commons
import qs.Ui
import "UpdateModel.js" as UpdateModel

// The window over `omarchy update -y`, and over one-click installs from the
// menu. The work itself runs detached in run.sh; this only draws its
// transcript and answers its questions, so closing the window hides it while
// the work carries on. Service.qml creates one per update or install.
Item {
  id: root

  property string omarchyPath: Quickshell.env("OMARCHY_PATH")
  property string stateDir: ""
  // A one-click install: the menu action to run. Empty for the update.
  property string task: ""
  // Something already runs: follow it instead of starting anything.
  property bool attach: false
  // Attached after a shell restart to a run the user had sent to the background.
  property bool startHidden: false

  readonly property string pluginDir: omarchyPath + "/shell/plugins/update"
  // Clicking Update now is the confirmation; -y also leaves orphan removal and
  // the reboot question to this window.
  property string updateCommand: "omarchy-update -y"
  property var pendingCommand: [pluginDir + "/pending.sh"]

  readonly property bool isTask: task !== ""
  // Nothing has run in this window yet, so a new request can reuse it.
  readonly property bool fresh: phase === "checking" || phase === "ready" || phase === "uptodate"
  readonly property bool busy: phase === "running"

  signal finished()

  property string phase: attach || isTask ? "running" : "checking"
  property var st: UpdateModel.create()
  property int rev: 0
  property bool dirty: false
  property int seenCount: 0
  // Plain ints, so views only rebuild when these actually change.
  property int lineCount: 0
  property int toolCount: 0
  property var known: ({})
  property var resolved: ({})
  property bool subjectShown: false
  property string claimed: ""
  property var ask: null
  property string answered: ""
  property string debounced: ""
  property bool details: false
  property double startedAt: 0
  property double finishedAt: 0
  // The package servers didn't answer, so "nothing new" isn't known.
  property bool checkFailed: false

  readonly property real prog: (rev, phase === "done" ? 1 : UpdateModel.progress(st))
  readonly property real taskProg: (rev, UpdateModel.transfer(st))
  readonly property int stepIndex: (rev, phase === "done" ? 5 : UpdateModel.STEPS.indexOf(st.step))

  readonly property color fg: Commons.Color.foreground
  readonly property color bg: Commons.Color.background
  readonly property color accent: Commons.Color.accent
  readonly property color urgent: Commons.Color.urgent
  readonly property string fontFamily: Style.font.family

  // ------------------------------------------------------------ plan
  ListModel { id: apps }
  ListModel { id: system }

  // Packages worth a tile even without a desktop entry: [glyph, font].
  readonly property var landmarks: ({
    "omarchy": ["\ue900", "omarchy"],
    "linux": ["\uf17c", ""],
    "linux-lts": ["\uf17c", ""],
    "linux-zen": ["\uf17c", ""]
  })

  function tile(source, name, version, desktop) {
    var mark = landmarks[name]
    return { source: source, name: name, version: version, desktop: desktop, glyph: mark ? mark[0] : "", glyphFont: mark ? mark[1] : "", own: false }
  }

  function addPendingLine(l) {
    if (l === "unknown") { checkFailed = true; return }
    var f = l.split("\t")
    if (f.length < 4 || known[f[1]]) return
    known[f[1]] = true
    if (f[4] || landmarks[f[1]]) apps.append(tile(f[0], f[1], f[3], f[4] || ""))
    else system.append({ name: f[1], version: f[3] })
  }

  Process {
    id: pending
    running: !root.attach && !root.isTask
    command: root.pendingCommand
    stdout: SplitParser { onRead: data => root.addPendingLine(data) }
    onExited: if (root.phase === "checking") root.phase = apps.count + system.count ? "ready" : "uptodate"
  }

  // What this window started, so a reopened one shows the same tiles.
  FileView {
    id: planFile
    path: root.stateDir + "/plan.tsv"
    blockAllReads: true
    printErrors: false
  }

  Component.onCompleted: {
    if (attach) {
      task = taskFile.text().replace(/\n$/, "")
      if (!isTask) planFile.text().split("\n").forEach(addPendingLine)
      alive.running = true
      follow.running = true
    } else if (isTask) {
      start()
    }
    if (!startHidden) win.visible = true
  }

  FileView {
    id: taskFile
    path: root.stateDir + "/task"
    blockAllReads: true
    printErrors: false
  }

  // A run killed outright never wrote its exit; don't wait on it forever.
  Process {
    id: alive
    command: ["flock", "-n", root.stateDir + "/running", "true"]
    onExited: code => { if (code === 0) aliveGrace.start() }
  }

  // Unless the transcript, still being read back, says how it ended.
  Timer { id: aliveGrace; interval: 2000; onTriggered: root.verifyFinished() }

  function verifyFinished() {
    if (st.exit === null) UpdateModel.feed(st, "\x1b]5150;exit;1\x07")
    dirty = true
  }

  // ------------------------------------------------------------ run
  function start() {
    var lines = []
    for (var i = 0; i < apps.count; i++) lines.push([apps.get(i).source, apps.get(i).name, "", apps.get(i).version, apps.get(i).desktop].join("\t"))
    for (i = 0; i < system.count; i++) lines.push(["repo", system.get(i).name, "", system.get(i).version, ""].join("\t"))
    phase = "running"
    startedAt = Date.now()
    launcher.command = ["sh", "-c",
      "mkdir -p -m 700 \"$1\" && flock -n \"$1/running\" rm -f \"$1/out\" && printf %s \"$3\" > \"$1/task\" && printf %s \"$4\" > \"$1/plan.tsv\" && setsid -f \"$0\" \"$1\" \"$2\"",
      pluginDir + "/run.sh", stateDir, isTask ? task : updateCommand, task, lines.join("\n")]
    launcher.running = true
  }

  Process {
    id: launcher
    onExited: follow.running = true
  }

  Process {
    id: follow
    // -s: the file is often missing when tail starts, and tail then polls,
    // once a second unless told otherwise.
    command: ["tail", "-c", "+1", "-F", "-s", "0.1", root.stateDir + "/out"]
    stdout: SplitParser {
      splitMarker: ""
      onRead: data => { UpdateModel.feed(root.st, data); root.dirty = true }
    }
  }

  // Redraw at most every 80ms; pacman redraws its progress far faster.
  Timer {
    interval: 80
    repeat: true
    running: root.dirty
    onTriggered: root.sync()
  }

  function sync() {
    dirty = false
    if (isTask && st.subject && !subjectShown) {
      // The app being installed gets its tile as soon as the installer names it.
      subjectShown = true
      var own = tile("task", "", "", "")
      own.own = true
      apps.insert(0, own)
    }
    for (; seenCount < st.seen.length; seenCount++) {
      var n = st.seen[seenCount]
      if (known[n]) continue
      known[n] = true
      if (!claim(n)) system.append({ name: n, version: "" })
    }
    if (isTask) resolve()
    lineCount = st.lines.length + 1
    toolCount = st.tools.length
    rev++
    if (st.exit !== null && phase === "running") {
      follow.running = false
      finishedAt = Date.now()
      phase = st.exit === 0 ? "done" : "failed"
      if (phase === "failed") details = true
      scroll.to = 0
      scroll.restart()
      present()
    }
    handleAsk()
  }

  function handleAsk() {
    var q = st.ask
    if (!q || q.id === answered) { ask = null; return }
    if (ask && ask.id === q.id) return

    // A question read off the last line of output only counts once nothing
    // has followed it for a moment: pacman under --noconfirm prints its own
    // answer straight after, and a line can pause mid-write.
    if (q.id.charAt(0) === "p" && debounced !== q.id) {
      debounced = q.id
      pause.interval = q.kind === "input" ? 1200 : 600
      pause.restart()
      return
    }
    ask = q
    present()
  }

  Timer { id: pause; onTriggered: root.handleAsk() }

  function reply(q, yes, text) {
    answered = q.id
    ask = null
    send(q.kind === "password" || q.kind === "input" ? text : (yes ? "y" : "n"))
  }

  // Answers go through stdin, never argv, so a password never shows in ps.
  Process {
    id: writer
    property string pending: ""
    command: ["sh", "-c", "[ -p \"$0\" ] && exec cat > \"$0\"", root.stateDir + "/in"]
    stdinEnabled: true
    onStarted: { write(pending + "\n"); pending = ""; stdinEnabled = false }
  }

  function send(text) {
    writer.pending = text
    writer.stdinEnabled = true
    writer.running = true
  }

  // Keep whatever is updating in view; the list can run past the window.
  function reveal(item) {
    if (phase !== "running" || details) return
    var y = item.mapToItem(content, 0, 0).y
    if (y >= list.contentY && y + item.height <= list.contentY + list.height) return
    scroll.to = Math.max(0, Math.min(y - Style.space(40), list.contentHeight - list.height))
    scroll.restart()
  }

  function pkgState(name) {
    rev
    // The installer's own tile, before pacman has said which package it is.
    if (!name) return phase === "done" ? "done" : phase === "running" ? "active" : "pending"
    return st.packages[name] || "pending"
  }

  // Once installed, a package the installer asked for (rather than one pulled
  // in as a dependency) is an app: it moves from the chips to a tile, with its
  // real icon if it ships a launcher.
  Process {
    id: resolver
    property var batch: []
    property var launchers: ({})
    property var wanted: []
    command: ["sh", "-c", "\"$0\" \"$@\"; pacman -Qqe \"$@\" 2>/dev/null | sed 's/^/\\t/'", root.pluginDir + "/launchers.sh"].concat(batch)
    stdout: SplitParser {
      onRead: line => {
        var f = line.split("\t")
        if (f[0]) resolver.launchers[f[0]] = f[1]
        else resolver.wanted.push(f[1])
      }
    }
    onExited: {
      // Ones with a launcher first, so the app, not its CLI, takes the tile.
      wanted.sort(function(a, b) { return !!launchers[b] - !!launchers[a] })
      wanted.forEach(function(n) { root.promote(n, launchers[n] || "") })
      launchers = {}
      wanted = []
      root.resolve()
    }
  }

  function resolve() {
    if (resolver.running) return
    var names = []
    for (var n in st.packages) if (st.packages[n] === "done" && !resolved[n]) { resolved[n] = true; names.push(n) }
    if (!names.length) return
    resolver.batch = names
    resolver.running = true
  }

  function promote(name, desktop) {
    var i
    for (i = 0; i < system.count; i++) if (system.get(i).name === name) { system.remove(i); break }
    for (i = 0; i < apps.count; i++) {
      if (apps.get(i).name === name) {
        if (desktop) apps.setProperty(i, "desktop", desktop)
        if (name === claimed) claimed = ""
        return
      }
    }
    // The first one becomes the installer's tile; any others get their own. A
    // dependency that only claimed the tile by name hands it over.
    for (i = 0; i < apps.count; i++) {
      if (!apps.get(i).name || apps.get(i).name === claimed) {
        if (apps.get(i).name) system.append({ name: claimed, version: "" })
        claimed = ""
        apps.setProperty(i, "name", name)
        apps.setProperty(i, "desktop", desktop)
        return
      }
    }
    apps.append(tile("task", name, "", desktop))
  }

  function claim(name) {
    if (!isTask || !UpdateModel.namesSubject(name, st.subject)) return false
    for (var i = 0; i < apps.count; i++) {
      if (!apps.get(i).name) {
        apps.setProperty(i, "name", name)
        claimed = name
        return true
      }
    }
    return false
  }

  readonly property string openable: {
    rev, apps.count
    for (var i = 0; i < apps.count; i++) if (apps.get(i).desktop) return apps.get(i).desktop
    return ""
  }
  readonly property bool launched: (rev, /gtk-launch|uwsm-app/.test(task) || st.opened)

  // After the compositor closes it, the window only maps again from hidden.
  function present() {
    hiddenFile.setText("")
    if (win.visible) return
    win.visible = false
    win.visible = true
  }

  // Remembers being sent to the background, for a window that comes back
  // after the shell restarts mid-update.
  FileView {
    id: hiddenFile
    path: root.stateDir + "/hidden"
    printErrors: false
  }

  function close() {
    if (phase === "running") {
      win.visible = false
      return
    }
    finished()
  }

  // ------------------------------------------------------------ words
  function duration() {
    var s = Math.max(1, Math.round((finishedAt - startedAt) / 1000))
    if (s < 60) return I18n.t("update.durationSeconds").arg(I18n.formatNumber(s, 0))
    return I18n.t("update.durationMinutes").arg(I18n.formatNumber(Math.floor(s / 60), 0)).arg(I18n.formatNumber(s % 60, 0))
  }

  function activityText(code, arg) {
    switch (code) {
      case "prune": return I18n.t("update.activityPrune")
      case "snapshot": return I18n.t("update.activitySnapshot")
      case "checkout": return I18n.t("update.activityCheckout")
      case "keyring": return I18n.t("update.activityKeyring")
      case "servers": return I18n.t("update.activityServers")
      case "resolving": return I18n.t("update.activityResolving")
      case "download": return I18n.t("update.activityDownload")
      case "verify": return I18n.t("update.activityVerify")
      case "conflicts": return I18n.t("update.activityConflicts")
      case "installing": return I18n.t("update.activityInstalling")
      case "hooks": return I18n.t("update.activityHooks")
      case "migrations": return I18n.t("update.activityMigrations")
      case "orphans": return I18n.t("update.activityOrphans")
      case "orphansRemove": return I18n.t("update.activityOrphansRemove")
      case "shell": return I18n.t("update.activityShell")
      case "mise": return I18n.t("update.activityMise")
      case "aur": return I18n.t("update.activityAur")
      case "aurSearch": return I18n.t("update.activityAurSearch")
      case "installPackage": return I18n.t("update.activityInstallPackage").arg(arg)
      case "removePackage": return I18n.t("update.activityRemovePackage").arg(arg)
      case "buildPackage": return I18n.t("update.activityBuildPackage").arg(arg)
      // A pacman hook describing itself.
      case "hook": return arg
    }
    return I18n.t("update.activityStarting")
  }

  readonly property string headline: {
    rev
    var what = st.subject
    if (isTask) {
      if (phase === "done") return what ? I18n.t("update.installReady").arg(what) : I18n.t("update.done")
      if (phase === "failed") return what ? I18n.t("update.installFailed").arg(what) : I18n.t("update.installFailedGeneric")
      return what ? I18n.t("update.installing").arg(what) : I18n.t("update.installWorking")
    }
    switch (phase) {
      case "checking": return I18n.t("update.checking")
      case "ready": return I18n.t("update.ready")
      case "uptodate": return checkFailed ? I18n.t("update.checkFailed") : I18n.t("update.upToDate")
      case "running": return I18n.t("update.running")
      case "done":
        if (st.reboot) return I18n.t("update.restartTitle")
        return st.errors.length ? I18n.t("update.doneHiccup") : I18n.t("update.done")
      case "failed": return I18n.t("update.failed")
    }
    return ""
  }

  readonly property string subline: {
    rev
    switch (phase) {
      case "checking": return I18n.t("update.checkingDetail")
      case "ready": {
        var count = apps.count + system.count
        return I18n.tn("update.readyDetail", count).arg(I18n.formatNumber(count, 0))
      }
      case "uptodate": return checkFailed ? I18n.t("update.checkFailedDetail") : I18n.t("update.upToDateDetail")
      case "running": {
        if (st.auth && !authCard) return st.auth
        var downloading = st.step === "packages" && st.download.percent >= 0 && st.download.percent < 100
        return activityText(st.activity, st.activityArg) + (downloading && st.download.speed ? "  ·  " + st.download.speed : "")
      }
      case "done": {
        if (st.reboot) return st.reboot
        if (st.errors.length) return st.errors[st.errors.length - 1]
        if (isTask && st.note) return st.note
        var packages = Object.keys(st.packages).filter(function(n) { return st.packages[n] === "done" }).length
        if (!packages) return isTask ? I18n.t("update.alreadyInstalled") : startedAt ? I18n.t("update.maintenanceDone").arg(duration()) : I18n.t("update.done")
        var n = I18n.formatNumber(packages, 0)
        if (!startedAt) return isTask ? I18n.tn("update.installedCount", packages).arg(n) : I18n.tn("update.updatedCount", packages).arg(n)
        return isTask ? I18n.tn("update.installedCountIn", packages).arg(n).arg(duration()) : I18n.tn("update.updatedCountIn", packages).arg(n).arg(duration())
      }
      case "failed": return st.errors.length ? st.errors[st.errors.length - 1] : I18n.t("update.failedDetail")
    }
    return ""
  }

  // sudo waiting on a PAM module: face, fingerprint, security key, ...
  readonly property var authCard: {
    rev
    var t = st.auth
    if (!t || phase !== "running" || ask || /^Sorry/.test(t)) return null
    if (/face/i.test(t)) return { glyph: "\udb83\udc7b", title: /not|fail|timed/i.test(t) ? I18n.t("update.authFaceFailed") : I18n.t("update.authFace"), body: t }
    if (/finger/i.test(t)) return { glyph: "\udb80\ude37", title: /fail|not|no match/i.test(t) ? I18n.t("update.authFingerFailed") : I18n.t("update.authFinger"), body: t }
    if (/touch|key|token|card|u2f/i.test(t)) return { glyph: "\uf084", title: I18n.t("update.authKey"), body: t }
    return { glyph: "\uf023", title: I18n.t("update.authOther"), body: t }
  }

  readonly property var question: {
    var q = ask
    if (!q) return null
    if (q.kind === "password") {
      var body = q.retry ? I18n.t("update.passwordRetryBody")
        : isTask ? I18n.t("update.passwordBodyInstall").arg(st.subject || I18n.t("update.installThis"))
        : I18n.t("update.passwordBody")
      return { glyph: "\uf023", title: q.retry ? I18n.t("update.passwordRetry") : I18n.t("update.password"), body: body, yes: I18n.t("update.continue"), no: "", field: true, secret: true }
    }
    if (q.kind === "input")
      return { glyph: q.secret ? "\uf023" : "\uf11c", title: q.question.replace(/:\s*$/, ""), body: q.hint || I18n.t("update.inputBody"), yes: I18n.t("update.continue"), no: "", field: true, secret: q.secret }
    return { glyph: "\uf059", title: q.question, body: q.kind === "pacman" ? I18n.t("update.pacmanBody") : "", yes: I18n.t("update.yes"), no: I18n.t("update.no") }
  }

  // ------------------------------------------------------------ window
  FloatingWindow {
    id: win
    visible: false
    title: root.isTask ? "Omarchy Install" : "Omarchy Update" // i18n: ignore
    implicitWidth: Style.space(root.isTask ? 700 : 780)
    implicitHeight: Style.space(root.isTask ? 470 : 660)
    color: root.bg

    onVisibleChanged: {
      if (visible) return
      if (root.phase !== "running") {
        root.finished()
        return
      }
      hiddenFile.setText("1")
      Util.execArgv(["omarchy-notification-send", "-g", "\uf01b", root.isTask ? I18n.t("update.backgroundInstall") : I18n.t("update.backgroundUpdate"), I18n.t("update.backgroundBody")])
    }

    Item {
      id: winContent
      anchors.fill: parent
      focus: true
      LayoutMirroring.enabled: I18n.rightToLeft
      LayoutMirroring.childrenInherit: true

      Keys.onEscapePressed: root.close()
      Keys.onReturnPressed: {
        if (root.phase === "ready" || root.phase === "uptodate") root.start()
        else if (root.phase === "done" || root.phase === "failed") root.close()
      }

      ColumnLayout {
        anchors.fill: parent
        anchors.margins: Style.space(28)
        spacing: 0

        // ---------------------------------------------------- header
        RowLayout {
          Layout.fillWidth: true
          spacing: Style.space(18)

          Text {
            textFormat: Text.PlainText
            text: (root.rev, root.phase === "failed" ? "\uf071" : root.phase === "done" ? (root.st.reboot ? "\uf011" : "\uf00c") : "\ue900")
            font.family: root.phase === "failed" || root.phase === "done" ? root.fontFamily : "omarchy"
            font.pixelSize: Style.space(40)
            color: root.phase === "failed" ? root.urgent : root.accent
            Layout.preferredWidth: Style.space(52)
            horizontalAlignment: Text.AlignHCenter
          }

          ColumnLayout {
            Layout.fillWidth: true
            spacing: Style.space(5)
            Text {
              Layout.fillWidth: true
              textFormat: Text.PlainText
              text: root.headline
              color: root.fg
              font.family: root.fontFamily
              font.pixelSize: Style.font.display
              font.weight: Font.DemiBold
              elide: Text.ElideRight
            }
            Text {
              Layout.fillWidth: true
              textFormat: Text.PlainText
              text: root.subline
              color: (root.rev, root.phase === "failed" || (root.phase === "done" && root.st.errors.length && !root.st.reboot) ? root.urgent : Util.alpha(root.fg, 0.7))
              font.family: root.fontFamily
              font.pixelSize: Style.font.body
              wrapMode: Text.Wrap
              maximumLineCount: 2
              elide: Text.ElideRight
            }
          }

          Text {
            textFormat: Text.PlainText
            visible: root.phase === "running" && (!root.isTask || root.taskProg >= 0)
            text: I18n.t("update.percent").arg(I18n.formatNumber(Math.floor((root.isTask ? root.taskProg : root.prog) * 100), 0))
            color: root.accent
            font.family: root.fontFamily
            font.pixelSize: Style.font.display
          }
        }

        // ---------------------------------------------------- steps
        RowLayout {
          Layout.fillWidth: true
          Layout.topMargin: Style.space(22)
          spacing: Style.space(6)
          visible: !root.isTask && (root.phase === "running" || root.phase === "done" || root.phase === "failed")

          Repeater {
            model: UpdateModel.STEPS
            delegate: ColumnLayout {
              id: step
              required property string modelData
              required property int index
              readonly property bool done: index < root.stepIndex
              readonly property bool current: index === root.stepIndex && root.phase === "running"
              readonly property bool failedHere: root.phase === "failed" && index === Math.max(0, root.stepIndex)
              readonly property real fraction: done || failedHere ? 1 : current ? (root.rev, UpdateModel.stepFraction(root.st)) : 0
              Layout.fillWidth: true
              Layout.preferredWidth: 1
              spacing: Style.space(7)

              Bar {
                Layout.fillWidth: true
                fraction: step.fraction
                sweeping: step.current && step.fraction < 0
                failed: step.failedHere
              }

              Text {
                textFormat: Text.PlainText
                Layout.fillWidth: true
                elide: Text.ElideRight
                text: (step.done ? "\uf00c  " : "") + root.stepLabel(step.modelData)
                color: step.current ? root.accent : Util.alpha(root.fg, step.done ? 0.8 : 0.4)
                font.family: root.fontFamily
                font.pixelSize: Style.font.bodySmall
              }
            }
          }
        }

        // One bar while checking or installing: real progress once pacman
        // reports any, a sweep until then.
        Bar {
          Layout.fillWidth: true
          Layout.topMargin: Style.space(22)
          visible: root.phase === "checking" || root.isTask
          fraction: root.phase === "checking" ? -1 : root.phase === "running" ? root.taskProg : 1
          sweeping: fraction < 0
          failed: root.phase === "failed"
        }

        // ---------------------------------------------------- content
        Item {
          Layout.fillWidth: true
          Layout.fillHeight: true
          Layout.topMargin: Style.space(24)

          Flickable {
            id: list
            anchors.fill: parent
            visible: !root.details
            clip: true
            contentHeight: content.implicitHeight
            boundsBehavior: Flickable.StopAtBounds

            NumberAnimation on contentY { id: scroll; running: false; duration: Style.duration(450); easing.type: Easing.OutCubic }

            ColumnLayout {
              id: content
              width: list.width
              spacing: Style.space(12)

              Section {
                visible: apps.count > 0
                text: !root.isTask ? I18n.t("update.sectionApps") : root.phase === "done" ? I18n.t("update.sectionInstalled") : I18n.t("update.sectionInstalling")
                count: apps.count
              }

              Flow {
                Layout.fillWidth: true
                spacing: Style.space(10)
                Repeater { model: apps; delegate: Tile {} }
              }

              Section {
                visible: system.count > 0
                Layout.topMargin: apps.count ? Style.space(14) : 0
                text: !root.isTask ? I18n.t("update.sectionSystem") : root.phase === "done" ? I18n.t("update.sectionAlsoInstalled") : I18n.t("update.sectionAlsoInstalling")
                count: system.count
              }

              Flow {
                Layout.fillWidth: true
                spacing: Style.space(6)
                Repeater {
                  model: system
                  delegate: Chip {
                    required property string name
                    label: name
                  }
                }
              }

              Section {
                visible: root.toolCount > 0
                Layout.topMargin: Style.space(14)
                text: I18n.t("update.sectionTools")
                count: root.toolCount
              }

              Flow {
                Layout.fillWidth: true
                spacing: Style.space(6)
                Repeater {
                  model: root.toolCount
                  delegate: Chip {
                    required property int index
                    readonly property var tool: root.st.tools[index]
                    label: tool.name + "  " + tool.from + " \u2192 " + tool.to
                    finished: true
                  }
                }
              }
            }
          }

          Text {
            textFormat: Text.PlainText
            anchors.centerIn: parent
            visible: root.phase === "uptodate" && !root.details
            text: root.checkFailed ? "\uf071" : "\uf00c"
            color: Util.alpha(root.accent, 0.5)
            font.family: root.fontFamily
            font.pixelSize: Style.space(96)
          }

          // Raw transcript, as the terminal would have shown it.
          Rectangle {
            anchors.fill: parent
            visible: root.details
            color: Util.alpha(root.fg, 0.03)
            border.width: Style.normalBorderWidth
            border.color: Util.alpha(root.fg, 0.12)

            ListView {
              id: log
              anchors.fill: parent
              anchors.margins: Style.space(12)
              anchors.bottomMargin: stuck.visible ? stuck.height + Style.space(16) : Style.space(12)
              clip: true
              model: root.lineCount
              boundsBehavior: Flickable.StopAtBounds
              property bool pinned: true
              onMovementEnded: pinned = atYEnd
              onCountChanged: if (pinned) Qt.callLater(positionViewAtEnd)
              onVisibleChanged: if (visible) Qt.callLater(positionViewAtEnd)
              delegate: Text {
                required property int index
                textFormat: Text.PlainText
                width: log.width
                text: (root.rev, index < root.st.lines.length ? root.st.lines[index] : root.st.tail)
                color: /^error|^Something went wrong/i.test(text) ? root.urgent : Util.alpha(root.fg, 0.75)
                font.family: root.fontFamily
                font.pixelSize: Style.font.bodySmall
                wrapMode: Text.WrapAnywhere
              }
            }

            // For a question this window doesn't recognise.
            TextField {
              id: stuck
              visible: root.phase === "running"
              anchors { left: parent.left; right: parent.right; bottom: parent.bottom; margins: Style.space(8) }
              placeholderText: I18n.t("update.stuckPlaceholder")
              onAccepted: { root.send(text); text = "" }
            }
          }
        }

        // ---------------------------------------------------- footer
        RowLayout {
          Layout.fillWidth: true
          Layout.topMargin: Style.space(20)
          spacing: Style.space(10)

          Button {
            visible: root.phase === "running" || root.phase === "done" || root.phase === "failed"
            iconText: root.details ? "\uf077" : "\uf078"
            text: root.details ? I18n.t("update.hideDetails") : I18n.t("update.showDetails")
            foreground: Util.alpha(root.fg, 0.7)
            onClicked: root.details = !root.details
          }

          Text {
            Layout.fillWidth: true
            textFormat: Text.PlainText
            text: root.phase === "ready" ? "\uf1e6  " + I18n.t("update.plugIn")
                : root.phase === "running" ? (root.isTask ? I18n.t("update.closeHintInstall") : I18n.t("update.closeHint"))
                : ""
            color: Util.alpha(root.fg, 0.5)
            font.family: root.fontFamily
            font.pixelSize: Style.font.bodySmall
            elide: Text.ElideRight
          }

          Button {
            visible: root.phase === "failed"
            bordered: true
            text: I18n.t("update.getHelp")
            onClicked: Qt.openUrlExternally("https://omarchy.org/discord")
          }
          Button {
            visible: root.phase === "ready" || root.phase === "checking"
            bordered: true
            text: I18n.t("update.notNow")
            onClicked: root.close()
          }
          Button {
            visible: root.phase === "uptodate"
            bordered: true
            text: root.checkFailed ? I18n.t("update.updateAnyway") : I18n.t("update.runMaintenance")
            onClicked: root.start()
          }
          Button {
            visible: root.phase === "ready"
            bordered: true
            foreground: root.accent
            text: I18n.t("update.updateNow")
            onClicked: root.start()
          }
          Button {
            visible: root.isTask && root.phase === "done" && root.openable !== "" && !root.launched
            bordered: true
            foreground: root.accent
            text: (root.rev, I18n.t("update.open").arg(root.st.subject || I18n.t("update.openApp")))
            onClicked: {
              Quickshell.execDetached(["uwsm-app", "--", "gtk-launch", root.openable])
              root.close()
            }
          }
          Button {
            visible: root.phase === "running"
            bordered: true
            text: I18n.t("update.runInBackground")
            onClicked: win.visible = false
          }
          Button {
            visible: root.phase === "done" || root.phase === "failed" || root.phase === "uptodate"
            bordered: true
            foreground: (root.rev, root.phase === "uptodate" || root.st.reboot ? root.fg : root.accent)
            text: (root.rev, root.st.reboot ? I18n.t("update.restartLater") : I18n.t("update.close"))
            onClicked: root.close()
          }
          Button {
            visible: (root.rev, root.phase === "done" && root.st.reboot !== "")
            bordered: true
            foreground: root.accent
            text: I18n.t("update.restartNow")
            onClicked: Quickshell.execDetached(["omarchy-system", "reboot"])
          }
        }
      }

      // ---------------------------------------------------- auth
      Rectangle {
        anchors.fill: parent
        visible: root.authCard !== null
        color: Util.alpha(root.bg, 0.88)

        Card {
          glyph: root.authCard ? root.authCard.glyph : ""
          title: root.authCard ? root.authCard.title : ""
          body: root.authCard ? root.authCard.body : ""
          note: I18n.t("update.authNote")
          pulse: true
        }
      }

      // ---------------------------------------------------- question
      Rectangle {
        anchors.fill: parent
        visible: root.question !== null
        color: Util.alpha(root.bg, 0.88)
        onVisibleChanged: if (visible) Qt.callLater(function() { root.question && root.question.field ? answer.forceActiveFocus() : card.forceActiveFocus() })

        MouseArea { anchors.fill: parent }

        Card {
          id: card
          readonly property var q: root.question || ({})
          readonly property bool defaultYes: !root.ask || root.ask.yes
          glyph: q.glyph || ""
          title: q.title || ""
          body: q.body || ""
          alarm: !!(root.ask && root.ask.retry)

          function choose(yes) {
            if (!root.ask) return
            if (q.field) {
              if (root.ask.kind === "password" && !answer.text) return
              root.reply(root.ask, true, answer.text)
              answer.text = ""
            } else {
              root.reply(root.ask, yes)
            }
          }

          Keys.onReturnPressed: choose(defaultYes)
          Keys.onEnterPressed: choose(defaultYes)
          Keys.onEscapePressed: if (q.no) choose(false)
          Keys.onPressed: event => {
            if (event.key === Qt.Key_Y) choose(true)
            else if (event.key === Qt.Key_N && q.no) choose(false)
          }

          TextField {
            id: answer
            Layout.fillWidth: true
            visible: !!card.q.field
            password: !!card.q.secret
            font.pixelSize: Style.font.title
            onAccepted: card.choose(true)
          }

          RowLayout {
            Layout.fillWidth: true
            Layout.topMargin: Style.space(6)
            spacing: Style.space(10)
            Item { Layout.fillWidth: true }
            Button {
              visible: !!card.q.no
              bordered: true
              foreground: card.defaultYes ? root.fg : root.accent
              text: card.q.no || ""
              onClicked: card.choose(false)
            }
            Button {
              bordered: true
              foreground: card.defaultYes ? root.accent : root.fg
              text: card.q.yes || ""
              onClicked: card.choose(true)
            }
          }
        }
      }
    }
  }

  function stepLabel(step) {
    switch (step) {
      case "prepare": return I18n.t("update.stepPrepare")
      case "packages": return I18n.t("update.stepPackages")
      case "configure": return I18n.t("update.stepConfigure")
      case "apps": return I18n.t("update.stepApps")
    }
    return I18n.t("update.stepCleanup")
  }

  // ------------------------------------------------------------ parts
  component Bar: Item {
    id: bar
    property real fraction: 0
    property bool sweeping: false
    property bool failed: false
    implicitHeight: Style.space(4)
    clip: true
    Rectangle { anchors.fill: parent; color: Util.alpha(root.fg, 0.1) }
    Rectangle {
      height: parent.height
      width: parent.width * Math.max(0, bar.fraction)
      color: bar.failed ? root.urgent : root.accent
      Behavior on width { NumberAnimation { duration: Style.duration(450); easing.type: Easing.OutCubic } }
    }
    // No measurable progress: sweep instead.
    Rectangle {
      id: sweep
      visible: bar.sweeping
      width: parent.width * 0.3
      height: parent.height
      color: root.accent
      NumberAnimation on x { from: -sweep.width; to: bar.width; duration: 1300; loops: Animation.Infinite; running: sweep.visible && !Style.reduceMotion }
    }
  }

  component Card: Rectangle {
    id: cardRoot
    property string glyph
    property string title
    property string body
    property string note
    property bool alarm: false
    property bool pulse: false
    default property alias extra: column.data
    anchors.centerIn: parent
    width: Math.min(parent.width - Style.space(40), Style.space(460))
    height: column.implicitHeight + Style.space(56)
    color: root.bg
    border.width: Math.max(1, Style.space(2))
    border.color: alarm ? root.urgent : root.accent

    ColumnLayout {
      id: column
      anchors { left: parent.left; right: parent.right; top: parent.top; margins: Style.space(28) }
      spacing: Style.space(14)

      RowLayout {
        spacing: Style.space(14)
        Text {
          textFormat: Text.PlainText
          text: cardRoot.glyph
          color: cardRoot.alarm ? root.urgent : root.accent
          font.family: root.fontFamily
          font.pixelSize: Style.space(22)
          SequentialAnimation on opacity {
            running: cardRoot.pulse && cardRoot.visible && !Style.reduceMotion
            loops: Animation.Infinite
            NumberAnimation { to: 0.35; duration: 800; easing.type: Easing.InOutSine }
            NumberAnimation { to: 1; duration: 800; easing.type: Easing.InOutSine }
          }
        }
        Text {
          Layout.fillWidth: true
          textFormat: Text.PlainText
          text: cardRoot.title
          color: root.fg
          font.family: root.fontFamily
          font.pixelSize: Style.font.heading
          font.weight: Font.DemiBold
          wrapMode: Text.Wrap
        }
      }

      Text {
        Layout.fillWidth: true
        textFormat: Text.PlainText
        visible: text !== ""
        text: cardRoot.body
        color: Util.alpha(root.fg, 0.75)
        font.family: root.fontFamily
        font.pixelSize: Style.font.body
        wrapMode: Text.Wrap
        lineHeight: 1.25
      }

      Text {
        Layout.fillWidth: true
        textFormat: Text.PlainText
        visible: text !== ""
        text: cardRoot.note
        color: Util.alpha(root.fg, 0.45)
        font.family: root.fontFamily
        font.pixelSize: Style.font.bodySmall
        wrapMode: Text.Wrap
        lineHeight: 1.25
      }
    }
  }

  component Section: RowLayout {
    id: section
    property alias text: label.text
    property int count: 0
    Layout.fillWidth: true
    spacing: Style.space(10)
    Text {
      id: label
      textFormat: Text.PlainText
      color: Util.alpha(root.fg, 0.55)
      font.family: root.fontFamily
      font.pixelSize: Style.font.bodySmall
      font.capitalization: Font.AllUppercase
      font.letterSpacing: 1.5
    }
    Text {
      textFormat: Text.PlainText
      text: I18n.formatNumber(section.count, 0)
      color: Util.alpha(root.fg, 0.35)
      font.family: root.fontFamily
      font.pixelSize: Style.font.bodySmall
    }
    Item { Layout.fillWidth: true }
  }

  component Chip: Rectangle {
    id: chip
    property string label
    readonly property string status: root.pkgState(label)
    property bool finished: status === "done"
    readonly property bool active: status === "active"
    readonly property bool waiting: root.phase === "running" && !finished && !active
    implicitWidth: chipText.implicitWidth + Style.space(18)
    implicitHeight: Style.space(24)
    color: active ? Util.alpha(root.accent, 0.16) : Util.alpha(root.fg, 0.04)
    border.width: Style.normalBorderWidth
    border.color: active ? root.accent : Util.alpha(root.fg, finished ? 0.28 : 0.1)
    Behavior on color { ColorAnimation { duration: Style.duration(250) } }
    Text {
      id: chipText
      textFormat: Text.PlainText
      anchors.centerIn: parent
      text: (chip.finished && root.phase !== "ready" ? "\uf00c " : "") + chip.label
      color: chip.active ? root.accent : Util.alpha(root.fg, chip.waiting ? 0.4 : 0.85)
      font.family: root.fontFamily
      font.pixelSize: Style.font.bodySmall
    }
  }

  component Tile: Rectangle {
    id: tile
    required property string name
    required property string source
    required property string desktop
    required property string version
    required property string glyph
    required property string glyphFont
    // The installer's own tile, named by the installer until its launcher is known.
    required property bool own
    readonly property string status: root.pkgState(name)
    readonly property bool active: status === "active"
    readonly property bool finished: status === "done"
    readonly property bool waiting: root.phase === "running" && !active && !finished
    readonly property var entry: (DesktopEntries.applications.values, desktop ? DesktopEntries.byId(desktop) : null)
    readonly property string iconSource: entry && entry.icon ? Quickshell.iconPath(entry.icon, true) : ""
    readonly property string label: entry ? entry.name : own ? (root.rev, root.st.subject) : name === "omarchy" ? "Omarchy" : /^linux/.test(name) ? I18n.t("update.kernel") : name // i18n: ignore

    onActiveChanged: if (active) root.reveal(tile)

    width: Style.space(106)
    height: Style.space(116)
    color: Util.alpha(active ? root.accent : root.fg, active ? 0.1 : 0.03)
    border.width: Style.normalBorderWidth
    border.color: active ? root.accent : Util.alpha(root.fg, 0.1)
    Behavior on color { ColorAnimation { duration: Style.duration(250) } }

    // Where it comes from, when that isn't the Arch repos.
    Text {
      textFormat: Text.PlainText
      visible: tile.source === "aur"
      anchors { left: parent.left; top: parent.top; margins: Style.space(7) }
      text: "AUR" // i18n: ignore
      color: Util.alpha(root.fg, 0.35)
      font.family: root.fontFamily
      font.pixelSize: Style.font.caption - 1
      font.letterSpacing: 1
    }

    Item {
      id: art
      width: Style.space(48)
      height: Style.space(48)
      anchors.horizontalCenter: parent.horizontalCenter
      y: Style.space(18)
      opacity: tile.waiting ? 0.35 : 1
      Behavior on opacity { NumberAnimation { duration: Style.duration(300) } }

      IconImage {
        anchors.fill: parent
        source: tile.iconSource
        visible: tile.iconSource !== ""
      }
      Text {
        textFormat: Text.PlainText
        anchors.centerIn: parent
        visible: tile.iconSource === ""
        text: tile.glyph || "\uf1b2"
        font.family: tile.glyphFont || root.fontFamily
        font.pixelSize: Style.space(36)
        color: root.fg
      }

      SequentialAnimation on scale {
        running: tile.active && !Style.reduceMotion
        loops: Animation.Infinite
        onRunningChanged: if (!running) art.scale = 1
        NumberAnimation { to: 1.1; duration: 650; easing.type: Easing.InOutSine }
        NumberAnimation { to: 1; duration: 650; easing.type: Easing.InOutSine }
      }
    }

    // Done badge
    Rectangle {
      x: art.x + art.width - Style.space(10)
      y: art.y - Style.space(6)
      width: Style.space(20)
      height: width
      radius: width / 2
      color: root.accent
      scale: tile.finished && root.phase !== "ready" ? 1 : 0
      Behavior on scale { NumberAnimation { duration: Style.duration(320); easing.type: Easing.OutBack } }
      Text {
        textFormat: Text.PlainText
        anchors.centerIn: parent
        text: "\uf00c"
        color: root.bg
        font.family: root.fontFamily
        font.pixelSize: Style.font.bodySmall
        font.weight: Font.Bold
      }
    }

    Text {
      textFormat: Text.PlainText
      anchors { left: parent.left; right: parent.right; top: art.bottom; topMargin: Style.space(12); leftMargin: Style.space(8); rightMargin: Style.space(8) }
      horizontalAlignment: Text.AlignHCenter
      text: tile.label
      color: Util.alpha(root.fg, tile.waiting ? 0.5 : 0.95)
      font.family: root.fontFamily
      font.pixelSize: Style.font.bodySmall
      elide: Text.ElideRight
    }
    Text {
      textFormat: Text.PlainText
      anchors { left: parent.left; right: parent.right; bottom: parent.bottom; bottomMargin: Style.space(10); leftMargin: Style.space(8); rightMargin: Style.space(8) }
      horizontalAlignment: Text.AlignHCenter
      text: tile.version
      color: Util.alpha(root.fg, 0.38)
      font.family: root.fontFamily
      font.pixelSize: Style.font.caption
      elide: Text.ElideMiddle
    }

    // Working on it: a sweep along the bottom edge.
    Item {
      anchors { left: parent.left; right: parent.right; bottom: parent.bottom }
      height: Style.space(2)
      clip: true
      visible: tile.active
      Rectangle {
        id: tileSweep
        width: parent.width * 0.4
        height: parent.height
        color: root.accent
        NumberAnimation on x { from: -tileSweep.width; to: tileSweep.parent.width; duration: 1000; loops: Animation.Infinite; running: tile.active && !Style.reduceMotion }
      }
    }
  }
}
