import QtQuick
import QtTest
import Quickshell
import Quickshell.Io
import "plugins/menu/MenuModel.js" as MenuModel
import "plugins/setup" as Setup
import "plugins/setup/SetupModel.js" as SetupModel

// Walks the welcome tour with its keys and a pointer, over the shipped menu,
// and holds each step to one pick: the card that is marked, the option the
// picture is of and what Finish would set up. The pointer may light a card,
// and moves none of those until it clicks. Then what must stay put: the list
// under a pointer that has just clicked, the list when the card it was on its
// way to has lost its mark, and a page's cursor under a pointer at rest.
ShellRoot {
  id: root

  readonly property string tiling: "appearance.workspace-layout.dwindle"
  readonly property string scrolling: "appearance.workspace-layout.scrolling"
  readonly property string floating: "appearance.workspace-layout.floating"
  readonly property var guards: ({ when: ({}), checked: ({ "appearance.workspace-layout.dwindle": true }), disabled: ({}) })
  property var menu: ({ items: ({}), itemOrder: [] })
  property var failures: []
  property string finished: ""
  // Where the Floating card is in the window.
  property point at
  // Where a list was scrolled to, for the step that looks at it again.
  property real was: 0
  // How often the card has said its pages or steps are about to be listed.
  property int listed: 0
  // Whether the agents panel is there, which is answered as Setup answers it:
  // when the card says so, and so the pages change under that very call.
  property bool panel: false
  // Each step, and how long to wait after it: a step of the tour takes a
  // moment to lay its cards out.
  property var steps: []
  property int step: 0
  readonly property int settle: 300

  function check(condition, message) {
    if (!condition) failures = failures.concat([String(message)])
  }

  function key(code) {
    card.handleKey({ key: code, text: "", modifiers: 0, isAutoRepeat: false })
  }

  // The cards of the step on show.
  function cards(item, found) {
    found = found || []
    if (item.chosen !== undefined && item.modelData !== undefined) found.push(item)
    for (var i = 0; i < item.children.length; i++) cards(item.children[i], found)
    return found
  }

  function cardFor(id) {
    return cards(card).filter(function(option) { return option.modelData.id === id })[0]
  }

  // The list those cards scroll in.
  function list(item) {
    item = item || card
    if (item.contentY !== undefined && item.fade !== undefined) return item
    for (var i = 0; i < item.children.length; i++) {
      var found = list(item.children[i])
      if (found) return found
    }
    return null
  }

  // The middle of a card, in the window.
  function middle(option) {
    return option.mapToItem(card.parent, option.width / 2, option.height / 2)
  }

  function ids(property) {
    return JSON.stringify(cards(card).filter(function(option) { return option[property] }).map(function(option) { return option.modelData.id }))
  }

  function agree(id, layout, when) {
    var plan = layout === "" ? "" : "omarchy-setup-essentials --layout " + layout
    var drawn = card.cursorOption ? card.cursorOption.id : null
    check(ids("chosen") === JSON.stringify([id]), when + ": the cards marked are " + ids("chosen") + ", not " + JSON.stringify(id))
    check(drawn === id, when + ": the picture is of " + JSON.stringify(drawn) + ", not " + JSON.stringify(id))
    check(card.plan.argv.join(" ") === plan, when + ": Finish would run '" + card.plan.argv.join(" ") + "', not '" + plan + "'")
  }

  function lit(expected, when) {
    check(ids("hovered") === JSON.stringify(expected), when + ": the cards lit are " + ids("hovered"))
  }

  FloatingWindow {
    implicitWidth: 960
    implicitHeight: 680

    Setup.SetupCard {
      id: card
      anchors.centerIn: parent
      pages: SetupModel.pages(root.menu.items, root.menu.itemOrder, root.guards, null, { panel: root.panel, chosen: "" }, null, MenuModel.resolveRoute)
      steps: SetupModel.tourSteps(pages, null)
      ready: root.menu.itemOrder.length > 0
      onFinished: function(argv) { root.finished = argv.join(" ") }
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
      // Backends enough for dictation's list to scroll, whatever ships.
      var more = {}
      for (var i = 10; i < 50; i++) more["setup.default.dictation.more" + i] = { label: "More " + i, action: "omarchy-default-dictation more" + i }
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
        card.start("tour", "")
        root.check(root.listed === 0, "the tour's first screen lists nothing yet: " + root.listed)
        root.key(Qt.Key_Return)
        root.check(root.listed === 1, "its steps are about to be listed as it leaves that screen, once: " + root.listed)
      }, root.settle],

      // The tour again, as Setup opens it: a little small, to grow in. The
      // pointer is at rest where the Floating card will be.
      [function() {
        root.at = root.middle(root.cardFor(root.floating))
        card.start("tour", "")
        card.scale = 0.97
        pointer.mouseMove(card.parent, root.at.x, root.at.y)
        root.key(Qt.Key_Return)
      }, root.settle],

      [function() {
        // What a card arriving under a pointer at rest is sent.
        card.scale = 1
        pointer.mouseMove(card.parent, root.at.x, root.at.y)
        root.agree(root.tiling, "", "a step opens on what the machine has")
        root.lit([], "a card that opens under a pointer at rest")

        pointer.mouseMove(card.parent, root.at.x + 8, root.at.y + 4)
        root.lit([root.floating], "the pointer moving over a card")
        root.agree(root.tiling, "", "the pointer passing over a card picks nothing")

        root.key(Qt.Key_Right)
        root.agree(root.scrolling, "scrolling", "an arrow key picks the card it lands on")
        root.lit([], "an arrow key taking over from the pointer")
        pointer.mouseMove(card.parent, root.at.x, root.at.y)
        root.lit([root.floating], "the pointer moving again")

        root.listed = 0
        root.key(Qt.Key_Space)
        root.check(card.stepIndex === 0, "Space stays on the step")
        root.key(Qt.Key_Return)
        root.check(card.stepIndex === 1, "Enter moves on")
        root.agree("", "scrolling", "a step with nothing to keep opens on Not now")
        root.key(Qt.Key_Backspace)
        root.agree(root.scrolling, "scrolling", "a step gone back to has its pick as it was left")
        root.check(root.listed === 0, "going from step to step lists nothing afresh: " + root.listed)
      }, root.settle],

      [function() {
        pointer.mouseClick(card.parent, root.at.x, root.at.y)
        root.agree(root.floating, "floating", "a click picks the card under the pointer")

        for (var i = 0; i < 12 && !card.onSummary; i++) root.key(Qt.Key_Return)
        root.key(Qt.Key_Return)
        root.check(root.finished === "omarchy-setup-essentials --layout floating", "Finish runs '" + root.finished + "'")

        // On to the step with a long list, wherever it comes.
        card.start("tour", "")
        card.goToStep(card.steps.map(function(step) { return step.id }).indexOf("dictation"))
        root.check(card.page && card.page.id === "dictation", "dictation is one of the tour's steps")
      }, root.settle],

      // A click on the lowest card that shows, under the fade at the foot of
      // the list, while a scroll the keys asked for is on its way.
      [function() {
        var options = root.list()
        var under = root.cards(card).filter(function(option) {
          var y = option.mapToItem(options, 0, option.height / 2).y
          return y > 0 && y < options.height
        }).pop()
        var spot = root.middle(under)
        root.check(options.contentHeight > options.height, "dictation's list is long enough to scroll")
        root.was = options.contentY
        pointer.mousePress(card.parent, spot.x, spot.y)
        root.key(Qt.Key_Down)
        pointer.mouseRelease(card.parent, spot.x, spot.y)
        root.check(root.ids("chosen") === JSON.stringify([under.modelData.id]), "a click after a key picks the card under the pointer: " + root.ids("chosen"))
      }, root.settle],

      [function() {
        root.check(root.list().contentY === root.was, "a card just clicked stays under the pointer: the list went from " + root.was + " to " + root.list().contentY)

        // The same list as a page, asked for by name. The agent's page comes
        // in ahead of it as the card says its pages are about to be listed.
        root.listed = 0
        root.panel = false
        card.start("app", "dictation")
        root.check(root.listed === 1, "the pages are about to be listed as they open, once: " + root.listed)
        root.check(card.page && card.page.id === "dictation", "a page asked for by name is looked up among the pages as they then stand: " + (card.page ? card.page.id : null))
      }, root.settle],

      // The cursor is put on the last row and, before the list has followed,
      // the mark goes to the tour's link, as Tab takes it from the last page.
      [function() {
        card.cursor = root.cards(card).length - 1
        card.goToPage(card.pages.length)
        root.check(card.onTourLink && root.ids("marked") === "[]", "the mark has gone from the last row to the tour's link")
      }, root.settle],

      [function() {
        root.check(root.list().contentY === 0, "a card that has lost its mark is not scrolled to: the list went to " + root.list().contentY)

        // The pages from their first, which the pointer has not been on yet.
        card.start("app", "")
      }, root.settle],

      // A page as Setup opens it, growing in under a pointer at rest on a
      // row that is not the cursor's.
      [function() {
        var over = root.cardFor(root.floating)
        var spot = root.middle(over)
        var before = card.cursor
        card.scale = 0.97
        pointer.mouseMove(card.parent, spot.x, spot.y)
        card.scale = 0.985
        pointer.mouseMove(card.parent, spot.x, spot.y)
        card.scale = 1
        pointer.mouseMove(card.parent, spot.x, spot.y)
        root.check(card.cursor === before && before !== over.flat, "a page growing in under a pointer at rest keeps its cursor: " + card.cursor)
        pointer.mouseMove(card.parent, spot.x + 6, spot.y)
        root.check(card.cursor === over.flat, "the cursor goes to the pointer once it moves: " + card.cursor)
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
