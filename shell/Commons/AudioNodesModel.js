// Audio node rules the bar and the audio panel share. Plain functions, so the
// tests load this file in Node.

// The level meters the shell runs itself: Quickshell's peak monitor stream
// (named after the shell or after its stream, depending on the PipeWire
// version) and omarchy-audio-source-level's recording. None is an app using
// the input.
function isShellLevelMeter(name) {
  var value = String(name || "")
  return value === "quickshell" || value === "quickshell-peak-monitor" || value === "omarchy-audio-level"
}

function wholeNamePattern(pattern) {
  if (typeof pattern !== "string" || pattern === "") return null
  try {
    return new RegExp("^(?:" + pattern + ")$")
  } catch (e) {
    return null
  }
}

// A platform's audio hints, which its own package ships in the platform root
// (/usr/share/omarchy-platform/audio.json, read by AudioNodes.qml; Omarchy
// ships none): nodes of its audio processing that are neither devices nor apps.
//
//   { "hidden": ["<pattern>", ...],
//     "replaced": [{ "node": "<pattern>", "by": "<pattern>" }, ...] }
//
// A pattern is a regular expression matched against a whole node.name. A
// hidden node is never listed as an output, an input or an app stream, and
// never counts as a recording; a replaced node is hidden while a node matching
// "by" exists. Missing or malformed text means no hints, and an invalid pattern
// or entry is skipped.
function parsePlatformAudio(text) {
  var hints = { hidden: [], replaced: [] }
  var data = null
  try {
    data = JSON.parse(String(text || ""))
  } catch (e) {
    return hints
  }
  if (!data || typeof data !== "object" || Array.isArray(data)) return hints

  var hidden = Array.isArray(data.hidden) ? data.hidden : []
  for (var i = 0; i < hidden.length; i++) {
    var pattern = wholeNamePattern(hidden[i])
    if (pattern) hints.hidden.push(pattern)
  }

  var replaced = Array.isArray(data.replaced) ? data.replaced : []
  for (var j = 0; j < replaced.length; j++) {
    var entry = replaced[j]
    if (!entry || typeof entry !== "object") continue
    var node = wholeNamePattern(entry.node)
    var by = wholeNamePattern(entry.by)
    if (node && by) hints.replaced.push({ node: node, by: by })
  }
  return hints
}

// Whether the platform's hints hide a node, given the names of every node now
// in the graph (for "replaced").
function platformHidesNode(name, hints, nodeNames) {
  var value = String(name || "")
  if (value === "" || !hints) return false
  var hidden = hints.hidden || []
  for (var i = 0; i < hidden.length; i++)
    if (hidden[i].test(value)) return true

  var replaced = hints.replaced || []
  var names = Array.isArray(nodeNames) ? nodeNames : []
  for (var j = 0; j < replaced.length; j++) {
    if (!replaced[j].node.test(value)) continue
    for (var k = 0; k < names.length; k++) {
      var other = String(names[k] || "")
      if (other !== value && replaced[j].by.test(other)) return true
    }
  }
  return false
}

// `wpctl get-volume <id>` prints "Volume: 0.50", with " [MUTED]" when muted, on
// the same cubic scale as PwNodeAudio.volume.
function parseWpctlVolume(text) {
  var match = /^Volume:\s+([0-9]+(?:\.[0-9]+)?)(\s+\[MUTED\])?$/.exec(String(text || "").trim())
  if (!match) return null
  return { volume: parseFloat(match[1]), muted: !!match[2] }
}

if (typeof module !== "undefined") {
  module.exports = {
    isShellLevelMeter: isShellLevelMeter,
    parsePlatformAudio: parsePlatformAudio,
    platformHidesNode: platformHidesNode,
    parseWpctlVolume: parseWpctlVolume
  }
}
