import QtQuick
import QtQuick.Controls
import Quickshell
import qs.Commons
import qs.Commons as Commons

// Renders the real agents panel and inspects its OpenCode Go sign-in form.
// The add command is stubbed by the test harness: it reports the Console
// instructions, then waits until cancelled. No browser opens and no key is
// requested or stored.
ShellRoot {
  id: test

  readonly property string resultPath: Quickshell.env("OMARCHY_QML_TEST_RESULT")
  readonly property string rootPath: Quickshell.env("OMARCHY_PATH")
  property var failures: []
  property var panel: null
  property var controls: ({})
  property int step: 0
  property int ticks: 0

  function fail(message) {
    failures.push(String(message))
  }

  function check(condition, message) {
    if (!condition) fail(message)
  }

  function findControls(item) {
    if (!item) return
    var name = String(item.objectName || "")
    if (["signInHeading", "signInStatus", "pasteInstructions", "pasteField"].indexOf(name) >= 0)
      controls[name] = item
    var children = item.children
    for (var i = 0; i < children.length; i++) findControls(children[i])
  }

  // The harness stops this fixture once the result lands (as with the
  // other fixtures): quitting here could exit before the detached writer
  // finishes and fail an otherwise passing test.
  function writeResult() {
    poll.running = false
    var payload = JSON.stringify({
      ok: failures.length === 0,
      failures: failures,
      controls: Object.keys(controls)
    })
    if (resultPath) {
      var quote = function(value) { return "'" + String(value).replace(/'/g, "'\\''") + "'" }
      Quickshell.execDetached(["bash", "-lc", "printf '%s' " + quote(payload) + " > " + quote(resultPath)])
    }
  }

  Item { id: host }

  Timer {
    id: poll
    interval: 50
    repeat: true
    running: false
    onTriggered: {
      if (step === 0) {
        if (panel && panel.column) {
          step = 1
          panel.addProvider = "opencode"
          panel.addChecks = { opencode: "first" }
          try {
            panel.startAdd("")
          } catch (e) {
            fail("startAdd threw: " + e)
            try { panel.cancelAdd() } catch (e2) {}
            writeResult()
            return
          }
        }
        return
      }
      if (step === 1) {
        // The Console instructions arrive from the stubbed CLI (already
        // translated by omarchy-i18n); the panel's own labels come from its
        // shell catalog. Wait for both before inspecting the rendered form.
        if (Commons.I18n.t("agents.connectApiKey") === "agents.connectApiKey") {
          ticks++
          if (ticks % 20 === 1)
            console.log("agents-add-view waiting for i18n keys=" + Object.keys(Commons.I18n.strings).length)
          return
        }
        if (panel.addStatus.indexOf("API key") < 0) {
          ticks++
          if (ticks % 20 === 1)
            console.log("agents-add-view waiting statusLen=" + panel.addStatus.length + " stage=" + panel.addStage
              + " status=" + panel.addStatus.slice(0, 80))
          return
        }
        var expected = panel.addStatus
          step = 2
          findControls(panel.column)
          check(controls.signInHeading !== undefined, "Go sign-in heading is rendered")
          check(controls.signInStatus !== undefined, "Go Console instructions are rendered")
          check(controls.pasteInstructions !== undefined, "Go API-key instructions are rendered")
          check(controls.pasteField !== undefined, "Go API-key field is rendered")
          if (failures.length > 0) {
            panel.cancelAdd()
            writeResult()
            return
          }
          check(controls.signInHeading.text === Commons.I18n.t("agents.connectApiKey"),
                "Go heading asks for an API key, not a browser login: " + controls.signInHeading.text)
          check(controls.signInStatus.visible, "Go keeps the Console instructions visible")
          check(controls.signInStatus.text === expected, "Go shows the Console key-creation instructions")
          check(controls.pasteInstructions.text === Commons.I18n.t("agents.pasteApiKey"),
                "Go describes the credential as an API key: " + controls.pasteInstructions.text)
          check(controls.pasteField.placeholderText === Commons.I18n.t("agents.placeholderApiKey"),
                "Go field placeholder names an API key: " + controls.pasteField.placeholderText)
          check(controls.pasteField.echoMode === TextInput.Password, "Go masks the API-key field")
          panel.submitPaste("fixture-key")
          step = 3
        return
      }
      if (step === 3) {
        if (panel.addStatus === Commons.I18n.t("agents.checkingApiKey")) {
          check(controls.signInStatus.visible, "Go keeps its status visible while the key is checked")
          panel.cancelAdd()
          panel.destroy()
          writeResult()
        }
        return
      }
    }
  }

  Timer {
    interval: 50
    running: true
    repeat: false
    onTriggered: {
      var component = Qt.createComponent("file://" + rootPath + "/shell/plugins/agents/Panel.qml", Component.PreferSynchronous)
      if (component.status !== Component.Ready) {
        fail("agents panel failed to load: " + component.errorString())
        writeResult()
        return
      }
      panel = component.createObject(host, { settings: {} })
      if (!panel) {
        fail("agents panel failed to instantiate: " + component.errorString())
        writeResult()
        return
      }
      panel.open()
      poll.running = true
    }
  }

  // Hard timeout: never hang the suite.
  Timer {
    interval: 15000
    running: true
    repeat: false
    onTriggered: {
      if (!resultPath) return
      fail("Go sign-in form timed out")
      try { if (panel) { panel.cancelAdd(); panel.destroy() } } catch (e) {}
      writeResult()
    }
  }
}
