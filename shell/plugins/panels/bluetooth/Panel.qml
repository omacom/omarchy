import QtQuick
import QtQuick.Controls
import Quickshell
import Quickshell.Io
import Quickshell.Bluetooth
import Quickshell.Services.Pipewire
import qs.Ui
import qs.Commons
import qs.Commons as Commons
import "Model.js" as Model

Panel {
  id: root
  moduleName: "omarchy.bluetooth"
  ipcTarget: "omarchy.bluetooth"
  // manageIpc: false so this panel can own the single IpcHandler the target
  // permits — needed for the toggleBluetooth method below.
  manageIpc: false

  // Address -> "connecting" | "disconnecting" | "forgetting".
  // The actual Bluetooth sequencing lives in bin/omarchy-bluetooth-device;
  // this map only keeps the panel responsive while BlueZ catches up.
  property var pendingActions: ({})

  readonly property var adapter: Bluetooth.defaultAdapter

  // True while this instance owes BlueZ a StopDiscovery: set when it starts
  // discovery (or opens onto a session already running) and cleared once
  // discovery is confirmed down after close. Ownership, not state — BlueZ's
  // Discovering property also reflects sessions other clients hold, which are
  // never this panel's to stop.
  property bool owesDiscoveryStop: false
  readonly property var devices: Bluetooth.devices ? Bluetooth.devices.values : []
  readonly property var pipewireNodes: Pipewire.nodes ? Pipewire.nodes.values : []
  property var pendingAudioOutputDevice: null
  property int pendingAudioOutputAttempts: 0

  // Headset audio nodes, picked out by name, which is readable before a node
  // is bound. They are bound only while the panel is open, the only time
  // anything shows their codec.
  readonly property var bluezNodes: {
    var list = []
    for (var i = 0; i < pipewireNodes.length; i++)
      if (Model.isBluezAudioNode(pipewireNodes[i])) list.push(pipewireNodes[i])
    return list
  }

  // Address -> { codec, headset, output }. Primitives only: a codec switch
  // destroys the node and builds a new one, so rows never hold a PwNode. The
  // binding follows each node's ready and properties signals, so it needs no
  // timer to catch a codec change.
  readonly property var codecsByAddress: opened ? Model.codecSnapshot(bluezNodes) : ({})

  // Codec section state from omarchy-bluetooth-codec. `codecCurrent` is the
  // codec playing now; `codecSelected` is the pinned one ("auto" when none).
  // `pendingCodec` holds the asked-for codec while the transport is rebuilt.
  property string codecStatusAddress: ""
  property string codecMode: ""
  property string codecCurrent: ""
  property string codecSelected: "auto"
  property var codecOptions: []
  property string pendingCodec: ""
  property int codecIndex: 0
  // The section has up to two cursor rows: the Automatic switch on the header
  // line, then the pills while a codec is pinned.
  property bool codecAutoFocused: true
  // Last connected device the cursor sat on, so the section stays with it
  // while the cursor is inside the section itself.
  property string codecFocusAddress: ""
  // A switch tears the headset's audio node down and builds a new one, so for
  // a moment PipeWire shows no codec for it at all. Holding the switched
  // headset as the target keeps the section (and the cursor in it) on screen
  // until the new node reports in.
  property string codecHoldAddress: ""
  // The codec the held headset should come back with. pactl returns before
  // the old node is gone, so the hold ends only once this one reports in.
  property string codecHoldCodec: ""

  function releaseCodecHold() {
    if (codecHoldAddress === "" || codecBusy) return
    var entry = codecsByAddress[Model.normalizedAddress(codecHoldAddress)]
    if (entry && (codecHoldCodec === "" || entry.codec === codecHoldCodec)) {
      codecHoldAddress = ""
      codecHoldTimeout.stop()
    }
  }

  // The connected headset the codec section controls: the one the cursor last
  // sat on, otherwise the first one playing through PipeWire.
  readonly property string codecTarget: {
    var focused = null
    var first = null
    for (var i = 0; i < connectedDevices.length; i++) {
      var d = connectedDevices[i]
      if (!d || !codecsByAddress[Model.normalizedAddress(d.address)]) continue
      if (!first) first = d
      if (d.address === codecFocusAddress) focused = d
    }
    if (codecHoldAddress !== "") return codecHoldAddress
    var target = focused || first
    return target ? (target.address || "") : ""
  }
  readonly property int codecDeviceCount: {
    var count = 0
    for (var i = 0; i < connectedDevices.length; i++)
      if (connectedDevices[i] && codecsByAddress[Model.normalizedAddress(connectedDevices[i].address)]) count++
    return count
  }
  readonly property bool codecBusy: pendingCodec !== ""
  readonly property string codecEffective: pendingCodec !== "" ? pendingCodec : codecSelected
  readonly property bool codecPinned: codecEffective !== "auto"
  // Music mode only: a headset-mode codec follows the call profile, and a
  // headset that offers one codec has nothing to choose -- unless one is
  // pinned, which has to stay reachable to undo.
  readonly property bool canSelectCodec: codecTarget !== "" && codecStatusAddress === codecTarget
    && (codecMode === "music" || codecBusy) && (codecOptions.length > 1 || codecPinned)
  readonly property bool codecPillsVisible: canSelectCodec && codecPinned
  readonly property string codecSectionTitle: {
    var title = Model.codecSectionTitle(codecEffective, codecCurrent, Commons.I18n.t)
    if (codecDeviceCount < 2) return title
    var dev = null
    for (var i = 0; i < connectedDevices.length; i++)
      if (connectedDevices[i] && connectedDevices[i].address === codecTarget) dev = connectedDevices[i]
    return dev ? title + " · " + Model.deviceLabel(dev).toUpperCase() : title
  }

  onCodecTargetChanged: codecStatusSettle.restart()
  onCodecsByAddressChanged: {
    releaseCodecHold()
    codecStatusSettle.restart()
  }
  onCodecPillsVisibleChanged: if (!codecPillsVisible) codecAutoFocused = true
  onCodecOptionsChanged: {
    if (codecIndex > codecOptions.length - 1) codecIndex = Math.max(0, codecOptions.length - 1)
  }

  function deviceLabel(device) {
    return Model.deviceLabel(device)
  }

  function isUuidLike(value) {
    return Model.isUuidLike(value)
  }

  function isAddressLike(value) {
    return Model.isAddressLike(value)
  }

  function hasHumanName(device) {
    return Model.hasHumanName(device)
  }

  readonly property var deviceGroups: Model.deviceLists(devices)
  readonly property var connectedDevices: deviceGroups.connected || []
  readonly property var knownDevices: deviceGroups.known || []
  readonly property var discoveredDevices: deviceGroups.discovered || []

  readonly property string icon: {
    if (!adapter) return ""
    if (!adapter.enabled) return "󰂲"
    if (connectedDevices.length > 0) return "󰂱"
    return "󰂯"
  }

  property int phraseIndex: 0
  readonly property var activePhrases: [
    Commons.I18n.t("bluetooth.phrase1"),
    Commons.I18n.t("bluetooth.phrase2"),
    Commons.I18n.t("bluetooth.phrase3"),
    Commons.I18n.t("bluetooth.phrase4"),
    Commons.I18n.t("bluetooth.phrase5"),
    Commons.I18n.t("bluetooth.phrase6"),
    Commons.I18n.t("bluetooth.phrase7"),
    Commons.I18n.t("bluetooth.phrase8")
  ]
  readonly property bool rotatingPhrases: adapter && adapter.enabled
  readonly property string heroStatusText: {
    if (!adapter) return Commons.I18n.t("bluetooth.noAdapter")
    if (!adapter.enabled) return Commons.I18n.t("bluetooth.turnedOff")
    return activePhrases[phraseIndex % activePhrases.length]
  }

  // Single cursor model shared by keyboard and mouse. Sections:
  //   "connected"  — currently connected devices; Enter disconnects.
  //   "known"      — remembered devices; Enter connects.
  //   "discovered" — unremembered devices visible while scanning; Enter connects.
  // Visuals always come from CursorSurface (hasCursor / current),
  // never from containsMouse. Mouse hover updates root cursor state too,
  // guaranteeing one highlight on screen.
  property string focusSection: "connected"
  property int selectedIndex: 0
  property bool actionFocused: false
  property bool cursorActive: false

  // Stable identity for the focused device. Devices move between sections as
  // they connect, disconnect, pair, or get forgotten, so follow the BlueZ
  // address across section changes instead of preserving a stale row index.
  property string focusedDeviceAddress: ""

  // "header" is a virtual section for the hero Bluetooth on/off toggle; it
  // sits above the device sections so the adapter can be toggled by keyboard
  // even when it is off and no device rows exist.
  readonly property bool headerHasCursor: cursorActive && focusSection === "header"
  readonly property string toggleHint: root.adapter && root.adapter.enabled ? Commons.I18n.t("bluetooth.turnOff") : Commons.I18n.t("bluetooth.turnOn")

  readonly property color hoverFill: bar
    ? Style.hoverFillFor(bar.foreground, Commons.Color.accent)
    : "transparent"
  readonly property color selectedFill: bar
    ? Style.selectedFillFor(bar.foreground, Commons.Color.accent)
    : "transparent"

  function sectionCount(section) {
    if (section === "connected") return connectedDevices.length
    if (section === "codec") return canSelectCodec ? 1 : 0
    if (section === "known") return knownDevices.length
    if (section === "discovered") return discoveredDevices.length
    return 0
  }

  function sectionVisible(section) {
    if (section === "connected") return connectedDevices.length > 0
    if (section === "known") return knownDevices.length > 0
    if (section === "discovered") return adapter && adapter.discovering && discoveredDevices.length > 0
    return false
  }

  // The codec section sits between the connected headsets and the
  // remembered devices, on screen and in the cursor order alike.
  readonly property var visibleSections: {
    var sections = Model.visibleSections(deviceGroups, adapter && adapter.discovering)
    if (canSelectCodec) sections.splice(sections.indexOf("connected") + 1, 0, "codec")
    return sections
  }

  function devicesForSection(section) {
    return Model.sectionDevices(deviceGroups, section)
  }

  // The scrollable half of the panel — remembered devices, then whatever the
  // scan turned up — flattened into one model so a ListView can own the
  // viewport. Each entry carries the section it came from, which is what lets
  // the delegate and the cursor keep working in section-relative terms.
  readonly property var scrollRows: {
    var rows = []
    for (var k = 0; k < knownDevices.length; k++)
      rows.push({ dev: Model.deviceRow(knownDevices[k]), section: "known", indexInSection: k })
    if (sectionVisible("discovered"))
      for (var d = 0; d < discoveredDevices.length; d++)
        rows.push({ dev: Model.deviceRow(discoveredDevices[d]), section: "discovered", indexInSection: d })
    return rows
  }

  // Connected devices render above the scroll area; same primitives-only
  // projection so those delegates never hold Device QObject wrappers either.
  readonly property var connectedRows: {
    var rows = []
    for (var i = 0; i < connectedDevices.length; i++)
      rows.push(Model.deviceRow(connectedDevices[i], codecsByAddress))
    return rows
  }

  // Live BlueZ device behind a row. Rows carry primitives only, so actions
  // resolve the backend object here rather than holding a wrapper that can
  // dangle mid-incubation. `devices` is already the raw device array (see the
  // property declaration), so it is iterated directly.
  function deviceFor(row) {
    if (!row || !row.dev) return null
    var addr = row.dev.address || ""
    var devs = devices || []
    for (var i = 0; i < devs.length; i++) {
      if ((devs[i].address || "") === addr) return devs[i]
    }
    return null
  }

  // Flat position of the keyboard cursor, or -1 while it sits on the hero or
  // in the connected list (both of which live outside the scroll area).
  readonly property int scrollRowIndex: {
    if (focusSection !== "known" && focusSection !== "discovered") return -1
    for (var i = 0; i < scrollRows.length; i++)
      if (scrollRows[i].section === focusSection && scrollRows[i].indexInSection === selectedIndex) return i
    return -1
  }

  // A row opens a section when it is the first of its kind in the flat list.
  function scrollSectionTitle(index) {
    var rows = scrollRows
    if (index < 0 || index >= rows.length) return ""
    if (index > 0 && rows[index - 1].section === rows[index].section) return ""
    return rows[index].section === "known" ? Commons.I18n.t("bluetooth.paired") : Commons.I18n.t("bluetooth.available")
  }

  function audioSinks() {
    var sinks = []
    for (var i = 0; i < pipewireNodes.length; i++) {
      var node = pipewireNodes[i]
      if (node && node.isSink && !node.isStream) sinks.push(node)
    }
    return sinks
  }

  function bluetoothAudioSink(device) {
    var sinks = audioSinks()
    for (var i = 0; i < sinks.length; i++) {
      if (Model.bluetoothSinkMatchesDevice(sinks[i], device)) return sinks[i]
    }
    return null
  }

  function refreshCodecStatus() {
    if (!opened || codecTarget === "") return
    if (codecStatusProc.running) {
      codecStatusSettle.restart()
      return
    }
    codecStatusProc.address = codecTarget
    codecStatusProc.command = ["omarchy-bluetooth-codec", codecTarget]
    codecStatusProc.running = true
  }

  function updateCodecStatus(address, raw) {
    // A status for a headset the section has since moved off is stale.
    if (address !== codecTarget) return
    var status = Model.parseCodecStatus(raw)
    // Mid-switch the card can briefly report no profile. Publishing that would
    // unmount the section under the busy switch -- same guard as Wi-Fi band.
    if (codecBusy && status.options.length === 0) return

    codecStatusAddress = address
    codecMode = status.mode
    codecCurrent = status.codec
    codecSelected = status.selected
    codecOptions = status.options
    if (!codecBusy) syncCodecIndex()
  }

  function codecLabel(codec) {
    for (var i = 0; i < codecOptions.length; i++)
      if (codecOptions[i].codec === codec) return codecOptions[i].label
    return Model.codecLabel(codec)
  }

  function codecTooltip(codec) {
    return Commons.I18n.t("bluetooth.stayOnCodec").arg(codecLabel(codec))
  }

  // Switching the codec rebuilds the transport -- a second or two of silence --
  // and the panel stays open so the switch and the row's codec show it land.
  function setCodec(codec) {
    if (!codec || codecTarget === "" || codecActionProc.running) return
    pendingCodec = codec
    codecHoldAddress = codecTarget
    // Automatic lands on the headset's best codec, which it lists first.
    codecHoldCodec = codec !== "auto" ? codec : (codecOptions.length > 0 ? codecOptions[0].codec : "")
    codecHoldTimeout.restart()
    codecActionProc.command = ["omarchy-bluetooth-codec", codecTarget, codec]
    codecActionProc.running = true
  }

  // Switching Automatic off has to commit to something, so it pins the codec
  // the headset is already playing: nothing audible changes until a pill is
  // picked.
  function toggleCodecAuto() {
    if (codecSelected !== "auto") {
      setCodec("auto")
      return
    }
    if (codecCurrent === "") return
    setCodec(codecCurrent)
  }

  function syncCodecIndex() {
    var idx = -1
    for (var i = 0; i < codecOptions.length; i++)
      if (codecOptions[i].codec === codecSelected) idx = i
    codecIndex = idx >= 0 ? idx : 0
  }

  function selectCodecByDelta(delta) {
    codecIndex = Math.max(0, Math.min(codecOptions.length - 1, codecIndex + delta))
  }

  function activateCodec() {
    if (codecAutoFocused) {
      toggleCodecAuto()
      return
    }
    if (codecIndex < 0 || codecIndex >= codecOptions.length) return
    setCodec(codecOptions[codecIndex].codec)
  }

  function setDefaultAudioSink(sink) {
    if (!sink) return
    Pipewire.preferredDefaultAudioSink = sink
    if (sink.id !== undefined && sink.name) {
      Quickshell.execDetached([
        "omarchy-audio-output-set-default",
        String(sink.id),
        String(sink.name)
      ])
    }
  }

  function scheduleAudioOutputSwitch(device) {
    pendingAudioOutputDevice = {
      address: device && device.address ? device.address : "",
      name: device && device.name ? device.name : "",
      deviceName: device && device.deviceName ? device.deviceName : ""
    }
    pendingAudioOutputAttempts = 0
    audioSwitchTimer.restart()
  }

  function switchPendingAudioOutput() {
    if (!pendingAudioOutputDevice) return

    var sink = bluetoothAudioSink(pendingAudioOutputDevice)
    if (sink) {
      setDefaultAudioSink(sink)
      pendingAudioOutputDevice = null
      audioSwitchTimer.stop()
      return
    }

    pendingAudioOutputAttempts += 1
    if (pendingAudioOutputAttempts >= 8) {
      pendingAudioOutputDevice = null
      return
    }
    audioSwitchTimer.restart()
  }

  function deviceAt(section, index) {
    var list = devicesForSection(section)
    return index >= 0 && index < list.length ? list[index] : null
  }

  function cloneMap(map) {
    return Model.cloneMap(map)
  }

  function pendingAction(address) {
    return Model.pendingAction(pendingActions, address)
  }

  function setPendingAction(address, action) {
    if (!address) return
    pendingActions = Model.withPendingAction(pendingActions, address, action)
    if (action) pendingTimeout.restart()
  }

  function deviceCommand(action, address) {
    return ["omarchy-bluetooth-device", action, address]
  }

  function runDeviceAction(device, action, pending) {
    if (!device || !device.address) return
    setPendingAction(device.address, pending)
    Quickshell.execDetached(deviceCommand(action, device.address))
  }

  function connectDevice(device) {
    if (!device || device.connected) return
    if (device.paired || device.bonded || device.trusted) runDeviceAction(device, "connect", "connecting")
    else runDeviceAction(device, "pair", "connecting")
  }

  function disconnectDevice(device) {
    if (!device || !device.address) return
    if (!device.connected) return
    setPendingAction(device.address, "disconnecting")
    if (device.disconnect) device.disconnect()
    Quickshell.execDetached(deviceCommand("disconnect", device.address))
  }

  function forgetDevice(device) {
    if (!device || !device.address) return
    runDeviceAction(device, "forget", "forgetting")
  }

  function syncPendingActions() {
    var next = cloneMap(pendingActions)
    var changed = false

    for (var address in next) {
      var action = next[address]
      var found = null

      for (var i = 0; i < devices.length; i++) {
        var d = devices[i]
        if (d && d.address === address) {
          found = d
          break
        }
      }

      var finishedConnecting = action === "connecting" && found && found.connected
      if (finishedConnecting
          || (action === "disconnecting" && found && !found.connected)
          || (action === "forgetting" && (!found || (!found.paired && !found.bonded && !found.trusted)))) {
        if (finishedConnecting) scheduleAudioOutputSwitch(found)
        delete next[address]
        changed = true
      }
    }

    if (changed) pendingActions = next
  }

  // j/k navigates the hero toggle ("header") and the device sections
  // row-by-row.
  function moveCursor(delta) {
    var sections = visibleSections
    if (focusSection === "header") {
      if (delta > 0 && sections && sections.length > 0) {
        focusSection = sections[0]; selectedIndex = 0; actionFocused = false
        codecAutoFocused = true
      }
      return
    }
    // Automatic on the header line, then the pills -- which collapse away
    // under Automatic, leaving a single row to walk.
    if (focusSection === "codec") {
      if (delta > 0 && codecAutoFocused && codecPillsVisible) { codecAutoFocused = false; return }
      if (delta < 0 && !codecAutoFocused) { codecAutoFocused = true; return }
    }
    var entering = delta > 0 ? sections[sections.indexOf(focusSection) + 1] : sections[sections.indexOf(focusSection) - 1]
    if (entering === "codec") codecAutoFocused = delta > 0 || !codecPillsVisible
    if (!sections || sections.length === 0) { focusSection = "header"; actionFocused = false; return }
    var sIdx = sections.indexOf(focusSection)
    if (sIdx < 0) { focusSection = sections[0]; selectedIndex = 0; actionFocused = false; return }

    var idx = selectedIndex
    var max = sectionCount(focusSection) - 1

    if (delta > 0) {
      if (idx < max) { selectedIndex = idx + 1; actionFocused = false; return }
      if (sIdx < sections.length - 1) {
        focusSection = sections[sIdx + 1]
        selectedIndex = 0
        actionFocused = false
      }
    } else {
      if (idx > 0) { selectedIndex = idx - 1; actionFocused = false; return }
      if (sIdx > 0) {
        focusSection = sections[sIdx - 1]
        selectedIndex = sectionCount(focusSection) - 1
        actionFocused = false
      } else {
        focusSection = "header"; actionFocused = false
      }
    }
  }

  function setHeaderCursor() {
    cursorActive = true
    focusSection = "header"
    actionFocused = false
  }

  function moveCursorH(delta) {
    if (!cursorActive) { cursorActive = true; return }
    if (focusSection === "codec") {
      if (!codecAutoFocused) selectCodecByDelta(delta)
      return
    }
    if (focusSection !== "known" && focusSection !== "connected") return
    var dev = deviceAt(focusSection, selectedIndex)
    if (!dev || !dev.address) return
    if (delta > 0) actionFocused = true
    else if (delta < 0) actionFocused = false
  }

  function activateCursor() {
    if (focusSection === "header") {
      toggleBluetooth()
      return
    }
    if (focusSection === "codec") {
      activateCodec()
      return
    }
    if (actionFocused) {
      deleteSelected()
      return
    }

    if (focusSection === "connected" || focusSection === "known") {
      var dev = deviceAt(focusSection, selectedIndex)
      if (!dev) return
      if (dev.connected) disconnectDevice(dev)
      else connectDevice(dev)
      return
    }
    if (focusSection === "discovered") {
      var d = discoveredDevices[selectedIndex]
      if (!d) return
      connectDevice(d)
    }
  }

  // 'x' forgets remembered devices. For connected devices this first
  // disconnects, then removes the BlueZ pairing record via omarchy-bluetooth-device.
  function deleteSelected() {
    if (focusSection !== "known" && focusSection !== "connected") return
    var dev = deviceAt(focusSection, selectedIndex)
    if (!dev) return
    forgetDevice(dev)
  }

  onOpenedChanged: {
    if (opened) {
      // Adopt a discovery session that is already running — a popout handoff
      // from another monitor, or one leaked by an instance that could not
      // finish its own stop — so this close settles it either way.
      if (adapter !== null && adapter.discovering) owesDiscoveryStop = true
      if (connectedDevices.length > 0) { focusSection = "connected"; selectedIndex = 0 }
      else if (knownDevices.length > 0) { focusSection = "known"; selectedIndex = 0 }
      else if (discoveredDevices.length > 0) { focusSection = "discovered"; selectedIndex = 0 }
      else { focusSection = "header" }
      actionFocused = false
      cursorActive = false
      codecAutoFocused = true
      codecStatusSettle.restart()
    } else {
      // A closed panel shows no codec; drop the reading so a reopen never
      // flashes a headset's stale state.
      codecStatusAddress = ""
    }
  }

  // Another per-monitor instance of this widget whose panel is open, if any.
  // All instances share the default adapter, and switching the popout to a
  // different monitor closes one instance as it opens the next, so the
  // closing side has to leave the scan alone for the side still on screen.
  function openSibling() {
    if (!bar || typeof bar.moduleWidgets !== "function") return null
    var items = bar.moduleWidgets(moduleName)
    for (var i = 0; i < items.length; i++) {
      if (items[i] && items[i] !== root && items[i].opened === true) return items[i]
    }
    return null
  }

  function updateFocusedAddress() {
    var d = deviceAt(focusSection, selectedIndex)
    focusedDeviceAddress = d ? (d.address || "") : ""
    if (d && focusSection === "connected") codecFocusAddress = d.address || ""
  }

  function reselectFocusedDevice() {
    if (focusedDeviceAddress === "") {
      clampCursor()
      return
    }

    var sections = ["connected", "known", "discovered"]
    for (var s = 0; s < sections.length; s++) {
      var section = sections[s]
      if (!sectionVisible(section)) continue
      var list = devicesForSection(section)
      for (var i = 0; i < list.length; i++) {
        if (list[i] && list[i].address === focusedDeviceAddress) {
          focusSection = section
          selectedIndex = i
          clampCursor()
          return
        }
      }
    }

    clampCursor()
  }

  onSelectedIndexChanged: updateFocusedAddress()
  onFocusSectionChanged: updateFocusedAddress()
  onConnectedDevicesChanged: { reselectFocusedDevice(); syncPendingActions() }
  onKnownDevicesChanged: { reselectFocusedDevice(); syncPendingActions() }
  onDiscoveredDevicesChanged: { reselectFocusedDevice(); syncPendingActions() }
  onVisibleSectionsChanged: clampCursor()

  function clampCursor() {
    var sections = visibleSections
    // "header" is virtual and never appears in visibleSections, so it has to
    // be let through: toggling the adapter empties and refills the device
    // lists, and clamping would knock the cursor off the hero switch every
    // time it is used.
    if (focusSection === "header") return
    if (!sections || !sections.length) {
      if (focusSection === "codec") focusSection = "header"
      selectedIndex = 0
      return
    }
    if (sections.indexOf(focusSection) < 0) {
      focusSection = sections[0]
      selectedIndex = 0
      return
    }
    var count = sectionCount(focusSection)
    if (count === 0) {
      // Section emptied out — bounce to the previous visible one.
      var sIdx = sections.indexOf(focusSection)
      focusSection = sIdx > 0 ? sections[sIdx - 1] : sections[0]
      selectedIndex = Math.max(0, sectionCount(focusSection) - 1)
      return
    }
    if (selectedIndex > count - 1) selectedIndex = count - 1
    if (selectedIndex < 0) selectedIndex = 0
  }

  PwObjectTracker { objects: root.opened ? root.bluezNodes : [] }

  visible: adapter !== null
  implicitWidth: button.implicitWidth
  implicitHeight: button.implicitHeight

  // BlueZ rejects StartDiscovery while the adapter is still powering up, and
  // discovery can also time out on its own. While the panel is open, keep
  // nudging it back on so an enabled adapter is always scanning.
  Timer {
    id: discoveryRetry
    interval: 1000
    repeat: true
    triggeredOnStart: true
    running: root.opened && root.adapter !== null && root.adapter.enabled && !root.adapter.discovering
    onTriggered: {
      root.owesDiscoveryStop = true
      root.adapter.discovering = true
    }
  }

  // The way back down. The BlueZ discovery session behind adapter.discovering
  // is held by quickshell's D-Bus connection, so nothing ends it at close:
  // without this timer, one visit to the panel left the radio in inquiry
  // until the next shell restart, starving A2DP audio on the same controller
  // into stutters.
  //
  // A timer bound to the confirmed state rather than a write at close time:
  // quickshell only forwards a discovering write that differs from the last
  // state BlueZ reported, so a stop issued while a just-fired StartDiscovery
  // is still awaiting confirmation would be swallowed and leak the session.
  // Binding to adapter.discovering means a confirmation landing at any point
  // after close re-arms the stop, and a reopen inside the first interval
  // keeps the scan running uninterrupted. Attempts are bounded so a session
  // some other BlueZ client keeps up cannot draw StopDiscovery fire forever.
  Timer {
    id: discoveryStop
    interval: 1000
    repeat: true
    property int attempts: 0
    running: !root.opened && root.owesDiscoveryStop && root.adapter !== null && root.adapter.discovering === true
    onRunningChanged: if (running) attempts = 0
    onTriggered: {
      // The scan now serves the open panel, so the debt moves with it — B may
      // have opened before BlueZ confirmed A's start, in which case B's own
      // open-time adoption saw nothing to adopt.
      var sibling = root.openSibling()
      if (sibling) {
        sibling.owesDiscoveryStop = true
        root.owesDiscoveryStop = false
        return
      }
      attempts += 1
      if (attempts > 3) { root.owesDiscoveryStop = false; return }
      root.adapter.discovering = false
    }
  }

  // The debt is settled the moment BlueZ reports discovery down — whether
  // because the stop above landed or the session ended some other way — so a
  // stale claim never touches a scan another client starts later. While the
  // panel is open, discoveryRetry re-incurs it as it restarts the scan.
  Connections {
    target: root.adapter
    function onDiscoveringChanged() {
      if (!root.adapter.discovering) root.owesDiscoveryStop = false
    }
  }

  // A destroyed instance cannot wait for BlueZ confirmations, so it hands any
  // debt to a surviving sibling — whose declarative stop catches even a start
  // confirmed after this object is gone — and only writes the stop directly
  // when it is the last one standing.
  Component.onDestruction: {
    if (!owesDiscoveryStop) return
    var items = bar && typeof bar.moduleWidgets === "function" ? bar.moduleWidgets(moduleName) : []
    for (var i = 0; i < items.length; i++) {
      if (items[i] && items[i] !== root) { items[i].owesDiscoveryStop = true; return }
    }
    if (adapter !== null && adapter.discovering) adapter.discovering = false
  }

  // Coalesces the node churn of a codec or profile switch into one status read.
  Timer {
    id: codecStatusSettle
    interval: 250
    repeat: false
    onTriggered: root.refreshCodecStatus()
  }

  // A headset that disconnects mid-switch never reports back; let go of it.
  Timer {
    id: codecHoldTimeout
    interval: 8000
    repeat: false
    onTriggered: root.codecHoldAddress = ""
  }

  Process {
    id: codecStatusProc
    property string address: ""
    stdout: StdioCollector {
      waitForEnd: true
      onStreamFinished: root.updateCodecStatus(codecStatusProc.address, text)
    }
  }

  Process {
    id: codecActionProc
    onExited: function(exitCode) {
      // A refused or reverted pin leaves codecSelected alone, so the pills keep
      // showing what is actually in force rather than what was asked.
      if (exitCode === 0) root.codecSelected = root.pendingCodec
      root.pendingCodec = ""
      // A refused switch keeps the old node, so nothing is coming back to wait
      // for. Otherwise the hold ends when the new codec reports in.
      if (exitCode !== 0) root.codecHoldCodec = ""
      root.releaseCodecHold()
      root.refreshCodecStatus()
    }
  }

  Timer {
    id: pendingTimeout
    interval: 20000
    repeat: false
    onTriggered: root.pendingActions = ({})
  }

  Timer {
    id: audioSwitchTimer
    interval: 500
    repeat: false
    onTriggered: root.switchPendingAudioOutput()
  }

  Timer {
    id: phraseTimer
    interval: 2800
    running: root.opened && root.rotatingPhrases
    repeat: true
    onTriggered: phraseSwap.restart()
  }

  SequentialAnimation {
    id: phraseSwap
    PropertyAnimation {
      target: panel.loadedContent ? panel.loadedContent.heroStatus : null; property: "opacity"
      to: 0.0; duration: Style.duration(150); easing.type: Easing.OutCubic
    }
    ScriptAction {
      script: root.phraseIndex = (root.phraseIndex + 1) % root.activePhrases.length
    }
    PropertyAnimation {
      target: panel.loadedContent ? panel.loadedContent.heroStatus : null; property: "opacity"
      to: 1.0; duration: Style.duration(200); easing.type: Easing.OutCubic
    }
  }

  Connections {
    target: root
    function onRotatingPhrasesChanged() {
      if (!root.rotatingPhrases) {
        phraseSwap.stop()
        if (panel.loadedContent) panel.loadedContent.heroStatus.opacity = 1.0
      }
    }
  }

  // Not adapter.enabled: that writes BlueZ's Powered, which nothing persists, so
  // the adapter came back on at the next boot. omarchy-bluetooth-power moves the
  // rfkill soft block instead, which systemd-rfkill restores across reboots.
  // Powered still follows the block, so the switch and icon read it as before.
  //
  // Asking for a direction rather than a toggle: the helper runs detached and the
  // switch only moves once BlueZ catches up, so a second click inside that window
  // would re-read the old state and undo the first.
  function toggleBluetooth() {
    if (!adapter) return
    Quickshell.execDetached(["omarchy-bluetooth-power", adapter.enabled ? "off" : "on"])
  }

  ShellIpc {
    target: "omarchy.bluetooth"

    function open() { root.open() }
    function close() { root.close() }
    function show() { root.open() }
    function hide() { root.close() }
    function toggle() { root.toggle() }
    function toggleBluetooth() { root.toggleBluetooth() }
  }

  BarIconButton {
    id: button
    anchors.fill: parent
    bar: root.bar
    text: root.icon
    onPressed: function(b) {
      if (b === Qt.RightButton) root.toggleBluetooth()
      else root.toggle()
    }
  }

  KeyboardPanel {
    id: panel
    anchorItem: button
    owner: root
    bar: root.bar
    open: root.opened
    focusTarget: panel.loadedContent
    contentWidth: panel.fittedContentWidth(Style.space(380))
    contentHeight: panel.fittedContentHeight(panel.loadedContentHeight)

    content: PanelKeyCatcher {
      id: keyCatcher
      property alias heroStatus: heroStatus
      implicitHeight: column.implicitHeight
      anchors.fill: parent
      onMoveRequested: function(dx, dy) {
        if (!root.cursorActive) { root.cursorActive = true; return }
        if (dy !== 0) root.moveCursor(dy)
        else if (dx !== 0) root.moveCursorH(dx)
      }
      onActivateRequested: if (root.cursorActive) root.activateCursor()
      onCloseRequested: root.close()
      onTabRequested: function(direction) { root.switchPanel(direction) }
      onDeleteRequested: if (root.cursorActive) root.deleteSelected()
      onTextKey: function(t) {
        if (t === "b" || t === "B") root.toggleBluetooth()
      }

      Column {
        id: column
        anchors.fill: parent
        spacing: Style.space(14)

        // ---------- Hero: Bluetooth icon · status ----------
        Item {
          width: parent.width
          implicitHeight: Math.max(heroIcon.implicitHeight, heroLabels.implicitHeight, powerSwitch.implicitHeight)

          // Status only — the switch owns toggling, mouse and keyboard alike.
          Text {
            id: heroIcon
            textFormat: Text.PlainText
            anchors.left: parent.left
            anchors.verticalCenter: parent.verticalCenter
            text: root.icon
            color: root.bar.foreground
            font.family: root.bar.fontFamily
            font.pixelSize: Style.font.display
            opacity: root.adapter && root.adapter.enabled ? 1.0 : 0.5
          }

          // Compact on/off switch on the trailing edge of the hero, and the
          // header's only cursor target.
          ToggleSwitch {
            id: powerSwitch
            visible: !!root.adapter
            checked: !!root.adapter && root.adapter.enabled
            hasCursor: root.headerHasCursor
            foreground: root.bar.foreground
            anchors.right: parent.right
            anchors.verticalCenter: parent.verticalCenter
            onHovered: function(on) { if (on) root.setHeaderCursor() }
            onToggled: root.toggleBluetooth()

            PanelToolTip {
              visible: powerSwitch.containsMouse
              text: root.toggleHint
              fontFamily: root.bar.fontFamily
            }
          }

          Column {
            id: heroLabels
            anchors.left: heroIcon.right
            anchors.leftMargin: Style.space(14)
            anchors.right: parent.right
            anchors.rightMargin: powerSwitch.visible ? powerSwitch.width + Style.space(12) : 0
            anchors.verticalCenter: parent.verticalCenter
            spacing: Style.space(2)

            Text {
              text: Commons.I18n.t("bluetooth.title")
              textFormat: Text.PlainText
              color: root.bar.foreground
              font.family: root.bar.fontFamily
              font.pixelSize: Style.font.title
              font.bold: true
              elide: Text.ElideRight
              width: parent.width
            }

            Text {
              id: heroStatus
              textFormat: Text.PlainText
              text: root.heroStatusText.toUpperCase()
              color: Qt.darker(root.bar.foreground, 1.4)
              font.family: root.bar.fontFamily
              font.pixelSize: Style.font.caption
              font.bold: true
              font.letterSpacing: 1.2
              elide: Text.ElideRight
              width: parent.width
            }
          }
        }

        // Scrollable device list — capped so a noisy neighborhood doesn't
        // grow the popup past the screen.
        PanelSeparator {
          foreground: root.bar.foreground
        }

        Column {
          id: connectedList
          visible: root.connectedDevices.length > 0
          width: parent.width
          spacing: Style.space(10)

          PanelSectionHeader {
            text: Commons.I18n.t("bluetooth.connected")
            foreground: root.bar.foreground
            fontFamily: root.bar.fontFamily
          }

          Repeater {
            model: root.connectedRows
            DeviceRow {
              required property var modelData
              required property int index
              width: connectedList.width
              dev: modelData
              rowIndex: index
              sectionName: "connected"
              isDiscovered: false
            }
          }
        }

        PanelSeparator {
          visible: root.canSelectCodec
          foreground: root.bar.foreground
        }

        // Codec for the connected headset, laid out like the Wi-Fi band
        // section: Automatic on the header line, the pinned choice as pills.
        Column {
          visible: root.canSelectCodec
          width: parent.width
          spacing: Style.space(10)

          Item {
            width: parent.width
            implicitHeight: Math.max(codecHeader.implicitHeight, codecAutoRow.implicitHeight)

            PanelSectionHeader {
              id: codecHeader
              text: root.codecSectionTitle
              foreground: root.bar.foreground
              fontFamily: root.bar.fontFamily
              anchors.left: parent.left
              anchors.right: codecAutoRow.left
              anchors.rightMargin: Style.space(8)
              anchors.verticalCenter: parent.verticalCenter
            }

            Row {
              id: codecAutoRow
              anchors.right: parent.right
              anchors.verticalCenter: parent.verticalCenter
              spacing: Style.space(6)

              PanelSectionHeader {
                id: codecAutoLabel
                text: Commons.I18n.t("bluetooth.automatic")
                foreground: root.bar.foreground
                fontFamily: root.bar.fontFamily
                anchors.verticalCenter: parent.verticalCenter
              }

              // Sized and centred off the label's glyphs, as in the Wi-Fi band
              // header, so it reads as part of the header line.
              ToggleSwitch {
                id: codecAutoSwitch
                trackHeight: Math.round(codecAutoLabel.font.pixelSize * 1.2)
                cursorPad: Style.space(3)
                anchors.verticalCenter: codecAutoLabel.verticalCenter
                anchors.verticalCenterOffset: Math.round(codecAutoLabel.topPadding / 2)
                checked: !root.codecPinned
                busy: root.codecBusy
                hasCursor: root.cursorActive && root.focusSection === "codec" && root.codecAutoFocused
                foreground: root.bar.foreground
                onToggled: root.toggleCodecAuto()

                onHovered: function(isHovered) {
                  if (!isHovered) return
                  root.cursorActive = true
                  root.focusSection = "codec"
                  root.selectedIndex = 0
                  root.codecAutoFocused = true
                }

                PanelToolTip {
                  visible: codecAutoSwitch.containsMouse
                  text: root.codecPinned
                    ? Commons.I18n.t("bluetooth.codecAutoTooltip")
                    : root.codecTooltip(root.codecCurrent)
                  fontFamily: root.bar.fontFamily
                }
              }
            }
          }

          // Collapsing container, as in the Wi-Fi band section: toggling
          // Automatic slides the list below into place instead of snapping.
          Item {
            width: parent.width
            clip: true
            visible: height > 0
            height: root.codecPillsVisible ? codecRow.implicitHeight : 0
            opacity: root.codecPillsVisible ? 1 : 0

            Behavior on height {
              NumberAnimation { duration: Style.duration(140); easing.type: Easing.OutCubic }
            }
            Behavior on opacity {
              NumberAnimation { duration: Style.duration(140); easing.type: Easing.OutCubic }
            }

            Row {
              id: codecRow
              width: parent.width
              spacing: Style.space(6)

              readonly property int count: Math.max(1, root.codecOptions.length)
              readonly property real cellWidth: (width - spacing * (count - 1)) / count

              Repeater {
                model: root.codecOptions

                delegate: Item {
                  required property var modelData
                  required property int index
                  width: codecRow.cellWidth
                  height: codecPill.implicitHeight

                  CodecPill {
                    id: codecPill
                    codec: modelData.codec
                    label: modelData.label
                    slot: index
                    width: parent.width
                  }
                }
              }
            }
          }
        }

        PanelSeparator {
          visible: root.connectedDevices.length > 0 && root.scrollRows.length > 0
          foreground: root.bar.foreground
        }

        // ListView, not a Flickable: it owns the scroll position, so it keeps
        // the current row visible on j/k, re-clamps itself when discovery
        // shortens the list, and — because Contain only moves when a row is
        // actually clipped — never lurches under a hovering mouse.
        ListView {
          id: deviceListView
          width: parent.width
          height: Math.min(contentHeight, Style.space(400))
          spacing: Style.space(10)
          clip: true
          boundsBehavior: Flickable.StopAtBounds
          interactive: contentHeight > height

          ScrollBar.vertical: ScrollBar { policy: ScrollBar.AsNeeded }

          model: root.scrollRows
          currentIndex: root.scrollRowIndex
          // Deferred by a turn. Called straight out of the signal the position
          // does not take — verified with the cursor six rows down and
          // contentY still 0 — because scrollRows is rebuilt every time
          // discovery reports, and swapping the model resets the view out from
          // under the call. Network's list is stable enough not to need this.
          onCurrentIndexChanged: if (currentIndex >= 0) Qt.callLater(keepCurrentVisible)
          function keepCurrentVisible() {
            if (currentIndex >= 0) positionViewAtIndex(currentIndex, ListView.Contain)
          }

          delegate: Item {
            required property var modelData
            required property int index
            readonly property string sectionTitle: root.scrollSectionTitle(index)

            width: ListView.view.width
            height: delegateColumn.implicitHeight

            Column {
              id: delegateColumn
              width: parent.width
              spacing: Style.space(10)

              PanelSeparator {
                visible: index > 0 && sectionTitle !== ""
                height: visible ? implicitHeight : 0
                foreground: root.bar.foreground
              }

              PanelSectionHeader {
                visible: sectionTitle !== ""
                height: visible ? implicitHeight : 0
                text: sectionTitle
                foreground: root.bar.foreground
                fontFamily: root.bar.fontFamily
              }

              DeviceRow {
                width: parent.width
                dev: modelData.dev
                rowIndex: modelData.indexInSection
                sectionName: modelData.section
                isDiscovered: modelData.section === "discovered"
              }
            }
          }
        }

        Text {
          textFormat: Text.PlainText
          visible: root.connectedDevices.length === 0 && root.scrollRows.length === 0
          text: !root.adapter ? Commons.I18n.t("bluetooth.noBluetoothAdapter")
              : !root.adapter.enabled ? Commons.I18n.t("bluetooth.turnOnToScan")
              : Commons.I18n.t("bluetooth.scanning")
          color: Qt.darker(root.bar.foreground, 1.5)
          font.family: root.bar.fontFamily
          font.pixelSize: Style.font.bodySmall
          wrapMode: Text.WordWrap
          width: parent.width
        }
      }
    }
  }

  // One codec choice. `active` marks the codec playing now and `selected` the
  // pinned one, as the Wi-Fi band pills do; they meet once the switch lands.
  component CodecPill: Button {
    id: pill
    required property string codec
    required property string label
    required property int slot

    text: label
    tooltipText: root.codecTooltip(codec)
    fontSize: Style.font.bodySmall
    foreground: root.bar.foreground
    fontFamily: root.bar.fontFamily
    horizontalPadding: Style.spacing.controlPaddingX
    verticalPadding: Style.spacing.controlPaddingY + Style.space(2)
    bordered: true

    active: root.codecCurrent === codec
    selected: root.codecEffective === codec
    hasCursor: root.cursorActive && root.focusSection === "codec"
      && !root.codecAutoFocused && root.codecIndex === slot

    onClicked: root.setCodec(codec)

    onHovered: function(isHovered) {
      if (!isHovered) return
      root.cursorActive = true
      root.focusSection = "codec"
      root.selectedIndex = 0
      root.codecAutoFocused = false
      root.codecIndex = pill.slot
    }
  }

  // Two-line device row showing name + live status. Pending state is owned
  // by the panel so it survives rows moving between sections.
  component DeviceRow: CursorSurface {
    id: row
    required property var dev
    required property int rowIndex
    required property string sectionName
    required property bool isDiscovered

    readonly property bool isConnected: dev && dev.connected
    readonly property int devState: dev && dev.state !== undefined ? dev.state : -1
    readonly property string action: root.pendingAction(dev ? dev.address : "")
    readonly property string actionTooltip: {
      if (!dev) return ""
      if (isConnected) return Commons.I18n.t("bluetooth.disconnect")
      if (isDiscovered) return Commons.I18n.t("bluetooth.pair")
      return Commons.I18n.t("bluetooth.connect")
    }

    readonly property bool rowSelected: root.cursorActive && root.focusSection === sectionName && root.selectedIndex === rowIndex
    readonly property bool forgetAvailable: (sectionName === "known" || sectionName === "connected") && !isDiscovered
    readonly property bool showForgetButton: forgetAvailable && (rowMouse.containsMouse || rowSelected)

    hasCursor: rowSelected && !root.actionFocused
    current: isConnected
    foreground: root.bar.foreground
    fill: root.hoverFill
    currentFill: root.selectedFill

    readonly property string statusText: {
      if (!dev) return ""
      if (action === "forgetting") return Commons.I18n.t("bluetooth.forgetting")
      if (action === "disconnecting" || devState === 2) return Commons.I18n.t("bluetooth.disconnecting")
      if (isConnected) {
        var parts = []
        if (dev.batteryAvailable) parts.push(Commons.I18n.formatNumber(Math.round(dev.battery * 100)) + "%")
        if (dev.codec) parts.push(Model.codecLabel(dev.codec))
        if (parts.length > 0) return parts.join(" · ")
        return sectionName === "connected" ? "" : Commons.I18n.t("bluetooth.connectedStatus")
      }
      if (action === "connecting" || devState === 3 || dev.pairing === true) return Commons.I18n.t("bluetooth.connecting")
      if (isDiscovered) return ""
      return ""
    }

    readonly property color statusColor: {
      if (isConnected) return root.bar.foreground
      if (action !== "" || devState === 3 || dev.pairing === true) return root.bar.foreground
      return Qt.darker(root.bar.foreground, 1.5)
    }

    implicitHeight: rowContent.implicitHeight + Style.spacing.rowPaddingX

    MouseArea {
      id: rowMouse
      anchors.fill: parent
      hoverEnabled: true
      acceptedButtons: Qt.LeftButton | Qt.RightButton
      cursorShape: row.dev ? Qt.PointingHandCursor : Qt.ArrowCursor

      onContainsMouseChanged: if (containsMouse) {
        root.cursorActive = true
        root.focusSection = row.sectionName
        root.selectedIndex = row.rowIndex
        root.actionFocused = false
      }

      onClicked: function(mouse) {
        var dev = root.deviceFor(row)
        if (!dev) return
        if (mouse.button === Qt.RightButton) {
          if (row.isConnected) root.disconnectDevice(dev)
          else if (!row.isDiscovered) root.forgetDevice(dev)
          return
        }
        if (row.isConnected) root.disconnectDevice(dev)
        else root.connectDevice(dev)
      }
    }

    PanelToolTip {
      visible: row.actionTooltip !== "" && rowMouse.containsMouse && !root.actionFocused
      text: row.actionTooltip
      fontFamily: root.bar.fontFamily
    }

    Item {
      id: rowContent
      anchors.left: parent.left
      anchors.right: parent.right
      anchors.verticalCenter: parent.verticalCenter
      anchors.leftMargin: Style.space(10)
      anchors.rightMargin: Style.space(10)
      implicitHeight: Math.max(deviceIcon.implicitHeight, info.implicitHeight, forgetBtn.implicitHeight)

      Text {
        id: deviceIcon
        textFormat: Text.PlainText
        text: row.isConnected ? "󰂱" : "󰂯"
        color: row.statusColor
        font.family: root.bar.fontFamily
        font.pixelSize: Style.font.heading
        anchors.left: parent.left
        anchors.verticalCenter: parent.verticalCenter
      }

      Column {
        id: info
        spacing: Style.space(1)
        anchors.left: deviceIcon.right
        anchors.leftMargin: Style.space(10)
        anchors.right: forgetBtn.visible ? forgetBtn.left : parent.right
        anchors.rightMargin: forgetBtn.visible ? Style.space(8) : 0
        anchors.verticalCenter: parent.verticalCenter

        Text {
          textFormat: Text.PlainText
          text: root.deviceLabel(row.dev) || Commons.I18n.t("bluetooth.device")
          color: root.bar.foreground
          font.family: root.bar.fontFamily
          font.pixelSize: Style.font.body
          elide: Text.ElideRight
          width: parent.width
        }
        Text {
          textFormat: Text.PlainText
          visible: row.statusText !== ""
          text: row.statusText
          color: row.statusColor
          font.family: root.bar.fontFamily
          font.pixelSize: Style.font.caption
          elide: Text.ElideRight
          width: parent.width
        }
      }

      PanelActionButton {
        id: forgetBtn
        anchors.right: parent.right
        anchors.verticalCenter: parent.verticalCenter
        visible: row.showForgetButton
        iconText: "󰅙"
        tooltipText: Commons.I18n.t("bluetooth.forget")
        foreground: root.bar.foreground
        hoverColor: root.bar.foreground
        fontFamily: root.bar.fontFamily
        hasCursor: row.rowSelected && root.actionFocused
        onHovered: function(isHovered) {
          if (!isHovered) {
            if (rowMouse.containsMouse) root.actionFocused = false
            return
          }
          root.cursorActive = true
          root.focusSection = row.sectionName
          root.selectedIndex = row.rowIndex
          root.actionFocused = true
        }
        onClicked: {
          var dev = root.deviceFor(row)
          if (!dev) return
          root.forgetDevice(dev)
        }
      }
    }
  }
}
