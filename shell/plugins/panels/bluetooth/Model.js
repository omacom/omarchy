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

// A row's identity across rebuilds: the section it sits in plus its BlueZ
// address. A device that moves between sections is removed and inserted again,
// which is what a ListView needs to see anyway.
function scrollRowKey(section, address) {
  return String(section || "") + ":" + String(address || "")
}

function scrollRowValues(row) {
  var dev = (row && row.dev) || {}
  return {
    key: scrollRowKey(row.section, dev.address),
    address: dev.address || "",
    name: dev.name || "",
    deviceName: dev.deviceName || "",
    connected: !!dev.connected,
    devState: dev.state !== undefined ? dev.state : -1,
    batteryAvailable: !!dev.batteryAvailable,
    battery: dev.battery !== undefined ? dev.battery : 0,
    pairing: !!dev.pairing,
    section: row.section || "",
    indexInSection: row.indexInSection !== undefined ? row.indexInSection : 0,
    first: row.first === true
  }
}

// Apply the difference between a ListModel's rows and `rows` in place.
// Replacing a ListView's model resets its scroll position to the top, and the
// panel rebuilds the desired rows every time BlueZ reports a device, so the
// view has to keep its model across updates. Rows keep their identity: an
// unchanged row is never removed and re-added, and only its changed fields
// are written.
function syncScrollRows(model, rows) {
  var desired = []
  var wanted = ({})
  for (var i = 0; i < rows.length; i++) {
    var values = scrollRowValues(rows[i])
    desired.push(values)
    wanted[values.key] = true
  }

  for (var r = model.count - 1; r >= 0; r--) {
    if (!wanted[model.get(r).key]) model.remove(r)
  }

  for (var k = 0; k < desired.length; k++) {
    var want = desired[k]
    var current = k < model.count ? model.get(k) : null
    if (!current || current.key !== want.key) {
      var found = -1
      for (var m = k + 1; m < model.count; m++) {
        if (model.get(m).key === want.key) { found = m; break }
      }
      if (found >= 0) model.move(found, k, 1)
      else model.insert(k, want)
    }
    updateScrollRow(model, k, want)
  }
}

function updateScrollRow(model, index, want) {
  var current = model.get(index)
  for (var field in want) {
    if (current[field] !== want[field]) {
      model.set(index, want)
      return
    }
  }
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
    visibleSections: visibleSections,
    sectionDevices: sectionDevices,
    scrollRowKey: scrollRowKey,
    scrollRowValues: scrollRowValues,
    syncScrollRows: syncScrollRows
  }
}
