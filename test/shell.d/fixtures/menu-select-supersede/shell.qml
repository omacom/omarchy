import QtQuick
import Quickshell

// Displacing a real Menu.qml request must write its completion file so the
// waiting command exits, including when keybindings take over the surface.
ShellRoot {
  id: root

  readonly property string resultPath: Quickshell.env("OMARCHY_QML_TEST_RESULT")
  readonly property string scratchDir: Quickshell.env("OMARCHY_MENU_TMP")
  property var menu: null
  property var failures: []

  function fail(message) {
    failures.push(String(message))
  }

  function assertTrue(condition, message) {
    if (!condition) fail(message)
  }

  function shellQuote(value) {
    return "'" + String(value).replace(/'/g, "'\\''") + "'"
  }

  function writeResult() {
    var payload = JSON.stringify({
      ok: failures.length === 0,
      failures: failures
    })

    if (resultPath) {
      Quickshell.execDetached(["bash", "-lc", "printf '%s' " + shellQuote(payload) + " > " + shellQuote(resultPath)])
    }
  }

  function selectPayload(prompt, name) {
    return JSON.stringify({
      mode: "select",
      prompt: prompt,
      options: ["alpha", "bravo"],
      selectionFile: scratchDir + "/sel-" + name,
      doneFile: scratchDir + "/done-" + name
    })
  }

  Timer {
    id: driver
    interval: 100
    repeat: true
    running: true
    property int tick: 0

    onTriggered: {
      try {
        tick += 1

        if (tick === 1) {
          var component = Qt.createComponent("file://" + Quickshell.env("OMARCHY_PATH") + "/shell/plugins/menu/Menu.qml", Component.PreferSynchronous)
          if (component.status !== Component.Ready) {
            root.fail("Menu.qml failed to load: " + component.errorString())
            root.finish()
            return
          }
          root.menu = component.createObject(null)
          if (!root.menu) {
            root.fail("Menu.qml failed to instantiate")
            root.finish()
            return
          }
        }

        // Scenario A: a live select request is superseded by the regular menu.
        if (tick === 3) {
          root.menu.open(root.selectPayload("A", "a"))
          root.assertTrue(root.menu.requestActive === true, "select A becomes the active request")
          root.assertTrue(root.menu.dmenuActive === true, "select A puts the menu into dmenu mode")
          root.menu.openExistingMenu("root")
          root.assertTrue(root.menu.mode === "menu", "the regular menu takes over from select A")
        }

        // Scenario B: several requests opened back-to-back with no delay in
        // between, so b, c and d are displaced synchronously — possibly while
        // an earlier completion write is still spawning. Their done files must
        // all land anyway.
        if (tick === 12) {
          root.menu.open(root.selectPayload("B", "b"))
          root.assertTrue(root.menu.requestActive === true, "select B becomes the active request")
          root.menu.open(root.selectPayload("C", "c"))
          root.menu.open(root.selectPayload("D", "d"))
          root.menu.open(root.selectPayload("E", "e"))
          root.assertTrue(root.menu.doneFile === root.scratchDir + "/done-e", "select E holds the live request afterwards")
          root.menu.applyDmenuSelection("bravo")
        }

        // Scenario C: the native keybindings menu replaces a live select.
        if (tick === 20) {
          root.menu.open(root.selectPayload("F", "f"))
          root.menu.open(JSON.stringify({ mode: "keybindings" }))
          root.assertTrue(root.menu.mode === "keybindings", "keybindings take over from select F")
          root.assertTrue(!root.menu.requestActive, "keybindings clear the old request")
        }

        if (tick === 28) {
          root.assertTrue(root.menu.opened, "completion writes leave the replacement menu open")
          root.finish()
        }
      } catch (error) {
        root.fail("menu supersede fixture threw: " + error)
        root.finish()
      }
    }
  }

  function finish() {
    driver.running = false
    // Result first, quit later: execDetached spawns asynchronously, and an
    // immediate Qt.quit() can win the race and leave the result unwritten.
    root.writeResult()
    quitDelay.restart()
  }

  Timer {
    id: quitDelay
    interval: 500
    repeat: false
    onTriggered: Qt.quit()
  }
}
