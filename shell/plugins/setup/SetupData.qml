import QtQuick
import Quickshell
import Quickshell.Io
import qs.Commons
import qs.Commons as Commons
import "../menu/MenuModel.js" as MenuModel
import "SetupModel.js" as SetupModel

// What the Welcome tour reads from the system: the menu entries for layout,
// dictation and Tailscale, their guard answers, the default agent, and the
// local model omarchy-models recommends for this hardware. Nothing polls, and
// opening Welcome never mutates the machine.
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
  // Superwhisper's active processing mode ("cloud", "offline", or "").
  property string dictationMode: ""
  // The default agent as `omarchy default agent` writes it; empty until chosen.
  property string defaultAgent: ""
  // Whether the agents panel has an IPC handler ready to open. Sampled once as
  // the tour leaves Splash and frozen for the duration of that tour.
  property bool agentsPanel: false

  property bool defaultSettled: false
  property bool userSettled: false
  property bool catalogSettled: false
  property bool guardsSettled: false
  property bool guardsPending: false
  property bool localSettled: false
  property bool dictationModeSettled: false
  property bool agentSettled: false

  readonly property bool ready: defaultSettled && userSettled && catalogSettled && guardsSettled && localSettled && dictationModeSettled && agentSettled
  readonly property var offers: SetupModel.localOffers(localList)
  readonly property var offer: offers.length > 0 ? offers[0] : null
  // Frozen snapshot of the tour's steps once Splash transitions into the tour,
  // or kept empty while on Splash; language changes still relabel live.
  property bool frozen: false
  property bool frozenAgentsPanel: false
  readonly property var steps: SetupModel.tourSteps(
    items, order, guards, offers,
    { panel: frozen ? frozenAgentsPanel : agentsPanel, chosen: defaultAgent },
    Commons.I18n.t,
    dictationMode
  )

  function freezeAgents(panelThere) {
    agentsPanel = panelThere
    frozenAgentsPanel = panelThere
    frozen = true
  }

  property int generation: 0
  property bool localPending: false
  property bool dictationModePending: false

  // Re-reads live system state if Welcome is summoned again while already open.
  // Bumping `generation` ensures an in-flight guard or model process from the
  // previous opening cannot mark the new opening ready with stale answers.
  function reload() {
    generation++
    frozen = false
    defaultSettled = false
    userSettled = false
    guardsSettled = false
    localSettled = false
    dictationModeSettled = false
    agentSettled = false
    defaultAgent = ""
    dictationMode = ""
    defaultMenuFile.reload()
    userMenuFile.reload()
    agentFile.reload()
    if (localProc.running) {
      localPending = true
    } else {
      localProc.gen = generation
      localProc.running = true
    }
    if (dictationModeProc.running) {
      dictationModePending = true
    } else {
      dictationModeProc.gen = generation
      dictationModeProc.running = true
    }
  }

  function rebuild(labelsOnly) {
    var merged = MenuModel.mergeMenuSources(MenuModel.applyTranslations(defaultItems, catalog), userItems, "")
    items = merged.items
    order = merged.itemOrder
    if (!labelsOnly && defaultSettled && userSettled) evaluateGuards()
  }

  // One bash batch answers only the guards the tour's menu rows need.
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
    guardProc.gen = root.generation
    guardProc.collected = ""
    guardProc.command = ["bash", "-lc", script]
    guardProc.running = true
  }

  Process {
    id: guardProc
    property int gen: 0
    property var asked: ({})
    property string collected: ""
    stdout: SplitParser {
      onRead: function(data) { guardProc.collected += data + "\n" }
    }
    onExited: function(exitCode, exitStatus) {
      var fresh = guardProc.gen === root.generation && root.defaultSettled && root.userSettled
      if (fresh) {
        var answers = SetupModel.parseGuards(guardProc.collected)
        if (exitCode !== 0 || exitStatus !== 0 || !SetupModel.answeredAll(guardProc.asked, answers)) answers.partial = true
        root.guards = answers
      }
      if (root.guardsPending) {
        Qt.callLater(function() { root.evaluateGuards() })
      } else if (fresh) {
        root.guardsSettled = true
      } else if (root.defaultSettled && root.userSettled) {
        Qt.callLater(function() { root.evaluateGuards() })
      }
    }
  }

  FileView {
    id: defaultMenuFile
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
    id: userMenuFile
    path: root.home + "/.config/omarchy/extensions/omarchy-menu.jsonc"
    printErrors: false
    onLoaded: {
      root.userItems = MenuModel.keepMenuRows(root.userItems, text(), false)
      root.userSettled = true
      root.rebuild(false)
    }
    onLoadFailed: {
      root.userItems = []
      root.userSettled = true
      root.rebuild(false)
    }
  }

  FileView {
    path: root.omarchyPath + "/default/i18n/" + Commons.I18n.language + "/menu.json"
    printErrors: false
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

  FileView {
    id: agentFile
    path: root.home + "/.config/omarchy/defaults/agent"
    printErrors: false
    onLoaded: {
      root.defaultAgent = text().split("\n")[0].trim()
      root.agentSettled = true
    }
    onLoadFailed: {
      root.defaultAgent = ""
      root.agentSettled = true
    }
  }

  Process {
    id: localProc
    property int gen: 0
    command: ["bash", "-c", "exec omarchy-models list --json 2>/dev/null"]
    running: true
    stdout: StdioCollector {
      waitForEnd: true
      onStreamFinished: {
        var fresh = localProc.gen === root.generation
        if (fresh) root.localList = text
        if (root.localPending || !fresh) {
          root.localPending = false
          Qt.callLater(function() {
            localProc.gen = root.generation
            localProc.running = true
          })
        } else {
          root.localSettled = true
        }
      }
    }
  }

  Process {
    id: dictationModeProc
    property int gen: 0
    command: ["bash", "-c", "omarchy-cmd-present superwhisper && exec superwhisper models show 2>/dev/null || true"]
    running: true
    stdout: StdioCollector {
      waitForEnd: true
      onStreamFinished: {
        var fresh = dictationModeProc.gen === root.generation
        if (fresh) root.dictationMode = SetupModel.parseSuperwhisperMode(text)
        if (root.dictationModePending || !fresh) {
          root.dictationModePending = false
          Qt.callLater(function() {
            dictationModeProc.gen = root.generation
            dictationModeProc.running = true
          })
        } else {
          root.dictationModeSettled = true
        }
      }
    }
  }
}
