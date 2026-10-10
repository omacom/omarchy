import QtQuick
import qs.Ui as Ui
import qs.Commons

Ui.WidgetButton {
  id: root
  required property var backend
  property bool animate: true
  property bool ready: false
  property string previousPair: ""
  readonly property bool flagPhase: incoming.isFlag
  readonly property int beatDuration: 180
  readonly property string mixedCode: (backend.state.activeLayouts || []).map(row => row.code)
    .filter((code, index, codes) => codes.indexOf(code) === index).join("/")
  readonly property string code: backend.current ? backend.current.code : mixedCode || "?"
  readonly property string country: backend.current ? backend.current.country : ""
  readonly property string flag: /^[a-z]{2}$/.test(country)
    ? String.fromCodePoint(0x1f1e6 + country.charCodeAt(0) - 97, 0x1f1e6 + country.charCodeAt(1) - 97) : ""
  readonly property string pair: backend.current ? backend.current.id : ""
  readonly property bool motion: animate && backend.animationsEnabled
  // Read the label, flag and identity together after their bindings update.
  onPairChanged: if (ready) Qt.callLater(root.synchronize)
  onCodeChanged: if (ready) Qt.callLater(root.synchronize)
  onFlagChanged: if (ready) Qt.callLater(root.synchronize)
  onMotionChanged: if (ready && !motion) settle()
  Component.onCompleted: { ready = true; synchronize() }

  function settle() {
    roll.stop()
    flagHold.stop()
    incoming.text = code
    incoming.isFlag = false
    incoming.y = 0
    outgoing.text = ""
  }

  function synchronize() {
    let changed = pair !== previousPair
    let animateChange = changed && previousPair !== "" && pair !== "" && motion
    previousPair = pair
    if (animateChange) rollTo(flag || code, flag !== "")
    else if (changed || !motion || (!roll.running && !flagHold.running)) settle()
  }

  function rollTo(glyph, isFlag) {
    // Preserve the most visible glyph when a newer switch interrupts a roll.
    let source = roll.running && Math.abs(outgoing.y) < Math.abs(incoming.y) ? outgoing : incoming
    let oldText = source.text
    let oldFlag = source.isFlag
    let oldY = source.y
    roll.stop()
    flagHold.stop()
    outgoing.text = oldText
    outgoing.isFlag = oldFlag
    outgoing.y = oldY
    incoming.text = glyph
    incoming.isFlag = isFlag
    incoming.y = slot.height
    roll.start()
  }

  text: code
  fontSize: Style.font.caption
  labelVisible: false
  hasVisualContent: true
  fixedWidth: bar && bar.vertical ? bar.barSize : Math.max(Style.space(34), codeMetrics.advanceWidth + Style.space(8))
  tooltipText: backend.current ? backend.current.label + (backend.current.variant ? " · " + backend.current.variantLabel : "")
    : backend.error || backend.state.problem || "Reading the keyboard layout…"
  Accessible.role: Accessible.Button
  Accessible.name: tooltipText
  TextMetrics {
    id: codeMetrics
    font.family: Style.font.family
    font.pixelSize: Style.font.caption
    text: root.code
  }

  component Glyph: Text {
    property bool isFlag: false
    width: slot.width
    height: slot.height
    textFormat: Text.PlainText
    font.family: isFlag ? "Noto Color Emoji" : Style.font.family
    font.pixelSize: isFlag ? Style.space(16) : Style.font.caption
    color: root.foreground
    horizontalAlignment: Text.AlignHCenter
    verticalAlignment: Text.AlignVCenter
    elide: Text.ElideRight
  }

  Item {
    id: slot
    anchors.centerIn: parent
    width: root.width
    height: Math.min(root.height, Style.space(22))
    clip: true
    Glyph { id: outgoing; visible: roll.running }
    Glyph { id: incoming }
  }

  ParallelAnimation {
    id: roll
    NumberAnimation {
      target: outgoing
      property: "y"
      to: -slot.height
      duration: root.beatDuration
      easing.type: Easing.OutCubic
    }
    NumberAnimation {
      target: incoming
      property: "y"
      to: 0
      duration: root.beatDuration
      easing.type: Easing.OutCubic
    }
    // The hold starts only once the flag has fully entered the slot.
    onFinished: if (incoming.isFlag && root.motion) flagHold.restart()
  }
  Timer {
    id: flagHold
    interval: root.beatDuration
    onTriggered: root.rollTo(root.code, false)
  }
}
