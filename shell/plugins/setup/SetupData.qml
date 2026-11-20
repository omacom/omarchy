import QtQuick
import Quickshell
import Quickshell.Io
import qs.Commons
import qs.Commons as Commons
import "../menu/MenuModel.js" as MenuModel
import "SetupModel.js" as SetupModel

// What Setup reads from the system: the menu definition its pages are a lens
// over, the answers to that menu's guards, and the local model on offer. Each
// is asked for once, when Setup opens, and only asked: opening Setup must not
// change the machine it is about to describe. Nothing here polls.
Item {
  id: root

  property string omarchyPath: Quickshell.env("OMARCHY_PATH")
  readonly property string home: Quickshell.env("HOME")

  property var defaultItems: []
  property var userItems: []
  property var catalog: ({})
  property var items: ({})
  property var order: []
  property var guards: ({ when: ({}), checked: ({}), disabled: ({}) })
  property string localList: ""

  // Each source has answered once, found or not.
  property bool defaultSettled: false
  property bool userSettled: false
  property bool catalogSettled: false
  property bool guardsSettled: false
  property bool guardsPending: false
  property bool localSettled: false

  // Until all of them have, a row could show and then vanish, gain its check
  // late, or move as a page arrives above it, so nothing may be picked. The
  // translations count too: a page can be asked for by the name they give it.
  readonly property bool ready: defaultSettled && userSettled && catalogSettled && guardsSettled && localSettled
  readonly property var offer: SetupModel.localOffer(localList)
  readonly property var pages: SetupModel.pages(items, order, guards, offer, Commons.I18n.t, MenuModel.resolveRoute)
  readonly property var steps: SetupModel.tourSteps(pages, Commons.I18n.t)

  // Translations go on the shipped rows before the user's extension merges, as
  // in the menu, so a user's own rows and retitles win.
  function rebuild(labelsOnly) {
    var merged = MenuModel.mergeMenuSources(MenuModel.applyTranslations(defaultItems, catalog), userItems, "")
    items = merged.items
    order = merged.itemOrder
    if (!labelsOnly && defaultSettled && userSettled) evaluateGuards()
  }

  // One bash process answers every guard the pages read, as the menu's batch
  // does for the whole menu. A run in flight is waited for, not replaced.
  function evaluateGuards() {
    if (guardProc.running) {
      guardsPending = true
      return
    }
    guardsPending = false

    guardProc.asked = SetupModel.guardEntries(items, order)
    var script = MenuModel.guardScript(guardProc.asked)
    if (!script) {
      guardsSettled = true
      return
    }
    guardProc.collected = ""
    guardProc.command = ["bash", "-lc", script]
    guardProc.running = true
  }

  Process {
    id: guardProc
    // The entries this batch was asked about, to tell whether it answered.
    property var asked: ({})
    property string collected: ""
    stdout: SplitParser {
      onRead: function(data) { guardProc.collected += data + "\n" }
    }
    onExited: function(exitCode, exitStatus) {
      // A batch that broke off part way, a guard having exited its group's
      // subshell say, has answered only some rows. Those answers stand, and
      // `partial` has the pages leave out the rows it never got to. A signal
      // leaves the exit code at 0, and a guard that exits cleanly leaves the
      // status clean too, so the answers are counted as well.
      var answers = SetupModel.parseGuards(guardProc.collected)
      if (exitCode !== 0 || exitStatus !== 0 || !SetupModel.answeredAll(guardProc.asked, answers)) answers.partial = true
      root.guards = answers
      if (root.guardsPending) Qt.callLater(function() { root.evaluateGuards() })
      else root.guardsSettled = true
    }
  }

  FileView {
    path: root.omarchyPath + "/default/omarchy/omarchy-menu.jsonc"
    printErrors: false
    onLoaded: {
      root.defaultItems = MenuModel.keepMenuRows(root.defaultItems, text(), true)
      root.defaultSettled = true
      root.rebuild(false)
    }
    onLoadFailed: {
      root.defaultSettled = true
      root.rebuild(false)
    }
  }

  FileView {
    path: root.home + "/.config/omarchy/extensions/omarchy-menu.jsonc"
    printErrors: false
    onLoaded: {
      root.userItems = MenuModel.keepMenuRows(root.userItems, text(), false)
      root.userSettled = true
      root.rebuild(false)
    }
    onLoadFailed: {
      root.userSettled = true
      root.rebuild(false)
    }
  }

  FileView {
    path: root.omarchyPath + "/default/i18n/" + Commons.I18n.language + "/menu.json"
    printErrors: false
    // Settled only once the rows carry the names it gives them: being ready
    // is what lets a page be looked up by name.
    onLoaded: {
      root.catalog = Commons.I18n.parseCatalog(text())
      root.rebuild(true)
      root.catalogSettled = true
    }
    onLoadFailed: {
      root.catalog = ({})
      root.rebuild(true)
      root.catalogSettled = true
    }
  }

  // omarchy-local-ai's own listing of what fits this machine. Its `refresh`
  // would also republish shares and rewrite an agent's provider file; `list`
  // only works the listing out, and saves it where the engine keeps its own
  // copy, as it does whenever the agents panel asks. A machine without the
  // engine offers nothing. The stream closing is the answer, whatever came of
  // the run.
  Process {
    command: ["bash", "-c", "exec omarchy-agent-local list --json 2>/dev/null"]
    running: true
    stdout: StdioCollector {
      waitForEnd: true
      onStreamFinished: {
        root.localList = text
        root.localSettled = true
      }
    }
  }
}
