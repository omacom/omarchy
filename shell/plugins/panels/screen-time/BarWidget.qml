import QtQuick
import Quickshell
import Quickshell.Io
import qs.Ui
import qs.Commons
import qs.Commons as Commons

// The pill in the bar plus the panel behind it. The pill shows a glyph for
// the phase and the time that is left; the panel is where the child earns
// minutes with math problems and writes their notes. The parent's side (a
// grown-up's password, handing out time, the settings) is not in here: it
// lives in omarchy.screen-time-parent, an authentication service outside the
// scene a third-party plugin can traverse, and this panel only asks it to open.
Panel {
  id: root
  moduleName: "omarchy.screen-time"
  ipcTarget: "omarchy.screen-time"

  readonly property var screenTime: bar && bar.shell ? bar.shell.firstPartyServiceFor("omarchy.screen-time") : null
  readonly property bool connected: screenTime ? screenTime.connected === true : false
  readonly property string phase: screenTime ? String(screenTime.phase) : ""
  readonly property int remaining: screenTime ? screenTime.remainingSeconds : 0
  // In together mode the widget is a mirror, not a meter: it shows time
  // spent and never counts down. The one colour it carries is red once the
  // day has gone past what the family agreed on, so the kid sees it too.
  readonly property bool together: screenTime ? screenTime.philosophy === "together" : false
  readonly property bool overAgreement: together && screenTime
    && screenTime.agreementMinutes > 0
    && screenTime.spentSeconds >= screenTime.agreementMinutes * 60
  readonly property bool blockedPhase: phase === "empty" || phase === "bedtime"
  readonly property bool low: connected && !together && !blockedPhase
    && remaining <= (screenTime ? screenTime.minWarnSeconds : 60)

  // Glyphs as \u escapes so they survive the trip through the editor.
  readonly property string iconHourglass: "\uf254"
  readonly property string iconClock: "\uf017"
  readonly property string iconPause: "\uf04c"
  readonly property string iconLock: "\uf023"
  readonly property string iconMoon: "\uf186"
  readonly property string iconGear: "\uf013"
  readonly property string iconClose: "\uf00d"

  readonly property string icon: {
    if (phase === "bedtime") return iconMoon
    if (phase === "empty") return iconLock
    if (phase === "paused") return iconPause
    if (phase === "idle") return iconClock
    return iconHourglass
  }

  // Colours that carry meaning have to hold up on light themes too, so blend
  // towards the background instead of darkening, and pick the accent colours
  // per theme.
  function fade(c, amount) {
    var bg = Commons.Color.background
    return Qt.rgba(c.r + (bg.r - c.r) * amount,
                   c.g + (bg.g - c.g) * amount,
                   c.b + (bg.b - c.b) * amount, 1)
  }
  readonly property bool lightTheme: {
    var bg = Commons.Color.background
    return (0.299 * bg.r + 0.587 * bg.g + 0.114 * bg.b) > 0.5
  }
  readonly property color warnColor: lightTheme ? "#B4620A" : "#E5A050"
  readonly property color blockColor: lightTheme ? "#B03434" : "#E06C6C"
  readonly property color okColor: lightTheme ? "#3C7C4E" : "#5FA46B"
  readonly property color pillColor: {
    if (!root.bar) return "white"
    if (blockedPhase || overAgreement) return blockColor
    if (low) return warnColor
    if (phase === "idle" || phase === "paused") return fade(root.bar.barForeground, 0.45)
    return root.bar.barForeground
  }

  function fmt(seconds) {
    seconds = Math.max(0, Math.floor(seconds))
    if (seconds >= 3600) {
      var h = Math.floor(seconds / 3600)
      var m = Math.floor((seconds % 3600) / 60)
      // A whole hour is "1h", not "1h00". The zeroes only earn their place
      // when there are minutes to read next to them.
      if (m === 0) return I18n.t("screenTime.hoursShort").arg(h)
      return I18n.t("screenTime.hoursMinutesShort").arg(h).arg((m < 10 ? "0" : "") + m)
    }
    if (seconds >= 600) return I18n.t("screenTime.minutesShort").arg(Math.floor(seconds / 60))
    var mm = Math.floor(seconds / 60)
    var ss = seconds % 60
    return mm + ":" + (ss < 10 ? "0" : "") + ss
  }

  function plain(s) { return String(s || "").replace(/[<>]/g, "") }

  // The wall clock time of a ledger entry, for the notes. Seconds since the
  // epoch, and anything that is not a number gets no label rather than a
  // wrong one.
  function clockTime(t) {
    var seconds = Number(t)
    if (!isFinite(seconds) || seconds <= 0) return ""
    var when = new Date(seconds * 1000)
    return Qt.formatTime(when, "HH:mm")
  }

  readonly property string label: {
    if (together) return fmt(screenTime ? screenTime.spentSeconds : 0)
    if (blockedPhase) return phase === "bedtime" ? blockedName : "0:00"
    return fmt(remaining)
  }

  readonly property string clientPath: "omarchy-screen-time"

  // --- quiz state -----------------------------------------------------

  property var question: null        // {id, text, reward_seconds}
  property string quizNoteKind: ""   // why there is no question: "full" or "none"
  readonly property string quizNote: quizNoteKind === "full" ? I18n.t("screenTime.bonusFull")
    : quizNoteKind === "none" ? I18n.t("screenTime.noQuestion") : ""
  // Newest first, so the reward that just landed is always in view.
  readonly property var earnEventsView: screenTime && screenTime.earnEvents
    ? screenTime.earnEvents.slice().reverse() : []
  // What the last answer earned, kept as a kind and its values rather than
  // as text, so a language switch redraws it.
  property string feedbackKind: ""
  property var feedbackArgs: []
  readonly property string feedback: {
    var a = feedbackArgs
    if (feedbackKind === "tooFast") return I18n.t("screenTime.tooFast").arg(a[0])
    if (feedbackKind === "expired") return I18n.t("screenTime.questionExpired")
    if (feedbackKind === "failed") return I18n.t("screenTime.questionFailed")
    if (feedbackKind === "correct") return I18n.t("screenTime.correct").arg(a[0])
    if (feedbackKind === "wrong") return I18n.t("screenTime.notQuite").arg(a[0]).arg(a[1])
    return ""
  }
  property color feedbackColor: root.bar ? root.bar.barForeground : "white"
  readonly property bool earnEnabled: screenTime ? screenTime.earnEnabled === true : false

  // --- what the head of the panel says --------------------------------

  // One line under the name: what the clock is doing. The numbers moved to
  // the stat row, so this says the thing a number cannot.
  readonly property string stateLine: {
    if (!screenTime) return ""
    if (phase === "empty") return I18n.t("screenTime.stateUp")
    if (phase === "bedtime") return blockedName
    if (phase === "paused") return I18n.t("screenTime.statePaused")
    if (phase === "idle") return I18n.t("screenTime.stateIdle")
    return I18n.t("screenTime.stateCounting")
  }

  // What to call the block that is on right now. The daemon names the period
  // the family wrote, so dinner does not get announced as bedtime.
  readonly property string blockedName: {
    var name = screenTime ? plain(String(screenTime.blockedLabel || "")).trim() : ""
    return name === "" ? I18n.t("screenTime.blocked") : name.toLowerCase()
  }

  // A fresh config names the profile "Default", which is nobody, and that is
  // what ends up in the biggest text on the card. Until a family gives a
  // child a name of their own, the panel says what it is instead.
  readonly property string heroTitle: {
    if (!screenTime) return I18n.t("screenTime.title")
    var name = plain(screenTime.profileName).trim()
    return (name === "" || name === "Default") ? I18n.t("screenTime.title") : name
  }

  // The line under the bar: what the bar itself cannot say. In limits mode
  // that is when the day ends, in agreement mode what the family settled on.
  // It lives here rather than in the hero's meta because the hero shouts its
  // meta in capitals, and a sentence is not a label.
  readonly property string underBarLine: {
    if (!screenTime) return ""
    if (together) {
      if (screenTime.agreementMinutes > 0)
        return I18n.t("screenTime.aboutAgreed").arg(fmt(screenTime.agreementMinutes * 60))
      return ""
    }
    var next = screenTime.nextBlock
    if (!next || !next.start) return ""
    return I18n.t("screenTime.blockAt").arg(plain(String(next.label)).toLowerCase()).arg(plain(String(next.start)))
  }

  // The day in even cells, so the eye can compare them instead of reading a
  // sentence. Earned and given only appear once they have something to say,
  // which keeps a plain day a plain two-cell row.
  readonly property var dayStats: {
    if (!screenTime || together) return []
    var out = [{ label: I18n.t("screenTime.statUsed"), value: fmt(screenTime.spentSeconds), accent: false }]
    if (screenTime.earnedSeconds > 0)
      out.push({ label: I18n.t("screenTime.statEarned"), value: fmt(screenTime.earnedSeconds), accent: true })
    if (screenTime.grantedSeconds > 0)
      out.push({ label: I18n.t("screenTime.statGiven"), value: fmt(screenTime.grantedSeconds), accent: true })
    out.push({ label: I18n.t("screenTime.statBudget"), value: fmt(screenTime.budgetSeconds), accent: false })
    return out
  }

  function fetchQuestion() {
    if (quizProc.running) return
    quizProc.running = true
  }

  function submitAnswer() {
    if (!question || answerProc.running) return
    var field = panel.loadedContent ? panel.loadedContent.answerField : null
    if (!field) return
    var given = field.text.trim()
    if (given === "") return
    answerProc.command = [root.clientPath, "answer", String(question.id), given]
    answerProc.running = true
  }

  function applyQuiz(payload) {
    if (payload.ok === true && payload.question) {
      question = payload.question
      quizNoteKind = ""
      return
    }
    question = null
    if (payload.error === "daily_cap_reached") quizNoteKind = "full"
    else if (payload.error === "earning_disabled") quizNoteKind = ""
    else quizNoteKind = "none"
  }

  function showFeedback(kind, args) {
    feedbackArgs = args
    feedbackKind = kind
  }

  function applyVerdict(payload) {
    if (payload.error === "too_fast") {
      showFeedback("tooFast", [Number(payload.wait_seconds) || 0])
      feedbackColor = root.warnColor
      return
    }
    if (payload.ok !== true) {
      showFeedback(payload.error === "expired" ? "expired" : "failed", [])
      feedbackColor = root.warnColor
      clearAnswer()
      fetchQuestion()
      return
    }
    if (payload.correct === true) {
      showFeedback("correct", [Number(payload.reward_seconds) || 0])
      feedbackColor = root.okColor
    } else {
      showFeedback("wrong", [plain(payload.text), plain(payload.answer)])
      feedbackColor = root.blockColor
    }
    clearAnswer()
    fetchQuestion()
  }

  // --- the parent ------------------------------------------------------

  // The parent's window is the authentication service's; the panel can only
  // ask for it over IPC, the same way a bin asks the lock screen to lock.
  function openParent(what) {
    if (parentProc.running) return
    parentProc.command = ["omarchy-shell", "screen-time-parent", what === "settings" ? "openSettings" : "open"]
    parentProc.running = true
    root.close()
  }

  function clearAnswer() {
    if (panel.loadedContent) panel.loadedContent.answerField.text = ""
  }

  function resetPanel() {
    showFeedback("", [])
    clearAnswer()
  }

  onOpenedChanged: {
    if (opened) {
      if (earnEnabled && !together) fetchQuestion()
    } else {
      resetPanel()
    }
  }

  function forgetNote(t) {
    if (forgetProc.running) return
    var stamp = Number(t)
    if (!isFinite(stamp) || stamp <= 0) return
    forgetProc.command = [root.clientPath, "forget", String(stamp)]
    forgetProc.running = true
  }

  function submitReflection() {
    if (reflectProc.running) return
    var field = panel.loadedContent ? panel.loadedContent.reflectField : null
    if (!field) return
    var text = field.text.trim()
    if (text === "") return
    reflectProc.command = [root.clientPath, "reflect", text]
    reflectProc.running = true
  }

  // --- processes ------------------------------------------------------

  Process {
    id: quizProc
    command: [root.clientPath, "quiz"]
    stdout: StdioCollector {
      onStreamFinished: {
        var payload
        try { payload = JSON.parse(text) } catch (e) { return }
        root.applyQuiz(payload)
      }
    }
  }

  Process {
    id: answerProc
    stdout: StdioCollector {
      onStreamFinished: {
        var payload
        try { payload = JSON.parse(text) } catch (e) { return }
        root.applyVerdict(payload)
      }
    }
  }

  Process {
    id: reflectProc
    stdout: StdioCollector {
      onStreamFinished: {
        var payload
        try { payload = JSON.parse(text) } catch (e) { return }
        if (payload.ok === true && panel.loadedContent) panel.loadedContent.reflectField.text = ""
      }
    }
  }

  Process {
    id: forgetProc
    // The list redraws off the watch stream, so nothing to do here but read
    // the answer and let a refusal be quiet: a note that would not go is
    // still on screen, which is the whole message.
    stdout: StdioCollector {
      onStreamFinished: {
        var payload
        try { payload = JSON.parse(text) } catch (e) { return }
      }
    }
  }

  Process {
    id: parentProc
  }

  // --- the pill -------------------------------------------------------

  visible: connected
  implicitWidth: connected ? row.implicitWidth + Style.space(14) : 0
  implicitHeight: bar ? bar.barSize : Style.bar.sizeHorizontal

  Row {
    id: row
    anchors.centerIn: parent
    spacing: Style.space(6)

    Text {
      textFormat: Text.PlainText
      anchors.verticalCenter: parent.verticalCenter
      text: root.icon
      color: root.pillColor
      font.family: root.bar ? root.bar.fontFamily : Style.font.family
      font.pixelSize: Style.font.caption
      Behavior on color {
        enabled: !root.bar || root.bar.foregroundAnimationEnabled
        ColorAnimation { duration: Style.duration(160) }
      }
    }

    Text {
      textFormat: Text.PlainText
      anchors.verticalCenter: parent.verticalCenter
      visible: !root.bar || !root.bar.vertical
      text: root.label
      color: root.pillColor
      font.family: root.bar ? root.bar.fontFamily : Style.font.family
      font.pixelSize: Style.font.body
      Behavior on color {
        enabled: !root.bar || root.bar.foregroundAnimationEnabled
        ColorAnimation { duration: Style.duration(160) }
      }
    }
  }

  MouseArea {
    id: pillArea
    anchors.fill: parent
    hoverEnabled: true
    cursorShape: Qt.PointingHandCursor
    onClicked: root.toggle()
  }

  // --- the panel ------------------------------------------------------

  KeyboardPanel {
    id: panel
    anchorItem: root
    owner: root
    bar: root.bar
    open: root.opened
    focusTarget: !panel.loadedContent ? null
      : (root.together ? panel.loadedContent.reflectField
        : (root.earnEnabled ? panel.loadedContent.answerField : panel.loadedContent))
    // Agreement mode is nearly all prose, and prose reads better on a
    // narrower measure than a card full of controls.
    readonly property int desiredWidth: Style.space(root.together ? 280 : 330)
    contentWidth: Math.min(desiredWidth,
                           panel.availableCardWidth > 0 ? panel.availableCardWidth : desiredWidth)
    contentHeight: panel.fittedContentHeight(panel.loadedContentHeight)

    content: PanelKeyCatcher {
      id: keyCatcher
      property alias answerField: answerField
      property alias reflectField: reflectField
      implicitHeight: cardColumn.implicitHeight
      anchors.fill: parent
      onCloseRequested: root.close()
      // A form, so Tab walks the controls in focus order instead of
      // switching panels.
      onTabRequested: function(direction) {
        var from = keyCatcher.Window.activeFocusItem || keyCatcher
        var next = from.nextItemInFocusChain(direction > 0)
        if (next) next.forceActiveFocus()
      }

      Column {
        id: cardColumn
        width: parent.width
        // The shell's own rhythm: 14 between sections, 6 inside one.
        spacing: Style.space(14)

        // header, in the shell's own hero shape: icon, name, the time as the
        // detail pill, and one uppercase meta line underneath
        PanelHero {
          width: parent.width
          foreground: Commons.Color.popups.text
          title: root.heroTitle
          detail: {
            if (root.together) return I18n.t("screenTime.spentToday").arg(root.fmt(root.screenTime ? root.screenTime.spentSeconds : 0))
            if (root.blockedPhase) return root.phase === "bedtime" ? root.blockedName : I18n.t("screenTime.timesUp")
            return I18n.t("screenTime.timeLeft").arg(root.fmt(root.remaining))
          }
          // One line, so one fact at a time: the hero meta elides rather than
          // wraps. Earned and granted minutes already show further down, and
          // the agreed time is also the progress bar's scale.
          meta: {
            if (!root.screenTime) return ""
            if (root.together) {
              if (root.phase === "paused") return I18n.t("screenTime.metaPaused")
              if (root.screenTime.stretchSeconds >= 600)
                return I18n.t("screenTime.withoutBreak").arg(root.fmt(root.screenTime.stretchSeconds))
              return ""
            }
            return root.stateLine
          }
          iconComponent: Component {
            Text {
              id: heroIcon
              textFormat: Text.PlainText
              text: root.icon
              color: root.pillColor
              font.family: Style.font.family
              font.pixelSize: Style.font.display

              // An hourglass that never turns is a drawing. Turning it over
              // every fifteen seconds is the panel saying the day is still
              // running, which is exactly when the glyph is an hourglass:
              // paused, idle and bedtime all draw something else.
              // The glyph is close to symmetric top to bottom, so the turn
              // itself is the whole effect: it lands looking the same. Hence
              // the overshoot and the squash, and hence the first turn coming
              // a second after the panel opens rather than only at the first
              // fifteen second mark, which you would have to be lucky to see.
              property real flip: 0
              rotation: flip
              transformOrigin: Item.Center

              Behavior on flip {
                NumberAnimation { duration: Style.duration(900); easing.type: Easing.InOutBack }
              }

              SequentialAnimation {
                id: flipSquash
                NumberAnimation {
                  target: heroIcon; property: "scale"
                  to: 0.8; duration: Style.duration(450); easing.type: Easing.OutQuad
                }
                NumberAnimation {
                  target: heroIcon; property: "scale"
                  to: 1.0; duration: Style.duration(450); easing.type: Easing.OutBack
                }
              }

              Timer {
                id: flipTimer
                interval: 1200
                repeat: true
                running: root.opened && root.phase === "running"
                onRunningChanged: if (running) interval = 1200
                onTriggered: {
                  heroIcon.flip += 180
                  flipSquash.restart()
                  interval = 15000
                }
              }
            }
          }
        }

        // The day, broken into cells of exactly equal width so the figures
        // line up under each other however many there are. The cell is a
        // plain Item and the labels are centred inside it: a nested layout
        // sizes itself to its content and packs everything to the left.
        Row {
          id: statRow
          width: parent.width
          spacing: 0
          visible: root.dayStats.length > 0

          Repeater {
            model: root.dayStats

            delegate: Item {
              width: statRow.width / Math.max(1, root.dayStats.length)
              height: statCell.implicitHeight

              Column {
                id: statCell
                anchors.centerIn: parent
                spacing: Style.space(4)

                Text {
                  textFormat: Text.PlainText
                  text: modelData.value
                  anchors.horizontalCenter: parent.horizontalCenter
                  color: modelData.accent === true ? root.okColor : Commons.Color.popups.text
                  font.family: Style.font.family
                  font.pixelSize: Style.font.title
                  font.bold: true
                }

                Text {
                  textFormat: Text.PlainText
                  text: String(modelData.label).toUpperCase()
                  anchors.horizontalCenter: parent.horizontalCenter
                  color: root.fade(Commons.Color.popups.text, 0.45)
                  font.family: Style.font.family
                  font.pixelSize: Style.font.caption
                  font.bold: true
                  font.letterSpacing: 1.2
                }
              }
            }
          }
        }

        // How far into the day you are: spent versus everything there is
        // today (or versus the agreement, in together mode, where the bar
        // stays a neutral colour whatever it says). The bar and the line
        // under it are one block, so they sit closer than the sections do.
        Column {
          width: parent.width
          spacing: Style.space(6)

          // Square ends, because the hatching runs to the edge and a rounded
          // cap would cut the diagonals off mid stroke.
          Rectangle {
            id: dayBar
            width: parent.width
            height: Style.space(12)
            radius: 0
            visible: !root.together || (root.screenTime && root.screenTime.agreementMinutes > 0)
            color: root.fade(Commons.Color.popups.text, 0.86)

            readonly property int total: {
              if (!root.screenTime) return 0
              if (root.together) return root.screenTime.agreementMinutes * 60
              return root.screenTime.spentSeconds + root.remaining
            }
            readonly property real fraction: total > 0
              ? Math.min(1, (root.screenTime ? root.screenTime.spentSeconds : 0) / total) : 0
            readonly property color fillColor: root.together
              ? (root.bar ? root.bar.barForeground : "white") : root.pillColor

            // The hatching: thin bars on the diagonal, one pitch apart. The
            // pitch is also how far the pattern has to travel before it repeats,
            // so drifting by exactly one pitch loops without a seam.
            readonly property int stroke: Style.space(2)
            readonly property int pitch: Style.space(7)
            property real drift: 0

            NumberAnimation on drift {
              from: 0
              to: dayBar.pitch
              duration: Style.duration(2200)
              loops: Animation.Infinite
              // Only while time is actually being used up, and only while
              // somebody is looking: a drifting pattern behind a closed panel
              // is work nobody asked for. Agreement mode drifts too. The rule
              // there is that nothing counts down and nothing warns, and a
              // pattern saying the clock runs does neither.
              running: root.opened && root.phase === "running"
            }

            Item {
              id: fill
              height: parent.height
              width: parent.width * dayBar.fraction

              Behavior on width {
                NumberAnimation { duration: Style.duration(300); easing.type: Easing.OutCubic }
              }

              // The base tint under the hatching.
              Rectangle {
                anchors.fill: parent
                color: root.fade(dayBar.fillColor, 0.55)
              }

              Item {
                anchors.fill: parent
                clip: true

                Row {
                  height: parent.height
                  x: -dayBar.pitch + dayBar.drift
                  spacing: dayBar.pitch - dayBar.stroke

                  Repeater {
                    // Counted off the track, not off the fill, so the model
                    // does not churn while the fill animates.
                    model: Math.ceil((dayBar.width + dayBar.pitch * 4) / dayBar.pitch)

                    delegate: Rectangle {
                      width: dayBar.stroke
                      // Taller than the bar and lifted, so the 45 degree turn
                      // still covers the full height at both ends.
                      height: dayBar.height * 2.4
                      y: -dayBar.height * 0.7
                      color: dayBar.fillColor
                      rotation: 45
                      antialiasing: true
                    }
                  }
                }
              }
            }
          }

          // When the day ends, which the bar cannot say because bedtime is not
          // a share of the budget.
          Text {
            textFormat: Text.PlainText
            visible: root.underBarLine !== ""
            text: root.underBarLine
            width: parent.width
            color: root.fade(Commons.Color.popups.text, 0.45)
            font.family: Style.font.family
            font.pixelSize: Style.font.caption
          }

        }

        // --- together mode: the agreement and the child's own notes ------
        PanelSeparator { width: parent.width; visible: root.together }

        Column {
          width: parent.width
          spacing: Style.space(6)
          visible: root.together

          PanelSectionHeader {
            text: I18n.t("screenTime.ourAgreement")
            foreground: Commons.Color.popups.text
          }

          Text {
            textFormat: Text.PlainText
            text: root.screenTime && root.screenTime.agreementText !== ""
              ? I18n.t("screenTime.agreementQuoted").arg(root.plain(root.screenTime.agreementText))
              : I18n.t("screenTime.noAgreement")
            width: parent.width
            wrapMode: Text.WordWrap
            font.italic: root.screenTime ? root.screenTime.agreementText !== "" : false
            color: Commons.Color.popups.text
            font.family: Style.font.family
            font.pixelSize: Style.font.body
          }

        }

        PanelSeparator { width: parent.width; visible: root.together }

        Column {
          width: parent.width
          spacing: Style.space(6)
          visible: root.together

          PanelSectionHeader {
            text: I18n.t("screenTime.howIsItGoing")
            foreground: Commons.Color.popups.text
          }

          // No button next to it: enter keeps the note, and the placeholder
          // is where that is said, now that the button is gone. Rounded like
          // the bubbles underneath, because it is the one you are writing.
          TextField {
            id: reflectField
            width: parent.width
            placeholderText: I18n.t("screenTime.notePlaceholder")
            activeFocusOnTab: true
            Keys.onPressed: function(event) {
              if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
                root.submitReflection(); event.accepted = true
              } else if (event.key === Qt.Key_Escape) {
                root.close(); event.accepted = true
              }
            }

            // Only the corner radius differs from the shared field, so the
            // fill and the border spec come from the field itself.
            background: BorderSurface {
              color: Style.controlFill(reflectField._focused, reflectField._hot,
                                       reflectField.foreground, reflectField.accent)
              borderSpec: reflectField._borderSpec
              radius: Math.max(Style.cornerRadius, Style.space(10))
            }
          }

          // The notes read as a conversation with yourself, so they are
          // bubbles and they run oldest to newest, the way a chat does. The
          // rounding is deliberate rather than the theme's: a square bubble
          // is not a bubble, so it takes the larger of the two.
          Column {
            id: notes
            width: parent.width
            // Bubbles need room to read as separate notes rather than as one
            // block of text, so they sit further apart than a list row would.
            // The top padding is the gap to the field you write them in.
            spacing: Style.space(10)
            topPadding: Style.space(12)
            bottomPadding: Style.space(4)

            Repeater {
              model: root.screenTime && root.screenTime.reflections
                ? root.screenTime.reflections : []

              // Anchored rather than a Row: the times line up in one column
              // on the right instead of trailing each bubble at whatever
              // width it happens to have, which reads as ragged.
              delegate: Item {
                id: noteRow
                width: notes.width
                height: bubble.height

                required property var modelData
                required property int index
                // Every other note leans the other way. A degree is enough to
                // read as handwriting on a wall; more and it reads as broken.
                readonly property real tilt: (index % 2 === 0 ? -0.9 : 0.8)
                // The hover covers the whole row, not just the bubble. With it
                // on the bubble the cross faded out exactly as the pointer
                // travelled to it, and an invisible button still takes clicks,
                // so it could also be hit blind.
                readonly property bool showForget: rowHover.hovered || forgetButton.activeFocus

                HoverHandler { id: rowHover }

                Rectangle {
                  id: bubble
                  anchors.left: parent.left
                  anchors.top: parent.top
                  radius: Math.max(Style.cornerRadius, Style.space(10))
                  color: root.fade(Commons.Color.popups.text, 0.86)
                  width: bubbleText.width + Style.space(20)
                  height: bubbleText.implicitHeight + Style.space(16)
                  rotation: noteRow.tilt
                  antialiasing: true

                  Text {
                    id: bubbleText
                    textFormat: Text.PlainText
                    text: root.plain(noteRow.modelData.text)
                    // Clamped against its own natural width, so a short note
                    // gets a short bubble and a long one wraps at the card.
                    width: Math.min(implicitWidth, notes.width * 0.72)
                    wrapMode: Text.WordWrap
                    anchors.centerIn: parent
                    color: Commons.Color.popups.text
                    font.family: Style.font.family
                    font.pixelSize: Style.font.body
                  }
                }

                // Taking a note back. Hidden until the pointer is on the
                // bubble, but it also appears on keyboard focus, because a
                // control that only a mouse can find is not a control.
                PanelActionButton {
                  id: forgetButton
                  iconText: root.iconClose
                  tooltipText: I18n.t("screenTime.forgetNote")
                  foreground: Commons.Color.popups.text
                  hoverColor: root.blockColor
                  size: Style.space(20)
                  focusable: true
                  opacity: noteRow.showForget ? 1 : 0
                  anchors.right: noteTime.left
                  anchors.rightMargin: Style.space(6)
                  anchors.verticalCenter: bubble.verticalCenter
                  onClicked: root.forgetNote(noteRow.modelData.t)

                  Behavior on opacity {
                    NumberAnimation { duration: Style.duration(120) }
                  }
                }

                Text {
                  id: noteTime
                  textFormat: Text.PlainText
                  text: root.clockTime(noteRow.modelData.t)
                  visible: text !== ""
                  anchors.right: parent.right
                  anchors.bottom: bubble.bottom
                  anchors.bottomMargin: Style.space(5)
                  color: root.fade(Commons.Color.popups.text, 0.55)
                  font.family: Style.font.family
                  font.pixelSize: Style.font.caption
                }
              }
            }
          }

        }

        // Revisiting the agreement lives at the very bottom, under the
        // notes: it is the one thing here a parent reaches for, and it
        // should not sit between the child and their own words.
        PanelSeparator { width: parent.width; visible: root.together }

        // Revisiting the agreement is the parent's window (the settings),
        // which in agreement mode saves without a password.
        Button {
          text: I18n.t("screenTime.revisitTogether")
          focusable: true
          width: parent.width
          visible: root.together
          onClicked: root.openParent("settings")
        }

        // --- limits mode: earning and the parent controls ----------------
        PanelSeparator { width: parent.width; visible: root.earnEnabled && !root.together }

        // earn minutes with math problems
        Column {
          width: parent.width
          spacing: Style.space(6)
          visible: root.earnEnabled && !root.together

          PanelSectionHeader {
            text: I18n.t("screenTime.earnMinutes")
            foreground: Commons.Color.popups.text
          }

          // The one thing the child came here to do, so it sits on a surface
          // of its own rather than reading as another line of text. The
          // answer field takes what is left over, which puts Check against
          // the right edge whatever the sum is.
          Rectangle {
            width: parent.width
            visible: root.question !== null
            radius: Style.cornerRadius
            color: root.fade(Commons.Color.popups.text, 0.88)
            implicitHeight: questionRow.implicitHeight + Style.space(12)

            Row {
              id: questionRow
              anchors.left: parent.left
              anchors.right: parent.right
              anchors.leftMargin: Style.space(10)
              anchors.rightMargin: Style.space(10)
              anchors.verticalCenter: parent.verticalCenter
              spacing: Style.space(10)

              Text {
                id: questionText
                textFormat: Text.PlainText
                text: root.question ? String(root.question.text) + " =" : ""
                color: Commons.Color.popups.text
                font.family: Style.font.family
                font.bold: true
                font.pixelSize: Style.font.title
                anchors.verticalCenter: parent.verticalCenter
              }

              TextField {
                id: answerField
                width: Math.max(Style.space(52),
                                questionRow.width - questionText.width
                                  - checkButton.implicitWidth - questionRow.spacing * 2)
                activeFocusOnTab: true
                inputMethodHints: Qt.ImhFormattedNumbersOnly
                Keys.onPressed: function(event) {
                  if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
                    root.submitAnswer(); event.accepted = true
                  } else if (event.key === Qt.Key_Escape) {
                    root.close(); event.accepted = true
                  }
                }
              }

              Button {
                id: checkButton
                text: I18n.t("screenTime.check")
                focusable: true
                anchors.verticalCenter: parent.verticalCenter
                onClicked: root.submitAnswer()
              }
            }
          }

          Text {
            textFormat: Text.PlainText
            visible: root.quizNote !== ""
            text: root.quizNote
            width: parent.width
            wrapMode: Text.WordWrap
            color: root.fade(Commons.Color.popups.text, 0.3)
            font.family: Style.font.family
            font.pixelSize: Style.font.body
          }

          Text {
            textFormat: Text.PlainText
            visible: root.feedback !== ""
            text: root.feedback
            color: root.feedbackColor
            font.family: Style.font.family
            font.pixelSize: Style.font.body
          }

          Text {
            textFormat: Text.PlainText
            visible: root.question !== null && root.screenTime !== null
            text: root.question && root.screenTime
              ? I18n.t("screenTime.quizTerms").arg(Number(root.question.reward_seconds) || 0).arg(root.fmt(root.screenTime.earnRoomSeconds))
              : ""
            color: root.fade(Commons.Color.popups.text, 0.45)
            font.family: Style.font.family
            font.pixelSize: Style.font.caption
          }

          // The tally: every reward earned today, newest on top. The list
          // scrolls inside a capped height, so the card never outgrows the
          // screen however good the day was.
          Column {
            width: parent.width
            spacing: Style.space(3)
            visible: root.earnEventsView.length > 0

            PanelSectionHeader {
              text: I18n.t("screenTime.sumsToday").arg(root.fmt(root.screenTime ? root.screenTime.earnedSeconds : 0).toUpperCase())
              foreground: Commons.Color.popups.text
            }

            ListView {
              id: earnList
              width: parent.width
              height: Math.min(contentHeight, Style.space(110))
              clip: true
              interactive: contentHeight > height
              model: root.earnEventsView
              delegate: Item {
                width: earnList.width
                height: earnRowText.implicitHeight + Style.space(10)

                readonly property bool missed: modelData.kind === "miss"

                // The sum is what happened, the right hand side is what it
                // was worth: the question recedes and the outcome carries the
                // colour. A miss keeps the answer that was given, struck
                // through, so the afternoon shows the hard tables too.
                Text {
                  id: earnRowText
                  textFormat: Text.PlainText
                  text: root.plain(modelData.q)
                  color: root.fade(Commons.Color.popups.text, 0.2)
                  font.family: Style.font.family
                  font.pixelSize: Style.font.body
                  anchors.verticalCenter: parent.verticalCenter
                }
                Row {
                  anchors.right: parent.right
                  anchors.verticalCenter: parent.verticalCenter
                  spacing: Style.space(6)

                  Text {
                    textFormat: Text.PlainText
                    visible: parent.parent.missed
                    text: String(modelData.given)
                    color: root.blockColor
                    font.family: Style.font.family
                    font.pixelSize: Style.font.body
                    font.strikeout: true
                  }

                  Text {
                    textFormat: Text.PlainText
                    text: parent.parent.missed
                      ? String(modelData.answer)
                      : I18n.t("screenTime.rewardSeconds").arg(Number(modelData.seconds) || 0)
                    color: parent.parent.missed
                      ? root.fade(Commons.Color.popups.text, 0.35) : root.okColor
                    font.family: Style.font.family
                    font.pixelSize: Style.font.body
                    font.bold: !parent.parent.missed
                  }
                }
              }
            }
          }
        }

        PanelSeparator { width: parent.width; visible: !root.together }

        // The parent's door. Everything behind it (the password, the minutes,
        // the settings) is drawn by omarchy.screen-time-parent in a window of
        // its own, so a password is never typed into this panel.
        Column {
          width: parent.width
          spacing: Style.space(6)
          visible: !root.together

          Item {
            width: parent.width
            implicitHeight: parentHeader.implicitHeight

            PanelSectionHeader {
              id: parentHeader
              text: I18n.t("screenTime.parentHeader")
              foreground: Commons.Color.popups.text
            }

            Text {
              textFormat: Text.PlainText
              text: root.iconLock
              color: root.fade(Commons.Color.popups.text, 0.5)
              anchors.right: parent.right
              anchors.verticalCenter: parentHeader.verticalCenter
              font.family: Style.font.family
              font.pixelSize: Style.font.caption
            }
          }

          Rectangle {
            width: parent.width
            radius: Style.cornerRadius
            implicitHeight: parentRow.implicitHeight + Style.space(12)
            color: root.fade(Commons.Color.popups.text, 0.9)

            Row {
              id: parentRow
              anchors.left: parent.left
              anchors.right: parent.right
              anchors.leftMargin: Style.space(10)
              anchors.rightMargin: Style.space(10)
              anchors.verticalCenter: parent.verticalCenter
              spacing: Style.space(8)

              Text {
                textFormat: Text.PlainText
                width: parentRow.width - parentButton.implicitWidth - parentRow.spacing
                wrapMode: Text.WordWrap
                anchors.verticalCenter: parent.verticalCenter
                text: I18n.t("screenTime.parentHint")
                color: root.fade(Commons.Color.popups.text, 0.2)
                font.family: Style.font.family
                font.pixelSize: Style.font.body
              }

              Button {
                id: parentButton
                text: I18n.t("screenTime.parentButton")
                focusable: true
                anchors.verticalCenter: parent.verticalCenter
                onClicked: root.openParent("controls")
              }
            }
          }
        }

      }
    }
  }
}
