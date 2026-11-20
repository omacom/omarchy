import QtQuick
import qs.Commons
import qs.Commons as Commons
import qs.Ui
import "SetupModel.js" as SetupModel
import "scenes"

// The card Setup is drawn on. It decides nothing about the system itself: it
// reports the row to run, or the command a finished tour adds up to.
//
// It is drawn from the [menu] colors, as the menu is, rather than from the
// kit's Button: a row's mark and its label need two fonts, and a button filled
// in the text color is not something Button can be asked for.
BorderSurface {
  id: root

  // Every page, and the tour's steps among them, from SetupData.
  property var pages: []
  property var steps: []
  // The local model on offer, for the page that describes it.
  property var offer: null
  // Once the menu, its guards and the local listing have answered. Until
  // then nothing can be picked: a row could still vanish, gain its check, or
  // move as a page arrives above it.
  property bool ready: false

  // "tour" walks the essentials and changes nothing until Finish. "app" lists
  // every page and runs a row as the menu would.
  property string mode: "app"
  // In the tour, -1 is the splash and steps.length the summary.
  property int stepIndex: -1
  property int pageIndex: 0
  // What the tour has picked so far, step id to option id.
  property var staged: ({})
  // The option under the keyboard cursor or the pointer.
  property int cursor: 0
  // On the summary, the button the keyboard is on: 0 goes back, 1 finishes.
  property int summaryCursor: 1
  // The page a summon asked for, until the pages are there to find it in.
  property string wantedPage: ""
  // Get started was pressed before there were steps to start on.
  property bool pendingStart: false
  // On the pages, the keyboard has tabbed past the last one to the tour's link.
  property bool onTourLink: false
  // The cursor is being moved by the pointer, which must not scroll the list
  // out from under itself.
  property bool pointing: false

  signal dismissed()
  // A row to run as the menu would: its action, or its route into the menu.
  signal activated(var option)
  // The tour is done, with the command its choices add up to, or none, and
  // the steps those choices were made at.
  signal finished(var argv, var steps)

  readonly property bool touring: mode === "tour"
  readonly property bool onSplash: touring && stepIndex < 0
  readonly property bool onSummary: touring && stepIndex >= steps.length
  readonly property var page: touring ? (onSplash || onSummary ? null : steps[stepIndex]) : (pages[pageIndex] || null)
  readonly property var options: SetupModel.flatOptions(page)
  readonly property var cursorOption: options[cursor] || null
  readonly property var plan: SetupModel.tourPlan(steps, staged)
  readonly property bool large: !!page && page.groups.length === 1 && options.length <= 4
  // Up to four options get a tall card each. Five or six sit three to a row,
  // so the second row is not one or two stragglers; more than that, four.
  readonly property int columns: large ? Math.max(1, options.length)
    : page && page.groups.length === 1 && options.length <= 6 ? 3
    : 4
  // One size for the labels on a page of small cards: the largest at which
  // the longest of them fits its card, down to nine tenths, so that one long
  // name is not set smaller than its neighbours.
  readonly property real labelSize: {
    if (large || single || options.length === 0) return Style.font.body
    // What a small card spends on its margins and its mark.
    var room = (pane.width - (columns - 1) * Style.space(6)) / columns - Style.space(44)
    var widest = 0
    for (var i = 0; i < options.length; i++) widest = Math.max(widest, labelMetrics.advanceWidth(options[i].label))
    if (widest <= room) return Style.font.body
    return Math.max(Math.round(Style.font.body * 0.9), Math.floor(Style.font.body * room / widest))
  }
  // A page that is one row needs no card repeating its title: it gets a button.
  readonly property bool single: !touring && options.length === 1
  readonly property bool hasDetails: options.some(function(option) { return option.detail !== "" })

  readonly property color foreground: Commons.Color.menu.text
  readonly property color accent: Commons.Color.accent
  readonly property color dim: Util.alpha(foreground, 0.66)
  readonly property string fontFamily: Style.font.menuFamily

  width: Style.space(900)
  height: Style.space(612)
  radius: Style.cornerRadius
  color: Commons.Color.menu.background
  borderSpec: Border.surfaceSpec("menu", "border", Commons.Color.menu.border, Math.max(1, Style.space(2)))
  padding: Style.space(20)

  // ------------------------------------------------------------- moving about

  function start(nextMode, pageName) {
    staged = ({})
    mode = nextMode === "tour" ? "tour" : "app"
    stepIndex = -1
    pageIndex = 0
    wantedPage = String(pageName || "")
    pendingStart = false
    onTourLink = false
    splash.cursor = 0
    summaryCursor = 1
    seekPage()
    settleCursor()
    entered()
  }

  // The splash plays from its start for whoever has just been shown it.
  function entered() {
    if (onSplash) splash.play()
  }

  // The page asked for is looked up once every page is there to look in.
  function seekPage() {
    if (!ready || wantedPage === "") return
    var index = SetupModel.pageIndex(pages, wantedPage)
    if (index >= 0) pageIndex = index
    wantedPage = ""
  }

  // The tour starts on its first step once there are steps to start on.
  function begin() {
    if (ready) goToStep(0)
    else pendingStart = true
  }

  // What the tour has picked at a step: the choice made there, else what the
  // machine has now.
  function chosenId(step) {
    if (!step) return ""
    if (staged[step.id] !== undefined) return staged[step.id]
    var current = SetupModel.currentOption(step)
    return current ? current.id : ""
  }

  // The cursor rests on the choice a page already shows, not on its first row.
  function settleCursor() {
    var index = 0
    var wanted = touring ? chosenId(page) : null
    // Read from the page itself: a handler for its change runs before the
    // bindings that follow from it have caught up.
    var list = SetupModel.flatOptions(page)
    for (var i = 0; i < list.length; i++) {
      if (touring ? list[i].id === wanted : list[i].current) { index = i; break }
    }
    cursor = index
  }

  onPageChanged: settleCursor()
  onReadyChanged: {
    if (!ready) return
    seekPage()
    settleCursor()
    if (pendingStart && onSplash) goToStep(0)
    pendingStart = false
  }
  // Options that move under a resting pointer, as a page changes or scrolls
  // to follow the keyboard, must not take the cursor from it.
  onCursorChanged: pointerGate.reset()

  PointerMoveGate {
    id: pointerGate
    referenceItem: root
  }

  FontMetrics {
    id: labelMetrics
    font.family: root.fontFamily
    font.pixelSize: Style.font.body
  }

  // The splash is where the tour starts, and is not somewhere to go back to.
  function goToStep(index) {
    if (!ready) return
    stepIndex = Math.max(0, Math.min(steps.length, index))
    summaryCursor = 1
  }

  // Past the last page, or back from the first, is the tour's link, so the
  // keyboard reaches it too.
  function goToPage(index) {
    if (!ready || pages.length === 0) return
    onTourLink = index < 0 || index >= pages.length
    if (!onTourLink) pageIndex = index
  }

  function stage(option) {
    if (!page || !option) return
    var next = ({})
    for (var key in staged) next[key] = staged[key]
    next[page.id] = option.id
    staged = next
  }

  // A click, or Enter: the tour remembers the choice, the pages run the row.
  function choose(index, advance) {
    var option = options[index]
    if (!ready || !option || option.installed) return
    cursor = index
    if (touring) {
      stage(option)
      if (advance) goToStep(stepIndex + 1)
    } else {
      activated(option)
    }
  }

  function finish() {
    if (ready) finished(plan.argv, plan.changes.map(function(change) { return change.page }))
  }

  // What the model on offer takes and gives. The agents panel says the same
  // in its own shorthand, which a first login has not learned yet.
  function localFacts() {
    if (!offer) return ""
    var facts = []
    if (offer.memoryGib > 0) facts.push(Commons.I18n.t("setup.localMemoryFact").arg(Commons.I18n.formatNumber(offer.memoryGib, 0)))
    if (offer.context > 0) facts.push(Commons.I18n.t("setup.localContextFact").arg(Commons.I18n.formatNumber(Math.round(offer.context / 1024), 0)))
    if (offer.tokensPerSecond > 0) facts.push(Commons.I18n.t("setup.localSpeedFact").arg(Commons.I18n.formatNumber(Math.round(offer.tokensPerSecond), 0)))
    return facts.join("  \u{b7}  ")
  }

  // What a lone row's button says: where pressing it leads.
  function actionLabel(option) {
    if (!option) return ""
    if (option.installed) return Commons.I18n.t("setup.installed")
    if (option.handoff === "terminal") return Commons.I18n.t("setup.actionStart")
    if (option.handoff === "editor") return Commons.I18n.t("setup.actionEdit")
    if (option.handoff === "menu") return Commons.I18n.t("setup.actionChoose")
    return Commons.I18n.t("setup.actionOpen")
  }

  // ------------------------------------------------------------- the keyboard

  function handleKey(event) {
    var key = Util.readingKey(event, true)
    var enter = event.key === Qt.Key_Return || event.key === Qt.Key_Enter || event.key === Qt.Key_Space
    var forward = event.key === Qt.Key_Tab
    var back = event.key === Qt.Key_Backtab || event.key === Qt.Key_Backspace
    var up = event.key === Qt.Key_Up || event.text === "k"
    var down = event.key === Qt.Key_Down || event.text === "j"

    if (event.key === Qt.Key_Escape) {
      dismissed()
      return true
    }
    // A key held down must not walk the tour, or run a row over and over.
    if (event.isAutoRepeat && (enter || forward || back)) return true

    if (onSplash) {
      if (enter) splash.activate()
      else if (forward) splash.cursor = (splash.cursor + 1) % 3
      else if (event.key === Qt.Key_Backtab) splash.cursor = (splash.cursor + 2) % 3
      else if (key === Qt.Key_Right && splash.cursor === 0) splash.cursor = 1
      else if (key === Qt.Key_Left && splash.cursor === 1) splash.cursor = 0
      else if (down) splash.cursor = 2
      else if (up && splash.cursor === 2) splash.cursor = 0
    } else if (!ready) {
      // Nothing is on the page yet to act on.
    } else if (onSummary) {
      if (enter && summaryCursor === 1) finish()
      else if (enter || back) goToStep(stepIndex - 1)
      else if (key === Qt.Key_Left) summaryCursor = 0
      else if (key === Qt.Key_Right || forward) summaryCursor = 1
    } else if (onTourLink) {
      if (enter) start("tour", "")
      else if (forward) goToPage(0)
      else if (back) goToPage(pages.length - 1)
    } else if (event.key === Qt.Key_Space) {
      choose(cursor, false)
    } else if (enter) {
      choose(cursor, true)
    } else if (forward || event.key === Qt.Key_PageDown) {
      if (touring) goToStep(stepIndex + 1)
      else goToPage(pageIndex + 1)
    } else if (back || event.key === Qt.Key_PageUp) {
      if (touring) goToStep(stepIndex - 1)
      else goToPage(pageIndex - 1)
    } else if (key === Qt.Key_Left) {
      cursor = SetupModel.moveCursor(page, columns, cursor, -1, 0)
    } else if (key === Qt.Key_Right) {
      cursor = SetupModel.moveCursor(page, columns, cursor, 1, 0)
    } else if (up) {
      cursor = SetupModel.moveCursor(page, columns, cursor, 0, -1)
    } else if (down) {
      cursor = SetupModel.moveCursor(page, columns, cursor, 0, 1)
    } else {
      return false
    }
    return true
  }

  // ------------------------------------------------------------- the pieces

  // A caption is set in spaced capitals, whatever case its words come in.
  component Caption: PanelSectionHeader {
    property string words: ""

    text: words.toUpperCase()
    foreground: root.foreground
    fontFamily: root.fontFamily
    font.letterSpacing: 1.6
  }

  component RailRow: Item {
    id: row

    property string label: ""
    property string icon: ""
    property string iconFont: ""
    property bool here: false
    // In the tour, a step whose pick differs from what the machine has.
    property bool changed: false

    signal picked()

    width: parent ? parent.width : 0
    height: Style.space(27)

    Rectangle {
      anchors.fill: parent
      radius: Style.cornerRadius
      color: row.here ? Commons.Color.menu.selectedBackground : hover.containsMouse ? Style.hoverFillFor(root.foreground, root.accent) : "transparent"
    }

    Rectangle {
      visible: row.here
      width: Style.space(3)
      height: parent.height - Style.space(12)
      anchors.left: parent.left
      anchors.verticalCenter: parent.verticalCenter
      color: Commons.Color.menu.selectedText
    }

    Text {
      id: railGlyph
      textFormat: Text.PlainText
      text: row.icon
      color: row.here ? Commons.Color.menu.selectedText : root.dim
      font.family: row.iconFont !== "" ? row.iconFont : root.fontFamily
      font.pixelSize: Style.font.icon
      horizontalAlignment: Text.AlignHCenter
      width: Style.space(18)
      anchors.left: parent.left
      anchors.leftMargin: Style.space(12)
      anchors.verticalCenter: parent.verticalCenter
    }

    Text {
      textFormat: Text.PlainText
      text: row.label
      color: row.here ? Commons.Color.menu.selectedText : root.foreground
      font.family: root.fontFamily
      font.pixelSize: Style.font.body
      font.bold: row.here
      elide: Text.ElideRight
      anchors.left: railGlyph.right
      anchors.leftMargin: Style.space(8)
      anchors.right: railMark.visible ? railMark.left : parent.right
      anchors.rightMargin: Style.space(8)
      anchors.verticalCenter: parent.verticalCenter
    }

    // A dot, as an editor marks a file with changes: the check is kept for
    // what the machine already has.
    Rectangle {
      id: railMark
      visible: row.changed
      width: Style.space(6)
      height: width
      radius: width / 2
      color: root.foreground
      anchors.right: parent.right
      anchors.rightMargin: Style.space(10)
      anchors.verticalCenter: parent.verticalCenter
    }

    MouseArea {
      id: hover
      anchors.fill: parent
      hoverEnabled: true
      cursorShape: Qt.PointingHandCursor
      onClicked: row.picked()
    }
  }

  // Clicks on the card are not clicks on the scrim behind it.
  MouseArea { anchors.fill: parent; onClicked: {} }

  Item {
    id: content
    anchors.fill: parent
    anchors.topMargin: root.contentTopInset
    anchors.rightMargin: root.contentRightInset
    anchors.bottomMargin: root.contentBottomInset
    anchors.leftMargin: root.contentLeftInset

    Splash {
      id: splash
      anchors.fill: parent
      visible: root.onSplash
      foreground: root.foreground
      onStarted: root.begin()
      onSkipped: root.dismissed()
      onBrowsed: root.start("app", "")
    }

    // ----------------------------------------------------------- header

    Item {
      id: header
      visible: !root.onSplash
      anchors.top: parent.top
      anchors.left: parent.left
      anchors.right: parent.right
      height: Style.space(24)

      Text {
        id: brand
        textFormat: Text.PlainText
        text: "\u{e900}"
        color: root.accent
        font.family: "omarchy"
        font.pixelSize: Style.font.heading
        anchors.left: parent.left
        anchors.verticalCenter: parent.verticalCenter
      }

      Caption {
        words: root.touring ? Commons.I18n.t("setup.welcomeHeader") : Commons.I18n.t("setup.title")
        color: root.foreground
        anchors.left: brand.right
        anchors.leftMargin: Style.space(10)
        anchors.verticalCenter: parent.verticalCenter
      }

      Caption {
        visible: root.touring && !root.onSummary
        words: Commons.I18n.t("setup.stepOf").arg(Commons.I18n.formatNumber(root.stepIndex + 1)).arg(Commons.I18n.formatNumber(root.steps.length))
        anchors.right: parent.right
        anchors.verticalCenter: parent.verticalCenter
      }
    }

    // ----------------------------------------------------------- rail

    Item {
      id: rail
      visible: !root.onSplash
      anchors.top: header.bottom
      anchors.topMargin: Style.space(16)
      anchors.left: parent.left
      anchors.bottom: footer.top
      anchors.bottomMargin: Style.space(14)
      width: Style.space(184)

      Flickable {
        id: railScroll
        anchors.fill: parent
        clip: true
        contentHeight: railColumn.height
        boundsBehavior: Flickable.StopAtBounds
        interactive: contentHeight > height

        Column {
          id: railColumn
          width: railScroll.width
          spacing: Style.space(1)

          Repeater {
            model: root.touring ? root.steps : root.pages

            Column {
              id: railEntry

              required property int index
              required property var modelData
              // Each group of pages gets its name above its first row.
              readonly property bool opensSection: !root.touring && (index === 0 || root.pages[index - 1].section !== modelData.section)

              width: railColumn.width
              spacing: Style.space(1)

              Item {
                visible: railEntry.opensSection
                width: parent.width
                height: railEntry.index === 0 ? Style.space(20) : Style.space(34)

                Caption {
                  words: railEntry.modelData.section === "essentials" ? Commons.I18n.t("setup.essentialsHeader") : Commons.I18n.t("setup.menuHeader")
                  anchors.left: parent.left
                  anchors.leftMargin: Style.space(12)
                  anchors.bottom: parent.bottom
                  anchors.bottomMargin: Style.space(6)
                }
              }

              RailRow {
                label: railEntry.modelData.title
                icon: railEntry.modelData.icon
                iconFont: railEntry.modelData.iconFont
                here: !root.onTourLink && (root.touring ? railEntry.index === root.stepIndex : railEntry.index === root.pageIndex)
                changed: root.touring && root.plan.changes.some(function(change) { return change.page === railEntry.modelData.id })
                onPicked: root.touring ? root.goToStep(railEntry.index) : root.goToPage(railEntry.index)
              }
            }
          }

          RailRow {
            visible: root.touring
            label: Commons.I18n.t("setup.review")
            icon: "\u{f11e}"
            here: root.onSummary
            onPicked: root.goToStep(root.steps.length)
          }
        }
      }
    }

    Rectangle {
      id: divider
      visible: rail.visible
      anchors.top: rail.top
      anchors.bottom: rail.bottom
      anchors.left: rail.right
      anchors.leftMargin: Style.space(14)
      width: Style.spacing.hairline
      color: Util.alpha(root.foreground, 0.12)
    }

    // ----------------------------------------------------------- a page

    Item {
      id: pane
      visible: !root.onSplash && !root.onSummary && !!root.page
      enabled: root.ready
      opacity: root.ready ? 1 : 0
      anchors.top: rail.top
      anchors.bottom: rail.bottom
      anchors.left: divider.right
      anchors.leftMargin: Style.space(18)
      anchors.right: parent.right

      // A step with a Not now card pictures the thing set up while the cursor
      // is on it, and left alone while the cursor is on Not now.
      readonly property bool wanted: !!root.cursorOption && root.cursorOption.id !== ""
      // What sits under the scene: the words, the options and the detail line,
      // with the gaps between them.
      readonly property real below: words.anchors.topMargin + words.height + optionScroll.anchors.topMargin + optionScroll.contentHeight
        + (detail.visible ? detail.anchors.topMargin + detail.height : 0)

      Behavior on opacity { NumberAnimation { duration: Style.duration(180); easing.type: Easing.OutCubic } }

      Loader {
        id: scene
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right
        // The scene takes what is left over, so a page with many options
        // trades some of its picture for room to list them.
        height: Util.clamp(pane.height - pane.below, Style.space(112), Style.space(268))
        sourceComponent: !root.page ? null
          : root.page.scene === "layout" ? layoutScene
          : root.page.scene === "agent" ? agentScene
          : root.page.scene === "dictation" ? dictationScene
          : root.page.scene === "local-ai" ? localAiScene
          : root.page.scene === "tailscale" ? tailscaleScene
          : root.page.scene === "defaults" ? defaultsScene
          : root.page.scene === "plugins" ? pluginsScene
          : root.page.scene === "security" ? securityScene
          : root.page.scene === "git" ? gitScene
          : root.page.scene === "keyboard" ? keyboardScene
          : root.page.scene === "region" ? regionScene
          : root.page.scene === "network" ? networkScene
          : handoffScene
      }

      Component {
        id: layoutScene
        LayoutScene {
          foreground: root.foreground
          accent: root.accent
          mode: root.cursorOption && root.cursorOption.args && root.cursorOption.args.length > 1 ? root.cursorOption.args[1] : "dwindle"
        }
      }
      Component {
        id: agentScene
        AgentScene { foreground: root.foreground; accent: root.accent; option: root.cursorOption }
      }
      Component {
        id: dictationScene
        DictationScene { foreground: root.foreground; accent: root.accent; place: root.cursorOption ? root.cursorOption.place : ""; listening: pane.wanted }
      }
      Component {
        id: localAiScene
        LocalAiScene { foreground: root.foreground; accent: root.accent; running: pane.wanted }
      }
      Component {
        id: tailscaleScene
        TailscaleScene { foreground: root.foreground; accent: root.accent; connected: pane.wanted }
      }
      Component {
        id: defaultsScene
        DefaultsScene { foreground: root.foreground; accent: root.accent; option: root.cursorOption }
      }
      Component {
        id: pluginsScene
        PluginsScene { foreground: root.foreground; accent: root.accent; option: root.cursorOption }
      }
      Component {
        id: securityScene
        SecurityScene { foreground: root.foreground; accent: root.accent; option: root.cursorOption }
      }
      Component {
        id: gitScene
        GitScene { foreground: root.foreground; accent: root.accent; option: root.cursorOption }
      }
      Component {
        id: keyboardScene
        KeyboardScene { foreground: root.foreground; accent: root.accent; option: root.cursorOption }
      }
      Component {
        id: regionScene
        RegionScene { foreground: root.foreground; accent: root.accent; option: root.cursorOption }
      }
      Component {
        id: networkScene
        NetworkScene { foreground: root.foreground; accent: root.accent; option: root.cursorOption }
      }
      Component {
        id: handoffScene
        HandoffScene { foreground: root.foreground; accent: root.accent; option: root.cursorOption }
      }

      Column {
        id: words
        anchors.top: scene.bottom
        anchors.topMargin: Style.space(14)
        anchors.left: parent.left
        anchors.right: parent.right
        spacing: Style.space(5)

        Text {
          textFormat: Text.PlainText
          text: root.page ? root.page.title : ""
          color: root.foreground
          font.family: root.fontFamily
          font.pixelSize: Style.font.heading
          font.bold: true
          elide: Text.ElideRight
          width: parent.width
        }

        Text {
          textFormat: Text.PlainText
          visible: text !== ""
          text: root.page ? root.page.description : ""
          color: root.dim
          font.family: root.fontFamily
          font.pixelSize: Style.font.body
          lineHeight: 1.3
          wrapMode: Text.WordWrap
          maximumLineCount: 2
          elide: Text.ElideRight
          width: parent.width
        }

        Text {
          textFormat: Text.PlainText
          visible: !!root.page && root.page.scene === "local-ai" && text !== ""
          text: root.localFacts()
          color: root.foreground
          font.family: root.fontFamily
          font.pixelSize: Style.font.bodySmall
          width: parent.width
        }
      }

      Flickable {
        id: optionScroll

        // It reaches a little past its options on every side, so the ring
        // around the one under the cursor is not cut by the clip.
        readonly property real bleed: Style.space(4)
        // How far in from an edge the options fade out, once there are more
        // past it.
        readonly property real fade: Math.min(Style.space(28), height / 2)

        anchors.top: words.bottom
        anchors.topMargin: Style.space(12) - bleed
        anchors.left: parent.left
        anchors.leftMargin: -bleed
        anchors.right: parent.right
        anchors.rightMargin: -bleed
        // As tall as its options, up to the room there is; then it scrolls.
        height: Math.min(contentHeight, pane.height - y - (detail.visible ? detail.anchors.topMargin + detail.height : 0))
        clip: true
        contentHeight: optionColumn.height + bleed * 2
        boundsBehavior: Flickable.StopAtBounds
        interactive: contentHeight > height

        // Keeps the keyboard's cursor in view on a page long enough to
        // scroll, and clear of the fade wherever more lies past it.
        function reveal(item) {
          if (!item) return
          var top = item.mapToItem(optionColumn, 0, 0).y
          var bottom = top + item.height + bleed * 2
          if (top - fade < contentY) contentY = Math.max(0, Math.floor(top - fade))
          else if (bottom + fade > contentY + height) contentY = Math.min(contentHeight - height, Math.ceil(bottom + fade - height))
        }

        // With the pointer gone, the picture goes back to the pick rather
        // than staying on whichever option it crossed last on its way out.
        HoverHandler {
          onHoveredChanged: if (!hovered) root.settleCursor()
        }

        Column {
          id: optionColumn
          x: optionScroll.bleed
          y: optionScroll.bleed
          width: optionScroll.width - optionScroll.bleed * 2
          spacing: Style.space(10)

          Repeater {
            model: root.page ? root.page.groups : []

            Column {
              id: group

              required property int index
              required property var modelData
              // Where this group's options start among the page's.
              readonly property int base: {
                var before = 0
                for (var i = 0; i < index; i++) before += root.page.groups[i].options.length
                return before
              }

              width: optionColumn.width
              spacing: Style.space(6)

              Caption {
                visible: group.modelData.title !== ""
                words: group.modelData.title
                width: parent.width
              }

              Grid {
                id: grid
                width: parent.width
                columns: root.columns
                spacing: Style.space(6)

                Repeater {
                  model: group.modelData.options

                  SetupOption {
                    id: card

                    required property int index
                    required property var modelData
                    readonly property int flat: group.base + index

                    width: root.single ? Style.space(200) : (grid.width - (grid.columns - 1) * grid.spacing) / grid.columns
                    label: root.single ? root.actionLabel(modelData) : modelData.label
                    icon: modelData.icon
                    iconFont: modelData.iconFont
                    large: root.large && !root.single
                    labelSize: root.labelSize
                    cursor: root.cursor === flat && !root.onTourLink
                    chosen: root.touring && root.chosenId(root.page) === modelData.id
                    current: modelData.current
                    installed: modelData.installed
                    foreground: root.foreground
                    accent: root.accent
                    onPointed: function(mouse) {
                      if (!pointerGate.moved(card, mouse)) return
                      root.pointing = true
                      root.cursor = flat
                      root.pointing = false
                    }
                    onClicked: root.choose(flat, false)
                    onCursorChanged: if (cursor && !root.pointing) optionScroll.reveal(card)
                  }
                }
              }
            }
          }
        }
      }

      // Fades at the edges once there is more than fits, as in the menu: how
      // strong follows how much is still hidden past each edge.
      Repeater {
        model: 2

        Rectangle {
          required property int index
          readonly property bool atTop: index === 0
          readonly property real hidden: atTop ? optionScroll.contentY : optionScroll.contentHeight - optionScroll.height - optionScroll.contentY

          x: optionScroll.x
          y: atTop ? optionScroll.y : optionScroll.y + optionScroll.height - height
          width: optionScroll.width
          height: optionScroll.fade
          visible: opacity > 0
          opacity: optionScroll.contentHeight > optionScroll.height ? Util.clamp(hidden / height, 0, 1) : 0
          gradient: Gradient {
            GradientStop { position: 0; color: Util.alpha(root.color, atTop ? 1 : 0) }
            GradientStop { position: 1; color: Util.alpha(root.color, atTop ? 0 : 1) }
          }
        }
      }

      // Two empty lines set as the detail is, for the room it is given.
      Text {
        id: twoLines
        visible: false
        textFormat: Text.PlainText
        text: "\n"
        font: detail.font
        lineHeight: detail.lineHeight
      }

      Text {
        id: detail
        textFormat: Text.PlainText
        visible: root.hasDetails
        text: root.cursorOption ? root.cursorOption.detail : ""
        color: root.dim
        font.family: root.fontFamily
        font.pixelSize: Style.font.bodySmall
        lineHeight: 1.3
        wrapMode: Text.WordWrap
        maximumLineCount: 2
        elide: Text.ElideRight
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: optionScroll.bottom
        anchors.topMargin: Style.space(10) - optionScroll.bleed
        // Two lines whether or not the words fill them, so nothing below shifts.
        height: twoLines.implicitHeight
      }
    }

    // ----------------------------------------------------------- summary

    Column {
      id: summary
      visible: root.onSummary
      anchors.left: divider.right
      anchors.leftMargin: Style.space(18)
      anchors.right: parent.right
      anchors.top: rail.top
      anchors.topMargin: Style.space(8)
      spacing: Style.space(20)

      Column {
        width: parent.width
        spacing: Style.space(6)

        Text {
          textFormat: Text.PlainText
          text: Commons.I18n.t("setup.summaryTitle")
          color: root.foreground
          font.family: root.fontFamily
          font.pixelSize: Style.font.heading
          font.bold: true
          width: parent.width
        }

        Text {
          textFormat: Text.PlainText
          text: root.plan.changes.length > 0 ? Commons.I18n.t("setup.summaryChanges") : Commons.I18n.t("setup.summaryNone")
          color: root.dim
          font.family: root.fontFamily
          font.pixelSize: Style.font.body
          lineHeight: 1.3
          wrapMode: Text.WordWrap
          width: parent.width
        }
      }

      Column {
        visible: root.plan.changes.length > 0
        width: parent.width
        spacing: Style.space(8)

        Repeater {
          model: root.plan.changes

          Row {
            required property var modelData
            width: parent.width
            // One height for every row, whatever the height of its mark.
            height: Style.space(26)
            spacing: Style.space(10)

            Text {
              textFormat: Text.PlainText
              text: modelData.icon
              color: root.accent
              font.family: modelData.iconFont !== "" ? modelData.iconFont : root.fontFamily
              font.pixelSize: Style.font.icon
              horizontalAlignment: Text.AlignHCenter
              width: Style.space(18)
              anchors.verticalCenter: parent.verticalCenter
            }

            Text {
              textFormat: Text.PlainText
              text: modelData.title
              color: root.dim
              font.family: root.fontFamily
              font.pixelSize: Style.font.body
              width: Style.space(150)
              elide: Text.ElideRight
              anchors.verticalCenter: parent.verticalCenter
            }

            // A step with one thing to set up is named for it already.
            Text {
              textFormat: Text.PlainText
              text: modelData.label === modelData.title ? Commons.I18n.t("setup.actionStart") : modelData.label
              color: root.foreground
              font.family: root.fontFamily
              font.pixelSize: Style.font.body
              font.bold: true
              anchors.verticalCenter: parent.verticalCenter
            }
          }
        }
      }

    }

    // Two things worth knowing on the way out, at the foot of the page.
    Column {
      visible: root.onSummary
      anchors.left: summary.left
      anchors.right: summary.right
      anchors.bottom: rail.bottom
      spacing: Style.space(4)

      Repeater {
        model: [Commons.I18n.t("setup.summaryHintMenu"), Commons.I18n.t("setup.summaryHintKeys")]

        Text {
          required property string modelData
          textFormat: Text.PlainText
          text: modelData
          color: root.dim
          font.family: root.fontFamily
          font.pixelSize: Style.font.bodySmall
          width: parent.width
        }
      }
    }

    // ----------------------------------------------------------- footer

    Item {
      id: footer
      visible: !root.onSplash
      anchors.left: parent.left
      anchors.right: parent.right
      anchors.bottom: parent.bottom
      height: Style.space(32)

      SetupButton {
        id: leave
        text: root.touring ? Commons.I18n.t("setup.skipTour") : Commons.I18n.t("setup.tour")
        quiet: true
        hasCursor: root.onTourLink
        foreground: root.foreground
        anchors.left: parent.left
        anchors.verticalCenter: parent.verticalCenter
        onClicked: root.touring ? root.dismissed() : root.start("tour", "")
      }

      // The keys, in the middle of the footer in the tour, whatever flanks
      // them, so they do not shift as Back comes and goes. On the pages they
      // have the right-hand side to themselves.
      TextMetrics {
        id: hintMetrics
        font: hint.font
        text: hint.text
      }

      Text {
        id: hint

        // What the link and the buttons leave it.
        readonly property real room: root.touring
          ? footer.width - 2 * (Math.max(leave.width, buttons.width) + Style.space(12))
          : footer.width - leave.width - Style.space(12)

        textFormat: Text.PlainText
        text: root.onSummary ? Commons.I18n.t("setup.reviewHint") : root.touring ? Commons.I18n.t("setup.tourHint") : Commons.I18n.t("setup.appHint")
        color: Util.alpha(root.foreground, 0.45)
        font.family: root.fontFamily
        font.pixelSize: Style.font.bodySmall
        elide: Text.ElideRight
        width: Math.min(Math.ceil(hintMetrics.advanceWidth), room)
        // Placed by hand, so the side it takes on the pages is mirrored by
        // hand too.
        x: root.touring ? (footer.width - width) / 2
          : LayoutMirroring.enabled ? 0
          : footer.width - width
        anchors.verticalCenter: parent.verticalCenter
      }

      Row {
        id: buttons
        visible: root.touring
        anchors.right: parent.right
        anchors.verticalCenter: parent.verticalCenter
        spacing: Style.space(10)

        SetupButton {
          visible: root.stepIndex > 0
          text: Commons.I18n.t("setup.back")
          hasCursor: root.onSummary && root.summaryCursor === 0
          foreground: root.foreground
          onClicked: root.goToStep(root.stepIndex - 1)
        }

        SetupButton {
          text: root.onSummary ? Commons.I18n.t("setup.finish") : Commons.I18n.t("setup.continue")
          primary: true
          hasCursor: root.onSummary && root.summaryCursor === 1
          foreground: root.foreground
          onClicked: root.onSummary ? root.finish() : root.goToStep(root.stepIndex + 1)
        }
      }
    }
  }
}
