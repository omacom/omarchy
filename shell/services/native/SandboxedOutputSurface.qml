import QtQuick
import QtQuick.Window
import Quickshell
import Quickshell.Wayland
import Omarchy.Ward
import "../PluginInput.js" as PluginInput

// A host-owned output view; it never starts a worker of its own.
PanelWindow {
  id: root
  required property var owner
  required property int outputId
  required property var targetScreen
  readonly property var bars: owner.placements.filter(view => view.output === outputId).map(view => view.bar)
  readonly property bool ownsPanel: owner.activeOutputId === outputId
  readonly property bool opened: ownsPanel && owner.opened
  // Closed plugins keep only their slots. Roaming presentation and pointer
  // authority are explicit host choices, neither of which grants keyboard focus.
  readonly property var policy: PluginInput.outputPolicy(owner.opened, ownsPanel,
    owner.overlayOutputId === outputId, owner.overlayMode, owner.overlayOutputs)
  readonly property bool presented: view.presented
  readonly property var presentationRegions: policy.render ? [{x: 0, y: 0, width: width, height: height}]
    : PluginInput.barSlots(bars, width, height)
  property bool focusPrimed: false
  property bool programmaticFocus: false
  property bool focusHeld: false
  property bool hadWindowFocus: false
  readonly property bool panelFocus: focusHeld && opened
  onBarsChanged: Qt.callLater(updateMask)
  onPanelFocusChanged: Qt.callLater(updateMask)
  onProgrammaticFocusChanged: Qt.callLater(updateMask)
  onPolicyChanged: Qt.callLater(updateMask)
  screen: targetScreen
  anchors { top: true; bottom: true; left: true; right: true }
  color: "transparent"
  // Empty/hidden streams still complete their GPU fences. Host render clips
  // suppress pixels, rather than hiding a window and stranding frame ownership.
  visible: !owner.error && targetScreen !== null
  exclusionMode: ExclusionMode.Ignore
  WlrLayershell.namespace: "omarchy-ward-" + owner.pluginId + "-" + outputId
  WlrLayershell.layer: WlrLayer.Overlay
  WlrLayershell.keyboardFocus: focusPrimed || programmaticFocus ? WlrKeyboardFocus.Exclusive
    : focusHeld ? WlrKeyboardFocus.OnDemand : WlrKeyboardFocus.None
  mask: inputMask
  property Region inputMask: Region {}
  property Component regionComponent: Component { Region {} }
  property var regions: []
  function inputRectangles(source) { return PluginInput.barMasks(source, bars, width, height, policy.pointer) }
  function updateMask() {
    const previous = regions
    const source = programmaticFocus || panelFocus ? [{x: 0, y: 0, width: width, height: height}] : view.inputRegions
    const rectangles = inputRectangles(source)
    const next = rectangles.map(rect => regionComponent.createObject(inputMask, rect))
    inputMask.regions = next
    regions = next
    for (const region of previous) region.destroy()
  }
  function primeFocus(programmatic) {
    if (!policy.keyboard) return
    programmaticFocus = programmatic === true
    focusHeld = true
    if (!view.Window.active) { focusPrimed = true; focusPrimeTimer.restart() }
    view.forceActiveFocus()
  }
  function clearFocus() {
    focusPrimeTimer.stop()
    // A compositor focus-out can arrive after an explicit close and a new
    // summon. It belongs to the released acquisition, not the new panel.
    hadWindowFocus = false
    focusPrimed = false
    programmaticFocus = false
    focusHeld = false
    view.dismiss()
  }
  function retire() { clearFocus(); view.session = null }
  Timer { id: focusPrimeTimer; interval: 75; onTriggered: root.focusPrimed = false }
  onWidthChanged: Qt.callLater(updateMask)
  onHeightChanged: Qt.callLater(updateMask)
  Component.onCompleted: Qt.callLater(updateMask)

  PluginView {
    id: view
    anchors.fill: parent
    session: root.owner.nativeSession
    outputId: root.outputId
    renderRegions: root.presentationRegions
    hostInputRegions: PluginInput.barMasks([{x: 0, y: 0, width: root.width, height: root.height}],
      root.bars, root.width, root.height, root.policy.pointer)
    onStateChanged: Qt.callLater(root.updateMask)
    onFocusRequested: point => {
      root.owner.claimOutput(root.outputId, point)
      if (root.policy.keyboard) root.primeFocus(false)
    }
    onPanelSwitchRequested: direction => {
      if (root.opened && root.focusHeld) root.owner.panelSwitchRequested(direction)
    }
    Window.onActiveChanged: {
      if (Window.active) root.hadWindowFocus = true
      else if (root.hadWindowFocus) {
        root.hadWindowFocus = false
        if (root.ownsPanel && root.owner.opened) root.owner.dismiss()
        else root.clearFocus()
      }
    }
  }
  MouseArea {
    anchors.fill: parent
    enabled: root.programmaticFocus || root.panelFocus
    acceptedButtons: Qt.AllButtons
    onPressed: mouse => {
      const rectangles = root.inputRectangles(view.inputRegions)
      if (rectangles.some(rect => mouse.x >= rect.x && mouse.y >= rect.y && mouse.x < rect.x + rect.width && mouse.y < rect.y + rect.height)) mouse.accepted = false
      else root.owner.dismiss()
    }
  }
}
