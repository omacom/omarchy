import QtQuick
import qs.Commons
import qs.Commons as Commons
import qs.Ui
import "SetupModel.js" as SetupModel
import "scenes"

// The centered single-column Welcome OOBE card. Decides nothing about the
// system itself: it stages choices across the essentials and reports the one
// `omarchy-setup-essentials` command Finish runs, or nothing when skipped.
BorderSurface {
  id: root

  property var steps: []
  property var offers: []
  readonly property var offer: offers && offers.length > 0 ? offers[0] : null
  property bool ready: false

  // -1 is the splash, 0..steps.length-1 are the essentials, steps.length is Ready.
  property int stepIndex: -1
  // Staged choices by step id: option id (or "" for keep-current) on choice
  // steps, boolean true/false on toggle steps.
  property var staged: ({})
  // Staged sub-options by step id (e.g. Superwhisper "cloud" vs "offline").
  property var stagedSub: ({})
  // Keyboard focus zone within the current screen.
  // Steps: "control", "sub", "keep", "continue", "skip", "back"
  // Ready: "finish", "skip", "back"
  property string focusZone: "control"
  // Pointer hover lights cards only after the pointer physically moves.
  property bool pointerAwake: false
  // Get started pressed before SetupData finished settling.
  property bool pendingStart: false
  // Suppresses keyboard-follow scrolling while a click is being handled.
  property bool pointing: false
  onPointingChanged: if (pointing) optionScroll.due = false
  // Subtle entrance settle on step switches (180ms easeOut; instant under reduced motion).
  property real stepEnter: 1

  NumberAnimation {
    id: stepEnterAnim
    target: root
    property: "stepEnter"
    from: 0
    to: 1
    duration: Style.duration(180)
    easing.type: Easing.Bezier
    easing.bezierCurve: Style.easeOut
  }

  signal dismissed()
  // Emitted once as the tour leaves Splash so Setup can freeze IPC availability.
  signal aboutToList()
  // Emitted whenever a step or "ready" is presented on screen.
  signal stepViewed(string stepId)
  // Emitted when Finish is confirmed: argv to execute and step ids changed.
  signal finished(var argv, var steps)

  readonly property bool onSplash: stepIndex < 0
  readonly property bool onSummary: stepIndex >= 0 && stepIndex >= steps.length
  readonly property var step: onSplash || onSummary ? null : (steps[stepIndex] || null)
  readonly property bool isChoice: !!step && step.kind === "choice"
  readonly property bool isToggle: !!step && step.kind === "toggle"
  readonly property var options: isChoice ? step.options : []
  readonly property var pickedOption: SetupModel.pick(step, staged)
  readonly property var subOptions: pickedOption && pickedOption.subOptions ? pickedOption.subOptions : []
  readonly property var pickedSubOption: SetupModel.pickSubOption(pickedOption, step ? stagedSub[step.id] : "")
  readonly property bool showSubOptions: isChoice && subOptions.length > 0
  readonly property bool hasStepSubOptions: isChoice && options.some(function(opt) { return !!opt.subOptions && opt.subOptions.length > 0 })
  readonly property bool toggleEnabled: isToggle && !!pickedOption
  readonly property var plan: SetupModel.tourPlan(steps, staged, stagedSub)
  readonly property bool compactChoices: isChoice && options.length > 3
  readonly property int columns: !isChoice ? 1
    : options.length <= 3 ? Math.max(1, options.length)
    : 2
  // Shown only when no offered choice matches the machine's saved setting and
  // the user has staged a choice, giving a clean way back to "unchanged".
  readonly property bool showKeepCurrent: isChoice && !SetupModel.currentOption(step) && !!pickedOption

  readonly property color foreground: Commons.Color.menu.text
  readonly property color accent: Commons.Color.accent
  readonly property color dim: Util.alpha(foreground, 0.66)
  readonly property string fontFamily: Style.font.menuFamily

  width: Style.space(760)
  height: Style.space(592)
  radius: Style.cornerRadius
  color: Commons.Color.menu.background
  borderSpec: Border.surfaceSpec("menu", "border", Commons.Color.menu.border, Math.max(1, Style.space(2)))
  padding: Style.space(24)

  // ------------------------------------------------------------- navigation

  function start() {
    staged = ({})
    stagedSub = ({})
    stepIndex = -1
    focusZone = "control"
    pointerAwake = false
    pendingStart = false
    splash.cursor = 0
    entered()
  }

  function entered() {
    if (onSplash) splash.play()
  }

  function begin() {
    if (ready) goToStep(0)
    else pendingStart = true
  }

  function goToStep(index) {
    if (!ready) return
    if (onSplash) aboutToList()
    var next = Math.max(0, Math.min(steps.length, index))
    stepIndex = next
    pointerAwake = false
    optionScroll.contentY = 0
    focusZone = next >= steps.length ? "finish" : "control"
    if (Style.reduceMotion) {
      stepEnterAnim.stop()
      stepEnter = 1
    } else {
      stepEnterAnim.restart()
    }
    stepViewed(next >= steps.length ? "ready" : steps[next].id)
  }

  onReadyChanged: {
    if (!ready) return
    if (pendingStart && onSplash) goToStep(0)
    pendingStart = false
  }

  function setStaged(stepId, value) {
    var next = ({})
    for (var key in staged) next[key] = staged[key]
    next[stepId] = value
    staged = next
  }

  function setStagedSub(stepId, value) {
    var next = ({})
    for (var key in stagedSub) next[key] = stagedSub[key]
    next[stepId] = value
    stagedSub = next
  }

  function pickChoice(option) {
    if (!ready || !isChoice || !option) return
    if (step.optional && pickedOption && pickedOption.id === option.id) {
      setStaged(step.id, "")
    } else {
      setStaged(step.id, option.id)
    }
    focusZone = "control"
  }

  function pickSubOption(sub) {
    if (!ready || !showSubOptions || !sub) return
    setStagedSub(step.id, sub.id)
    focusZone = "sub"
  }

  function moveSubOption(delta, wrap) {
    if (!showSubOptions || subOptions.length === 0) return
    pointerAwake = false
    focusZone = "sub"
    var currentIndex = 0
    if (pickedSubOption) {
      for (var i = 0; i < subOptions.length; i++) {
        if (subOptions[i].id === pickedSubOption.id) { currentIndex = i; break }
      }
    }
    var nextIndex = wrap
      ? (currentIndex + delta + subOptions.length) % subOptions.length
      : Math.max(0, Math.min(subOptions.length - 1, currentIndex + delta))
    if (nextIndex !== currentIndex || !stagedSub[step.id]) setStagedSub(step.id, subOptions[nextIndex].id)
  }

  function keepCurrentChoice() {
    if (!ready || !isChoice) return
    setStaged(step.id, "")
    focusZone = "control"
  }

  function setToggle(value) {
    if (!ready || !isToggle) return
    setStaged(step.id, !!value)
    focusZone = "control"
  }

  function flipToggle() {
    setToggle(!toggleEnabled)
  }

  function moveChoice(dx, dy) {
    if (!isChoice || options.length === 0) return
    pointerAwake = false
    focusZone = "control"
    var currentIndex = -1
    if (pickedOption) {
      for (var i = 0; i < options.length; i++) {
        if (options[i].id === pickedOption.id) { currentIndex = i; break }
      }
    }
    if (currentIndex < 0) {
      setStaged(step.id, options[0].id)
      return
    }
    var nextIndex = currentIndex
    if (dx !== 0) {
      var rowStart = Math.floor(currentIndex / columns) * columns
      var rowEnd = Math.min(options.length - 1, rowStart + columns - 1)
      nextIndex = Math.max(rowStart, Math.min(rowEnd, currentIndex + dx))
    } else if (dy !== 0) {
      var target = currentIndex + dy * columns
      if (target >= 0 && target < options.length) nextIndex = target
      else if (dy > 0 && Math.floor(currentIndex / columns) < Math.floor((options.length - 1) / columns)) nextIndex = options.length - 1
      else if (dy > 0 && showSubOptions) { focusZone = "sub"; return }
    }
    if (nextIndex !== currentIndex) setStaged(step.id, options[nextIndex].id)
  }

  function stepFocusOrder() {
    if (onSummary) return steps.length > 0 ? ["finish", "skip", "back"] : ["finish", "skip"]
    var zones = ["control"]
    if (showSubOptions) zones.push("sub")
    if (showKeepCurrent) zones.push("keep")
    zones.push("continue")
    zones.push("skip")
    if (stepIndex > 0) zones.push("back")
    return zones
  }

  function cycleFocus(delta) {
    var zones = stepFocusOrder()
    var idx = zones.indexOf(focusZone)
    if (idx < 0) idx = 0
    focusZone = zones[(idx + delta + zones.length) % zones.length]
  }

  function activateFocusedButton() {
    if (focusZone === "skip") dismissed()
    else if (focusZone === "back") goToStep(stepIndex - 1)
    else if (focusZone === "keep") keepCurrentChoice()
    else if (focusZone === "continue") goToStep(stepIndex + 1)
    else if (focusZone === "finish") finish()
  }

  function finish() {
    if (ready) finished(plan.argv, plan.changes.map(function(change) { return change.page }))
  }

  function localFacts(item, multiline) {
    var target = item || offer
    if (!target) return ""
    var mem = target.memoryGib > 0 ? Commons.I18n.t("setup.localMemoryFact").arg(Commons.I18n.formatNumber(target.memoryGib, 0)) : ""
    var rest = []
    if (target.context > 0) rest.push(Commons.I18n.t("setup.localContextFact").arg(Commons.I18n.formatNumber(Math.round(target.context / 1024), 0)))
    if (target.tokensPerSecond > 0) rest.push(Commons.I18n.t("setup.localSpeedFact").arg(Commons.I18n.formatNumber(Math.round(target.tokensPerSecond), 0)))
    if (multiline) {
      if (mem && rest.length > 0) return mem + "\n" + rest.join(" \u{b7} ")
      return mem || rest.join(" \u{b7} ")
    }
    var all = mem ? [mem].concat(rest) : rest
    return all.join("  \u{b7}  ")
  }

  // Tracks actual pointer motion in window coordinates so a card arriving
  // under a resting pointer never lights up until the user moves it.
  PointerMoveGate {
    id: wakeGate
    referenceItem: root.Window.contentItem
  }

  HoverHandler {
    onPointChanged: if (wakeGate.moved(root, point.position)) root.pointerAwake = true
  }

  // ------------------------------------------------------------- keyboard

  function handleKey(event) {
    var key = Util.readingKey(event, true)
    var isReturn = event.key === Qt.Key_Return || event.key === Qt.Key_Enter
    var isSpace = event.key === Qt.Key_Space
    var isTab = event.key === Qt.Key_Tab
    var isBacktab = event.key === Qt.Key_Backtab
    var isBack = event.key === Qt.Key_Backspace || event.key === Qt.Key_PageUp
    var isPageNext = event.key === Qt.Key_PageDown
    var up = event.key === Qt.Key_Up || event.text === "k"
    var down = event.key === Qt.Key_Down || event.text === "j"

    if (event.key === Qt.Key_Escape) {
      dismissed()
      return true
    }
    if (event.isAutoRepeat && (isReturn || isSpace || isTab || isBacktab || isBack || isPageNext)) return true

    if (onSplash) {
      if (isReturn || isSpace) splash.activate()
      else if (isTab || isBacktab) splash.cursor = (splash.cursor + 1) % 2
      else if (key === Qt.Key_Right && splash.cursor === 0) splash.cursor = 1
      else if (key === Qt.Key_Left && splash.cursor === 1) splash.cursor = 0
      else return false
      return true
    }

    if (!ready) return true

    if (onSummary) {
      if (isReturn || isSpace) activateFocusedButton()
      else if (isTab) cycleFocus(1)
      else if (isBacktab) cycleFocus(-1)
      else if (isBack && steps.length > 0) goToStep(stepIndex - 1)
      else if (key === Qt.Key_Left && steps.length > 0) focusZone = "back"
      else if (key === Qt.Key_Right) focusZone = "finish"
      else return false
      return true
    }

    // Essential step: every key has one clear job.
    if (isTab) {
      cycleFocus(1)
      return true
    }
    if (isBacktab) {
      cycleFocus(-1)
      return true
    }
    if (isBack) {
      if (stepIndex > 0) goToStep(stepIndex - 1)
      return true
    }
    if (isPageNext) {
      goToStep(stepIndex + 1)
      return true
    }

    if (focusZone === "sub") {
      if (isReturn) { goToStep(stepIndex + 1); return true }
      if (isSpace) { moveSubOption(1, true); return true }
      if (key === Qt.Key_Left) { moveSubOption(-1, false); return true }
      if (key === Qt.Key_Right) { moveSubOption(1, false); return true }
      if (up) { focusZone = "control"; return true }
      return false
    }

    if (focusZone !== "control") {
      if (isReturn || isSpace) {
        activateFocusedButton()
        return true
      }
      if (key === Qt.Key_Left || key === Qt.Key_Right || up || down) {
        if (isChoice) moveChoice(key === Qt.Key_Left ? -1 : key === Qt.Key_Right ? 1 : 0, up ? -1 : down ? 1 : 0)
        else if (isToggle && (key === Qt.Key_Left || key === Qt.Key_Right)) setToggle(key === Qt.Key_Right)
        else focusZone = "control"
        return true
      }
      return false
    }

    // Focus is on the step's primary control.
    if (isReturn) {
      goToStep(stepIndex + 1)
      return true
    }
    if (isToggle) {
      if (isSpace) { flipToggle(); return true }
      if (key === Qt.Key_Left) { pointerAwake = false; setToggle(false); return true }
      if (key === Qt.Key_Right) { pointerAwake = false; setToggle(true); return true }
      return false
    }
    if (isChoice) {
      if (isSpace) {
        if (step.optional) {
          if (pickedOption) keepCurrentChoice()
          else moveChoice(0, 0)
        }
        return true
      }
      if (key === Qt.Key_Left) { moveChoice(-1, 0); return true }
      if (key === Qt.Key_Right) { moveChoice(1, 0); return true }
      if (up) { moveChoice(0, -1); return true }
      if (down) { moveChoice(0, 1); return true }
    }
    return false
  }

  // Swallow clicks inside the card so they do not bubble to the scrim.
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
      accent: root.accent
      surface: root.color
      onStarted: root.begin()
      onSkipped: root.dismissed()
    }

    // ----------------------------------------------------------- top bar

    Item {
      id: topBar
      visible: !root.onSplash
      anchors.top: parent.top
      anchors.left: parent.left
      anchors.right: parent.right
      height: Style.space(24)

      BrandMark {
        width: Style.space(22)
        height: width
        foreground: root.foreground
        accent: root.accent
        surface: root.color
        anchors.left: parent.left
        anchors.verticalCenter: parent.verticalCenter
      }

      // Passive step pills: elongated for the active screen, accent-tinted for
      // steps with a staged change, softly lit once visited.
      Row {
        id: progressPills
        anchors.centerIn: parent
        spacing: Style.space(7)

        Repeater {
          model: root.steps.length + 1

          Rectangle {
            required property int index
            readonly property bool isCurrent: root.onSummary ? index === root.steps.length : index === root.stepIndex
            readonly property bool visited: root.onSummary ? index < root.steps.length : index < root.stepIndex
            readonly property var stepObj: index < root.steps.length ? root.steps[index] : null
            readonly property bool changed: !!stepObj && root.plan.changes.some(function(change) { return change.page === stepObj.id })

            width: isCurrent ? Style.space(22) : Style.space(7)
            height: Style.space(7)
            radius: Style.cornerRadius > 0 ? height / 2 : 0
            color: isCurrent ? root.foreground
              : changed ? root.accent
              : visited ? Util.alpha(root.foreground, 0.42)
              : Util.alpha(root.foreground, 0.2)

            Accessible.role: Accessible.Indicator
            Accessible.name: stepObj ? stepObj.title : Commons.I18n.t("setup.readyPill")

            Behavior on width {
              NumberAnimation {
                duration: Style.duration(220)
                easing.type: Easing.Bezier
                easing.bezierCurve: Style.easeOut
              }
            }
            Behavior on color { ColorAnimation { duration: Style.duration(160) } }
          }
        }
      }
    }

    // ----------------------------------------------------------- essential step

    Item {
      id: pane
      visible: !root.onSplash && !root.onSummary && !!root.step
      enabled: root.ready
      opacity: root.ready ? root.stepEnter : 0
      transform: Translate { y: (1 - root.stepEnter) * Style.space(6) }
      anchors.top: topBar.bottom
      anchors.topMargin: Style.space(18)
      anchors.bottom: footer.top
      anchors.bottomMargin: Style.space(18)
      anchors.left: parent.left
      anchors.right: parent.right

      readonly property real subBarHeight: Style.space(40)
      readonly property real subSlot: root.hasStepSubOptions ? (Style.space(10) + subBarHeight) : 0
      readonly property real controlsHeight: root.isToggle ? toggleCard.implicitHeight : (optionScroll.contentHeight + subSlot)
      readonly property real reserved: words.height + Style.space(14) + Style.space(16) + controlsHeight

      // Step title and description sit at the top so every tour screen and
      // Ready share the same top-down hierarchy: what -> preview -> choice.
      Column {
        id: words
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right
        spacing: Style.space(4)

        Item {
          width: parent.width
          height: Math.max(stepTitle.implicitHeight, keepCurrentLink.implicitHeight)

          Text {
            id: stepTitle
            textFormat: Text.PlainText
            text: root.step ? root.step.title : ""
            color: root.foreground
            font.family: root.fontFamily
            font.pixelSize: Style.font.heading
            font.bold: true
            horizontalAlignment: Text.AlignLeft
            wrapMode: Text.WordWrap
            anchors.left: parent.left
            anchors.right: keepCurrentLink.visible ? keepCurrentLink.left : parent.right
            anchors.rightMargin: keepCurrentLink.visible ? Style.space(12) : 0
            anchors.verticalCenter: parent.verticalCenter
          }

          // Anchored on the heading baseline so showing or hiding it never
          // shifts the scene height or choice grid below.
          SetupButton {
            id: keepCurrentLink
            visible: root.showKeepCurrent
            text: root.step && root.step.optional ? Commons.I18n.t("setup.notNow") : Commons.I18n.t("setup.keepCurrent")
            quiet: true
            hasCursor: root.focusZone === "keep"
            foreground: root.foreground
            accent: root.accent
            anchors.right: parent.right
            anchors.verticalCenter: parent.verticalCenter
            onClicked: root.keepCurrentChoice()
          }
        }

        Text {
          textFormat: Text.PlainText
          visible: text !== ""
          text: root.step ? root.step.description : ""
          color: root.dim
          font.family: root.fontFamily
          font.pixelSize: Style.font.body
          lineHeight: 1.35
          horizontalAlignment: Text.AlignLeft
          wrapMode: Text.WordWrap
          width: parent.width
        }
      }

      // Hero illustration shrinks first on short displays so translated copy
      // wraps cleanly at full size.
      Loader {
        id: scene
        anchors.top: words.bottom
        anchors.topMargin: Style.space(14)
        anchors.left: parent.left
        anchors.right: parent.right
        height: Util.clamp(pane.height - pane.reserved, Style.space(120), Style.space(248))
        sourceComponent: !root.step ? null
          : root.step.scene === "layout" ? layoutScene
          : root.step.scene === "dictation" ? dictationScene
          : root.step.scene === "agent" ? agentScene
          : root.step.scene === "local-ai" ? localAiScene
          : tailscaleScene
      }

      Component {
        id: layoutScene
        LayoutScene {
          foreground: root.foreground
          accent: root.accent
          mode: root.pickedOption && root.pickedOption.args && root.pickedOption.args.length > 1 ? root.pickedOption.args[1] : ""
        }
      }
      Component {
        id: dictationScene
        DictationScene {
          foreground: root.foreground
          accent: root.accent
          place: root.pickedSubOption ? root.pickedSubOption.place : (root.pickedOption ? root.pickedOption.place : "")
          listening: !!root.pickedOption
        }
      }
      Component {
        id: agentScene
        AgentScene {
          foreground: root.foreground
          accent: root.accent
          option: root.pickedOption
        }
      }
      Component {
        id: localAiScene
        LocalAiScene {
          foreground: root.foreground
          accent: root.accent
          running: root.isToggle ? root.toggleEnabled : !!root.pickedOption
        }
      }
      Component {
        id: tailscaleScene
        TailscaleScene {
          foreground: root.foreground
          accent: root.accent
          connected: root.toggleEnabled
        }
      }

      // Choice cards (Workspace Layout, Dictation, multi-blueprint Local AI)
      Flickable {
        id: optionScroll
        visible: root.isChoice

        readonly property real bleed: Style.space(4)
        readonly property real fade: Math.min(Style.space(24), height / 2)

        anchors.top: scene.bottom
        anchors.topMargin: Style.space(16) - bleed
        anchors.left: parent.left
        anchors.leftMargin: -bleed
        anchors.right: parent.right
        anchors.rightMargin: -bleed
        height: Math.min(contentHeight, Math.max(Style.space(60), pane.height - y - pane.subSlot))
        clip: true
        contentHeight: choiceGrid.height + bleed * 2
        boundsBehavior: Flickable.StopAtBounds
        interactive: contentHeight > height

        property Item kept: null
        property bool due: false

        function reveal() {
          if (!due) return
          due = false
          if (!kept) return
          var top = kept.y
          var bottom = top + kept.height + bleed * 2
          var yPos = contentY
          if (top - fade < yPos) yPos = Math.floor(top - fade)
          else if (bottom + fade > yPos + height) yPos = Math.ceil(bottom + fade - height)
          contentY = Math.max(0, Math.min(contentHeight - height, yPos))
        }

        function follow() {
          if (root.pointing) return
          due = true
          Qt.callLater(reveal)
        }

        onContentHeightChanged: follow()
        onHeightChanged: follow()

        Grid {
          id: choiceGrid
          x: optionScroll.bleed
          y: optionScroll.bleed
          width: optionScroll.width - optionScroll.bleed * 2
          columns: root.columns
          spacing: Style.space(10)

          Repeater {
            model: root.options

            SetupOption {
              id: choiceCard

              required property int index
              required property var modelData
              readonly property bool selected: !!root.pickedOption && root.pickedOption.id === modelData.id

              width: (choiceGrid.width - (choiceGrid.columns - 1) * choiceGrid.spacing) / choiceGrid.columns
              label: modelData.label
              detail: modelData.facts ? (root.localFacts(modelData.facts, !root.compactChoices) || modelData.detail) : modelData.detail
              icon: selected && root.pickedSubOption && root.pickedSubOption.icon ? root.pickedSubOption.icon : modelData.icon
              iconFont: selected && root.pickedSubOption && root.pickedSubOption.icon ? "" : modelData.iconFont
              vendor: modelData.vendor || ""
              pictogram: modelData.pictogram
              compact: root.compactChoices
              lights: root.pointerAwake
              chosen: selected
              focused: root.focusZone === "control"
              focusedAnchor: !root.pickedOption && index === 0 && root.focusZone === "control"
              current: modelData.current
              recommended: !!modelData.recommended
              foreground: root.foreground
              accent: root.accent
              onClicked: {
                root.pointing = true
                root.pickChoice(modelData)
                root.pointing = false
              }
              onChosenChanged: {
                if (chosen) {
                  optionScroll.kept = choiceCard
                  optionScroll.follow()
                } else if (optionScroll.kept === choiceCard) {
                  optionScroll.kept = null
                }
              }
              onYChanged: if (chosen) optionScroll.follow()
            }
          }
        }
      }

      // Edge fades only when an extension adds enough choices to scroll.
      Repeater {
        model: root.isChoice ? 2 : 0

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

      // Segmented sub-option bar (e.g. Superwhisper Cloud vs On-device).
      // Its vertical slot is reserved across every option on the step so
      // switching between options with and without sub-options causes zero jump.
      Item {
        id: subBar
        property var cachedSubOptions: []
        readonly property var shownSubOptions: root.subOptions.length > 0 ? root.subOptions : cachedSubOptions

        Connections {
          target: root
          function onSubOptionsChanged() {
            if (root.subOptions.length > 0) subBar.cachedSubOptions = root.subOptions
          }
          function onStepChanged() {
            subBar.cachedSubOptions = root.subOptions
          }
        }

        visible: root.hasStepSubOptions
        enabled: root.showSubOptions
        opacity: root.showSubOptions ? 1 : 0
        anchors.top: optionScroll.bottom
        anchors.topMargin: Style.space(6)
        anchors.left: parent.left
        anchors.right: parent.right
        height: pane.subBarHeight

        transform: Translate {
          y: root.showSubOptions ? 0 : Style.space(4)
          Behavior on y {
            NumberAnimation {
              duration: Style.duration(150)
              easing.type: Easing.Bezier
              easing.bezierCurve: Style.easeOut
            }
          }
        }

        Behavior on opacity {
          NumberAnimation {
            duration: Style.duration(150)
            easing.type: Easing.Bezier
            easing.bezierCurve: Style.easeOut
          }
        }

        Text {
          id: subLabel
          textFormat: Text.PlainText
          text: Commons.I18n.t("setup.dictationModeLabel")
          color: root.dim
          font.family: root.fontFamily
          font.pixelSize: Style.font.bodySmall
          anchors.left: parent.left
          anchors.verticalCenter: parent.verticalCenter
        }

        Row {
          id: subRow
          anchors.left: subLabel.right
          anchors.leftMargin: Style.space(14)
          anchors.right: parent.right
          anchors.verticalCenter: parent.verticalCenter
          height: parent.height
          spacing: Style.space(8)

          Repeater {
            model: subBar.shownSubOptions

            BorderSurface {
              id: subPill
              required property var modelData
              readonly property bool picked: !!root.pickedSubOption && root.pickedSubOption.id === modelData.id
              readonly property bool hovered: root.pointerAwake && segHover.hovered

              width: (subRow.width - Math.max(0, subBar.shownSubOptions.length - 1) * subRow.spacing) / Math.max(1, subBar.shownSubOptions.length)
              height: subRow.height
              radius: Style.cornerRadius
              color: picked ? Style.selectedFillFor(root.foreground, root.accent)
                : hovered ? Style.hoverFillFor(root.foreground, root.accent)
                : Style.normalFillFor(root.foreground, root.accent)
              borderSpec: Border.flat(
                picked ? (root.focusZone === "sub" ? root.accent : Util.alpha(root.accent, 0.72))
                  : hovered ? Util.alpha(root.foreground, 0.34)
                  : Util.alpha(root.foreground, 0.16),
                picked && root.focusZone === "sub" ? Math.max(1.5, Style.space(1.5)) : Style.spacing.hairline
              )

              Behavior on color { ColorAnimation { duration: Style.duration(130) } }

              Accessible.role: Accessible.RadioButton
              Accessible.name: modelData.label + (modelData.detail ? " " + modelData.detail : "")
              Accessible.checked: picked

              HoverHandler {
                id: segHover
                cursorShape: Qt.PointingHandCursor
              }

              TapHandler {
                onTapped: root.pickSubOption(modelData)
              }

              Row {
                anchors.centerIn: parent
                spacing: Style.space(7)

                Text {
                  textFormat: Text.PlainText
                  text: modelData.icon || ""
                  visible: text !== ""
                  color: subPill.picked ? root.accent : Util.alpha(root.foreground, 0.62)
                  font.family: root.fontFamily
                  font.pixelSize: Style.font.icon
                  anchors.verticalCenter: parent.verticalCenter
                  Behavior on color { ColorAnimation { duration: Style.duration(130) } }
                }

                Text {
                  textFormat: Text.PlainText
                  text: modelData.label
                  color: subPill.picked ? root.foreground : Util.alpha(root.foreground, 0.84)
                  font.family: root.fontFamily
                  font.pixelSize: Style.font.bodySmall
                  font.bold: subPill.picked
                  anchors.verticalCenter: parent.verticalCenter
                  Behavior on color { ColorAnimation { duration: Style.duration(130) } }
                }

                Text {
                  textFormat: Text.PlainText
                  visible: !!modelData.detail
                  text: "\u{b7}  " + (modelData.detail || "")
                  color: subPill.picked ? Util.alpha(root.foreground, 0.68) : Util.alpha(root.foreground, 0.46)
                  font.family: root.fontFamily
                  font.pixelSize: Style.font.bodySmall
                  anchors.verticalCenter: parent.verticalCenter
                  Behavior on color { ColorAnimation { duration: Style.duration(130) } }
                }

                Text {
                  textFormat: Text.PlainText
                  visible: subPill.picked
                  text: "\u{f00c}"
                  color: root.accent
                  font.family: root.fontFamily
                  font.pixelSize: Style.font.caption
                  anchors.verticalCenter: parent.verticalCenter
                }
              }
            }
          }
        }
      }

      // Single opt-in feature toggle card (Agent, single-model Local AI, Tailscale)
      SetupToggleCard {
        id: toggleCard
        visible: root.isToggle
        anchors.top: scene.bottom
        anchors.topMargin: Style.space(16)
        anchors.left: parent.left
        anchors.right: parent.right
        label: root.isToggle ? root.step.option.label : ""
        detail: root.isToggle ? root.step.option.detail : ""
        meta: root.isToggle && root.step.id === "local-ai" ? root.localFacts(root.step.option.facts, false) : ""
        icon: root.isToggle ? root.step.option.icon : ""
        iconFont: root.isToggle ? root.step.option.iconFont : ""
        vendor: root.isToggle ? (root.step.option.vendor || "") : ""
        enabled: root.toggleEnabled
        focused: root.focusZone === "control"
        lights: root.pointerAwake
        foreground: root.foreground
        accent: root.accent
        onToggled: root.flipToggle()
      }
    }

    // ----------------------------------------------------------- Ready screen

    Item {
      id: summaryPane
      visible: root.onSummary
      opacity: root.stepEnter
      transform: Translate { y: (1 - root.stepEnter) * Style.space(6) }
      anchors.top: topBar.bottom
      anchors.topMargin: Style.space(18)
      anchors.bottom: footer.top
      anchors.bottomMargin: Style.space(18)
      anchors.left: parent.left
      anchors.right: parent.right

      Column {
        id: summaryBody
        anchors.verticalCenter: parent.verticalCenter
        anchors.left: parent.left
        anchors.right: parent.right
        spacing: Style.space(22)

        Column {
          id: summaryHeader
          width: parent.width
          spacing: Style.space(14)

          Column {
            width: parent.width
            spacing: Style.space(8)

            // Calm 5-band Omarchy emblem when keeping current settings so the
            // zero-change finale feels intentional and ties back to Splash.
            Item {
              visible: root.plan.changes.length === 0
              anchors.horizontalCenter: parent.horizontalCenter
              width: Style.space(52)
              height: width

              BrandMark {
                anchors.centerIn: parent
                width: Style.space(40)
                height: width
                foreground: root.foreground
                accent: root.accent
                surface: root.color
              }
            }

            Text {
              textFormat: Text.PlainText
              text: root.plan.changes.length > 0 ? Commons.I18n.t("setup.summaryTitleChanges") : Commons.I18n.t("setup.summaryTitle")
              color: root.foreground
              font.family: root.fontFamily
              font.pixelSize: Style.font.heading
              font.bold: true
              horizontalAlignment: root.plan.changes.length === 0 ? Text.AlignHCenter : Text.AlignLeft
              wrapMode: Text.WordWrap
              width: parent.width
            }

            Text {
              textFormat: Text.PlainText
              text: root.plan.changes.length === 0 ? Commons.I18n.t("setup.summaryNone")
                : root.plan.hasInstalls ? Commons.I18n.t("setup.summaryInstalls")
                : Commons.I18n.t("setup.summaryInstant")
              color: root.dim
              font.family: root.fontFamily
              font.pixelSize: Style.font.body
              lineHeight: 1.35
              horizontalAlignment: root.plan.changes.length === 0 ? Text.AlignHCenter : Text.AlignLeft
              wrapMode: Text.WordWrap
              width: parent.width
            }
          }

          // Staged changes summary card with full-width left-label / right-value
          // alignment and subtle hairline row dividers.
          BorderSurface {
            visible: root.plan.changes.length > 0
            width: parent.width
            implicitHeight: changesCol.implicitHeight + Style.space(12)
            radius: Style.cornerRadius
            color: Style.normalFillFor(root.foreground, root.accent)
            borderSpec: Border.flat(Util.alpha(root.foreground, 0.2), Style.spacing.hairline)

            Column {
              id: changesCol
              anchors.left: parent.left
              anchors.right: parent.right
              anchors.verticalCenter: parent.verticalCenter
              anchors.leftMargin: Style.space(16)
              anchors.rightMargin: Style.space(16)

              Repeater {
                model: root.plan.changes

                Item {
                  required property int index
                  required property var modelData
                  width: parent.width
                  height: Style.space(34)

                  Rectangle {
                    visible: index > 0
                    anchors.top: parent.top
                    anchors.left: parent.left
                    anchors.right: parent.right
                    height: Style.spacing.hairline
                    color: Util.alpha(root.foreground, 0.1)
                  }

                  Text {
                    id: sumIcon
                    textFormat: Text.PlainText
                    text: modelData.icon
                    color: root.accent
                    font.family: modelData.iconFont !== "" ? modelData.iconFont : root.fontFamily
                    font.pixelSize: Style.font.icon
                    horizontalAlignment: Text.AlignHCenter
                    width: Style.space(20)
                    anchors.left: parent.left
                    anchors.verticalCenter: parent.verticalCenter
                  }

                  Text {
                    id: sumStep
                    textFormat: Text.PlainText
                    text: modelData.title
                    color: root.dim
                    font.family: root.fontFamily
                    font.pixelSize: Style.font.body
                    elide: Text.ElideRight
                    anchors.left: sumIcon.right
                    anchors.leftMargin: Style.space(10)
                    anchors.right: sumValue.left
                    anchors.rightMargin: Style.space(16)
                    anchors.verticalCenter: parent.verticalCenter
                  }

                  Text {
                    id: sumValue
                    textFormat: Text.PlainText
                    text: modelData.label
                    color: root.foreground
                    font.family: root.fontFamily
                    font.pixelSize: Style.font.body
                    font.bold: true
                    horizontalAlignment: Text.AlignRight
                    elide: Text.ElideRight
                    width: Math.min(implicitWidth, parent.width * 0.55)
                    anchors.right: parent.right
                    anchors.verticalCenter: parent.verticalCenter
                  }
                }
              }
            }
          }
        }

        // Three essential Omarchy shortcuts, sitting directly below the summary
        // without a giant gap.
        Column {
          width: parent.width
          spacing: Style.space(10)

          PanelSectionHeader {
            text: Commons.I18n.t("setup.shortcutsHeader").toUpperCase()
            foreground: root.foreground
            fontFamily: root.fontFamily
            font.letterSpacing: 1.4
          }

          Row {
            width: parent.width
            spacing: Style.space(10)

            Repeater {
              model: [
                { keys: ["Super", "Space"], label: Commons.I18n.t("setup.shortcutMenu") },
                { keys: ["Super", "L"], label: Commons.I18n.t("setup.shortcutLayout") },
                { keys: ["Super", "K"], label: Commons.I18n.t("setup.shortcutKeys") }
              ]

              BorderSurface {
                required property var modelData
                width: (parent.width - Style.space(20)) / 3
                height: shortcutCol.implicitHeight + Style.space(20)
                radius: Style.cornerRadius
                color: Style.normalFillFor(root.foreground, root.accent)
                borderSpec: Border.flat(Util.alpha(root.foreground, 0.2), Style.spacing.hairline)

                Column {
                  id: shortcutCol
                  anchors.left: parent.left
                  anchors.right: parent.right
                  anchors.margins: Style.space(12)
                  anchors.verticalCenter: parent.verticalCenter
                  spacing: Style.space(8)

                  Row {
                    spacing: Style.space(4)
                    LayoutMirroring.enabled: false

                    Repeater {
                      model: modelData.keys

                      Keycap {
                        required property string modelData
                        legend: modelData
                        foreground: root.foreground
                        accent: root.accent
                      }
                    }
                  }

                  Text {
                    textFormat: Text.PlainText
                    text: modelData.label
                    color: Util.alpha(root.foreground, 0.82)
                    font.family: root.fontFamily
                    font.pixelSize: Style.font.bodySmall
                    wrapMode: Text.WordWrap
                    width: parent.width
                  }
                }
              }
            }
          }
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
      height: Style.space(34)

      SetupButton {
        id: leave
        text: Commons.I18n.t("setup.skipTour")
        quiet: true
        hasCursor: root.focusZone === "skip"
        foreground: root.foreground
        accent: root.accent
        anchors.left: parent.left
        anchors.verticalCenter: parent.verticalCenter
        onClicked: root.dismissed()
      }

      TextMetrics {
        id: hintMetrics
        font: hint.font
        text: hint.text
      }

      Text {
        id: hint
        readonly property real room: Math.max(0, footer.width - 2 * (Math.max(leave.width, buttons.width) + Style.space(12)))

        textFormat: Text.PlainText
        text: root.onSummary ? Commons.I18n.t("setup.reviewHint")
          : root.isToggle ? Commons.I18n.t("setup.toggleHint")
          : Commons.I18n.t("setup.tourHint")
        color: Util.alpha(root.foreground, 0.42)
        font.family: root.fontFamily
        font.pixelSize: Style.font.bodySmall
        elide: Text.ElideRight
        width: Math.min(Math.ceil(hintMetrics.advanceWidth), room)
        visible: room > Style.space(80)
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.verticalCenter: parent.verticalCenter
      }

      Row {
        id: buttons
        anchors.right: parent.right
        anchors.verticalCenter: parent.verticalCenter
        spacing: Style.space(10)

        SetupButton {
          visible: root.onSummary ? root.steps.length > 0 : root.stepIndex > 0
          text: Commons.I18n.t("setup.back")
          hasCursor: root.focusZone === "back"
          foreground: root.foreground
          accent: root.accent
          onClicked: root.goToStep(root.stepIndex - 1)
        }

        SetupButton {
          text: root.onSummary
            ? (root.plan.changes.length > 0 ? Commons.I18n.t("setup.apply") : Commons.I18n.t("setup.startUsing"))
            : Commons.I18n.t("setup.continue")
          primary: true
          hasCursor: root.onSummary ? root.focusZone === "finish" : root.focusZone === "continue"
          foreground: root.foreground
          accent: root.accent
          onClicked: root.onSummary ? root.finish() : root.goToStep(root.stepIndex + 1)
        }
      }
    }
  }
}
