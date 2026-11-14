import QtQuick
import Quickshell
import qs.Commons
import qs.Commons as Commons
import qs.Ui

// Lays ConfirmDialog out in the hosts the shell gives it (the 300px menu card
// and a wide panel) with the language's own button labels, and checks every
// label stays inside its button and every button inside the card.
ShellRoot {
  id: root

  readonly property string resultPath: Quickshell.env("OMARCHY_QML_TEST_RESULT")
  readonly property string expectedLanguage: Quickshell.env("CONFIRM_DIALOG_LANGUAGE") || "en"
  readonly property string extreme: "Delete every clipboard entry permanently and forever"
  property var failures: []
  property var measurements: []
  property var cases: []
  property int current: 0
  property int languageWaits: 0

  function fail(message) {
    failures.push(String(message))
  }

  function shellQuote(value) {
    return "'" + String(value).replace(/'/g, "'\\''") + "'"
  }

  function finish() {
    var payload = JSON.stringify({
      ok: failures.length === 0,
      language: Commons.I18n.language,
      failures: failures,
      measurements: measurements
    })
    if (resultPath)
      Quickshell.execDetached(["bash", "-c", "printf '%s' " + shellQuote(payload) + " > " + shellQuote(resultPath)])
  }

  function find(item, test, out) {
    if (test(item)) out.push(item)
    for (var i = 0; i < item.children.length; i++) find(item.children[i], test, out)
    return out
  }

  function buildCases() {
    var cancel = Commons.I18n.t("common.cancel")
    var hosts = [600, 300]
    var list = []
    for (var h = 0; h < hosts.length; h++) {
      list.push({ host: hosts[h], cancel: cancel, confirm: Commons.I18n.t("common.confirm"), name: "confirm" })
      list.push({ host: hosts[h], cancel: cancel, confirm: Commons.I18n.t("common.delete"), name: "delete" })
      list.push({ host: hosts[h], cancel: cancel, confirm: Commons.I18n.t("common.uninstall"), name: "uninstall" })
      list.push({ host: hosts[h], cancel: cancel, confirm: "Delete permanently", name: "long English" })
      list.push({ host: hosts[h], cancel: cancel, confirm: root.extreme, name: "extreme" })
      list.push({ host: hosts[h], cancel: root.extreme, confirm: root.extreme, name: "two extremes" })
    }
    return list
  }

  function check() {
    var c = cases[current]
    var name = c.name + " ('" + c.confirm + "') in a " + c.host + "px host"
    var buttons = find(dialog, function(item) {
      return item.hasOwnProperty("destructive") && item.hasOwnProperty("modelData")
    }, [])
    if (buttons.length !== 2) {
      fail(name + ": expected two buttons, found " + buttons.length)
      return next()
    }
    buttons.sort(function(a, b) { return a.index - b.index })
    var row = buttons[0].parent
    var content = row.parent
    row.forceLayout()

    var minimum = Style.space(88)
    var available = content.width - row.spacing
    var record = { host: c.host, name: c.name, content: content.width, buttons: [] }
    var spans = []

    for (var i = 0; i < 2; i++) {
      var button = buttons[i]
      var label = find(button, function(item) {
        return item.hasOwnProperty("truncated") && item.text === button.modelData
      }, [])[0]
      if (!label) {
        fail(name + ": no label for '" + button.modelData + "'")
        continue
      }
      var left = label.mapToItem(button, 0, 0).x + (label.width - label.paintedWidth) / 2
      var x = button.mapToItem(content, 0, 0).x
      spans.push([x, x + button.width])
      record.buttons.push({
        text: button.modelData, width: button.width, natural: label.implicitWidth,
        painted: label.paintedWidth, truncated: label.truncated, x: x
      })

      if (left < -0.5 || left + label.paintedWidth > button.width + 0.5)
        fail(name + ": '" + button.modelData + "' paints " + label.paintedWidth + "px of text from " + left + " in a " + button.width + "px button")
      if (x < -0.5 || x + button.width > content.width + 0.5)
        fail(name + ": the '" + button.modelData + "' button (" + x + ".." + (x + button.width) + ") leaves the card's " + content.width + "px content")
      if (button.width < minimum - 0.5)
        fail(name + ": the '" + button.modelData + "' button is " + button.width + "px, under the " + minimum + "px minimum")
      // A label may only be cut short when the row has no room left to give it.
      if (label.truncated && spans.length && available - (buttons[0].width + buttons[1].width) > 1)
        fail(name + ": '" + button.modelData + "' elides although the row has " + (available - buttons[0].width - buttons[1].width) + "px to spare")
      if (label.truncated && button.width < Math.floor(available / 2) - 1)
        fail(name + ": '" + button.modelData + "' elides in a " + button.width + "px button, less than half of the " + available + "px row")
    }
    if (spans.length === 2 && spans[0][1] > spans[1][0] + 0.5)
      fail(name + ": the buttons overlap")

    // Labels that already fit keep the dialog's familiar 88px buttons.
    if (root.expectedLanguage === "en" && (c.name === "confirm" || c.name === "delete")) {
      for (var j = 0; j < 2; j++) {
        if (Math.abs(buttons[j].width - minimum) > 0.5)
          fail(name + ": '" + buttons[j].modelData + "' is " + buttons[j].width + "px, expected the " + minimum + "px minimum")
      }
    }
    // Long English fits a wide card in full, and an extreme label is cut short.
    if (c.name === "long English" && c.host === 600 && record.buttons.length === 2 && record.buttons[1].truncated)
      fail(name + ": a long label is cut short in a wide card")
    if (c.name === "extreme" && record.buttons.length === 2 && !record.buttons[1].truncated)
      fail(name + ": an extreme label is not cut short")

    measurements.push(record)
    next()
  }

  function next() {
    current++
    if (current >= cases.length) finish()
    else load()
  }

  function load() {
    var c = cases[current]
    host.width = c.host
    dialog.cancelText = c.cancel
    dialog.confirmText = c.confirm
    Qt.callLater(function() { Qt.callLater(root.check) })
  }

  Timer {
    interval: 20
    running: true
    repeat: true
    onTriggered: {
      if (Commons.I18n.language !== root.expectedLanguage && root.languageWaits++ < 100) return
      running = false
      if (Commons.I18n.language !== root.expectedLanguage) {
        root.fail("I18n language is '" + Commons.I18n.language + "', expected '" + root.expectedLanguage + "'")
        root.finish()
        return
      }
      root.cases = root.buildCases()
      root.load()
    }
  }

  Item {
    id: host
    width: 600
    height: 400

    ConfirmDialog {
      id: dialog
      anchors.fill: parent
      opened: true
      message: "Remove this?"
    }
  }
}
