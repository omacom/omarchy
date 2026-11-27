import QtQuick
import QtTest
import Quickshell
import Quickshell.Io
import "plugins/menu/MenuModel.js" as MenuModel
import "plugins/setup" as Setup
import "plugins/setup/SetupModel.js" as SetupModel

// Exercises the Welcome OOBE card with keys and pointer events off-screen:
// Splash gating of aboutToList, resting pointer suppression, choice card
// arrows/Space/Enter, toggle card Space/Left/Right idempotence, Tab focus
// cycling, stepViewed tracking for agent & ready, and scroll stability under click.
ShellRoot {
  id: root

  readonly property string tiling: "appearance.workspace-layout.dwindle"
  readonly property string scrolling: "appearance.workspace-layout.scrolling"
  readonly property string floating: "appearance.workspace-layout.floating"
  readonly property var guards: ({
    when: ({}),
    checked: ({ "appearance.workspace-layout.dwindle": true, "setup.default.dictation.superwhisper": true }),
    disabled: ({})
  })
  property var menu: ({ items: ({}), itemOrder: [] })
  property var failures: []
  property string finished: ""
  property point at
  property real was: 0
  property int listed: 0
  property bool panel: false
  property var viewed: []
  property var steps: []
  property int step: 0
  readonly property int settle: 300

  function check(condition, message) {
    if (!condition) failures = failures.concat([String(message)])
  }

  function key(code) {
    card.handleKey({ key: code, text: "", modifiers: 0, isAutoRepeat: false })
  }

  function cards(item, found) {
    found = found || []
    if (item.chosen !== undefined && item.modelData !== undefined) found.push(item)
    for (var i = 0; i < item.children.length; i++) cards(item.children[i], found)
    return found
  }

  function cardFor(id) {
    return cards(card).filter(function(option) { return option.modelData.id === id })[0]
  }

  function toggleItem(item) {
    item = item || card
    if (item.enabled !== undefined && item.toggled !== undefined && item.meta !== undefined) return item
    for (var i = 0; i < item.children.length; i++) {
      var found = toggleItem(item.children[i])
      if (found) return found
    }
    return null
  }

  function list(item) {
    item = item || card
    if (item.contentY !== undefined && item.fade !== undefined) return item
    for (var i = 0; i < item.children.length; i++) {
      var found = list(item.children[i])
      if (found) return found
    }
    return null
  }

  function middle(item) {
    return item.mapToItem(card.parent, item.width / 2, item.height / 2)
  }

  function ids(property) {
    return JSON.stringify(cards(card).filter(function(option) { return option[property] }).map(function(option) { return option.modelData.id }))
  }

  function agree(id, layout, when) {
    var plan = layout === "" ? "" : "omarchy-setup-essentials --layout " + layout
    var drawn = card.pickedOption ? card.pickedOption.id : null
    check(ids("chosen") === JSON.stringify([id]), when + ": chosen cards are " + ids("chosen") + ", not " + JSON.stringify(id))
    check(drawn === id, when + ": preview is " + JSON.stringify(drawn) + ", not " + JSON.stringify(id))
    check(card.plan.argv.join(" ") === plan, when + ": Finish would run '" + card.plan.argv.join(" ") + "', not '" + plan + "'")
  }

  function lit(expected, when) {
    check(ids("hovered") === JSON.stringify(expected), when + ": lit cards are " + ids("hovered"))
  }

  FloatingWindow {
    implicitWidth: 860
    implicitHeight: 680

    Setup.SetupCard {
      id: card
      anchors.centerIn: parent
      steps: SetupModel.tourSteps(root.menu.items, root.menu.itemOrder, root.guards, null, { panel: root.panel, chosen: "" }, null)
      ready: root.menu.itemOrder.length > 0
      onFinished: function(argv) { root.finished = argv.join(" ") }
      onStepViewed: function(stepId) { root.viewed = root.viewed.concat([stepId]) }
    }
  }

  TestCase {
    id: pointer
    name: "setup-tour"
    when: false
  }

  Connections {
    target: card
    function onAboutToList() {
      root.listed++
      root.panel = true
    }
  }

  FileView {
    id: result
    path: Quickshell.env("OMARCHY_QML_TEST_RESULT")
    preload: false
  }

  FileView {
    path: Quickshell.env("OMARCHY_PATH") + "/default/omarchy/omarchy-menu.jsonc"
    onLoaded: {
      var more = {}
      for (var i = 10; i < 42; i++) more["setup.default.dictation.more" + i] = { label: "More " + i, action: "omarchy-default-dictation more" + i }
      root.menu = MenuModel.mergeMenuSources(MenuModel.parseMenuJsonc(text()), MenuModel.parseMenuJsonc(JSON.stringify(more)), "")
      stepper.start()
    }
    onLoadFailed: {
      root.check(false, "the shipped menu could not be read")
      root.steps = []
      stepper.start()
    }
  }

  Component.onCompleted: {
    steps = [
      [function() {
        card.start()
        root.check(root.listed === 0, "Splash lists nothing yet: " + root.listed)
        root.key(Qt.Key_Return)
        root.check(root.listed === 1, "leaving Splash lists steps once: " + root.listed)
        root.check(card.step && card.step.id === "layout", "first step is layout")
      }, root.settle],

      // Reopen tour with pointer resting where Floating will appear as the card grows in.
      [function() {
        root.at = root.middle(root.cardFor(root.floating))
        root.viewed = []
        card.start()
        card.scale = 0.97
        pointer.mouseMove(card.parent, root.at.x, root.at.y)
        root.key(Qt.Key_Return)
      }, root.settle],

      [function() {
        card.scale = 1
        pointer.mouseMove(card.parent, root.at.x, root.at.y)
        root.agree(root.tiling, "", "layout opens on current choice")
        root.lit([], "resting pointer lights nothing on open")

        pointer.mouseMove(card.parent, root.at.x + 8, root.at.y + 4)
        root.lit([root.floating], "moving pointer lights card")
        root.agree(root.tiling, "", "hovering picks nothing")

        root.key(Qt.Key_Right)
        root.agree(root.scrolling, "scrolling", "Right arrow picks scrolling")
        root.lit([], "arrow clears pointer hover")

        root.listed = 0
        root.key(Qt.Key_Space)
        root.check(card.stepIndex === 0, "Space stays on a choice step")
        root.key(Qt.Key_Return)
        root.check(card.step && card.step.id === "dictation", "Enter advances to dictation")
        root.key(Qt.Key_Backspace)
        root.agree(root.scrolling, "scrolling", "Backspace returns with staged pick intact")
        root.check(root.listed === 0, "stepping does not re-list: " + root.listed)
      }, root.settle],

      // Click Floating, then advance to Agent toggle step and test Space/Left/Right/click.
      [function() {
        pointer.mouseClick(card.parent, root.at.x, root.at.y)
        root.agree(root.floating, "floating", "click picks Floating")

        // Advance past dictation to agent.
        root.key(Qt.Key_Return)
        root.key(Qt.Key_Return)
        root.check(card.step && card.step.id === "agent", "third step is agent: " + (card.step ? card.step.id : null))
        root.check(root.viewed.indexOf("agent") !== -1, "stepViewed fired for agent")
        root.check(!card.toggleEnabled, "toggle step starts off")

        root.key(Qt.Key_Right)
        root.check(card.toggleEnabled, "Right turns toggle on")
        root.key(Qt.Key_Right)
        root.check(card.toggleEnabled, "Right again stays on (idempotent)")
        root.key(Qt.Key_Left)
        root.check(!card.toggleEnabled, "Left turns toggle off")
        root.key(Qt.Key_Space)
        root.check(card.toggleEnabled, "Space flips toggle on")
      }, root.settle],

      // Click the toggle card directly to flip it off, then test Tab focus and Finish.
      [function() {
        var tog = root.toggleItem()
        root.check(!!tog, "toggle card exists")
        var spot = root.middle(tog)
        pointer.mouseClick(card.parent, spot.x, spot.y)
        root.check(!card.toggleEnabled, "clicking toggle card flips it off")

        // Tab moves focus from control -> continue; Enter advances.
        root.key(Qt.Key_Tab)
        root.check(card.focusZone === "continue", "Tab moves focus to continue: " + card.focusZone)
        root.key(Qt.Key_Return)
        root.check(card.step && card.step.id === "tailscale", "Enter on continue advances to tailscale")

        // Advance to Ready and finish.
        root.key(Qt.Key_Return)
        root.check(card.onSummary, "Enter advances to Ready")
        root.check(root.viewed.indexOf("ready") !== -1, "stepViewed fired for ready")
        root.key(Qt.Key_Return)
        root.check(root.finished === "omarchy-setup-essentials --layout floating", "Finish runs '" + root.finished + "'")

        // Reopen and jump to dictation (which has >30 options) to verify scroll stability under click.
        card.start()
        card.goToStep(card.steps.map(function(s) { return s.id }).indexOf("dictation"))
        root.check(card.step && card.step.id === "dictation", "dictation step open")
      }, root.settle],

      [function() {
        var options = root.list()
        var under = root.cards(card).filter(function(option) {
          var y = option.mapToItem(options, 0, option.height / 2).y
          return y > 0 && y < options.height
        }).pop()
        var spot = root.middle(under)
        root.check(options.contentHeight > options.height, "dictation list scrolls with extension rows")
        root.was = options.contentY
        pointer.mousePress(card.parent, spot.x, spot.y)
        root.key(Qt.Key_Down)
        pointer.mouseRelease(card.parent, spot.x, spot.y)
        root.check(root.ids("chosen") === JSON.stringify([under.modelData.id]), "click picks clicked card: " + root.ids("chosen"))
      }, root.settle],

      [function() {
        root.check(root.list().contentY === root.was, "clicked card stays put: " + root.was + " -> " + root.list().contentY)
      }, 1]
    ]
  }

  Timer {
    id: stepper
    interval: 10
    onTriggered: {
      if (root.step >= root.steps.length) {
        result.setText(JSON.stringify({ ok: root.failures.length === 0, failures: root.failures }))
        return
      }
      var current = root.steps[root.step++]
      try {
        current[0]()
      } catch (e) {
        root.check(false, "step " + root.step + " threw: " + e)
      }
      interval = current[1]
      restart()
    }
  }
}
