function deviceLabel(device) {
  if (!device) return ""
  return String(device.deviceName || device.name || "").trim()
}

function toArray(values) {
  if (!values) return []
  if (Array.isArray(values)) return values.slice()

  var length = Number(values.length || 0)
  if (!isFinite(length) || length <= 0) return []

  var list = []
  for (var i = 0; i < length; i++) list.push(values[i])
  return list
}

function isUuidLike(value) {
  var text = String(value || "").trim()
  if (text === "") return false
  return /^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$/i.test(text)
    || /^[0-9a-f]{32}$/i.test(text)
    || /^0x[0-9a-f]{4,32}$/i.test(text)
    || /^0000[0-9a-f]{4}-0000-1000-8000-00805f9b34fb$/i.test(text)
}

function isAddressLike(value) {
  var text = String(value || "").trim()
  return /^([0-9a-f]{2}[:-]){5}[0-9a-f]{2}$/i.test(text)
}

function normalizedAddress(value) {
  return String(value || "").trim().toLowerCase().replace(/[^0-9a-f]/g, "")
}

function hasHumanName(device) {
  var label = deviceLabel(device)
  return label !== "" && !isUuidLike(label) && !isAddressLike(label)
}

function nodeProps(node) {
  return node && node.ready && node.properties ? node.properties : {}
}

function nodeText(node) {
  var props = nodeProps(node)
  return [
    node ? node.name : "",
    node ? node.description : "",
    node ? node.nickname : "",
    node ? node.nick : "",
    props["node.name"],
    props["node.description"],
    props["node.nick"],
    props["device.name"],
    props["device.description"],
    props["device.product.name"],
    props["device.alias"],
    props["device.string"],
    props["api.bluez5.address"],
    props["bluez5.address"],
    props["media.name"]
  ].join(" ").toLowerCase()
}

function bluetoothSinkMatchesDevice(node, device) {
  if (!node || !node.isSink || node.isStream || !device) return false

  var address = normalizedAddress(device.address)
  var text = nodeText(node)
  if (address !== "" && normalizedAddress(text).indexOf(address) !== -1) return true

  var label = deviceLabel(device).toLowerCase()
  return label !== "" && text.indexOf(label) !== -1
}

function sortedByLabel(devices) {
  var list = toArray(devices)
  list.sort(function(a, b) { return deviceLabel(a).localeCompare(deviceLabel(b)) })
  return list
}

// Primitives-only projection of a BlueZ device for list-model rows. Holding
// the Device QObject in model data puts a live wrapper into every delegate's
// var property, and BlueZ churn (discovery timeouts, unpair) can destroy the
// object while a delegate is still incubating, which segfaults quickshell.
// Actions resolve the backend object via Panel.deviceFor().
function deviceRow(d) {
  if (!d) return null
  return {
    address: d.address || "",
    name: d.name || "",
    deviceName: d.deviceName || "",
    connected: !!d.connected,
    paired: !!(d.paired || d.bonded || d.trusted),
    state: d.state !== undefined ? d.state : -1,
    batteryAvailable: !!d.batteryAvailable,
    battery: d.battery !== undefined ? d.battery : 0,
    pairing: !!d.pairing
  }
}

function deviceLists(devices) {
  var values = toArray(devices)
  var connected = []
  var known = []
  var discovered = []

  for (var i = 0; i < values.length; i++) {
    var d = values[i]
    if (!d || !hasHumanName(d)) continue
    if (d.connected) connected.push(d)
    else if (d.paired || d.bonded || d.trusted) known.push(d)
    else discovered.push(d)
  }

  return {
    connected: sortedByLabel(connected),
    known: sortedByLabel(known),
    discovered: sortedByLabel(discovered)
  }
}

// Keeps every device in the section and position it was last drawn in, so rows
// never slide under the pointer; newcomers go last. `previous` null sorts afresh.
function steadyLists(lists, previous, scanShown) {
  var sections = ["connected", "known", "discovered"]
  var byAddress = {}
  var natural = {}
  for (var s = 0; s < sections.length; s++) {
    var list = (lists && lists[sections[s]]) || []
    for (var i = 0; i < list.length; i++) {
      byAddress[list[i].address] = list[i]
      natural[list[i].address] = sections[s]
    }
  }

  var out = { connected: [], known: [], discovered: [] }
  var placed = {}
  function place(section, address) {
    out[section].push(byAddress[address])
    placed[address] = true
  }

  if (previous) {
    for (var p = 0; p < sections.length; p++) {
      var section = sections[p]
      var before = previous[section] || []
      for (var j = 0; j < before.length; j++) {
        var address = typeof before[j] === "string" ? before[j] : (before[j] && before[j].address)
        if (!address || !byAddress[address] || placed[address]) continue
        // A forget removes the row; hidden scan results take nothing with them.
        if (section !== "discovered" && natural[address] === "discovered") continue
        if (section === "discovered" && !scanShown && natural[address] !== "discovered") continue
        place(section, address)
      }
    }
  }

  // Mid-scan newcomers go to the bottom of the list, whatever they are, so no row moves down.
  var last = previous && scanShown ? "discovered" : ""
  for (var n = 0; n < sections.length; n++) {
    var fresh = (lists && lists[sections[n]]) || []
    for (var k = 0; k < fresh.length; k++) {
      if (!placed[fresh[k].address]) place(last || sections[n], fresh[k].address)
    }
  }

  return out
}

function cloneMap(map) {
  var next = ({})
  for (var key in map || {}) next[key] = map[key]
  return next
}

function pendingAction(actions, address) {
  return address && actions && actions[address] ? actions[address] : ""
}

function withPendingAction(actions, address, action) {
  var next = cloneMap(actions)
  if (!address) return next
  if (action) next[address] = action
  else delete next[address]
  return next
}

// Each pending action has its own deadline, so a new click never extends another row's.
function expiredPending(deadlines, now) {
  var expired = []
  for (var address in deadlines || {}) {
    if (deadlines[address] <= now) expired.push(address)
  }
  return expired
}

function nextDeadline(deadlines) {
  var next = 0
  for (var address in deadlines || {}) {
    if (next === 0 || deadlines[address] < next) next = deadlines[address]
  }
  return next
}

function visibleSections(lists, discovering) {
  var sections = []
  if (lists && lists.connected && lists.connected.length > 0) sections.push("connected")
  if (lists && lists.known && lists.known.length > 0) sections.push("known")
  if (discovering && lists && lists.discovered && lists.discovered.length > 0) sections.push("discovered")
  return sections
}

function sectionDevices(lists, section) {
  if (!lists) return []
  if (section === "connected") return lists.connected || []
  if (section === "known") return lists.known || []
  if (section === "discovered") return lists.discovered || []
  return []
}

if (typeof module !== "undefined") {
  module.exports = {
    deviceLabel: deviceLabel,
    toArray: toArray,
    isUuidLike: isUuidLike,
    isAddressLike: isAddressLike,
    normalizedAddress: normalizedAddress,
    hasHumanName: hasHumanName,
    nodeProps: nodeProps,
    nodeText: nodeText,
    bluetoothSinkMatchesDevice: bluetoothSinkMatchesDevice,
    sortedByLabel: sortedByLabel,
    deviceRow: deviceRow,
    deviceLists: deviceLists,
    cloneMap: cloneMap,
    pendingAction: pendingAction,
    withPendingAction: withPendingAction,
    steadyLists: steadyLists,
    expiredPending: expiredPending,
    nextDeadline: nextDeadline,
    visibleSections: visibleSections,
    sectionDevices: sectionDevices
  }
}
