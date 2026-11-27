import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import qs.Commons
import "AppSearch.js" as AppSearch

// Shared desktop-application library: the sorted entry list with hidden-entry
// filtering, the icon fallback index, launch feedback, and entry removal.
// Injected as shell.appLibrary; the menu's Apps submenu is the consumer.
Item {
  id: root

  property string omarchyPath: Quickshell.env("OMARCHY_PATH")
  // The shell that owns this library; launch feedback drives the OSD plugin
  // through it in-process rather than through a spawned omarchy-shell call.
  property var shell: null

  property var configuredHiddenEntryIds: ({})
  property var desktopHiddenEntryIds: ({})
  // Desktop id -> X-Omarchy-Dock-Click, which Quickshell doesn't parse.
  property var dockClickModes: ({})

  // Maps an icon name to a file on disk (e.g. "omacut" -> ".../apps/omacut.svg").
  // Used as a fallback for icons that Qt's themed lookup misses because they were
  // installed after this process started (its icon cache never re-scans). Refreshed
  // whenever the app list changes, so newly installed apps get their icon live.
  property var iconIndex: ({})
  property var pendingIconIndex: ({})
  property bool iconRescanQueued: false
  property bool desktopEntryRescanQueued: false

  // Omarchy's own app icons are linked into the user's icon dir and redrawn in
  // place after each theme switch, which then writes icons.revision. The
  // revision goes on their URLs to make images reload instead of showing the
  // cached previous theme, and the rescan picks up links created for the first
  // time.
  readonly property string home: Quickshell.env("HOME")
  readonly property string userIconsPath: (Quickshell.env("XDG_DATA_HOME") || home + "/.local/share") + "/icons/"
  property int themeRevision: 0
  property string lastLinksRevision: ""
  property bool iconsRevisionInitialized: false

  // Maps a desktop id to the version of the package that owns it. Rescanned
  // each time the app grid opens, since upgrades leave desktop entries alone.
  property var versions: ({})
  property var pendingVersions: ({})

  property int launchSerial: 0
  property int launchToplevelCount: 0
  property var launchActiveToplevel: null
  // True while the launch OSD is on screen. It outlives the launch that opened
  // it: closeLaunchFeedback() normally takes it down, and its own duration
  // (the rest of launchTimeout) dismisses it if a show lands after that close.
  property bool launchOsdOpen: false
  property string launchOsdMessage: ""

  // Emitted whenever the visible application set may have changed: desktop
  // entries appeared or vanished, or the hidden-entry filters reloaded.
  signal appsChanged()

  // Emitted when removing an entry has to open a terminal (a package
  // uninstall asking for a password), so an open launcher can step aside.
  // Other removals happen in place and the entry just drops out of the list.
  signal removalNeedsTerminal()

  function entryName(entry) {
    return AppSearch.entryName(entry)
  }

  function entrySubtext(entry) {
    return AppSearch.entrySubtext(entry)
  }

  function isHiddenEntry(entry) {
    var id = String((entry && entry.id) || "")
    return root.configuredHiddenEntryIds[id] === true || root.desktopHiddenEntryIds[id] === true
  }

  function sortedEntries(query) {
    var values = DesktopEntries.applications.values || []
    return AppSearch.sortedEntries(values, query, function(entry) { return root.isHiddenEntry(entry) })
  }

  function iconSource(icon) {
    var value = String(icon || "")
    if (value.length === 0) return Quickshell.iconPath("application-x-executable", true)
    if (value.indexOf("file://") === 0 || value.indexOf("image://") === 0) return value
    if (value.charAt(0) === "/") return Util.fileUrl(value)
    // Prefer the context-limited app/device index. An unconstrained themed
    // lookup can resolve an app name such as "zoom" to an action icon instead.
    var found = root.iconIndex[value]
    var revision = root.themeRevision
    if (found) return Util.fileUrl(found) + (found.indexOf(root.userIconsPath) === 0 ? "?theme=" + revision : "")
    var themed = Quickshell.iconPath(value, true)
    if (themed.length > 0) return themed
    return Quickshell.iconPath("application-x-executable", true)
  }

  // The shell may start before first-install packages have finished placing
  // their icons; consumers call this when they open so icons appear live.
  // A request during a scan queues one more, since the running scan may have
  // listed icons before they changed.
  function refreshIcons() {
    if (iconIndexScan.running) root.iconRescanQueued = true
    else iconIndexScan.running = true
  }

  function refreshDesktopEntries() {
    if (desktopEntryScan.running) root.desktopEntryRescanQueued = true
    else desktopEntryScan.running = true
  }

  function refreshVersions() {
    if (!versionScan.running) versionScan.running = true
  }

  function version(entry) {
    return String(root.versions[String((entry && entry.id) || "")] || "")
  }

  function launch(desktopId, name) {
    var id = String(desktopId || "")
    if (!id) return
    root.beginLaunchFeedback(name)
    // A terminal app goes through Omarchy's TUI launcher, which names its
    // terminal window after the command (org.omarchy.nvim), so the dock and
    // titlebars can tell Neovim from the terminal it runs in.
    var command = root.terminalCommand(DesktopEntries.byId(id))
    if (command.length > 0) {
      Util.execArgv(["omarchy-launch-tui"].concat(command))
      return
    }
    // Start gtk-launch inside a scope under app-graphical.slice so apps do not
    // inherit wayland-wm@.service. Keeping gtk-launch as the desktop-entry
    // resolver supports IDs with spaces and entries that UWSM rejects.
    // Keep the .desktop suffix or ids like org.telegram.desktop won't resolve.
    Util.execArgv(["uwsm-app", "--", "gtk-launch", "--", id + ".desktop"])
  }

  // The command a terminal entry runs, without the field codes it leaves for a
  // launcher to fill in; empty for an entry that is not run in a terminal.
  function terminalCommand(entry) {
    if (!entry || !entry.runInTerminal) return []
    return (entry.command || []).filter(function(word) { return !/^%[a-zA-Z]$/.test(String(word)) })
  }

  function remove(desktopId, name) {
    var id = String(desktopId || "")
    if (!id) return
    // The login shell gives the removal commands the session PATH.
    removal.createObject(root, {
      command: ["bash", "-lc", 'exec "$@"', "bash", root.omarchyPath + "/bin/omarchy-remove-launcher-entry", id, String(name || id)],
      running: true
    })
  }

  Component {
    id: removal

    Process {
      stdout: SplitParser {
        onRead: function(line) { if (line === "terminal") root.removalNeedsTerminal() }
      }
      onExited: destroy()
    }
  }

  function normalizeDesktopId(id) {
    var value = String(id || "").trim()
    if (value.slice(-8) === ".desktop") value = value.slice(0, -8)
    return value
  }

  function loadConfiguredHides(rawText) {
    var next = ({})
    var lines = String(rawText || "").split(/\n/)
    for (var i = 0; i < lines.length; i++) {
      var id = root.normalizeDesktopId(lines[i])
      if (id.length > 0) next[id] = true
    }
    root.configuredHiddenEntryIds = next
    root.appsChanged()
  }

  function loadDesktopEntryScan(rawText) {
    var hidden = ({})
    var dockClicks = ({})
    var lines = String(rawText || "").split(/\n/)
    for (var i = 0; i < lines.length; i++) {
      var fields = lines[i].split("\t")
      var id = root.normalizeDesktopId(fields[fields.length - 1])
      if (id.length === 0) continue
      if (fields[0] === "hidden") hidden[id] = true
      else if (fields[0] === "dock-click") dockClicks[id] = fields[1]
    }
    root.desktopHiddenEntryIds = hidden
    root.dockClickModes = dockClicks
    root.appsChanged()
  }

  function dockClickMode(desktopId) {
    return root.dockClickModes[root.normalizeDesktopId(desktopId)] || ""
  }

  function iconIndexScanCommand() {
    // List one winning app/device icon per basename across the XDG icon dirs
    // and /usr/share/pixmaps as "<path>" lines. Some desktop entries, such as
    // Print Settings, use device icons like "printer" instead of app icons.
    // Deduplicating in awk keeps SVG ahead of PNG, preserves XDG directory
    // precedence, picks the largest PNG size within a directory, and avoids
    // streaming thousands of shadowed duplicates into QML.
    return [
      'dirs=("$HOME/.icons" "${XDG_DATA_HOME:-$HOME/.local/share}/icons");',
      'IFS=":" read -ra xdg_dirs <<< "${XDG_DATA_DIRS:-/usr/local/share:/usr/share}";',
      'for d in "${xdg_dirs[@]}"; do [[ -n $d ]] && dirs+=("$d/icons"); done;',
      '{',
      '  for base in "${dirs[@]}"; do',
      '    [[ -d $base ]] && find "$base" \\( -path "*/apps/*" -o -path "*/devices/*" \\) \\( -name "*.svg" -o -name "*.png" \\) 2>/dev/null;',
      '    echo;',
      '  done;',
      '  find /usr/share/pixmaps -maxdepth 1 \\( -name "*.svg" -o -name "*.png" \\) 2>/dev/null;',
      '} | awk \'',
      '!length { dir++; next }',
      '{',
      '  name = $0; sub(/^.*\\//, "", name); sub(/\\.[^.]+$/, "", name);',
      '  if (!length(name)) next;',
      '  is_png = !/\\.svg$/;',
      '  sz = is_png && match($0, /\\/[0-9]+x[0-9]+[@\\/]/) ? substr($0, RSTART + 1) + 0 : 0;',
      '  if (!(name in best)) {',
      '    order[++count] = name;',
      '    best[name] = $0; best_png[name] = is_png; best_dir[name] = dir; best_sz[name] = sz;',
      '  } else if (!is_png) {',
      '    if (best_png[name]) { best[name] = $0; best_png[name] = 0; best_dir[name] = dir; best_sz[name] = 0 }',
      '  } else if (best_png[name] && (dir < best_dir[name] || (dir == best_dir[name] && sz > best_sz[name]))) {',
      '    best[name] = $0; best_dir[name] = dir; best_sz[name] = sz;',
      '  }',
      '}',
      'END {',
      '  for (i = 1; i <= count; i++) if (!best_png[order[i]]) print best[order[i]];',
      '  for (i = 1; i <= count; i++) if (best_png[order[i]]) print best[order[i]];',
      '}\''
    ].join(' ')
  }

  function indexIconLine(path) {
    var value = String(path || "").trim()
    if (value.length === 0) return
    var slash = value.lastIndexOf("/")
    var file = slash >= 0 ? value.slice(slash + 1) : value
    var dot = file.lastIndexOf(".")
    var name = dot > 0 ? file.slice(0, dot) : file
    if (name.length > 0 && root.pendingIconIndex[name] === undefined)
      root.pendingIconIndex[name] = value
  }

  function desktopEntryScanCommand() {
    var desktop = [Quickshell.env("XDG_CURRENT_DESKTOP"), Quickshell.env("XDG_SESSION_DESKTOP"), Quickshell.env("DESKTOP_SESSION")].filter(function(v) { return String(v || "").length > 0 }).join(":")
    var script = root.omarchyPath + "/shell/services/desktop-entries.sh"
    return Util.shellQuote(script) + " " + Util.shellQuote(desktop)
  }

  function toplevelCount() {
    try { return ToplevelManager.toplevels.values.length } catch (e) { return 0 }
  }

  function beginLaunchFeedback(name) {
    root.launchSerial++
    root.launchToplevelCount = root.toplevelCount()
    root.launchActiveToplevel = ToplevelManager.activeToplevel
    root.launchOsdMessage = name ? I18n.t("appLibrary.launching").arg(String(name)) : I18n.t("appLibrary.launchingApp")
    launchDelay.restart()
    launchTimeout.restart()
  }

  function closeLaunchFeedback(serial) {
    if (serial !== root.launchSerial) return
    launchDelay.stop()
    launchTimeout.stop()
    if (root.launchOsdOpen) {
      if (root.shell) root.shell.hide("omarchy.osd")
      root.launchOsdOpen = false
    }
  }

  function maybeFinishLaunchFeedback() {
    if (!launchDelay.running && !launchTimeout.running && !root.launchOsdOpen) return
    if (root.toplevelCount() <= root.launchToplevelCount && ToplevelManager.activeToplevel === root.launchActiveToplevel) return
    root.closeLaunchFeedback(root.launchSerial)
  }

  QtObject {
    id: desktopEntryOutput
    property string text: ""
  }

  // Both scans must run in non-login shells. A login shell sources the user's
  // profile, and tools like mise touch ~/.local/share on activation — a
  // directory the desktop-entry watcher monitors — so every scan would
  // trigger the next one, pinning a core at idle.
  Process {
    id: desktopEntryScan
    command: ["bash", "-c", root.desktopEntryScanCommand()]
    stdout: SplitParser { onRead: function(line) { desktopEntryOutput.text += line + "\n" } }
    onStarted: desktopEntryOutput.text = ""
    onExited: {
      root.loadDesktopEntryScan(desktopEntryOutput.text)
      if (root.desktopEntryRescanQueued) {
        root.desktopEntryRescanQueued = false
        running = true
      }
    }
  }

  Process {
    id: iconIndexScan
    command: ["bash", "-c", root.iconIndexScanCommand()]
    stdout: SplitParser { onRead: function(line) { root.indexIconLine(line) } }
    onStarted: root.pendingIconIndex = ({})
    // Swapping the property re-evaluates every iconSource() binding, so
    // newly found icons appear without rebuilding the list.
    onExited: {
      root.iconIndex = root.pendingIconIndex
      if (root.iconRescanQueued) {
        root.iconRescanQueued = false
        running = true
      }
    }
  }

  Process {
    id: versionScan
    command: [root.omarchyPath + "/bin/omarchy-launch-versions"]
    stdout: SplitParser {
      onRead: function(line) {
        var tab = line.indexOf("\t")
        if (tab > 0) root.pendingVersions[line.slice(0, tab)] = line.slice(tab + 1)
      }
    }
    onStarted: root.pendingVersions = ({})
    onExited: root.versions = root.pendingVersions
  }

  // Coalesces bursts of app-list changes (a package install touches many
  // entries) into a single rescan.
  Timer {
    id: iconIndexDebounce
    interval: 750
    onTriggered: root.refreshIcons()
  }

  FileView {
    path: root.home + "/.local/state/omarchy/current/icons.revision"
    watchChanges: true
    preload: true
    printErrors: false
    onFileChanged: reload()
    onLoadFailed: root.iconsRevisionInitialized = true
    onLoaded: {
      var parts = String(text() || "").trim().split(/\s+/)
      var linksRev = parts.length >= 2 ? parts[1] : ""
      if (!root.iconsRevisionInitialized) {
        root.iconsRevisionInitialized = true
        root.lastLinksRevision = linksRev
        return
      }
      root.themeRevision++
      // Theme switches redraw existing icon files in place; only rescan the
      // icon tree when the link-change revision advances (or if an older writer
      // omitted it, or the index has not been populated yet).
      if (linksRev === "" || linksRev !== root.lastLinksRevision || Object.keys(root.iconIndex).length === 0) {
        root.lastLinksRevision = linksRev
        root.refreshIcons()
      }
    }
  }

  FileView {
    path: root.omarchyPath + "/default/omarchy/launcher.hides"
    watchChanges: true
    printErrors: false
    onLoaded: root.loadConfiguredHides(text())
    onFileChanged: reload()
    onLoadFailed: root.loadConfiguredHides("")
  }

  Connections {
    target: ToplevelManager.toplevels
    function onValuesChanged() { root.maybeFinishLaunchFeedback() }
  }

  Connections {
    target: ToplevelManager
    function onActiveToplevelChanged() { root.maybeFinishLaunchFeedback() }
  }

  Timer {
    id: launchDelay
    interval: 2000
    onTriggered: {
      if (root.toplevelCount() > root.launchToplevelCount || ToplevelManager.activeToplevel !== root.launchActiveToplevel) return
      if (!root.shell) return
      root.launchOsdOpen = true
      root.shell.summon("omarchy.osd", JSON.stringify({ icon: "󱓞", message: root.launchOsdMessage, duration: launchTimeout.interval - launchDelay.interval }))
    }
  }

  Timer {
    id: launchTimeout
    interval: 15000
    onTriggered: root.closeLaunchFeedback(root.launchSerial)
  }

  Connections {
    target: DesktopEntries.applications
    function onValuesChanged() {
      root.refreshDesktopEntries()
      iconIndexDebounce.restart()
      root.appsChanged()
    }
  }

  Component.onCompleted: {
    desktopEntryScan.running = true
    iconIndexScan.running = true
  }
}
