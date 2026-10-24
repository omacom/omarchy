import QtQuick
import QtTest
import Quickshell

ShellRoot {
  id: test
  property var clipboard
  property var failedClipboard
  property var input
  property string historyBeforeClear: ""
  property int step: 0
  property bool preview: Quickshell.env("CLIPBOARD_PIN_PREVIEW") === "1"

  Item { id: host }

  Component {
    id: inputComponent
    TestEvent {}
  }

  function check(condition, message) {
    if (!condition) throw new Error(message)
  }

  function findItem(item, name) {
    if (!item) return null
    if (item.objectName === name) return item
    var contents = item.children || []
    for (var i = 0; i < contents.length; i++) {
      var found = findItem(contents[i], name)
      if (found) return found
    }
    if (item.contentItem) {
      var content = findItem(item.contentItem, name)
      if (content) return content
    }
    var resources = item.resources || []
    for (var r = 0; r < resources.length; r++) {
      var resource = findItem(resources[r], name)
      if (resource) return resource
    }
    return null
  }

  function showSamples() {
    clipboard.loadHistory(JSON.stringify([
      { type: "text", text: "A recently copied item" },
      { type: "text", text: "npm run dev", pinned: true },
      { type: "text", text: "A useful note\nSaved across restarts", pinned: true },
      { type: "text", text: "Another clipboard entry" }
    ]))
    clipboard.saveHistory()
    clipboard.open("{}")
    if (preview) console.log("PREVIEW_READY")
    else screenshot.start()
  }

  function selectedText() {
    return findItem(clipboard, "clipboardResults").model.get(clipboard.selectedIndex).fullText
  }

  function clickPin(index) {
    var list = findItem(clipboard, "clipboardResults")
    var button = findItem(list.itemAtIndex(index), "clipboardPinButton")
    check(button !== null, "the visible row has a pin control")
    // Send the click through the window so overlapping mouse targets count.
    check(input.mouseClick(button, button.width / 2, button.height / 2, Qt.LeftButton, Qt.NoModifier, 0), "pin button receives a mouse event")
    check(clipboard.opened, "pin control does not activate or paste the row")
  }

  Timer {
    interval: 150
    repeat: true
    running: true
    onTriggered: {
      try {
        if (test.step === 0) {
          var component = Qt.createComponent("Clipboard.qml")
          check(component.status === Component.Ready, component.errorString())
          test.clipboard = component.createObject(host)
          check(test.clipboard !== null, component.errorString())
        } else if (test.step === 1) {
          check(clipboard.historyReady, "history loads before pinning")
          clipboard.loadHistory('[{"type":"text","text":"other"},{"type":"text","text":"old"}]')
          clipboard.open("{}")
        } else if (test.step === 2) {
          test.input = inputComponent.createObject(findItem(clipboard, "clipboardCard"))
          check(findItem(clipboard, "clipboardKeyCatcher").activeFocus, "the panel receives keyboard focus")
          check(input.keyClick(Qt.Key_Down, Qt.NoModifier, 0), "arrow key reaches the panel")
          check(selectedText() === "old", "keyboard selects the second entry")
          check(input.keyClick(Qt.Key_P, Qt.ControlModifier, 0), "Ctrl+P reaches the panel")
          check(clipboard.pinCount === 1, "Ctrl+P pins the selected entry")
          check(selectedText() === "old" && clipboard.selectedIndex === 0, "Ctrl+P keeps the pinned entry selected as it moves first")
        } else if (test.step === 3) {
          clipboard.history = []
          clipboard.destroy()
          test.clipboard = Qt.createComponent("Clipboard.qml").createObject(host)
        } else if (test.step === 4) {
          check(clipboard.pinCount === 1, "a fresh plugin reloads the saved pin")
          clipboard.addClipboardEntry({type: "text", text: "recent"})
          clipboard.open("{}")
          var list = findItem(clipboard, "clipboardResults")
          check(list.model.get(0).pinned && list.model.get(0).historyIndex === 1, "UI pins come first with correct history indexes")
        } else if (test.step === 5) {
          test.input = inputComponent.createObject(findItem(clipboard, "clipboardCard"))
          clickPin(0)
          check(clipboard.pinCount === 0, "clicking Unpin releases a pin")
          check(selectedText() === "old" && clipboard.selectedIndex === 0, "Unpin keeps the released entry selected at the front")
        } else if (test.step === 6) {
          clickPin(0)
          check(clipboard.pinCount === 1 && selectedText() === "old" && clipboard.selectedIndex === 0, "clicking Pin pins the row and keeps it selected")
          check(input.keyClick(Qt.Key_P, Qt.ControlModifier, 0), "Ctrl+P reaches the panel after clicking Pin")
          check(clipboard.pinCount === 0 && selectedText() === "old", "Ctrl+P unpins and keeps the same entry selected")
        } else if (test.step === 7) {
          var result = clipboard.pinClipboardFile(Quickshell.env("CLIPBOARD_PIN_REQUEST"))
          check(result === "pinned" && clipboard.pinCount === 1, "file IPC pins a captured payload")
          check(clipboard.pinClipboardFile(Quickshell.env("CLIPBOARD_PIN_REQUEST")) === "already-pinned", "repeated IPC requests are idempotent")
          for (var i = 0; i < 9; i++) {
            clipboard.addClipboardEntry({type: "text", text: "pin " + i})
            clipboard.togglePinDisplayIndex(clipboard.pinCount)
          }
          check(clipboard.pinCount === 10, "UI permits ten pins")
          clipboard.addClipboardEntry({type: "text", text: "eleventh"})
          clipboard.togglePinDisplayIndex(10)
          check(clipboard.pinCount === 10 && clipboard.statusMessage.indexOf("Unpin") >= 0, "UI reports pin limit")
          clipboard.setFilter("eleventh")
          check(findItem(clipboard, "clipboardResults").model.count === 1, "search still finds ordinary entries")
        } else if (test.step === 8) {
          clipboard.setFilter("pin 8")
          check(findItem(clipboard, "clipboardResults").model.count === 1, "search selects one pinned entry for deletion")
          check(input.keyClick(Qt.Key_Delete, Qt.NoModifier, 0), "Delete reaches the panel")
          check(clipboard.pinCount === 9 && !clipboard.history.some(function(entry) { return entry.text === "pin 8" }), "Delete removes the selected pin from filtered history")
          check(clipboard.history.some(function(entry) { return entry.text === "eleventh" }), "Delete preserves entries at other history indexes")
          clipboard.setFilter("")
          historyBeforeClear = JSON.stringify(clipboard.history)
          check(input.keyClick(Qt.Key_Delete, Qt.ShiftModifier, 0), "Shift+Delete reaches the panel")
          check(clipboard.clearConfirmOpen && JSON.stringify(clipboard.history) === historyBeforeClear, "Shift+Delete requires confirmation before deleting history or pins")
        } else if (test.step === 9) {
          findItem(clipboard, "clipboardCard").grabToImage(function(result) {
            if (!result.saveToFile(Quickshell.env("CLIPBOARD_PIN_CONFIRM_SCREENSHOT")))
              console.error("CLIPBOARD_PINS_QML_FAIL: confirmation screenshot could not be saved")
          })
        } else if (test.step === 10) {
          check(input.keyClick(Qt.Key_Escape, Qt.NoModifier, 0), "Escape reaches the confirmation dialog")
          check(!clipboard.clearConfirmOpen && clipboard.opened && JSON.stringify(clipboard.history) === historyBeforeClear, "canceling deletion preserves history and pins")
          check(input.keyClick(Qt.Key_Delete, Qt.ShiftModifier, 0), "Shift+Delete reopens confirmation")
          check(input.keyClick(Qt.Key_Return, Qt.NoModifier, 0), "Return confirms deletion")
          check(!clipboard.clearConfirmOpen && clipboard.history.length === 0 && clipboard.pinCount === 0, "confirmed Shift+Delete clears history and pins")
        } else if (test.step === 11) {
          test.failedClipboard = Qt.createComponent("Clipboard.qml").createObject(host, {
            historyPath: Quickshell.env("CLIPBOARD_PIN_BLOCKED_HISTORY")
          })
        } else if (test.step === 12) {
          check(failedClipboard.historyReady, "blocked history path finishes loading")
          failedClipboard.loadHistory('[{"type":"text","text":"old"}]')
          var requestPath = Quickshell.env("CLIPBOARD_PIN_REQUEST")
          check(failedClipboard.pinClipboardFile(requestPath) === "save-failed", "a real filesystem write failure is reported")
          check(failedClipboard.pinCount === 0 && failedClipboard.history.length === 1 && failedClipboard.history[0].text === "old", "failed saves leave pins and history unchanged")
          check(failedClipboard.statusMessage.indexOf("Could not save") >= 0, "the panel explains the save failure")
          check(failedClipboard.pinClipboardFile(requestPath) === "save-failed", "retrying a failed save does not claim already-pinned")
          failedClipboard.loadHistory('[{"type":"text","text":"Pinned from a private request","pinned":true}]')
          check(failedClipboard.pinClipboardFile(requestPath) === "save-failed", "already-pinned also requires a successful save")
          failedClipboard.historyPath = Quickshell.env("CLIPBOARD_PIN_RETRY_HISTORY")
        } else if (test.step === 13) {
          failedClipboard.loadHistory('[{"type":"text","text":"old"}]')
          check(failedClipboard.pinClipboardFile(Quickshell.env("CLIPBOARD_PIN_REQUEST")) === "pinned", "retry succeeds when history is writable")
          check(failedClipboard.pinCount === 1 && failedClipboard.statusMessage === "", "a successful retry publishes the pin and clears the error")
        } else if (test.step === 14) {
          failedClipboard.destroy()
          test.failedClipboard = Qt.createComponent("Clipboard.qml").createObject(host, {
            historyPath: Quickshell.env("CLIPBOARD_PIN_RETRY_HISTORY")
          })
        } else if (test.step === 15) {
          check(failedClipboard.pinCount === 1 && failedClipboard.history[0].text === "Pinned from a private request", "a pin saved on retry survives a fresh plugin instance")
          failedClipboard.destroy()
        } else if (test.step === 16) {
          var saturated = []
          for (var n = 0; n < 500; n++) saturated.push({type: "text", text: "newer copy " + n})
          saturated.push({type: "text", text: "old pinned entry", pinned: true})
          clipboard.loadHistory(JSON.stringify(saturated))
          clipboard.open("{}")
        } else if (test.step === 17) {
          clickPin(0)
          check(clipboard.pinCount === 0 && clipboard.history.length === 500, "Unpin keeps ordinary history within its quota")
          check(selectedText() === "old pinned entry" && clipboard.selectedIndex === 0, "Unpin retains and selects an old pin with full ordinary history")
          check(!clipboard.history.some(function(entry) { return entry.text === "newer copy 499" }), "Unpin evicts the oldest ordinary entry instead of the released pin")
          clipboard.destroy()
          test.clipboard = Qt.createComponent("Clipboard.qml").createObject(host)
        } else if (test.step === 18) {
          check(clipboard.historyReady && clipboard.history.length === 500, "unpinning at capacity saves history across restart")
          check(clipboard.history[0].text === "old pinned entry" && !clipboard.history[0].pinned, "the released entry survives restart without a pin")
        } else {
          running = false
          console.log("CLIPBOARD_PINS_QML_PASS")
          showSamples()
        }
        test.step++
      } catch (error) {
        console.error("CLIPBOARD_PINS_QML_FAIL: " + error)
        Qt.quit()
      }
    }
  }

  Timer {
    id: screenshot
    interval: 500
    onTriggered: {
      var card = findItem(clipboard, "clipboardCard")
      card.grabToImage(function(result) {
        if (!result.saveToFile(Quickshell.env("CLIPBOARD_PIN_SCREENSHOT")))
          console.error("CLIPBOARD_PINS_QML_FAIL: screenshot could not be saved")
        Qt.quit()
      })
    }
  }
}
