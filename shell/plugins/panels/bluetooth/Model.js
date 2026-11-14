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

// PipeWire names a headset's audio nodes bluez_output.<AA_BB_CC_DD_EE_FF>.<n>
// (playback) and bluez_input.<address>.<n> (microphone), and publishes the
// negotiated codec on them as api.bluez5.codec. Matching on the name alone
// means picking these nodes out never reads properties before they are bound.
function parseBluezNodeName(name) {
  var match = /^bluez_(output|input)\.([0-9A-Fa-f]{2}(?:_[0-9A-Fa-f]{2}){5})(?:\.|$)/.exec(String(name || ""))
  if (!match) return null
  return { address: normalizedAddress(match[2]), output: match[1] === "output" }
}

function isBluezAudioNode(node) {
  return !!(node && !node.isStream && parseBluezNodeName(node.name))
}

var CODEC_LABELS = {
  sbc: "SBC", sbc_xq: "SBC-XQ", mpeg: "MP3", aac: "AAC", aac_eld: "AAC-ELD",
  aptx: "aptX", aptx_hd: "aptX HD", aptx_ll: "aptX LL", aptx_ll_duplex: "aptX LL",
  ldac: "LDAC", faststream: "FastStream", faststream_duplex: "FastStream",
  lc3plus_hr: "LC3plus HR", opus_05: "Opus", opus_05_51: "Opus 5.1",
  opus_05_71: "Opus 7.1", opus_05_duplex: "Opus", opus_05_pro: "Opus Pro",
  opus_g: "Opus", cvsd: "CVSD", msbc: "mSBC", lc3_swb: "LC3-SWB",
  lc3_a127: "LC3", lc3: "LC3", g722: "G.722"
}

// A codec a later PipeWire adds still shows, as its bounded uppercase name.
function codecLabel(codec) {
  var key = String(codec || "").trim().toLowerCase()
  if (key === "") return ""
  if (CODEC_LABELS.hasOwnProperty(key)) return CODEC_LABELS[key]
  return key.replace(/[^a-z0-9_]/g, "").slice(0, 24).toUpperCase()
}

// Address -> { codec, headset } from the headsets' audio nodes. Playback
// wins over the microphone: that is the codec the listener hears.
function codecSnapshot(nodes) {
  var list = toArray(nodes)
  var codecs = ({})
  for (var i = 0; i < list.length; i++) {
    var parsed = list[i] ? parseBluezNodeName(list[i].name) : null
    if (!parsed) continue
    var props = nodeProps(list[i])
    var codec = String(props["api.bluez5.codec"] || "")
    if (codec === "") continue
    var previous = codecs[parsed.address]
    if (previous && previous.output && !parsed.output) continue
    codecs[parsed.address] = {
      codec: codec,
      headset: String(props["api.bluez5.profile"] || "").indexOf("headset") === 0,
      output: parsed.output
    }
  }
  return codecs
}

function sameCodecs(a, b) {
  return JSON.stringify(a || {}) === JSON.stringify(b || {})
}

// `omarchy-bluetooth-codec <address>` prints mode, codec and selected lines,
// then one option line per A2DP codec the headset offers, best first.
function parseCodecStatus(raw) {
  var status = { mode: "", codec: "", selected: "auto", options: [], ldacQuality: "auto", headsetSwitch: "on" }
  var lines = String(raw || "").split("\n")
  for (var i = 0; i < lines.length && i < 64; i++) {
    var fields = lines[i].split("\t")
    var key = fields[0]
    var value = String(fields[1] || "").trim()
    if (!/^[a-z0-9_]{0,32}$/.test(value)) continue
    if (key === "mode") status.mode = value
    else if (key === "codec") status.codec = value
    else if (key === "selected" && value !== "") status.selected = value
    else if (key === "ldac-quality" && LDAC_QUALITIES.indexOf(value) !== -1) status.ldacQuality = value
    else if (key === "headset-switch" && (value === "on" || value === "off")) status.headsetSwitch = value
    else if (key === "option" && value !== "")
      status.options.push({ codec: value, label: String(fields[2] || "").trim().slice(0, 24) || codecLabel(value) })
  }
  return status
}

// LDAC's bitrate settings, as omarchy-bluetooth-codec names them, with the
// bitrate each pins (auto adapts to the signal).
var LDAC_QUALITIES = ["auto", "hq", "sq", "mq"]
var LDAC_KBPS = { hq: 990, sq: 660, mq: 330 }

function ldacKbps(quality) {
  return LDAC_KBPS[quality] || 0
}

// Under Automatic the header carries the live codec -- "CODEC: LDAC" -- the
// way the Wi-Fi band header does; once a codec is pinned the pills say it.
// In headset mode the codec follows the call profile, and the header says so.
function codecSectionTitle(selected, current, tr, headset) {
  var t = typeof tr === "function" ? tr : function(key, fallback) { return fallback }
  if (headset && current)
    return t("bluetooth.codecHeadsetMode", "CODEC: %1 · HEADSET MODE").replace("%1", codecLabel(current).toUpperCase())
  if (selected !== "auto" || !current) return t("bluetooth.codec", "CODEC")
  return t("bluetooth.codecCurrent", "CODEC: %1").replace("%1", codecLabel(current).toUpperCase())
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
function deviceRow(d, codecs) {
  if (!d) return null
  var codec = d.connected && codecs ? codecs[normalizedAddress(d.address)] : null
  return {
    codec: codec ? codec.codec : "",
    headset: codec ? codec.headset : false,
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
    parseBluezNodeName: parseBluezNodeName,
    isBluezAudioNode: isBluezAudioNode,
    codecLabel: codecLabel,
    codecSnapshot: codecSnapshot,
    sameCodecs: sameCodecs,
    parseCodecStatus: parseCodecStatus,
    codecSectionTitle: codecSectionTitle,
    LDAC_QUALITIES: LDAC_QUALITIES,
    ldacKbps: ldacKbps,
    sortedByLabel: sortedByLabel,
    deviceRow: deviceRow,
    deviceLists: deviceLists,
    cloneMap: cloneMap,
    pendingAction: pendingAction,
    withPendingAction: withPendingAction,
    visibleSections: visibleSections,
    sectionDevices: sectionDevices
  }
}
