import QtQuick
import QtQuick.Dialogs
import QtQuick.Effects
import Quickshell
import Quickshell.Io
import qs.Commons
import qs.Ui
import "Model.js" as Model

// Local AI: the model validated for your GPU, one click to run it, one click to open your agent on it.
// Model.js turns the backend's snapshot into a view; this file draws it and runs the backend's verbs.
Panel {
  id: root
  moduleName: "omarchy.local-ai"
  ipcTarget: "omarchy.local-ai"
  implicitWidth: button.implicitWidth
  implicitHeight: button.implicitHeight

  readonly property string cli: "omarchy-local-ai"
  readonly property color theme: bar ? bar.foreground : Color.foreground
  // the dots sit on the bar, which may be transparent: they take the bar's own foreground, as Omarchy's buttons do
  readonly property color dotTone: bar && bar.barForeground !== undefined ? bar.barForeground : theme
  readonly property color bg: Color.popups.background
  readonly property color surface: Util.alpha(theme, 0.06)
  readonly property color urgent: bar ? bar.urgent : Color.urgent
  readonly property string mono: bar ? bar.fontFamily : Style.font.family
  // Nerd Font glyphs for the icon names Model.js uses
  readonly property var glyphs: ({ gpu: 0xf08ae, memory: 0xf035b, temp: 0xf050f, context: 0xf09aa, weights: 0xf01a7, vision: 0xf06d0,
    speed: 0xf140c, tokens: 0xf04a0, agent: 0xf07b7, folder: 0xf0256, machine: 0xf0379, tailnet: 0xf0317, check: 0xf012c, down: 0xf0140 })
  function glyph(name) { return glyphs[name] ? String.fromCodePoint(glyphs[name]) : "" }

  // Four tones, each picked by the APCA contrast it must reach on a card (Model.tones): ink for what matters
  // now (a model's name, the primary action, a choice made), value for what a label names, one tone for every
  // label, and rule for lines that are not text. Problems use alert.
  readonly property var tones: Model.tones(theme, bg, surface, urgent)
  readonly property color ink: Qt.rgba(tones.ink.r, tones.ink.g, tones.ink.b, 1)
  readonly property color valueTone: Qt.rgba(tones.value.r, tones.value.g, tones.value.b, 1)
  readonly property color labelTone: Qt.rgba(tones.label.r, tones.label.g, tones.label.b, 1)
  readonly property color ruleTone: Qt.rgba(tones.rule.r, tones.rule.g, tones.rule.b, 1)
  readonly property color alertTone: Qt.rgba(tones.alert.r, tones.alert.g, tones.alert.b, 1)
  readonly property color alertRule: Qt.rgba(tones.alertRule.r, tones.alertRule.g, tones.alertRule.b, 1)

  // One grid. Every line of text starts and ends on the gutter; surfaces sit at the edge, so the text inside
  // them lands on the same gutter. Rows in a group touch; groups are a gap apart; a heading sits on its rows.
  readonly property int gutter: Style.space(20)
  readonly property int edge: Style.space(8)
  readonly property int pad: gutter - edge
  readonly property int rowH: Style.space(22)
  // the chart borders breathe between 12% and 26% of the ink every 3.6 s while one is on screen: ten steps a second,
  // too small to see apart, so the panel draws ten frames a second for it rather than sixty
  property real glow: 0.12
  Timer {
    property real t: 0
    interval: 100
    repeat: true
    running: root.opened && (!!root.view.hero && !!root.view.hero.line || (root.view.rows || []).some(function(r) { return r.type === "run" }))
    onTriggered: {
      t = (t + interval) % 3600
      root.glow = 0.19 - 0.07 * Math.cos(t / 3600 * 2 * Math.PI)
    }
  }
  readonly property int headH: Style.space(16)
  readonly property int groupGap: Style.space(20)
  readonly property int blockGap: Style.space(8)
  readonly property int topGap: Style.space(12)

  property var snap: ({})
  property var ui: ({ view: "home", id: "", open: "", key: "", problem: "" })
  property bool copied: false
  property bool revealed: false
  property var queue: []
  // a refresh asked for while a snapshot runs
  property bool again: false
  // A snapshot the view cannot read says so, rather than looking like a machine with no GPU
  readonly property var view: {
    try {
      return Model.build(snap, ui)
    } catch (e) {
      return { title: "LOCAL AI", mark: "failed", rows: [{ type: "error", label: "could not read the backend's answer: " + e.message }] }
    }
  }

  // a new view starts at its top with nothing chosen; within a view, a chosen model stays chosen
  function nav(patch) {
    var moved = patch.view !== undefined || patch.id !== undefined
    ui = Object.assign({ view: ui.view, id: ui.id, open: "", key: ui.key, problem: "", pollProblem: ui.pollProblem || "", registryBusy: ui.registryBusy || false, notice: ui.notice || "", updatingAgent: ui.updatingAgent || "", model: moved ? "" : ui.model || "" }, patch)
    revealed = false
    if (moved) flick.contentY = 0
  }
  function home() { nav({ view: "home", id: "", key: "" }) }
  function run(args) { queue.push(args); if (!verb.running) next() }
  function next() {
    if (!queue.length) return refresh()
    var args = queue.shift()
    verb.operation = args[0]
    verb.command = ["timeout", "--kill-after=5", args[0] === "update" ? "900" : "120", cli].concat(args)
    verb.running = true
  }
  // a refresh while a snapshot runs (the one after a verb) runs once that ends, so the verb's result shows at once
  function refresh() { if (poll.running) again = true; else poll.running = true }

  // The space above row i: a group opens a gap, a surface follows a surface closely, rows in a group touch
  function gapBefore(i) {
    var rows = view.rows || [], t = rows[i].type
    if (i === 0 && !view.hero && t !== "sec") return topGap
    if (t === "sec" || t === "acts" || t === "error") return groupGap
    if (t === "run" || t === "grid") return i === 0 && !view.hero ? topGap : blockGap
    return i === 0 ? topGap : 0
  }

  // An action is "verb|arg|arg", from Model.js
  function activate(action) {
    ui = Object.assign({}, ui, { notice: "", problem: "" })
    var a = (action || "").split("|")
    switch (a[0]) {
    case "forget": run(["forget", a[1]]); nav({ open: "" }); break
    case "default": run(["set", "agent", a[1]]); break
    case "update": ui = Object.assign({}, ui, { updatingAgent: a[1] }); run(["update", a[1]]); break
    case "folder":
      folderDialog.recipe = a[1]
      folderDialog.currentFolder = "file://" + encodeURI(decodeURIComponent(a[2]) || Quickshell.env("HOME")).replace(/#/g, "%23").replace(/\?/g, "%3F")
      folderDialog.selectedFolder = folderDialog.currentFolder
      root.close()
      Qt.callLater(function() { folderDialog.open() })
      break
    case "registry": ui = Object.assign({}, ui, { registryBusy: true, problem: "" }); run(["registry"]); break
    case "run": run(["run", a[1], a[2]]); home(); break
    case "again": run(["stop", a[1]]); run(["run", a[1], a[2]]); home(); break
    case "stop": run(["stop", a[1]]); home(); break
    // the panel stays up until the agent's terminal is launched, so a refusal shows here instead of vanishing
    case "open": run(["open", a[1]]); break
    case "share": run(["share", a[1]].concat(a[2] ? [a[2]] : [])); break
    case "set": run(["set", a[1], decodeURIComponent(a[2])].concat(a[3] ? [a[3]] : [])); nav({ open: "" }); break
    case "more": nav({ view: "run", id: a[1] }); break
    case "kind": nav({ view: "kind", id: a[1], key: a[2] || "" }); break
    case "group": nav({ view: "group", id: a[1], key: a[2] }); break
    case "model": nav({ model: a[1] }); break
    case "gpus": nav({ view: "gpus", id: "" }); break
    case "agents": nav({ view: "agents", id: "" }); break
    case "pick": nav({ open: ui.open === a[1] ? "" : a[1] }); break
    case "home": home(); break
    case "log": Quickshell.execDetached([cli, "log"]); root.close(); break
    case "url": Quickshell.execDetached(["omarchy-launch-browser", a[1]]); root.close(); break
    case "copy": copy.command = ["wl-copy", a[1]]; copy.running = true; copied = true; copiedTimer.restart(); break
    }
  }

  function polled(code, text) {
    var s = code === 0 ? Model.parse(text) : null
    var ok = s && Array.isArray(s.gpus) && Array.isArray(s.kinds) && Array.isArray(s.deployments)
    if (ok) snap = s
    ui = Object.assign({}, ui, { pollProblem: ok ? "" : "Could not refresh Local AI; retrying." })
  }
  Process {
    id: poll
    command: ["timeout", "--kill-after=5", "90", root.cli, "snapshot"]
    stdout: StdioCollector { id: pollOut; waitForEnd: true }
    onExited: function(code) { root.polled(code, pollOut.text); if (root.again) { root.again = false; Qt.callLater(root.refresh) } }
  }
  // A verb that fails says why on its last "local-ai:" line; the panel opens to show it.
  function finished(code, operation, output, error) {
    ui = Object.assign({}, ui, { registryBusy: false, updatingAgent: operation === "update" ? "" : ui.updatingAgent || "" })
    if (code !== 0) {
      var m = (error || "").split("\n").filter(function(l) { return l.indexOf("local-ai: ") === 0 }).pop()
      queue = []
      if (!root.opened) root.open()
      ui = Object.assign({}, ui, { problem: code === 124 || code === 137 ? "That took too long; try again." : m ? m.slice(10) : "that did not work (see the log)" })
    } else if (operation === "open") {
      root.close()
    } else if (operation === "registry" || operation === "update") {
      ui = Object.assign({}, ui, { notice: output.trim(), problem: "" })
    }
    next()
  }
  Process {
    id: verb
    property string operation: ""
    stdout: StdioCollector { id: verbOut; waitForEnd: true }
    stderr: StdioCollector { id: verbErr; waitForEnd: true }
    onExited: function(code) { root.finished(code, operation, verbOut.text, verbErr.text) }
  }
  function pickedFolder(url, id) {
    run(["set", "folder", decodeURIComponent(String(url).replace(/^file:\/\//, ""))].concat(id ? [id] : []))
  }
  FolderDialog {
    id: folderDialog
    property string recipe: ""
    title: "Choose the agent's folder"
    function returnToSettings() {
      root.open()
      root.nav({ view: recipe ? "run" : "agents", id: recipe })
    }
    onAccepted: { root.pickedFolder(selectedFolder, recipe); returnToSettings() }
    onRejected: returnToSettings()
  }
  Process { id: copy }
  Timer { id: copiedTimer; interval: 1500; onTriggered: root.copied = false }
  Timer {
    interval: root.view.mark === "busy" ? (root.opened ? 1500 : 5000) : root.opened ? 5000 : 30000
    running: true; repeat: true; triggeredOnStart: true
    onTriggered: root.refresh()
  }
  // a failure stays until it is read: closing the panel clears it, and the dots with it
  onOpenedChanged: if (opened) { refresh(); if (!ui.problem) home() } else if (ui.problem) ui = Object.assign({}, ui, { problem: "" })

  // Nine dots: faint when idle, lit when a model is ready, urgent when one failed, a diagonal ripple while working
  property int ripple: 0
  Timer { interval: 160; repeat: true; running: root.view.mark === "busy"; onTriggered: root.ripple = (root.ripple + 1) % 5 }
  BarIconButton {
    id: button
    objectName: "local-ai-mark"
    anchors.fill: parent
    bar: root.bar
    tooltipText: "Local AI"
    onPressed: root.toggle()
    iconComponent: Component {
      Item {
        Grid {
          anchors.centerIn: parent
          columns: 3
          spacing: Style.space(2)
          Repeater {
            model: 9
            Rectangle {
              required property int index
              readonly property bool on: root.view.mark === "busy" ? (index % 3 + Math.floor(index / 3)) === root.ripple % 5 : !!root.view.mark
              width: Style.space(3)
              height: width
              radius: width / 2
              color: root.view.mark === "failed" ? root.urgent : on ? root.dotTone : Util.alpha(root.dotTone, 0.3)
            }
          }
        }
      }
    }
  }

  KeyboardPanel {
    id: panel
    anchorItem: button
    owner: root
    bar: root.bar
    open: root.opened
    focusTarget: keys
    padding: 0
    contentWidth: Style.space(340)
    contentHeight: panel.fittedContentHeight(content.implicitHeight)

    Rectangle { anchors.fill: parent; color: root.bg }
    Item {
      id: keys
      anchors.fill: parent
      focus: true
      Keys.onEscapePressed: root.ui.view === "home" ? root.close() : root.home()

      Flickable {
        id: flick
        anchors.fill: parent
        contentHeight: content.implicitHeight
        clip: true
        interactive: contentHeight > height
        boundsBehavior: Flickable.StopAtBounds

        Column {
          id: content
          objectName: "local-ai-content"
          width: flick.width
          topPadding: Style.space(16)
          bottomPadding: Style.space(16)
          spacing: 0

          // The top line: the name and version, or the way back
          Item {
            width: parent.width
            height: root.headH
            Label {
              id: head
              x: root.gutter
              anchors.verticalCenter: parent.verticalCenter
              text: root.view.back ? "‹ home" : root.view.title
              color: root.view.back ? root.valueTone : root.labelTone
            }
            Label {
              visible: !root.view.back
              anchors.left: head.right
              anchors.leftMargin: Style.space(8)
              anchors.baseline: head.baseline
              text: root.view.version || ""
              color: Util.alpha(root.labelTone, 0.55)
              font.pixelSize: Style.font.caption - 2
            }
            Click { anchors.fill: head; action: root.view.back ? "home" : "" }
          }

          Item {
            width: parent.width
            height: root.view.hero && hero.item ? root.topGap + hero.item.implicitHeight : 0
            Loader {
              id: hero
              active: !!root.view.hero
              x: root.edge
              y: root.topGap
              width: parent.width - 2 * root.edge
              sourceComponent: Component { Hero { h: root.view.hero } }
            }
          }

          Repeater {
            // keyed by position, so a refresh updates rows in place instead of rebuilding them (no flicker)
            model: (root.view.rows || []).length
            Item {
              required property int index
              readonly property var r: (root.view.rows || [])[index] || ({ type: "" })
              readonly property int gap: root.gapBefore(index)
              width: content.width
              height: gap + row.height

              // A Loader sizes its item, so a surface's inset lives on the Loader; other rows keep their own gutter
              Loader {
                id: row
                readonly property real inset: ["run", "grid"].indexOf(r.type) >= 0 ? root.edge : 0
                x: inset
                y: parent.gap
                width: parent.width - 2 * inset
                sourceComponent: ({ life: lifeC, run: runC, slot: slotC, links: linksC, soon: soonC, grid: gridC, gpu: gpuC,
                  field: fieldC, agent: agentC, opt: optC, acts: linksC })[r.type] || textC
              }

              // Your lifetime: the totals, then the activity grid (a column a week, a row a weekday) with its months
              Component {
                id: lifeC
                Column {
                  id: life
                  objectName: "local-ai-life"
                  readonly property int cols: Math.ceil((r.cells || []).length / 7)
                  readonly property real cell: Math.min(Style.space(12), (width - 2 * root.gutter - (cols - 1) * Style.space(3)) / cols)
                  // Day details stay beneath the chart; the totals never move on hover.
                  property int hover: -1
                  spacing: Style.space(10)
                  Item {
                    width: parent.width
                    height: lifeTokens.implicitHeight
                    Row {
                      x: root.gutter
                      spacing: Style.space(10)
                      Label { id: lifeTokens; text: r.tokens; color: root.ink }
                      Label { anchors.baseline: lifeTokens.baseline; text: r.requests; color: root.labelTone }
                    }
                    Right {
                      margin: root.gutter
                      text: r.since
                      color: root.labelTone
                    }
                  }
                  Grid {
                    x: root.gutter
                    rows: 7
                    flow: Grid.TopToBottom
                    spacing: Style.space(3)
                    Repeater {
                      // keyed by position, so a refresh recolours the squares instead of rebuilding them
                      model: (r.cells || []).length
                      Rectangle {
                        required property int index
                        readonly property int level: (r.cells || [])[index]
                        width: life.cell
                        height: life.cell
                        radius: 2
                        color: level < 0 ? "transparent" : Util.alpha(root.theme, [0.07, 0.25, 0.45, 0.7, 0.95][level])
                        border.width: life.hover === index ? 1 : 0
                        border.color: root.ink
                        MouseArea {
                          anchors.fill: parent
                          enabled: level >= 0
                          hoverEnabled: true
                          onEntered: life.hover = index
                          onExited: if (life.hover === index) life.hover = -1
                        }
                      }
                    }
                  }
                  Item {
                    width: parent.width
                    height: Style.space(12)
                    Repeater {
                      model: r.months || []
                      Label {
                        required property var modelData
                        x: root.gutter + modelData.col * (life.cell + Style.space(3))
                        text: modelData.label
                        color: root.labelTone
                        font.pixelSize: Style.font.caption - 1
                      }
                    }
                  }
                  Label {
                    x: root.gutter
                    width: parent.width - 2 * root.gutter
                    text: (r.labels || [])[life.hover >= 0 ? life.hover : (r.labels || []).length - 1] || ""
                    color: root.labelTone
                    font.pixelSize: Style.font.caption
                  }
                }
              }

              // A running model: its all-time token line across the whole card, behind its name, card, speed and
              // tokens; Open and More
              Component {
                id: runC
                Rectangle {
                  height: Style.space(156)
                  // a little above the page: a lighter surface, and a light border that glows slowly
                  color: Util.alpha(root.theme, 0.08)
                  border.width: 1
                  border.color: Util.alpha(root.theme, root.glow)
                  clip: true
                  Line { anchors.fill: parent; values: r.line }
                  Column {
                    x: root.pad
                    y: Style.space(16)
                    width: parent.width - 2 * root.pad
                    spacing: Style.space(6)
                    Row {
                      width: parent.width
                      spacing: Style.space(10)
                      Logo { id: cardLogo; family: r.family; size: 18; anchors.verticalCenter: parent.verticalCenter }
                      Label { width: parent.width - (cardLogo.visible ? cardLogo.width + parent.spacing : 0); elide: Text.ElideRight; text: r.name; color: root.ink; font.pixelSize: Style.font.subtitle }
                    }
                    Row {
                      spacing: Style.space(10)
                      Label { text: r.gpu; color: root.labelTone }
                      Label { visible: !!r.mem; text: r.mem || ""; color: Util.alpha(root.labelTone, 0.6) }
                    }
                    Item { width: 1; height: Style.space(4) }
                    Label {
                      visible: !!r.sub
                      width: parent.width
                      text: r.sub || ""
                      color: root.valueTone
                      wrapMode: Text.WordWrap
                      maximumLineCount: 2
                      elide: Text.ElideRight
                    }
                    Rectangle {
                      visible: r.progress >= 0
                      width: parent.width
                      height: 2
                      color: root.ruleTone
                      Rectangle { width: parent.width * (r.progress || 0) / 100; height: parent.height; color: root.ink }
                    }
                  }
                  // speed and tokens, small, in the bottom-right corner, level with the buttons
                  Chips {
                    items: r.chips || []
                    anchors.right: parent.right
                    anchors.rightMargin: root.pad
                    anchors.bottom: parent.bottom
                    anchors.bottomMargin: Style.space(20)
                    size: Style.font.caption - 1
                  }
                  Row {
                    x: root.pad
                    anchors.bottom: parent.bottom
                    anchors.bottomMargin: Style.space(14)
                    spacing: Style.space(8)
                    Btn {
                      label: r.primary.label + (r.primary.quiet ? "" : " ›")
                      action: r.primary.action
                      primary: !r.primary.quiet
                      danger: !!r.primary.quiet
                    }
                    Btn { label: "More"; action: r.more }
                  }
                }
              }

              // One GPU: its name, and on the right one quick action (the model to run on it, or run again) or what
              // it is doing; a crashed one also offers dismiss beside it, and is framed in dashes. Clicking the row
              // opens a line under it with the rest.
              Component {
                id: slotC
                Item {
                  height: r.crashed ? Style.space(34) : root.rowH
                  Canvas {
                    visible: !!r.crashed
                    x: root.edge
                    width: parent.width - 2 * root.edge
                    height: parent.height
                    onPaint: {
                      var g = getContext("2d")
                      g.clearRect(0, 0, width, height)
                      g.setLineDash([3, 3])
                      g.strokeStyle = root.alertRule
                      g.strokeRect(0.5, 0.5, width - 1, height - 1)
                    }
                  }
                  Click { action: r.toggle || "" }
                  Row {
                    x: root.gutter
                    anchors.verticalCenter: parent.verticalCenter
                    spacing: Style.space(10)
                    Label { text: r.label; color: r.open ? root.ink : root.valueTone }
                    Label { visible: !!r.hint; text: r.hint || ""; color: root.alertTone }
                  }
                  Row {
                    id: slotRun
                    visible: !!r.run
                    anchors.right: parent.right
                    anchors.rightMargin: root.gutter
                    anchors.verticalCenter: parent.verticalCenter
                    spacing: Style.space(6)
                    Logo { family: r.run && r.run.family || ""; size: 12; anchors.verticalCenter: parent.verticalCenter }
                    Label { text: r.run ? r.run.label : ""; color: root.ink }
                  }
                  Click { anchors.fill: slotRun; action: r.run ? r.run.action : "" }
                  Label {
                    id: slotDismiss
                    visible: !!r.dismiss
                    anchors.right: slotRun.left
                    anchors.rightMargin: Style.space(16)
                    anchors.verticalCenter: parent.verticalCenter
                    text: "dismiss"
                    color: root.labelTone
                  }
                  Click { anchors.fill: slotDismiss; action: r.dismiss || "" }
                  Right {
                    visible: !r.run
                    margin: root.gutter
                    width: Math.min(implicitWidth, parent.width * 0.6)
                    elide: Text.ElideRight
                    text: r.note || ""
                    color: r.warn ? root.alertTone : root.labelTone
                  }
                }
              }

              // A row of buttons, with what there is to know above it: the line a GPU row opens, or a page's actions
              Component {
                id: linksC
                Column {
                  topPadding: Style.space(2)
                  bottomPadding: Style.space(10)
                  spacing: Style.space(8)
                  Chips { visible: (r.chips || []).length > 0; x: root.gutter; items: r.chips || [] }
                  Label { visible: !!r.note; x: root.gutter; width: parent.width - 2 * root.gutter; text: r.note || ""; color: root.labelTone; wrapMode: Text.WordWrap }
                  // the same buttons as a model card's: filled for the main action, outlined for the rest
                  Flow {
                    visible: (r.items || []).length > 0
                    x: root.gutter
                    width: parent.width - 2 * root.gutter
                    spacing: Style.space(8)
                    Repeater {
                      model: r.items || []
                      Btn {
                        required property var modelData
                        label: modelData.label
                        action: modelData.action
                        primary: !!modelData.primary
                        danger: !!modelData.danger
                      }
                    }
                  }
                }
              }

              // No card to run on: a square wave, one line, and where the list of supported cards lives
              Component {
                id: soonC
                Column {
                  topPadding: Style.space(28)
                  bottomPadding: Style.space(20)
                  spacing: Style.space(18)
                  // a square wave drifting left, thin and quiet, fading out at both ends: four thin rectangles a period,
                  // a period more than it shows, slid along, so no frame draws anything
                  Item {
                    anchors.horizontalCenter: parent.horizontalCenter
                    width: Style.space(140)
                    height: Style.space(18)
                    clip: true
                    // a period every 2.4 s, twenty steps a second: half a pixel a step, as smooth as sixty frames
                    Timer {
                      interval: 50
                      repeat: true
                      running: root.opened
                      onTriggered: wave.x = (wave.x - wave.period * interval / 2400) % wave.period
                    }
                    Row {
                      id: wave
                      readonly property real period: Style.space(28)
                      readonly property real stroke: 1.5
                      Repeater {
                        model: Math.ceil(Style.space(140) / wave.period) + 1
                        Item {
                          width: wave.period
                          height: Style.space(18)
                          Rectangle { x: -wave.stroke / 2; y: 2 - wave.stroke / 2; width: wave.stroke; height: parent.height - 4 + wave.stroke; color: root.labelTone }
                          Rectangle { y: 2 - wave.stroke / 2; width: wave.period / 2; height: wave.stroke; color: root.labelTone }
                          Rectangle { x: wave.period / 2 - wave.stroke / 2; y: 2 - wave.stroke / 2; width: wave.stroke; height: parent.height - 4 + wave.stroke; color: root.labelTone }
                          Rectangle { x: wave.period / 2; y: parent.height - 2 - wave.stroke / 2; width: wave.period / 2; height: wave.stroke; color: root.labelTone }
                        }
                      }
                    }
                    Rectangle {
                      width: parent.width / 4
                      height: parent.height
                      gradient: Gradient { orientation: Gradient.Horizontal; GradientStop { position: 0; color: root.bg } GradientStop { position: 1; color: "transparent" } }
                    }
                    Rectangle {
                      x: parent.width * 3 / 4
                      width: parent.width / 4
                      height: parent.height
                      gradient: Gradient { orientation: Gradient.Horizontal; GradientStop { position: 0; color: "transparent" } GradientStop { position: 1; color: root.bg } }
                    }
                  }
                  Label {
                    x: root.gutter
                    width: parent.width - 2 * root.gutter
                    horizontalAlignment: Text.AlignHCenter
                    text: r.head
                    wrapMode: Text.WordWrap
                  }
                  Btn { anchors.horizontalCenter: parent.horizontalCenter; label: "See supported cards ›"; action: r.action }
                }
              }

              // A section's name, or an error in its place
              Component {
                id: textC
                Label {
                  readonly property bool sec: r.type === "sec"
                  leftPadding: root.gutter; rightPadding: root.gutter
                  width: parent.width
                  height: sec ? root.headH : implicitHeight
                  verticalAlignment: Text.AlignVCenter
                  text: r.label || ""
                  color: sec ? root.labelTone : root.alertTone
                  wrapMode: Text.WordWrap
                }
              }

              // Six figures, three by two, hairline gaps
              Component {
                id: gridC
                Grid {
                  columns: 3
                  spacing: 1
                  Repeater {
                    model: r.cells
                    Rectangle {
                      required property var modelData
                      width: (parent.width - 2) / 3
                      height: Style.space(44)
                      color: root.surface
                      Column {
                        x: root.pad
                        anchors.verticalCenter: parent.verticalCenter
                        spacing: Style.space(4)
                        Row {
                          spacing: Style.space(6)
                          Label { id: figure; text: modelData.v }
                          Label { anchors.baseline: figure.baseline; text: modelData.u; color: root.labelTone }
                        }
                        Label { text: modelData.k; color: root.labelTone }
                      }
                    }
                  }
                }
              }

              // One card: its name (and what holds it), memory in use, temperature
              Component {
                id: gpuC
                Item {
                  height: r.status ? Style.space(36) : root.rowH
                  Column {
                    x: root.gutter
                    width: Style.space(100)
                    anchors.verticalCenter: parent.verticalCenter
                    spacing: Style.space(2)
                    Label { width: parent.width; text: r.name; elide: Text.ElideRight }
                    Label { visible: !!text; text: r.status || ""; color: root.labelTone }
                  }
                  Rectangle {
                    x: root.gutter + Style.space(104)
                    visible: r.bar
                    width: Math.max(0, gpuMem.x - x - Style.space(12))
                    height: 3
                    anchors.verticalCenter: parent.verticalCenter
                    color: root.ruleTone
                    Rectangle {
                      width: parent.width * r.pct / 100
                      height: parent.height
                      color: root.valueTone
                    }
                  }
                  Right { id: gpuMem; margin: root.gutter; text: r.mem + (r.temp ? "  " + r.temp : "") }
                }
              }

              // A label on the left, a value on the right; a secret value stays hidden, small, until clicked, beside an always-on copy
              Component {
                id: fieldC
                Item {
                  height: root.rowH
                  Row {
                    id: fieldLabel
                    x: root.gutter
                    anchors.verticalCenter: parent.verticalCenter
                    spacing: Style.space(8)
                    Label { visible: !!r.icon; width: Style.space(12); text: root.glyph(r.icon || ""); color: root.labelTone }
                    Logo { family: r.logo || ""; size: 12; anchors.verticalCenter: parent.verticalCenter }
                    Label { text: r.label; color: root.labelTone }
                  }
                  // a long value (a weights repository) gives way in its middle rather than run over the label
                  Right {
                    id: fieldValue
                    margin: root.gutter
                    width: Math.min(implicitWidth, parent.width - fieldLabel.x - fieldLabel.width - root.gutter - Style.space(16))
                    elide: Text.ElideMiddle
                    text: r.secret ? (root.copied ? "copied" : "copy") : r.value + (r.drop ? "  " + root.glyph("down") : r.action ? " ›" : "")
                    color: r.open ? root.ink : root.valueTone
                  }
                  Label {
                    id: secretValue
                    visible: !!r.secret
                    anchors.right: fieldValue.left
                    anchors.rightMargin: Style.space(10)
                    anchors.verticalCenter: parent.verticalCenter
                    width: Math.max(0, fieldValue.x - fieldLabel.x - fieldLabel.width - Style.space(20))
                    elide: Text.ElideMiddle
                    text: !r.secret ? "" : root.revealed ? r.value : r.value.replace(/[^.:\/]+/g, "•••")
                    color: Util.alpha(root.labelTone, root.revealed ? 1 : 0.55)
                    font.pixelSize: Style.font.caption - 2
                  }
                  Click { visible: !r.secret; action: r.action || "" }
                  Click { visible: !!r.secret; anchors.fill: fieldValue; action: r.action || "" }
                  MouseArea { visible: !!r.secret; anchors.fill: secretValue; cursorShape: Qt.PointingHandCursor; onClicked: root.revealed = !root.revealed }
                }
              }

              Component {
                id: optC
                Item {
                  height: root.rowH
                  Row {
                    id: optLabel
                    x: root.gutter
                    width: Math.max(0, optValue.x - x - Style.space(10))
                    anchors.verticalCenter: parent.verticalCenter
                    spacing: Style.space(8)
                    Label { width: Style.space(12); text: r.on ? root.glyph("check") : ""; color: root.ink }
                    Label {
                      objectName: "local-ai-option-name"
                      width: Math.max(0, optLabel.width - Style.space(20))
                      elide: Text.ElideRight
                      text: r.label
                      color: r.on ? root.ink : r.off ? root.labelTone : root.valueTone
                    }
                  }
                  // Keep the fit visible and give long model names the remaining space.
                  Right {
                    id: optValue
                    objectName: "local-ai-option-fit"
                    margin: root.gutter
                    width: r.value ? Math.min(implicitWidth, (parent.width - 2 * root.gutter) / 2) : 0
                    horizontalAlignment: Text.AlignRight
                    elide: Text.ElideRight
                    text: r.value || ""
                    color: root.labelTone
                  }
                  Click { action: r.action }
                }
              }

              Component {
                id: agentC
                Item {
                  height: Style.space(38)
                  Row {
                    x: root.gutter
                    anchors.verticalCenter: parent.verticalCenter
                    spacing: Style.space(10)
                    Item {
                      width: Style.space(24); height: width
                      Image {
                        id: agentLogo
                        anchors.fill: parent
                        source: ["claude", "codex", "omp", "opencode", "hermes", "copilot", "crush"].indexOf(r.agent) >= 0 ? Qt.resolvedUrl("agents/" + r.agent + (r.agent === "crush" ? ".png" : ".svg")) : ""
                        fillMode: Image.PreserveAspectFit
                        layer.enabled: true
                        layer.effect: MultiEffect { colorization: 1; colorizationColor: root.ink }
                      }
                      Label {
                        anchors.centerIn: parent
                        visible: agentLogo.status !== Image.Ready
                        font.pixelSize: Style.space(20)
                        text: ({ pi: "π", grok: "𝕏" })[r.agent] || root.glyph("agent")
                      }
                    }
                    Label { anchors.verticalCenter: parent.verticalCenter; text: r.label; color: root.ink }
                  }
                  Right { margin: root.gutter; text: r.value + " ›"; color: root.labelTone }
                  Click { action: r.action }
                }
              }

            }
          }
        }
      }
    }
  }

  // ---------------------------------------------------------------- pieces

  component Label: Text {
    textFormat: Text.PlainText
    color: root.valueTone
    font.family: root.mono
    font.pixelSize: Style.font.caption
  }

  // Facts as small icon-and-text pairs, spaced instead of joined with dots
  component Chips: Flow {
    id: chips
    property var items: []
    property color tone: root.labelTone
    property int size: Style.font.caption
    spacing: Style.space(12)
    Repeater {
      model: chips.items
      Row {
        required property var modelData
        spacing: Style.space(4)
        Label { id: chipIcon; visible: !!modelData.icon; text: root.glyph(modelData.icon || ""); color: root.labelTone; font.pixelSize: chips.size }
        // a fact longer than the line wraps inside it
        Label {
          visible: !!modelData.text
          width: Math.min(implicitWidth, chips.width - (chipIcon.visible ? chipIcon.width + Style.space(4) : 0))
          wrapMode: Text.WordWrap
          text: modelData.text || ""
          color: chips.tone
          font.pixelSize: chips.size
        }
      }
    }
  }

  // A label against its row's right edge
  component Right: Label {
    property int margin
    anchors.right: parent.right
    anchors.rightMargin: margin
    anchors.verticalCenter: parent.verticalCenter
  }

  // A whole row, or the item it fills, that runs an action; nothing when the action is ""
  component Click: MouseArea {
    property string action
    anchors.fill: parent
    enabled: action !== ""
    cursorShape: Qt.PointingHandCursor
    onClicked: root.activate(action)
  }

  component Logo: Image {
    property string family
    property int size
    width: Style.space(size)
    height: width
    // only the logos shipped beside this file; any other family shows none and takes no space
    readonly property bool shipped: ["qwen", "hf"].indexOf(family) >= 0
    visible: shipped && status === Image.Ready
    source: shipped ? Qt.resolvedUrl(family + ".svg") : ""
    sourceSize: Qt.size(Style.space(32), Style.space(32))
    fillMode: Image.PreserveAspectFit
  }


  // Tokens over time, cumulative, rising to the right: a dim line over a faint area, so text over it keeps its contrast
  component Line: Canvas {
    property var values: []
    onValuesChanged: requestPaint()
    Component.onCompleted: requestPaint()
    onPaint: {
      var g = getContext("2d"), v = values || [], n = v.length, top = Math.max.apply(null, v.concat([1]))
      g.clearRect(0, 0, width, height)
      if (n < 2 || top <= 1) return
      g.beginPath()
      for (var i = 0; i < n; i++) {
        var x = i / (n - 1) * width, y = height - 4 - v[i] / top * (height * 0.8)
        if (i) g.lineTo(x, y)
        else g.moveTo(x, y)
      }
      g.strokeStyle = Qt.rgba(root.ink.r, root.ink.g, root.ink.b, 0.25)
      g.lineWidth = 1.2
      g.stroke()
      g.lineTo(width, height)
      g.lineTo(0, height)
      g.closePath()
      g.fillStyle = Qt.rgba(root.ink.r, root.ink.g, root.ink.b, 0.06)
      g.fill()
    }
  }

  // Primary is filled with ink; secondary is outlined in the same ink, so the pair reads as one family;
  // danger is outlined in alert. The label is centered optically, not on its advance: first on its ink (a
  // trailing "›" carries empty space on its right), then nudged right by a sixth of the space and chevron,
  // since a thin chevron weighs less than the letters and would otherwise leave "Open pi ›" sitting left.
  component Btn: Rectangle {
    id: btn
    property string label
    property string action
    property bool primary
    property bool danger
    readonly property bool chevron: /\s›$/.test(label)
    readonly property rect glyphs: metrics.tightBoundingRect
    readonly property real weight: chevron ? (glyphs.x + glyphs.width - words.tightBoundingRect.x - words.tightBoundingRect.width) / 6 : 0
    visible: label !== ""
    implicitWidth: Math.ceil(glyphs.width) + Style.space(24)
    implicitHeight: btnText.implicitHeight + Style.space(10)
    color: primary ? root.ink : "transparent"
    border.width: primary ? 0 : 1
    border.color: danger ? root.alertRule : root.ink
    opacity: action === "" ? 0.5 : 1
    TextMetrics { id: metrics; font: btnText.font; text: btn.label }
    TextMetrics { id: words; font: btnText.font; text: btn.label.replace(/\s›$/, "") }
    Label {
      id: btnText
      anchors.centerIn: parent
      anchors.horizontalCenterOffset: metrics.advanceWidth / 2 - (btn.glyphs.x + btn.glyphs.width / 2) + btn.weight
      text: btn.label
      color: btn.primary ? Qt.rgba(root.bg.r, root.bg.g, root.bg.b, 1) : btn.danger ? root.alertTone : root.ink
    }
    Click { action: btn.action }
  }

  // The top of a model's page: its name, what it is, and a surface under them (its token line with the scale
  // and dates, when it runs)
  component Hero: Column {
    property var h
    spacing: 0
    Column {
      x: root.pad
      width: parent.width - 2 * root.pad
      spacing: Style.space(4)
      Row {
        width: parent.width
        spacing: Style.space(8)
        Logo { id: heroLogo; family: h.family; size: 14; anchors.verticalCenter: parent.verticalCenter }
        Label { width: parent.width - (heroLogo.visible ? heroLogo.width + parent.spacing : 0); elide: Text.ElideRight; text: h.name; color: root.ink; font.pixelSize: Style.font.body }
      }
      Chips { width: parent.width; items: h.chips || []; tone: root.valueTone }
    }
    Item { width: 1; height: root.topGap }
    // a running model's token line, edge to edge, with its numbers over it (a free card has none)
    Rectangle {
      visible: !!h.line
      width: parent.width
      height: visible ? Style.space(110) : 0
      color: root.surface
      border.width: 1
      border.color: Util.alpha(root.theme, root.glow)
      clip: true
      Line { anchors.fill: parent; values: h.line || [] }
      Label { x: root.pad; y: Style.space(8); text: h.top || ""; color: root.labelTone }
      Label { x: root.pad; y: parent.height / 2 - height / 2; text: h.mid || ""; color: root.labelTone }
      Label { x: root.pad; y: parent.height - Style.space(8) - height; text: h.since || ""; color: root.labelTone }
      Label { x: parent.width - Style.space(6) - width; y: parent.height - Style.space(8) - height; text: h.now || ""; color: root.labelTone }
    }
  }
}
