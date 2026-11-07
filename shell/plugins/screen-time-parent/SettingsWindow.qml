import QtQuick
import QtQuick.Controls
import Quickshell
import Quickshell.Io
import qs.Ui
import qs.Commons
import qs.Commons as Commons

// The parent's settings, in a window of their own. Changes gather into one
// partial patch, saved with a grown-up's password at the foot of the window;
// in agreement mode, which the daemon lets through without one, each change
// applies as it is made.
Item {
  id: root

  property var service: null
  property string clientPath: ""
  readonly property bool opened: win.visible
  property string note: ""
  property color noteColor: Commons.Color.foreground

  readonly property bool lightTheme: {
    var bg = Commons.Color.background
    return (0.299 * bg.r + 0.587 * bg.g + 0.114 * bg.b) > 0.5
  }
  readonly property color okColor: lightTheme ? "#3C7C4E" : "#5FA46B"
  readonly property color errColor: lightTheme ? "#B03434" : "#E06C6C"

  // What the window shows is what is saved with the unsaved changes on top.
  property var pending: ({})
  // The web allowlist is a request of its own (omarchy-screen-time web), read
  // when the window opens; its edits wait beside the config's and are saved
  // with the same password, which it always takes, even in agreement mode.
  property var savedWeb: ({ enabled: false, domains: [] })
  property var pendingWeb: null
  readonly property var shownWeb: pendingWeb || savedWeb
  readonly property bool saving: patchProc.running || webSetProc.running
  readonly property bool dirty: Object.keys(pending).length > 0 || pendingWeb !== null
  readonly property bool savedTogether: service ? service.philosophy === "together" : false
  readonly property var pendingEarn: pending.earn || ({})
  readonly property bool together: pending.philosophy !== undefined ? pending.philosophy === "together" : savedTogether
  readonly property bool earnEnabled: pendingEarn.enabled !== undefined ? pendingEarn.enabled === true
    : (service ? service.earnEnabled === true : false)
  readonly property var earnOps: pendingEarn.ops || (service && service.earnOps ? service.earnOps : [])
  readonly property bool divisionOn: earnOps.indexOf("div") >= 0
  readonly property var tables: pendingEarn.tables || (service && service.earnTables ? service.earnTables : [])

  // The list is held locally while the window is open, for the same reason
  // the number fields are: the daemon streams a fresh array every second, and
  // a live model would rebuild the rows under whoever is typing in one.
  property var localPeriods: []
  readonly property int periodLimit: 8
  readonly property string iconClose: "\uf00d"

  readonly property var dayKeys: ["mon", "tue", "wed", "thu", "fri", "sat", "sun"]
  // Qt numbers the week from Sunday.
  readonly property var dayLabels: [1, 2, 3, 4, 5, 6, 0].map(function(d) { return Qt.locale(I18n.formatLocale).dayName(d, Locale.ShortFormat) })

  function fadeText(amount) {
    var c = Commons.Color.foreground
    var bg = Commons.Color.background
    return Qt.rgba(c.r + (bg.r - c.r) * amount,
                   c.g + (bg.g - c.g) * amount,
                   c.b + (bg.b - c.b) * amount, 1)
  }

  function show() {
    note = ""
    pending = {}
    pendingWeb = null
    syncFields()
    webGetProc.running = true
    win.visible = true
  }

  // Closing drops what was not saved.
  function close() {
    win.visible = false
    pending = {}
    pendingWeb = null
    passwordField.text = ""
  }

  // Number and time fields are authoritative while the window is open, so
  // they are filled once on show instead of fighting the stream mid-edit.
  property var localBudget: ({})
  property var localEarn: ({})
  property var localAgreement: ({})

  function syncFields() {
    if (!service) return
    var b = {}
    for (var i = 0; i < dayKeys.length; i++) b[dayKeys[i]] = Number(service.budgetMinutes[dayKeys[i]]) || 0
    localBudget = b
    localPeriods = clonePeriods()
    localEarn = { seconds_per_correct: service.earnSecondsPerCorrect, daily_cap_minutes: service.earnCapMinutes }
    agreementField.text = String(service.agreementText || "")
    localAgreement = { agreement_minutes: service.agreementMinutes, break_nudge_minutes: service.breakNudgeMinutes }
  }

  function clonePeriods() {
    var out = []
    var source = service && service.blockedPeriods ? service.blockedPeriods : []
    for (var i = 0; i < source.length; i++) {
      out.push({ label: "",
                 enabled: source[i].enabled === true,
                 start: String(source[i].start || ""),
                 end: String(source[i].end || ""),
                 days: Array.isArray(source[i].days) ? source[i].days.slice() : dayKeys.slice() })
    }
    return out
  }

  // Every write sends the whole array: the daemon merges dicts but replaces
  // lists, which is what you want here. A period that is gone is gone.
  function writePeriods(list) {
    localPeriods = list
    patch({ "blocked_periods": list })
  }

  function setPeriod(index, key, value) {
    var list = clonePeriodsFromLocal()
    if (index < 0 || index >= list.length) return
    if (list[index][key] === value) return
    list[index][key] = value
    writePeriods(list)
  }

  function clonePeriodsFromLocal() {
    var out = []
    for (var i = 0; i < localPeriods.length; i++) {
      out.push({ label: "", enabled: localPeriods[i].enabled === true,
                 start: localPeriods[i].start, end: localPeriods[i].end,
                 days: (localPeriods[i].days || dayKeys).slice() })
    }
    return out
  }

  // The section's own switch: on when any period runs. Flipping it sets
  // every period at once, so a parent can pause the whole schedule for a
  // holiday and get it back as it was.
  readonly property bool periodsOn: {
    for (var i = 0; i < localPeriods.length; i++)
      if (localPeriods[i].enabled === true) return true
    return false
  }

  function setPeriodsOn(value) {
    var list = clonePeriodsFromLocal()
    for (var i = 0; i < list.length; i++) list[i].enabled = value
    writePeriods(list)
  }

  function addPeriod() {
    var list = clonePeriodsFromLocal()
    if (list.length >= periodLimit) return
    list.push({ label: "", enabled: periodsOn || list.length === 0, start: "18:00", end: "18:45", days: dayKeys.slice() })
    writePeriods(list)
  }

  // A period runs on the days that are lit. The last lit day stays lit: a
  // period on no day at all would be a period that is silently off.
  function togglePeriodDay(index, key) {
    var list = clonePeriodsFromLocal()
    if (index < 0 || index >= list.length) return
    var days = list[index].days
    var at = days.indexOf(key)
    if (at >= 0) {
      if (days.length <= 1) return
      days.splice(at, 1)
    } else {
      days.push(key)
    }
    // Keep the week's order, so the daemon and the chips agree.
    list[index].days = dayKeys.filter(function(k) { return days.indexOf(k) >= 0 })
    writePeriods(list)
  }

  function removePeriod(index) {
    var list = clonePeriodsFromLocal()
    if (index < 0 || index >= list.length) return
    list.splice(index, 1)
    writePeriods(list)
  }

  // Objects merge and lists replace, the way the daemon applies a patch.
  function merged(base, change) {
    var out = {}
    for (var k in base) out[k] = base[k]
    for (var c in change) {
      var value = change[c]
      out[c] = (value && typeof value === "object" && !Array.isArray(value) && out[c] && typeof out[c] === "object" && !Array.isArray(out[c]))
        ? merged(out[c], value) : value
    }
    return out
  }

  // Agreement-mode changes made while a save is still running wait here and
  // go out together once it answers, rather than being dropped.
  property var queued: ({})

  function patch(obj) {
    if (savedTogether && !dirty) {
      if (patchProc.running) queued = merged(queued, obj)
      else send(obj, "")
      return
    }
    pending = merged(pending, obj)
    note = ""
  }

  function flushQueued() {
    if (patchProc.running || Object.keys(queued).length === 0) return
    var next = queued
    queued = {}
    patch(next)
  }

  function send(obj, password) {
    if (patchProc.running) return
    patchProc.secret = password
    patchProc.body = obj
    patchProc.passwordless = password === ""
    patchProc.command = [root.clientPath, "--password-stdin", "config", "patch", JSON.stringify(obj)]
    patchProc.running = true
  }

  function save() {
    var password = passwordField.text
    if (!dirty || password === "") return
    passwordField.text = ""
    if (Object.keys(pending).length > 0) send(pending, password)
    if (pendingWeb !== null) sendWeb(pendingWeb, password)
  }

  function patchWeb(change) {
    pendingWeb = merged(shownWeb, change)
    note = ""
  }

  function sendWeb(obj, password) {
    if (webSetProc.running) return
    webSetProc.secret = password
    webSetProc.body = obj
    webSetProc.command = [root.clientPath, "--password-stdin", "web", "set", JSON.stringify(obj)]
    webSetProc.running = true
  }

  function domainsFromText(text) {
    return String(text).split(/[\s,]+/).map(function(d) { return d.trim().toLowerCase() }).filter(function(d) { return d.length > 0 })
  }

  function discard() {
    pendingWeb = null
    webField.text = root.savedWeb.domains.join("\n")
    pending = {}
    note = ""
    passwordField.text = ""
    syncFields()
  }

  function toggleTable(n) {
    var current = tables.slice()
    var index = current.indexOf(n)
    if (index >= 0) {
      if (current.length <= 1) return   // the last table stays
      current.splice(index, 1)
    } else {
      current.push(n)
    }
    patch({ "earn": { "tables": current } })
  }

  function validTime(text) {
    return /^([01]?\d|2[0-3]):[0-5]\d$/.test(text)
  }

  Process {
    id: patchProc
    property string secret: ""
    property var body: null
    property bool passwordless: false
    stdinEnabled: true
    onStarted: {
      write(secret + "\n")
      secret = ""
    }
    onRunningChanged: {
      if (running) return
      secret = ""
      Qt.callLater(root.flushQueued)
    }
    stdout: StdioCollector {
      onStreamFinished: {
        var payload
        try { payload = JSON.parse(text) } catch (e) { payload = {} }
        if (payload.ok === true) {
          // A save that worked says nothing: the fields already show it.
          // Changes made while it ran stay pending.
          if (root.pending === patchProc.body) root.pending = {}
          root.note = ""
          return
        }
        // A change sent without a password that did not land (the mode left
        // agreement meanwhile, say) waits for one in the foot instead.
        if (patchProc.passwordless) {
          root.pending = root.merged(root.merged(patchProc.body, root.pending), root.queued)
          root.queued = {}
          if (payload.error === "bad_password") {
            root.note = ""
            return
          }
        }
        if (payload.error === "bad_password") {
          root.note = I18n.t("screenTime.notAdultPassword")
          root.noteColor = root.errColor
        } else if (payload.error === "locked_out") {
          root.note = I18n.t("screenTime.tooManyTries").arg(payload.retry_in_seconds)
          root.noteColor = root.errColor
        } else {
          root.note = payload.error ? String(payload.error) : I18n.t("screenTime.failed")
          root.noteColor = root.errColor
        }
      }
    }
  }

  Process {
    id: webGetProc
    command: [root.clientPath, "web", "get"]
    stdout: StdioCollector {
      onStreamFinished: {
        var payload
        try { payload = JSON.parse(text) } catch (e) { return }
        if (payload.ok !== true) return
        root.savedWeb = { enabled: payload.enabled === true, domains: payload.domains || [] }
        if (root.pendingWeb === null) webField.text = root.savedWeb.domains.join("\n")
      }
    }
  }

  Process {
    id: webSetProc
    property string secret: ""
    property var body: null
    stdinEnabled: true
    onStarted: {
      write(secret + "\n")
      secret = ""
    }
    onRunningChanged: if (!running) secret = ""
    stdout: StdioCollector {
      onStreamFinished: {
        var payload
        try { payload = JSON.parse(text) } catch (e) { return }
        if (payload.ok === true) {
          root.savedWeb = { enabled: payload.enabled === true, domains: payload.domains || [] }
          if (root.pendingWeb === webSetProc.body) {
            root.pendingWeb = null
            webField.text = root.savedWeb.domains.join("\n")
          }
        } else if (payload.error === "bad_password") {
          root.note = I18n.t("screenTime.notAdultPassword")
          root.noteColor = root.errColor
        } else if (payload.error === "locked_out") {
          root.note = I18n.t("screenTime.tooManyTries").arg(payload.retry_in_seconds)
          root.noteColor = root.errColor
        } else {
          root.note = payload.error ? String(payload.error) : I18n.t("screenTime.failed")
          root.noteColor = root.errColor
        }
      }
    }
  }

  // Sized like a settings dialog: a fixed size floats under Hyprland, and the
  // content scrolls inside it, so a long list of periods never grows the
  // window off the screen.
  // A section's head: the small-caps title and the one line under it that
  // says what the section is for, kept as one block so the gap between them
  // is always the small one and the gap above is always the big one.
  component SectionHead: Column {
    property alias title: headTitle.text
    property alias caption: headCaption.text
    width: parent.width
    spacing: Style.space(4)

    PanelSectionHeader {
      id: headTitle
      foreground: Commons.Color.foreground
    }

    Text {
      id: headCaption
      textFormat: Text.PlainText
      visible: text !== ""
      width: parent.width
      wrapMode: Text.WordWrap
      color: root.fadeText(0.5)
      font.family: Style.font.family
      font.pixelSize: Style.font.caption
    }
  }

  // A row of equal cells in one bar, of which any number can be lit: the
  // days a period runs on, the tables the sums come from. One shape for all
  // the cells, so the eye reads the set and not a row of buttons of slightly
  // different widths. `options` are the values, `labels` what they show.
  component SegmentPicker: Rectangle {
    id: picker
    property var options: []
    property var labels: options
    property var selected: []
    signal toggled(var value)
    width: parent.width
    implicitHeight: Style.space(30)
    radius: Style.cornerRadius
    color: "transparent"
    border.width: 1
    border.color: root.fadeText(0.75)
    clip: true

    Row {
      anchors.fill: parent
      anchors.margins: 1

      Repeater {
        model: picker.options.length

        delegate: Item {
          id: cell
          required property int index
          readonly property var value: picker.options[index]
          readonly property bool on: (picker.selected || []).indexOf(value) >= 0
          width: parent.width / picker.options.length
          height: parent.height
          activeFocusOnTab: true
          Keys.onPressed: function(event) {
            if (event.key === Qt.Key_Space || event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
              picker.toggled(cell.value); event.accepted = true
            }
          }

          Rectangle {
            anchors.fill: parent
            color: cell.on
              ? Qt.rgba(Commons.Color.accent.r, Commons.Color.accent.g, Commons.Color.accent.b, cellArea.containsMouse ? 0.3 : 0.22)
              : (cellArea.containsMouse ? root.fadeText(0.9) : "transparent")
            Behavior on color { ColorAnimation { duration: Style.duration(100) } }
          }

          // A hairline between the cells, except before the first.
          Rectangle {
            visible: cell.index > 0
            width: 1
            height: parent.height
            anchors.left: parent.left
            color: root.fadeText(0.82)
          }

          Rectangle {
            visible: cell.activeFocus
            anchors.fill: parent
            color: "transparent"
            border.width: 1
            border.color: Commons.Color.accent
          }

          Text {
            textFormat: Text.PlainText
            anchors.centerIn: parent
            text: String(picker.labels[cell.index])
            color: cell.on ? Commons.Color.foreground : root.fadeText(0.45)
            font.family: Style.font.family
            font.pixelSize: Style.font.body
            font.bold: cell.on
          }

          MouseArea {
            id: cellArea
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: picker.toggled(cell.value)
          }
        }
      }
    }
  }

  // Numbers in a bar of equal cells, the label above the value. A value is
  // typed in place, or nudged one step at a time with the wheel; it saves
  // when the cursor leaves or on enter. The week's budget is one of these
  // with seven cells, the earning knobs one with two.
  component NumberBar: Rectangle {
    id: bar
    // [{key, label, min, max, step}]
    property var fields: []
    property var values: ({})
    signal changed(string key, int value)
    width: parent.width
    implicitHeight: Style.space(52)
    radius: Style.cornerRadius
    color: "transparent"
    border.width: 1
    border.color: root.fadeText(0.75)
    clip: true

    function commit(field, text) {
      var n = parseInt(text, 10)
      if (!isFinite(n)) return
      n = Math.max(field.min, Math.min(field.max, n))
      if (n !== (Number(bar.values[field.key]) || 0)) bar.changed(field.key, n)
    }

    Row {
      anchors.fill: parent
      anchors.margins: 1

      Repeater {
        model: bar.fields.length

        delegate: Item {
          id: cell
          required property int index
          readonly property var field: bar.fields[index]
          width: parent.width / bar.fields.length
          height: parent.height

          Rectangle {
            anchors.fill: parent
            color: number.activeFocus
              ? Qt.rgba(Commons.Color.accent.r, Commons.Color.accent.g, Commons.Color.accent.b, 0.18)
              : (cellArea.containsMouse ? root.fadeText(0.9) : "transparent")
            Behavior on color { ColorAnimation { duration: Style.duration(100) } }
          }

          Rectangle {
            visible: cell.index > 0
            width: 1
            height: parent.height
            anchors.left: parent.left
            color: root.fadeText(0.82)
          }

          Column {
            anchors.centerIn: parent
            spacing: Style.space(2)

            Text {
              textFormat: Text.PlainText
              anchors.horizontalCenter: parent.horizontalCenter
              text: cell.field.label
              color: root.fadeText(0.45)
              font.family: Style.font.family
              font.pixelSize: Style.font.caption
            }

            TextInput {
              id: number
              anchors.horizontalCenter: parent.horizontalCenter
              width: cell.width - Style.space(8)
              horizontalAlignment: TextInput.AlignHCenter
              text: String(Number(bar.values[cell.field.key]) || 0)
              color: Commons.Color.foreground
              selectionColor: Util.alpha(Commons.Color.accent, 0.45)
              selectedTextColor: Commons.Color.foreground
              font.family: Style.font.family
              font.pixelSize: Style.font.body
              font.bold: true
              validator: IntValidator { bottom: cell.field.min; top: cell.field.max }
              inputMethodHints: Qt.ImhDigitsOnly
              activeFocusOnTab: true
              selectByMouse: true
              onEditingFinished: bar.commit(cell.field, text)
              onActiveFocusChanged: if (activeFocus) selectAll()
              Keys.onPressed: function(event) {
                if (event.key === Qt.Key_Escape) {
                  text = String(Number(bar.values[cell.field.key]) || 0); focus = false; event.accepted = true
                }
              }
            }
          }

          MouseArea {
            id: cellArea
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.IBeamCursor
            // Clicks go through to the input; the wheel nudges by a step.
            onPressed: function(mouse) { number.forceActiveFocus(); mouse.accepted = false }
            onWheel: function(wheel) {
              var current = parseInt(number.text, 10) || 0
              var step = cell.field.step || 1
              var next = Math.max(cell.field.min, Math.min(cell.field.max, current + (wheel.angleDelta.y > 0 ? step : -step)))
              number.text = String(next)
              bar.commit(cell.field, number.text)
            }
          }
        }
      }
    }
  }

  // Two clock times in a bar, "from" and "until". The input takes digits
  // only, into an HH:MM mask, and refuses an hour past 23 or a minute past
  // 59; the wheel moves a quarter of an hour at a time.
  component TimeBar: Rectangle {
    id: times
    property string start: "00:00"
    property string end: "00:00"
    signal changed(string key, string value)
    // Two times need no more room than this; the bar stays as wide as
    // what it holds, left, instead of stretching across the card.
    width: Style.space(240)
    implicitHeight: Style.space(52)
    radius: Style.cornerRadius
    color: "transparent"
    border.width: 1
    border.color: root.fadeText(0.75)
    clip: true

    function nudge(value, minutes) {
      var parts = String(value).split(":")
      var total = (parseInt(parts[0], 10) || 0) * 60 + (parseInt(parts[1], 10) || 0)
      total = ((total + minutes) % 1440 + 1440) % 1440
      var h = Math.floor(total / 60), m = total % 60
      return (h < 10 ? "0" : "") + h + ":" + (m < 10 ? "0" : "") + m
    }

    Row {
      anchors.fill: parent
      anchors.margins: 1

      Repeater {
        model: [{ key: "start", label: I18n.t("screenTime.from") }, { key: "end", label: I18n.t("screenTime.until") }]

        delegate: Item {
          id: cell
          required property var modelData
          required property int index
          readonly property string current: cell.modelData.key === "start" ? times.start : times.end
          width: parent.width / 2
          height: parent.height

          Rectangle {
            anchors.fill: parent
            color: clock.activeFocus
              ? Qt.rgba(Commons.Color.accent.r, Commons.Color.accent.g, Commons.Color.accent.b, 0.18)
              : (cellArea.containsMouse ? root.fadeText(0.9) : "transparent")
            Behavior on color { ColorAnimation { duration: Style.duration(100) } }
          }

          Rectangle {
            visible: cell.index > 0
            width: 1
            height: parent.height
            anchors.left: parent.left
            color: root.fadeText(0.82)
          }

          Column {
            anchors.left: parent.left
            anchors.leftMargin: Style.space(12)
            anchors.verticalCenter: parent.verticalCenter
            spacing: Style.space(2)

            Text {
              textFormat: Text.PlainText
              text: cell.modelData.label
              color: root.fadeText(0.45)
              font.family: Style.font.family
              font.pixelSize: Style.font.caption
            }

            TextInput {
              id: clock
              width: Style.space(56)
              horizontalAlignment: TextInput.AlignLeft
              text: cell.current
              color: Commons.Color.foreground
              selectionColor: Util.alpha(Commons.Color.accent, 0.45)
              selectedTextColor: Commons.Color.foreground
              font.family: Style.font.family
              font.pixelSize: Style.font.body
              font.bold: true
              inputMask: "99:99;_"
              validator: RegularExpressionValidator { regularExpression: /^([01][0-9]|2[0-3]):[0-5][0-9]$/ }
              inputMethodHints: Qt.ImhDigitsOnly
              activeFocusOnTab: true
              selectByMouse: true
              onEditingFinished: {
                if (acceptableInput) { if (text !== cell.current) times.changed(cell.modelData.key, text) }
                else text = cell.current
              }
              onActiveFocusChanged: {
                if (activeFocus) { cursorPosition = 0; selectAll() }
                else if (!acceptableInput) text = cell.current
              }
              Keys.onPressed: function(event) {
                if (event.key === Qt.Key_Escape) { text = cell.current; focus = false; event.accepted = true }
              }
            }
          }

          MouseArea {
            id: cellArea
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.IBeamCursor
            onPressed: function(mouse) { clock.forceActiveFocus(); mouse.accepted = false }
            onWheel: function(wheel) {
              var next = times.nudge(clock.acceptableInput ? clock.text : cell.current, wheel.angleDelta.y > 0 ? 15 : -15)
              clock.text = next
              times.changed(cell.modelData.key, next)
            }
          }
        }
      }
    }
  }

  // A labelled number: the label above, the value in a box of its own,
  // typed in place or nudged a step with the wheel. No arrows.
  component NumberBox: Column {
    id: box
    property string label: ""
    property int value: 0
    property int min: 0
    property int max: 100
    property int step: 1
    signal changed(int value)
    spacing: Style.space(6)

    function commit(text) {
      var n = parseInt(text, 10)
      if (!isFinite(n)) { field.text = String(box.value); return }
      n = Math.max(box.min, Math.min(box.max, n))
      field.text = String(n)
      if (n !== box.value) box.changed(n)
    }

    Text {
      textFormat: Text.PlainText
      text: box.label
      color: Commons.Color.foreground
      font.family: Style.font.family
      font.pixelSize: Style.font.body
    }

    Rectangle {
      width: Style.space(96)
      height: Style.space(36)
      radius: Style.cornerRadius
      color: field.activeFocus
        ? Qt.rgba(Commons.Color.accent.r, Commons.Color.accent.g, Commons.Color.accent.b, 0.18)
        : (boxArea.containsMouse ? root.fadeText(0.9) : "transparent")
      border.width: 1
      border.color: field.activeFocus ? Commons.Color.accent : root.fadeText(0.75)
      Behavior on color { ColorAnimation { duration: Style.duration(100) } }

      TextInput {
        id: field
        anchors.fill: parent
        anchors.margins: Style.space(6)
        horizontalAlignment: TextInput.AlignHCenter
        verticalAlignment: TextInput.AlignVCenter
        text: String(box.value)
        color: Commons.Color.foreground
        selectionColor: Util.alpha(Commons.Color.accent, 0.45)
        selectedTextColor: Commons.Color.foreground
        font.family: Style.font.family
        font.pixelSize: Style.font.body
        font.bold: true
        validator: IntValidator { bottom: box.min; top: box.max }
        inputMethodHints: Qt.ImhDigitsOnly
        activeFocusOnTab: true
        selectByMouse: true
        onEditingFinished: box.commit(text)
        onActiveFocusChanged: if (activeFocus) selectAll()
        Keys.onPressed: function(event) {
          if (event.key === Qt.Key_Escape) { text = String(box.value); focus = false; event.accepted = true }
        }
      }

      MouseArea {
        id: boxArea
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.IBeamCursor
        onPressed: function(mouse) { field.forceActiveFocus(); mouse.accepted = false }
        onWheel: function(wheel) {
          var current = parseInt(field.text, 10) || 0
          box.commit(String(current + (wheel.angleDelta.y > 0 ? box.step : -box.step)))
        }
      }
    }
  }

  // A switch that Tab can reach: the cursor ring shows where the focus is,
  // and space or enter flips it, the way the Toggle rows already work.
  component FocusSwitch: ToggleSwitch {
    activeFocusOnTab: true
    hasCursor: activeFocus
    Keys.onSpacePressed: toggled()
    Keys.onReturnPressed: toggled()
    Keys.onEnterPressed: toggled()
  }

  FloatingWindow {
    id: win
    visible: false
    title: I18n.t("screenTime.settingsTitle")
    color: Commons.Color.background
    // As tall as its content, as far as the screen allows: switching a
    // section off shrinks the window, a long list of periods grows it, and
    // past the screen's height the content scrolls instead.
    readonly property int fittedW: 600
    readonly property int naturalH: Style.space(24) + head.implicitHeight + Style.space(20)
      + content.implicitHeight + Style.space(24) + saveBar.implicitHeight + Style.space(24)
    readonly property int screenCap: (win.screen ? win.screen.height : 900) - Style.space(120)
    readonly property int fittedH: Math.max(Style.space(360), Math.min(naturalH, screenCap))
    implicitWidth: fittedW
    implicitHeight: fittedH
    minimumSize: Qt.size(fittedW, fittedH)
    maximumSize: Qt.size(fittedW, fittedH)

    FocusScope {
      anchors.fill: parent
      focus: true

      Keys.onPressed: function(event) {
        if (event.key === Qt.Key_Escape) { root.close(); event.accepted = true }
      }

      // --- the head: what this is, and the way out -----------------------
      Column {
        id: head
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.margins: Style.space(24)
        anchors.bottomMargin: 0
        spacing: Style.space(18)

        // The title, and next to it the two ways to run a day: the choice
        // that colours every section below, so it sits at the very top. No
        // close button; the window closes like any other, with Super+W or
        // Escape.
        Row {
          width: parent.width

          Text {
            textFormat: Text.PlainText
            text: I18n.t("screenTime.title")
            width: parent.width - modes.width
            color: Commons.Color.foreground
            font.family: Style.font.family
            font.pixelSize: Style.font.title
            font.bold: true
            anchors.verticalCenter: parent.verticalCenter
          }

          // The two modes as one joined bar, the lit cell being the mode
          // the day runs in; picking the other switches.
          SegmentPicker {
            id: modes
            width: Style.space(250)
            implicitHeight: Style.space(32)
            anchors.verticalCenter: parent.verticalCenter
            options: ["limits", "together"]
            labels: [I18n.t("screenTime.hardLimits"), I18n.t("screenTime.softAgreement")]
            selected: [root.together ? "together" : "limits"]
            onToggled: function(value) {
              if (value === "together" && !root.together) root.patch({ "philosophy": "together" })
              else if (value === "limits" && root.together) root.patch({ "philosophy": "limits" })
            }
          }
        }

        Text {
          textFormat: Text.PlainText
          width: parent.width
          wrapMode: Text.WordWrap
          text: root.together ? I18n.t("screenTime.togetherCaption") : I18n.t("screenTime.limitsCaption")
          color: root.fadeText(0.5)
          font.family: Style.font.family
          font.pixelSize: Style.font.caption
        }

        // A rule under the head, so the title and the modes read as the
        // window's own bar and the sections start below it.
        PanelSeparator { width: parent.width }
      }

      // --- the foot, pinned to the bottom of the window: saving ----------
      // In agreement mode a change applies as it is made, so there is
      // nothing to save and the foot only says so.
      Item {
        id: saveBar
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        anchors.margins: Style.space(24)
        anchors.topMargin: 0
        implicitHeight: Math.max(saveRow.implicitHeight, savedHint.implicitHeight)
        height: implicitHeight

        Text {
          id: savedHint
          visible: root.savedTogether && !root.dirty
          textFormat: Text.PlainText
          width: parent.width
          wrapMode: Text.WordWrap
          text: I18n.t("screenTime.appliesAsMade")
          color: root.fadeText(0.6)
          font.family: Style.font.family
          font.pixelSize: Style.font.caption
          anchors.verticalCenter: parent.verticalCenter
        }

        Row {
          id: saveRow
          visible: !savedHint.visible
          anchors.left: parent.left
          anchors.right: parent.right
          anchors.verticalCenter: parent.verticalCenter
          spacing: Style.space(8)

          Rectangle {
            width: saveRow.width - saveButton.width - discardButton.width - saveRow.spacing * 2
            height: Style.space(36)
            radius: Style.cornerRadius
            color: passwordField.activeFocus
              ? Qt.rgba(Commons.Color.accent.r, Commons.Color.accent.g, Commons.Color.accent.b, 0.18) : "transparent"
            border.width: 1
            border.color: passwordField.activeFocus ? Commons.Color.accent : root.fadeText(0.75)
            anchors.verticalCenter: parent.verticalCenter

            TextInput {
              id: passwordField
              anchors.fill: parent
              anchors.leftMargin: Style.space(10)
              anchors.rightMargin: Style.space(10)
              verticalAlignment: TextInput.AlignVCenter
              clip: true
              enabled: root.dirty && !root.saving
              echoMode: TextInput.Password
              passwordCharacter: "•"
              inputMethodHints: Qt.ImhSensitiveData | Qt.ImhNoPredictiveText | Qt.ImhNoAutoUppercase
              color: Commons.Color.foreground
              selectionColor: Util.alpha(Commons.Color.accent, 0.45)
              selectedTextColor: Commons.Color.foreground
              font.family: Style.font.family
              font.pixelSize: Style.font.body
              activeFocusOnTab: true
              onAccepted: root.save()
            }

            Text {
              textFormat: Text.PlainText
              anchors.fill: passwordField
              verticalAlignment: Text.AlignVCenter
              visible: passwordField.text.length === 0
              text: root.dirty ? I18n.t("screenTime.adultPasswordToSave") : I18n.t("screenTime.noChanges")
              color: root.fadeText(0.55)
              font.family: Style.font.family
              font.pixelSize: Style.font.body
              elide: Text.ElideRight
            }
          }

          Button {
            id: discardButton
            text: I18n.t("screenTime.discard")
            bordered: true
            focusable: true
            enabled: root.dirty && !root.saving
            anchors.verticalCenter: parent.verticalCenter
            onClicked: root.discard()
          }

          Button {
            id: saveButton
            text: I18n.t("screenTime.save")
            bordered: true
            focusable: true
            enabled: root.dirty && !root.saving
            anchors.verticalCenter: parent.verticalCenter
            onClicked: root.save()
          }
        }
      }

      // --- the body, scrolling --------------------------------------------
      ScrollView {
        id: scrollArea
        anchors.top: head.bottom
        anchors.bottom: saveBar.top
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.margins: Style.space(24)
        anchors.topMargin: Style.space(20)
        clip: true
        ScrollBar.horizontal.policy: ScrollBar.AlwaysOff

        // Sections are far apart, and everything inside one is close: the
        // separator gets the big gap on both sides, controls the small one.
        Column {
          id: content
          width: scrollArea.availableWidth
          spacing: Style.space(18)

          // --- together: the agreement ----------------------------------
          Column {
            width: parent.width
            spacing: Style.space(12)
            visible: root.together

            SectionHead {
              title: I18n.t("screenTime.agreementTitle")
              caption: I18n.t("screenTime.agreementCaption")
            }

            // An agreement is a few sentences, not a field, so it wraps and
            // grows. There is no editingFinished on a text area, so it saves
            // when the focus leaves and on ctrl+enter, and plain enter is a
            // newline like anywhere else you write prose.
            Rectangle {
              width: parent.width
              implicitHeight: Math.max(Style.space(84), agreementField.implicitHeight + Style.space(4))
              radius: Style.cornerRadius
              color: Style.controlFill(agreementField.activeFocus, agreementField.hovered,
                                       Commons.Color.foreground, Commons.Color.accent)
              border.width: 1
              border.color: agreementField.activeFocus
                ? Commons.Color.accent : root.fadeText(0.75)

              ScrollView {
                anchors.fill: parent
                anchors.margins: Style.space(2)
                clip: true

                TextArea {
                  id: agreementField
                  wrapMode: TextArea.Wrap
                  activeFocusOnTab: true
                  placeholderText: I18n.t("screenTime.agreementPlaceholder")
                  placeholderTextColor: root.fadeText(0.55)
                  color: Commons.Color.foreground
                  font.family: Style.font.family
                  font.pixelSize: Style.font.body
                  background: null

                  function save() {
                    var value = text.trim()
                    var current = root.pending.agreement_text !== undefined ? root.pending.agreement_text
                      : String(root.service ? root.service.agreementText : "")
                    if (value !== current)
                      root.patch({ "agreement_text": value })
                  }

                  onActiveFocusChanged: if (!activeFocus) save()

                  Keys.onPressed: function(event) {
                    if ((event.key === Qt.Key_Return || event.key === Qt.Key_Enter)
                        && (event.modifiers & Qt.ControlModifier)) {
                      save(); event.accepted = true
                    } else if (event.key === Qt.Key_Tab || event.key === Qt.Key_Backtab) {
                      // A text area swallows tab as a character, which would
                      // take this field out of the keyboard's reach.
                      save()
                      nextItemInFocusChain(event.key === Qt.Key_Tab).forceActiveFocus()
                      event.accepted = true
                    }
                  }
                }
              }
            }

            Row {
              spacing: Style.space(32)

              NumberBox {
                label: I18n.t("screenTime.agreedMinutes")
                value: Number(root.localAgreement.agreement_minutes) || 0
                min: 0; max: 1440; step: 5
                onChanged: function(n) {
                  root.localAgreement = { agreement_minutes: n, break_nudge_minutes: root.localAgreement.break_nudge_minutes }
                  root.patch({ "agreement_minutes": n })
                }
              }

              NumberBox {
                label: I18n.t("screenTime.nudgeMinutes")
                value: Number(root.localAgreement.break_nudge_minutes) || 0
                min: 0; max: 480; step: 5
                onChanged: function(n) {
                  root.localAgreement = { agreement_minutes: root.localAgreement.agreement_minutes, break_nudge_minutes: n }
                  root.patch({ "break_nudge_minutes": n })
                }
              }
            }
          }

          // --- budget ---------------------------------------------------
          Column {
            width: parent.width
            spacing: Style.space(12)
            visible: !root.together

            SectionHead {
              title: I18n.t("screenTime.budgetTitle")
              caption: I18n.t("screenTime.budgetCaption")
            }

            NumberBar {
              fields: root.dayKeys.map(function(k, i) { return { key: k, label: root.dayLabels[i], min: 0, max: 1440, step: 5 } })
              values: root.localBudget
              onChanged: function(key, minutes) {
                var next = {}
                for (var k in root.localBudget) next[k] = root.localBudget[k]
                next[key] = minutes
                root.localBudget = next
                var change = {}
                change[key] = minutes
                root.patch({ "budget_minutes": change })
              }
            }
          }

          PanelSeparator { width: parent.width; visible: !root.together }

          // --- blocked periods ------------------------------------------
          Column {
            id: periodsColumn
            width: parent.width
            spacing: Style.space(12)
            visible: !root.together

            Item {
              width: parent.width
              implicitHeight: periodsHead.implicitHeight

              SectionHead {
                id: periodsHead
                width: parent.width - periodsSwitch.width - Style.space(16)
                title: I18n.t("screenTime.periodsTitle")
                caption: I18n.t("screenTime.periodsCaption")
              }

              FocusSwitch {
                id: periodsSwitch
                anchors.right: parent.right
                anchors.verticalCenter: parent.verticalCenter
                checked: root.periodsOn
                onToggled: root.periodsOn ? root.setPeriodsOn(false)
                                          : (root.localPeriods.length > 0 ? root.setPeriodsOn(true) : root.addPeriod())
              }
            }

            Text {
              textFormat: Text.PlainText
              visible: root.periodsOn && root.localPeriods.length === 0
              text: I18n.t("screenTime.noPeriods")
              width: parent.width
              wrapMode: Text.WordWrap
              color: root.fadeText(0.5)
              font.family: Style.font.family
              font.pixelSize: Style.font.body
            }

            Repeater {
              model: root.periodsOn ? root.localPeriods : []

              // One card per period, so the name, the hours and the days
              // read as one thing and two periods never run into each other.
              delegate: Rectangle {
                id: periodCard
                required property var modelData
                required property int index
                width: periodsColumn.width
                implicitHeight: periodRow.implicitHeight + Style.space(24)
                radius: Style.cornerRadius
                color: root.fadeText(0.94)
                border.width: 1
                border.color: root.fadeText(0.82)

                Column {
                  id: periodRow
                  readonly property var modelData: periodCard.modelData
                  readonly property int index: periodCard.index
                  anchors.left: parent.left
                  anchors.right: parent.right
                  anchors.top: parent.top
                  anchors.margins: Style.space(12)
                  spacing: Style.space(10)

                // Which days it runs on, and on the right the way to take
                // the period away. The hours sit under it in a bar of their
                // own. No name: the kid's side says "blocked", which is all
                // a period has to say.
                Item {
                  width: parent.width
                  implicitHeight: periodRemove.implicitHeight

                  Text {
                    textFormat: Text.PlainText
                    text: I18n.t("screenTime.days")
                    color: root.fadeText(0.45)
                    font.family: Style.font.family
                    font.pixelSize: Style.font.caption
                    anchors.left: parent.left
                    anchors.verticalCenter: parent.verticalCenter
                  }

                  PanelActionButton {
                    id: periodRemove
                    iconText: root.iconClose
                    tooltipText: I18n.t("screenTime.removePeriod")
                    foreground: Commons.Color.foreground
                    hoverColor: root.errColor
                    size: Style.space(22)
                    focusable: true
                    anchors.right: parent.right
                    anchors.verticalCenter: parent.verticalCenter
                    onClicked: root.removePeriod(periodRow.index)
                  }
                }

                SegmentPicker {
                  options: root.dayKeys
                  labels: root.dayLabels
                  selected: periodRow.modelData.days || []
                  onToggled: function(key) { root.togglePeriodDay(periodRow.index, key) }
                }

                TimeBar {
                  start: String(periodRow.modelData.start || "")
                  end: String(periodRow.modelData.end || "")
                  onChanged: function(key, value) { root.setPeriod(periodRow.index, key, value) }
                }

                }
              }
            }

            // The one action of the section sits on the right, bordered,
            // under the cards it adds to.
            Item {
              width: parent.width
              implicitHeight: addPeriod.implicitHeight
              visible: root.periodsOn

              Text {
                textFormat: Text.PlainText
                visible: root.localPeriods.length >= root.periodLimit
                text: I18n.t("screenTime.periodLimit")
                color: root.fadeText(0.5)
                font.family: Style.font.family
                font.pixelSize: Style.font.caption
                anchors.left: parent.left
                anchors.verticalCenter: parent.verticalCenter
              }

              Button {
                id: addPeriod
                text: I18n.t("screenTime.addPeriod")
                bordered: true
                focusable: true
                enabled: root.localPeriods.length < root.periodLimit
                anchors.right: parent.right
                onClicked: root.addPeriod()
              }
            }
          }

          PanelSeparator { width: parent.width; visible: !root.together }

          // --- earning --------------------------------------------------
          Column {
            width: parent.width
            spacing: Style.space(12)
            visible: !root.together

            // The section's switch sits by its head, like the periods': off
            // hides everything beneath it.
            Item {
              width: parent.width
              implicitHeight: earnHead.implicitHeight

              SectionHead {
                id: earnHead
                width: parent.width - earnSwitch.width - Style.space(16)
                title: I18n.t("screenTime.earnTitle")
                caption: I18n.t("screenTime.earnCaption")
              }

              FocusSwitch {
                id: earnSwitch
                anchors.right: parent.right
                anchors.verticalCenter: parent.verticalCenter
                checked: root.earnEnabled
                onToggled: root.patch({ "earn": { "enabled": !root.earnEnabled } })
              }
            }

            Column {
              width: parent.width
              spacing: Style.space(10)
              visible: root.earnEnabled

              Toggle {
                width: parent.width
                label: I18n.t("screenTime.division")
                description: I18n.t("screenTime.divisionDescription")
                checked: root.divisionOn
                onClicked: root.patch({ "earn": { "ops": root.divisionOn ? ["mul"] : ["mul", "div"] } })
              }

              SectionHead {
                title: I18n.t("screenTime.tablesTitle")
                caption: I18n.t("screenTime.tablesCaption")
              }

              SegmentPicker {
                options: [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12]
                selected: root.tables
                onToggled: function(n) { root.toggleTable(n) }
              }

              Row {
                spacing: Style.space(32)

                NumberBox {
                  label: I18n.t("screenTime.secondsPerAnswer")
                  value: Number(root.localEarn.seconds_per_correct) || 0
                  min: 5; max: 600; step: 5
                  onChanged: function(n) {
                    root.localEarn = { seconds_per_correct: n, daily_cap_minutes: root.localEarn.daily_cap_minutes }
                    root.patch({ "earn": { "seconds_per_correct": n } })
                  }
                }

                NumberBox {
                  label: I18n.t("screenTime.earnCap")
                  value: Number(root.localEarn.daily_cap_minutes) || 0
                  min: 0; max: 480; step: 5
                  onChanged: function(n) {
                    root.localEarn = { seconds_per_correct: root.localEarn.seconds_per_correct, daily_cap_minutes: n }
                    root.patch({ "earn": { "daily_cap_minutes": n } })
                  }
                }
              }
            }
          }

          PanelSeparator { width: parent.width }

          // --- the web allowlist ----------------------------------------
          Column {
            width: parent.width
            spacing: Style.space(12)

            Item {
              width: parent.width
              implicitHeight: webHead.implicitHeight

              SectionHead {
                id: webHead
                width: parent.width - webSwitch.width - Style.space(16)
                title: I18n.t("screenTime.webTitle")
                caption: I18n.t("screenTime.webCaption")
              }

              FocusSwitch {
                id: webSwitch
                anchors.right: parent.right
                anchors.verticalCenter: parent.verticalCenter
                checked: root.shownWeb.enabled === true
                onToggled: root.patchWeb({ "enabled": !(root.shownWeb.enabled === true) })
              }
            }

            // One site per line; each also opens its subdomains. Saved into the
            // pending change when the focus leaves and on ctrl+enter, as the
            // agreement is.
            Rectangle {
              width: parent.width
              visible: root.shownWeb.enabled === true
              implicitHeight: Math.max(Style.space(120), webField.implicitHeight + Style.space(4))
              radius: Style.cornerRadius
              color: Style.controlFill(webField.activeFocus, webField.hovered, Commons.Color.foreground, Commons.Color.accent)
              border.width: 1
              border.color: webField.activeFocus ? Commons.Color.accent : root.fadeText(0.75)

              ScrollView {
                anchors.fill: parent
                anchors.margins: Style.space(2)
                clip: true

                TextArea {
                  id: webField
                  wrapMode: TextArea.NoWrap
                  activeFocusOnTab: true
                  placeholderText: I18n.t("screenTime.webPlaceholder")
                  placeholderTextColor: root.fadeText(0.55)
                  color: Commons.Color.foreground
                  font.family: Style.font.family
                  font.pixelSize: Style.font.body
                  background: null

                  function save() {
                    var domains = root.domainsFromText(text)
                    if (JSON.stringify(domains) !== JSON.stringify(root.shownWeb.domains))
                      root.patchWeb({ "domains": domains })
                  }

                  onActiveFocusChanged: if (!activeFocus) save()

                  Keys.onPressed: function(event) {
                    if ((event.key === Qt.Key_Return || event.key === Qt.Key_Enter)
                        && (event.modifiers & Qt.ControlModifier)) {
                      save(); event.accepted = true
                    } else if (event.key === Qt.Key_Tab || event.key === Qt.Key_Backtab) {
                      save()
                      nextItemInFocusChain(event.key === Qt.Key_Tab).forceActiveFocus()
                      event.accepted = true
                    }
                  }
                }
              }
            }
          }

          PanelSeparator { width: parent.width; visible: root.note !== "" }

          // --- the foot: only speaks when a save has something to say ---
          Text {
            textFormat: Text.PlainText
            visible: root.note !== ""
            text: root.note
            color: root.noteColor
            font.family: Style.font.family
            font.pixelSize: Style.font.caption
            width: parent.width
            elide: Text.ElideRight
          }
        }
      }
    }
  }
}
