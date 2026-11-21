pragma Singleton
import QtQuick
import Quickshell
import "AppMatchModel.js" as Model

// Which installed app an app id (a window class) belongs to. It lives here,
// rather than with the dock or the app library, so the dock, a cloned dock
// and the menu's app: icons all match the same way, with or without the
// shell's app library.
Singleton {
  id: root

  // Entries that can claim a terminal app's window: those run in a terminal,
  // and those that hand the terminal an app id of their own.
  readonly property var terminalEntries: {
    var values = DesktopEntries.applications.values
    var out = []
    for (var i = 0; i < values.length; i++) {
      var entry = values[i]
      if (entry.runInTerminal || String(entry.execString || "").indexOf("--app-id=") >= 0)
        out.push({ id: entry.id, execString: entry.execString, command: entry.command, runInTerminal: entry.runInTerminal })
    }
    return out
  }

  // Quickshell's own lookup, then the terminal entry that launched it
  // (org.omarchy.nvim is Neovim, TUI.tile is Docker).
  function entryForAppId(appId) {
    var entry = DesktopEntries.heuristicLookup(appId)
    if (entry) return entry
    var id = Model.claimingEntryId(appId, root.terminalEntries)
    return id ? DesktopEntries.byId(id) : null
  }
}
