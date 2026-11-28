import QtQuick
import Quickshell
import Quickshell.Io
import qs.Commons
import qs.Ui
import "Model.js" as Model

// Date/time label for the bar, and the host for the calendar popup.
//
// Left click reveals the calendar — asking "what is the date?" is what a
// click on a clock means — right click walks the common label formats, and
// middle click opens the timezone picker.
BarWidget {
  id: root
  moduleName: "omarchy.clock"

  property date displayDate: clock.date

  readonly property string configuredFormat: vertical
    ? setting("verticalFormat", "HH\n—\nmm")
    : setting("format", "dddd HH:mm")
  readonly property string configuredAltFormat: vertical
    ? setting("verticalFormatAlt", "dd\nMMM\n'W'ww\n''yy")
    : setting("formatAlt", "d MMMM 'W'ww yyyy")

  readonly property var formatRing: Model.clockFormatRing(configuredFormat, configuredAltFormat, Model.clockFormats(vertical))

  // What the bar shows is what shell.json stores, so a cycled format is the
  // format from then on rather than something that reverts on restart.
  readonly property string activeFormat: configuredFormat

  // A seconds label needs the clock to tick sixty times as often, and a
  // repaint a second is a price only the formats that print seconds pay.
  readonly property bool showsSeconds: Model.clockNeedsSeconds(activeFormat)
  readonly property string displayText: formatted(displayDate)

  // A running countdown from the calendar panel rides along beside the time,
  // so it can be watched without opening the popup.
  // The panel this bar built, for the other monitors' clocks to share timers
  // through (see timerOwner in Panel.qml).
  readonly property var timerPanel: panelLoader.item
  readonly property string timerText: panelLoader.item && panelLoader.item.barTimerText ? panelLoader.item.barTimerText : ""
  readonly property string timerGlyph: panelLoader.item && panelLoader.item.barTimerKind === "stopwatch" ? "󰔛" : "󰔟"
  readonly property string timerSegment: timerText !== "" ? timerGlyph + " " + timerText : ""
  readonly property bool showsTimer: !vertical && timerSegment !== ""
  readonly property var verticalLines: timerText !== ""
    ? displayText.split("\n").concat([timerGlyph], Model.verticalTimerLines(panelLoader.item.barTimerTime))
    : displayText.split("\n")

  // ---- Scrolling over the label steps through the timers. The segment
  //      slides like a list: scrolling down brings the next one up from
  //      below, scrolling up brings the previous one down from above.
  //      Touchpads report many small deltas, so they are summed to a full
  //      wheel notch before a step, and one step plays out before the next.
  property int timerSlideDirection: 1
  property string outgoingTimerSegment: ""
  property int wheelAccumulator: 0

  function stepTimer(step) {
    if (!panelLoader.item || typeof panelLoader.item.cycleBarTimer !== "function") return
    var before = root.timerSegment
    if (!panelLoader.item.cycleBarTimer(step)) return
    root.outgoingTimerSegment = before
    root.timerSlideDirection = step
    timerSlide.restart()
  }

  function handleWheel(delta) {
    if (delta === 0 || timerSlide.running) return
    if ((delta > 0) !== (root.wheelAccumulator > 0)) root.wheelAccumulator = 0
    root.wheelAccumulator += delta
    if (Math.abs(root.wheelAccumulator) < 120) return
    var step = root.wheelAccumulator < 0 ? 1 : -1
    root.wheelAccumulator = 0
    root.stepTimer(step)
  }

  function refresh() {
    displayDate = new Date()
    if (panelLoader.item && panelLoader.item.refresh) panelLoader.item.refresh()
  }

  // The timer stops during suspend, so after a wake the label kept the time
  // from before it for up to a minute. Resyncing re-reads the time and arms
  // its next tick from now, and onDateChanged below puts the result on the
  // label. Unlike refresh() this leaves a month the user is browsing in the
  // calendar where it is.
  function resync() {
    clock.resync()
    if (panelLoader.item && panelLoader.item.resync) panelLoader.item.resync()
  }

  function cycleFormat() {
    var current = String(configuredFormat)
    var next = Model.nextClockFormat(formatRing, current)
    if (next === "" || next === current) return

    var entry = { id: root.moduleName }
    for (var key in root.settings) if (key !== "id") entry[key] = root.settings[key]
    entry[vertical ? "verticalFormat" : "format"] = next

    // Applied locally first so the label changes on the click itself; the
    // shell.json write comes back through the bar as the same value.
    root.settings = entry
    if (root.bar && root.bar.shell && typeof root.bar.shell.updateEntryInline === "function")
      root.bar.shell.updateEntryInline(root.moduleName, entry)
  }

  // Day and month names follow the Omarchy language, not the system locale,
  // which only catches up at the next login.
  readonly property var formatLocale: Qt.locale(I18n.formatLocale)

  // The ISO week goes in as a literal, so its digits are localized here the
  // way Qt localizes the rest of the format.
  function formatted(date) {
    var week = Model.isoWeekLiteral(date.getFullYear(), date.getMonth(), date.getDate())
    week = week.split("").map(function(digit) { return I18n.formatNumber(digit) }).join("")
    return date.toLocaleString(root.formatLocale, activeFormat.replace(/ww/g, week))
  }

  // ---- Calendar popup. Shape contract for shell.summon/hide/toggle
  //      routing: Bar.findPanelWidget requires open/close/opened on the
  //      bar-widget root.
  readonly property bool opened: panelLoader.item ? panelLoader.item.opened === true : false

  function open() {
    if (panelLoader.item) panelLoader.item.open()
  }

  function close() {
    if (panelLoader.item) panelLoader.item.close()
  }

  function togglePanel() {
    if (panelLoader.item) panelLoader.item.toggle()
  }

  function toggleWeekStart() {
    if (panelLoader.item) panelLoader.item.toggleWeekStart()
  }

  // The clock fills more slot than it paints a mark for, at both
  // orientations: horizontally it is a text label in a padded slot, so the
  // dot takes the label width; vertically it is a stack of icon-sized lines,
  // so the dot takes one line — the same mark every icon widget gets, rather
  // than a rule running the height of the whole stack.
  readonly property real openPanelIndicatorWidth: showsTimer ? labelRow.implicitWidth : button.labelWidth
  readonly property real openPanelIndicatorHeight: Math.max(Style.space(10), Math.round(Style.bar.iconSlot * 0.55))

  // Forwarded so this widget can stand in for the panel as the bar's popout
  // identity: Bar.requestPopout prefers closeForPopoutSwitch over close, and
  // KeyboardPanel reads popoutSwitchClosing back off its owner.
  readonly property bool popoutSwitchClosing: panelLoader.item ? panelLoader.item.popoutSwitchClosing === true : false

  function closeForPopoutSwitch() {
    if (panelLoader.item) panelLoader.item.closeForPopoutSwitch()
  }

  function injectPanel() {
    var target = panelLoader.item
    if (!target) return
    if ("bar" in target) target.bar = root.bar
    if ("settings" in target) target.settings = root.settings
    if ("anchorItem" in target) target.anchorItem = button
    if ("hostWidget" in target) target.hostWidget = root
  }

  implicitWidth: button.implicitWidth
  implicitHeight: button.implicitHeight

  onBarChanged: injectPanel()
  onSettingsChanged: injectPanel()

  WallClock {
    id: clock
    step: root.showsSeconds ? 1000 : 60000
    onDateChanged: root.displayDate = date
  }

  Loader {
    id: panelLoader
    active: true
    source: Qt.resolvedUrl("Panel.qml")
    visible: false
    onLoaded: {
      root.injectPanel()
      Qt.callLater(root.injectPanel)
    }
  }

  ShellIpc {
    target: "omarchy.clock"

    function refresh(): void { root.broadcast("refresh") }
    function resync(): void { root.broadcast("resync") }
    function cycleFormat(): void { root.cycleFormat() }
    function toggleWeekStart(): void { root.toggleWeekStart() }
    function open(): void { root.open() }
    function close(): void { root.close() }
    function show(): void { root.open() }
    function hide(): void { root.close() }
    function toggle(): void { root.togglePanel() }
  }

  WidgetButton {
    id: button
    anchors.fill: parent
    bar: root.bar
    text: root.vertical || root.showsTimer ? "" : root.displayText
    labelVisible: !root.vertical && !root.showsTimer
    fixedWidth: root.showsTimer ? Math.max(12, labelRow.implicitWidth + button.scaledHorizontalMargin * 2) : -1
    hasVisualContent: root.vertical ? root.verticalLines.length > 0 : (root.showsTimer || text !== "")
    fixedHeight: root.vertical ? root.verticalLines.length * Style.bar.iconSlot : -1
    horizontalMargin: 8.75
    verticalPadding: 8.75
    tooltipText: I18n.t("clock.toggleFormat")
    // The clock is text to read, not an icon to press, so a click never
    // shrinks it; the format it cycles to, or the panel it opens, is feedback.
    pressFeedbackButtons: Qt.NoButton

    onWheelMoved: function(delta) { root.handleWheel(delta) }

    onPressed: function(b) {
      if (b === Qt.RightButton) root.cycleFormat()
      else if (b === Qt.MiddleButton) { if (root.bar) root.bar.run("omarchy-menu-timezone") }
      else root.togglePanel()
    }

    // The time and the timer segment drawn apart, so only the segment moves
    // when the wheel steps it.
    Row {
      id: labelRow
      visible: root.showsTimer
      anchors.centerIn: parent
      height: parent.height
      spacing: Style.spaceReal(10)

      Text {
        anchors.verticalCenter: parent.verticalCenter
        textFormat: Text.PlainText
        text: root.displayText
        color: button.foreground
        font.family: button.fontFamily
        font.pixelSize: button.fontSize
        renderType: Text.NativeRendering
      }

      Item {
        id: timerWindow
        height: parent.height
        width: incomingTimer.implicitWidth
        clip: true

        Behavior on width {
          NumberAnimation { duration: Style.duration(180); easing.type: Easing.Bezier; easing.bezierCurve: Style.easeOut }
        }

        property real progress: 1

        Text {
          id: outgoingTimer
          visible: timerSlide.running
          anchors.verticalCenter: parent.verticalCenter
          anchors.verticalCenterOffset: -root.timerSlideDirection * timerWindow.height * timerWindow.progress
          textFormat: Text.PlainText
          text: root.outgoingTimerSegment
          color: button.foreground
          opacity: 1 - timerWindow.progress
          font.family: button.fontFamily
          font.pixelSize: button.fontSize
          renderType: Text.NativeRendering
        }

        Text {
          id: incomingTimer
          anchors.verticalCenter: parent.verticalCenter
          anchors.verticalCenterOffset: root.timerSlideDirection * timerWindow.height * (1 - timerWindow.progress)
          textFormat: Text.PlainText
          text: root.timerSegment
          color: button.foreground
          opacity: timerWindow.progress
          font.family: button.fontFamily
          font.pixelSize: button.fontSize
          renderType: Text.NativeRendering
        }

        NumberAnimation {
          id: timerSlide
          target: timerWindow
          property: "progress"
          from: 0
          to: 1
          duration: Style.duration(220)
          easing.type: Easing.Bezier
          easing.bezierCurve: Style.easeOut
        }
      }
    }

    Column {
      visible: root.vertical
      anchors.fill: parent

      Repeater {
        model: root.verticalLines

        OpticalGlyph {
          required property string modelData
          width: button.width
          height: Style.bar.iconSlot
          text: modelData
          fontFamily: button.fontFamily
          fontSize: modelData.length > 3
            ? button.fontSize * 0.9
            : button.fontSize
          color: button.foreground
        }
      }
    }
  }
}
