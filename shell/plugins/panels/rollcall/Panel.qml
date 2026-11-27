import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import qs.Commons
import qs.Commons as Commons
import qs.Ui
import "Model.js" as Model

// The roll call walkthrough: the automated omarchy-rollcall checks, then every
// attended test omarchy-rollcall-test lists for this machine, one step at a
// time, and a report to paste into an issue. A floating card rather than an
// overlay, since steps send the person to the Bluetooth panel, a monitor or a
// media player; it takes the keyboard only where a step needs it.
//
// The tests run, record and restore on their own; this panel shows what they
// ask, answers their questions with --record, and measures the three things
// only a window can see: typing, touchpad gestures and touches.
Item {
  id: root

  property var shell: null
  property var manifest: null

  property bool opened: false
  property string view: "start"          // start | step | summary
  property var tests: []
  property var automated: null
  property bool listing: false
  property bool checking: false
  property int stepIndex: 0

  // The step on screen.
  property string phase: "ready"         // ready | running | verify | done
  property string promptKey: ""
  property string promptEnglish: ""
  property real progress: -1
  property string imagePath: ""
  property int imageToken: 0
  property string questionKey: ""
  property string questionEnglish: ""
  property string result: ""
  property string detail: ""
  property string lastLog: ""
  property bool stopping: false
  property var outcomes: ({})

  readonly property string stateDir: (Quickshell.env("XDG_RUNTIME_DIR") || "") + "/omarchy-rollcall"
  readonly property var steps: tests.filter(function(t) { return t.applicable })
  readonly property var current: steps.length > 0 && stepIndex < steps.length ? steps[stepIndex] : null
  readonly property bool panelStep: !!current && current.kind === "panel"
  // Running tests leave the keyboard to the rest of the desktop, except the
  // keyboard check, which is nothing but key presses.
  readonly property bool wantsKeyboard: view !== "step" || phase !== "running" || (panelStep && current.id === "keyboard")

  function open(payloadJson) {
    opened = true
    view = "start"
    stepIndex = 0
    outcomes = ({})
    refresh()
    Qt.callLater(function() { if (root.opened) keys.forceActiveFocus() })
  }

  function close() {
    opened = false
    stopTest()
  }

  function dismiss() {
    if (shell && typeof shell.hide === "function")
      shell.hide((manifest && manifest.id) || "omarchy.rollcall")
    else close()
  }

  function refresh() {
    if (!listProc.running) { listing = true; listProc.running = true }
    if (!autoProc.running) { checking = true; autoProc.running = true }
  }

  function begin() {
    if (steps.length === 0) { view = "summary"; return }
    view = "step"
    showStep(0)
  }

  function showStep(i) {
    stopTest()
    stepIndex = Math.max(0, Math.min(i, steps.length - 1))
    var done = current ? outcomes[current.id] : null
    phase = done ? "done" : "ready"
    result = done ? done.result : ""
    detail = done ? done.detail : ""
    promptKey = ""
    promptEnglish = ""
    questionKey = ""
    questionEnglish = ""
    imagePath = ""
    progress = -1
    lastLog = ""
    keys.forceActiveFocus()
  }

  function next() {
    if (stepIndex + 1 < steps.length) showStep(stepIndex + 1)
    else { stopTest(); view = "summary" }
  }

  function start() {
    if (!current || testProc.running) return
    phase = "running"
    result = ""
    detail = ""
    lastLog = ""
    promptKey = ""
    promptEnglish = ""
    imagePath = ""
    progress = -1
    stopping = false
    if (panelStep) return
    testProc.command = ["omarchy-rollcall-test", current.id, "--no-ask"]
    testProc.running = true
  }

  function stopTest() {
    if (testProc.running) {
      stopping = true
      testProc.running = false
    }
  }

  function skip() {
    if (!current) return
    stopTest()
    record(current.id, "skip", "")
    next()
  }

  function settle(id, value, text) {
    var copy = Object.assign({}, outcomes)
    copy[id] = { result: value, detail: text }
    outcomes = copy
    if (current && current.id === id) {
      result = value
      detail = text
      phase = "done"
    }
  }

  // A person's answer, or a panel-side measurement; the store keeps it for
  // the report, and the test keeps the detail it measured before asking.
  function record(id, value, text) {
    var args = ["omarchy-rollcall-test", id, "--record", value]
    if (text !== "") args.push("--detail", text)
    Quickshell.execDetached(args)
    settle(id, value, text !== "" ? text : (value === "skip" ? "" : lastLog))
  }

  function answer(value) {
    if (!current || phase !== "verify") return
    record(current.id, value, "")
  }

  function copyReport() {
    if (!reportProc.running) reportProc.running = true
  }

  function onTestLine(line) {
    var parsed = Model.parseLine(line)
    if (parsed.kind === "prompt") {
      promptKey = parsed.key
      promptEnglish = parsed.text
    } else if (parsed.kind === "verify") {
      questionKey = parsed.key
      questionEnglish = parsed.text
    } else if (parsed.kind === "progress") {
      progress = parsed.value
    } else if (parsed.kind === "image") {
      if (Model.imageAllowed(parsed.path, stateDir)) { imagePath = parsed.path; imageToken++ }
    } else if (parsed.text.trim() !== "") {
      lastLog = parsed.text.trim()
    }
  }

  Process {
    id: listProc
    command: ["omarchy-rollcall-test", "--list", "--json"]
    stdout: StdioCollector {
      waitForEnd: true
      onStreamFinished: {
        root.tests = Model.parseList(text)
        var copy = {}
        for (var i = 0; i < root.tests.length; i++) {
          var t = root.tests[i]
          if (t.result === "pass" || t.result === "fail" || t.result === "skip") copy[t.id] = { result: t.result, detail: t.detail }
        }
        root.outcomes = copy
      }
    }
    onExited: root.listing = false
  }

  Process {
    id: autoProc
    command: ["omarchy-rollcall", "--json"]
    stdout: StdioCollector {
      waitForEnd: true
      onStreamFinished: root.automated = Model.parseReport(text)
    }
    onExited: root.checking = false
  }

  Process {
    id: testProc
    stdout: SplitParser { onRead: function(line) { root.onTestLine(line) } }
    onExited: function(exitCode) {
      var id = command.length > 1 ? command[1] : ""
      if (root.stopping) { root.stopping = false; return }
      var value = Model.resultForExit(exitCode)
      if (value === "verify") {
        if (root.current && root.current.id === id) root.phase = "verify"
        return
      }
      // A test records its own pass, fail and most skips; a crash, or a skip it
      // found only once running, is recorded here so the report agrees.
      if (value === "error") {
        root.record(id, "fail", root.lastLog !== "" ? root.lastLog : "the test stopped with exit code " + exitCode)
      } else if (value === "skip") {
        root.record(id, "skip", root.lastLog)
      } else {
        root.settle(id, value, root.lastLog)
      }
    }
  }

  Process {
    id: reportProc
    command: ["omarchy-rollcall"]
    stdout: StdioCollector {
      waitForEnd: true
      onStreamFinished: {
        var report = String(text || "")
        if (report.trim() === "") return
        Quickshell.execDetached(["wl-copy", "--", report])
        Quickshell.execDetached(["omarchy-notification-send", Commons.I18n.t("rollcall.copiedTitle"), Commons.I18n.t("rollcall.copiedBody")])
      }
    }
  }

  PanelWindow {
    id: window
    visible: root.opened
    color: "transparent"
    exclusionMode: ExclusionMode.Ignore
    implicitWidth: card.width
    implicitHeight: card.height
    WlrLayershell.namespace: "omarchy-rollcall"
    WlrLayershell.layer: WlrLayer.Top
    WlrLayershell.keyboardFocus: root.wantsKeyboard ? WlrKeyboardFocus.Exclusive : WlrKeyboardFocus.OnDemand

    Binding { target: window.contentItem; property: "LayoutMirroring.enabled"; value: Commons.I18n.rightToLeft }
    Binding { target: window.contentItem; property: "LayoutMirroring.childrenInherit"; value: true }

    Rectangle {
      id: card
      width: Style.space(540)
      height: body.implicitHeight + Style.spacing.panelPadding * 2
      color: Commons.Color.popups.background
      border.color: Commons.Color.popups.border
      border.width: Math.max(1, Style.normalBorderWidth)
      radius: Style.cornerRadius

      Item {
        id: keys
        anchors.fill: parent
        focus: true
        Keys.onEscapePressed: if (!(root.panelStep && root.phase === "running")) root.dismiss()
        Keys.onReturnPressed: root.primary()
        Keys.onEnterPressed: root.primary()
        Keys.onPressed: function(event) {
          if (root.view === "step" && root.phase === "verify") {
            if (event.key === Qt.Key_Y) { root.answer("pass"); event.accepted = true }
            else if (event.key === Qt.Key_N) { root.answer("fail"); event.accepted = true }
          }
        }
      }

      ColumnLayout {
        id: body
        anchors { left: parent.left; right: parent.right; top: parent.top; margins: Style.spacing.panelPadding }
        spacing: Style.spacing.panelGap

        RowLayout {
          Layout.fillWidth: true
          spacing: Style.spacing.controlGap

          Label {
            text: Commons.I18n.t("rollcall.title").toUpperCase()
            dim: true
            font.pixelSize: Style.font.caption
            font.bold: true
            font.letterSpacing: 2
            Layout.fillWidth: true
          }
          Label {
            visible: root.view === "step"
            dim: true
            font.pixelSize: Style.font.caption
            text: Commons.I18n.t("rollcall.stepOf").arg(Commons.I18n.formatNumber(root.stepIndex + 1)).arg(Commons.I18n.formatNumber(root.steps.length))
          }
          Button {
            iconText: "󰅖"
            tooltipText: Commons.I18n.t("rollcall.close")
            onClicked: root.dismiss()
          }
        }

        Rectangle {
          visible: root.view === "step"
          Layout.fillWidth: true
          implicitHeight: Style.space(2)
          color: Util.alpha(Commons.Color.popups.text, 0.12)
          Rectangle {
            width: parent.width * (root.steps.length > 0 ? (root.stepIndex + (root.phase === "done" ? 1 : 0)) / root.steps.length : 0)
            height: parent.height
            color: Commons.Color.accent
            Behavior on width { NumberAnimation { duration: Style.duration(180); easing.type: Easing.OutCubic } }
          }
        }

        // Start: what this is, and what the automated checks already found.
        ColumnLayout {
          visible: root.view === "start"
          Layout.fillWidth: true
          spacing: Style.spacing.rowGap

          Label { text: Commons.I18n.t("rollcall.heading"); font.pixelSize: Style.font.heading; font.bold: true }
          Label { text: Commons.I18n.t("rollcall.intro"); wrap: true }

          Label {
            visible: root.checking
            dim: true
            text: Commons.I18n.t("rollcall.checking")
          }
          Label {
            visible: !root.checking && root.automated !== null
            text: root.automated ? Commons.I18n.t("rollcall.automatedCounts")
              .arg(Commons.I18n.formatNumber(root.automated.counts.pass))
              .arg(Commons.I18n.formatNumber(root.automated.counts.fail))
              .arg(Commons.I18n.formatNumber(root.automated.counts.skip)) : ""
          }
          Repeater {
            model: root.automated && !root.checking ? root.automated.failed : []
            ResultRow { required property var modelData; mark: "fail"; name: modelData.id; detail: modelData.detail }
          }
          Label {
            visible: !root.checking && root.automated === null
            dim: true
            text: Commons.I18n.t("rollcall.automatedFailed")
          }
          Label {
            visible: !root.listing
            dim: true
            text: Commons.I18n.t("rollcall.stepCount").arg(Commons.I18n.formatNumber(root.steps.length))
          }
        }

        // One attended step.
        ColumnLayout {
          visible: root.view === "step" && !!root.current
          Layout.fillWidth: true
          spacing: Style.spacing.rowGap

          Label {
            text: root.current ? Model.titleText(Commons.I18n.t, root.current.id, root.current.title) : ""
            font.pixelSize: Style.font.heading
            font.bold: true
          }
          Label {
            text: root.current ? Model.stepsText(Commons.I18n.t, root.current.id) : ""
            wrap: true
          }
          Label {
            readonly property string needs: root.current ? Model.needsText(Commons.I18n.t, root.current.needs) : ""
            visible: needs !== ""
            dim: true
            text: Commons.I18n.t("rollcall.needs").arg(needs)
          }

          // What the test is asking for right now.
          Rectangle {
            visible: !root.panelStep && (root.phase === "running" || root.phase === "verify")
            Layout.fillWidth: true
            implicitHeight: live.implicitHeight + Style.spacing.popupPadding * 2
            color: Style.normalFill
            radius: Style.cornerRadius

            ColumnLayout {
              id: live
              anchors { left: parent.left; right: parent.right; verticalCenter: parent.verticalCenter; margins: Style.spacing.popupPadding }
              spacing: Style.spacing.rowGap

              Label {
                text: root.phase === "verify"
                  ? Model.promptText(Commons.I18n.t, root.questionKey, root.questionEnglish)
                  : (root.promptKey !== "" ? Model.promptText(Commons.I18n.t, root.promptKey, root.promptEnglish) : Commons.I18n.t("rollcall.working"))
                font.pixelSize: Style.font.title
                font.bold: root.phase === "verify"
                wrap: true
              }
              Rectangle {
                visible: root.phase === "running" && root.progress >= 0
                Layout.fillWidth: true
                implicitHeight: Style.space(3)
                color: Util.alpha(Commons.Color.popups.text, 0.12)
                Rectangle { width: parent.width * Math.max(0, root.progress); height: parent.height; color: Commons.Color.accent }
              }
              Image {
                visible: root.imagePath !== ""
                source: root.imagePath !== "" ? "file://" + root.imagePath + "?" + root.imageToken : ""
                cache: false
                asynchronous: true
                fillMode: Image.PreserveAspectFit
                Layout.fillWidth: true
                Layout.preferredHeight: Style.space(240)
              }
            }
          }

          KeyboardCheck {
            id: keyboardCheck
            visible: root.panelStep && root.current.id === "keyboard" && root.phase === "running"
            active: visible
            Layout.fillWidth: true
            onFinished: function(value, text) { root.record("keyboard", value, text) }
          }
          TouchpadCheck {
            visible: root.panelStep && root.current.id === "touchpad" && root.phase === "running"
            active: visible
            Layout.fillWidth: true
            onFinished: function(value, text) { root.record("touchpad", value, text) }
          }
          TouchscreenCheck {
            visible: root.panelStep && root.current.id === "touchscreen" && root.phase === "running"
            active: visible
            Layout.fillWidth: true
            onFinished: function(value, text) { root.record("touchscreen", value, text) }
          }

          ResultRow {
            visible: root.phase === "done"
            mark: root.result
            name: root.result === "pass" ? Commons.I18n.t("rollcall.passed") : root.result === "fail" ? Commons.I18n.t("rollcall.failed") : Commons.I18n.t("rollcall.skipped")
            detail: root.detail
          }
        }

        // Summary: every step, then the report.
        ColumnLayout {
          visible: root.view === "summary"
          Layout.fillWidth: true
          spacing: Style.spacing.rowGap

          Label { text: Commons.I18n.t("rollcall.summaryHeading"); font.pixelSize: Style.font.heading; font.bold: true }
          Label {
            visible: root.automated !== null
            text: root.automated ? Commons.I18n.t("rollcall.automatedCounts")
              .arg(Commons.I18n.formatNumber(root.automated.counts.pass))
              .arg(Commons.I18n.formatNumber(root.automated.counts.fail))
              .arg(Commons.I18n.formatNumber(root.automated.counts.skip)) : ""
          }
          Flickable {
            Layout.fillWidth: true
            Layout.preferredHeight: Math.min(summaryRows.implicitHeight, Style.space(360))
            contentHeight: summaryRows.implicitHeight
            clip: true
            boundsBehavior: Flickable.StopAtBounds

            ColumnLayout {
              id: summaryRows
              width: parent.width
              spacing: Style.spacing.rowGap

              Repeater {
                model: root.steps
                ResultRow {
                  required property var modelData
                  readonly property var outcome: root.outcomes[modelData.id] || null
                  mark: outcome ? outcome.result : ""
                  name: Model.titleText(Commons.I18n.t, modelData.id, modelData.title)
                  detail: outcome ? outcome.detail : Commons.I18n.t("rollcall.notRun")
                }
              }
            }
          }
          Label { text: Commons.I18n.t("rollcall.summaryHint"); dim: true; wrap: true }
        }

        RowLayout {
          Layout.fillWidth: true
          spacing: Style.spacing.controlGap

          Button {
            visible: root.view === "step" && root.phase !== "done"
            bordered: true
            text: Commons.I18n.t("rollcall.skip")
            onClicked: root.skip()
          }
          Button {
            visible: root.view === "step" && root.stepIndex > 0 && root.phase !== "running"
            bordered: true
            text: Commons.I18n.t("rollcall.back")
            onClicked: root.showStep(root.stepIndex - 1)
          }
          Button {
            visible: root.view === "summary"
            bordered: true
            text: Commons.I18n.t("rollcall.startOver")
            onClicked: { Quickshell.execDetached(["omarchy-rollcall-test", "--reset"]); root.open("{}") }
          }
          Item { Layout.fillWidth: true }

          Button {
            visible: root.view === "step" && root.phase === "verify"
            bordered: true
            text: Commons.I18n.t("rollcall.notHere")
            onClicked: root.answer("skip")
          }
          Button {
            visible: root.view === "step" && root.phase === "verify"
            bordered: true
            text: Commons.I18n.t("rollcall.no")
            onClicked: root.answer("fail")
          }
          Button {
            visible: root.view === "step" && root.phase === "verify"
            bordered: true
            selected: true
            text: Commons.I18n.t("rollcall.yes")
            onClicked: root.answer("pass")
          }
          Button {
            visible: root.view === "step" && (root.phase === "done" || root.phase === "verify") && !root.panelStep
            bordered: true
            text: Commons.I18n.t("rollcall.retry")
            onClicked: root.start()
          }
          Button {
            visible: root.primaryText !== ""
            bordered: true
            selected: true
            text: root.primaryText
            onClicked: root.primary()
          }
        }
      }
    }
  }

  readonly property string primaryText: {
    if (view === "start") return listing ? "" : Commons.I18n.t("rollcall.begin")
    if (view === "summary") return Commons.I18n.t("rollcall.copyReport")
    if (phase === "ready") return Commons.I18n.t("rollcall.start")
    if (phase === "done") return stepIndex + 1 < steps.length ? Commons.I18n.t("rollcall.next") : Commons.I18n.t("rollcall.finish")
    return ""
  }

  function primary() {
    if (view === "start") { if (!listing) begin() }
    else if (view === "summary") copyReport()
    else if (phase === "ready") start()
    else if (phase === "done") next()
  }

  component Label: Text {
    property bool dim: false
    property bool wrap: false
    textFormat: Text.PlainText
    color: dim ? Util.alpha(Commons.Color.popups.text, 0.6) : Commons.Color.popups.text
    font.family: Style.font.family
    font.pixelSize: Style.font.body
    wrapMode: wrap ? Text.Wrap : Text.NoWrap
    elide: wrap ? Text.ElideNone : Text.ElideRight
    Layout.fillWidth: true
  }

  component ResultRow: RowLayout {
    property string mark: ""
    property string name: ""
    property string detail: ""
    Layout.fillWidth: true
    spacing: Style.spacing.controlGap

    Label {
      text: mark === "pass" ? "✓" : mark === "fail" ? "✗" : mark === "skip" ? "–" : "·"
      color: mark === "fail" ? Commons.Color.urgent : mark === "pass" ? Commons.Color.accent : Util.alpha(Commons.Color.popups.text, 0.6)
      font.bold: true
      Layout.fillWidth: false
      Layout.alignment: Qt.AlignTop
    }
    Label {
      text: name
      Layout.fillWidth: false
      Layout.preferredWidth: Style.space(150)
      Layout.alignment: Qt.AlignTop
    }
    Label {
      text: detail
      dim: true
      wrap: true
      Layout.alignment: Qt.AlignTop
    }
  }
}
