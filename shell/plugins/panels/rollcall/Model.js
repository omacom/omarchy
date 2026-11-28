// Pure helpers for the roll call walkthrough: the omarchy-rollcall-test line
// protocol, the plan of steps, and the literal catalog keys every string the
// panel shows comes from (the i18n test only sees keys written out in full).

var RESULT_BY_CODE = { 0: "pass", 1: "fail", 77: "skip", 4: "verify" }

function resultForExit(code) {
  return RESULT_BY_CODE.hasOwnProperty(code) ? RESULT_BY_CODE[code] : "error"
}

// "::prompt:: speakers.left Listen for a tone" -> {kind, key, text}; anything
// unprefixed is log, and the last log line is the test's detail.
function parseLine(raw) {
  var line = String(raw === undefined || raw === null ? "" : raw).replace(/\r$/, "")
  var match = /^::(prompt|verify|progress|image)::\s?(.*)$/.exec(line)
  if (!match) return { kind: "log", text: line }
  var rest = match[2]
  if (match[1] === "progress") {
    var value = parseFloat(rest)
    return isFinite(value) ? { kind: "progress", value: Math.max(0, Math.min(1, value)) } : { kind: "log", text: line }
  }
  if (match[1] === "image") return { kind: "image", path: rest.trim() }
  var space = rest.indexOf(" ")
  var key = space < 0 ? rest : rest.slice(0, space)
  var text = space < 0 ? "" : rest.slice(space + 1)
  if (!/^[a-z][a-z0-9-]*(\.[a-z0-9-]+)+$/i.test(key)) return { kind: match[1], key: "", text: rest }
  return { kind: match[1], key: key, text: text }
}

// Only frames the test wrote into the roll call's own runtime directory are
// shown; anything else a line names is ignored.
function imageAllowed(path, stateDir) {
  var p = String(path || "")
  var dir = String(stateDir || "").replace(/\/+$/, "")
  if (dir === "" || p.indexOf("..") >= 0) return false
  return p.indexOf(dir + "/") === 0 && /\.(png|jpe?g|ppm)$/i.test(p)
}

function parseList(raw) {
  var parsed
  try { parsed = JSON.parse(String(raw || "")) } catch (e) { return [] }
  if (!Array.isArray(parsed)) return []
  var out = []
  for (var i = 0; i < parsed.length && out.length < 64; i++) {
    var t = parsed[i]
    if (!t || typeof t.id !== "string" || !/^[a-z][a-z0-9-]{0,40}$/.test(t.id)) continue
    out.push({
      id: t.id,
      title: String(t.title || t.id).slice(0, 80),
      kind: ["verify", "interact", "panel"].indexOf(t.kind) >= 0 ? t.kind : "interact",
      needs: typeof t.needs === "string" ? t.needs : "",
      applicable: t.applicable === true,
      reason: String(t.reason || "").slice(0, 160),
      result: ["pass", "fail", "skip", "pending"].indexOf(t.result) >= 0 ? t.result : "",
      detail: typeof t.detail === "string" ? t.detail.slice(0, 200) : ""
    })
  }
  return out
}

function parseReport(raw) {
  var parsed
  try { parsed = JSON.parse(String(raw || "")) } catch (e) { return null }
  if (!parsed || !Array.isArray(parsed.checks)) return null
  var counts = { pass: 0, fail: 0, skip: 0 }
  var failed = []
  for (var i = 0; i < parsed.checks.length; i++) {
    var c = parsed.checks[i]
    if (!c || !counts.hasOwnProperty(c.result)) continue
    counts[c.result]++
    if (c.result === "fail") failed.push({ id: String(c.id || ""), detail: String(c.detail || "").slice(0, 200) })
  }
  return { counts: counts, failed: failed }
}

function camel(id) {
  return String(id || "").replace(/-([a-z0-9])/g, function(m, c) { return c.toUpperCase() })
}


function translator(tr) {
  return typeof tr === "function" ? tr : function(key, english) { return english }
}

function titleText(tr, id, fallback) {
  var t = translator(tr)
  var table = {
    "speakers": t("rollcall.title.speakers"),
    "microphone": t("rollcall.title.microphone"),
    "headphones": t("rollcall.title.headphones"),
    "camera": t("rollcall.title.camera"),
    "volume-keys": t("rollcall.title.volumeKeys"),
    "mic-mute-key": t("rollcall.title.micMuteKey"),
    "brightness-keys": t("rollcall.title.brightnessKeys"),
    "keyboard-backlight-key": t("rollcall.title.keyboardBacklightKey"),
    "wireless-key": t("rollcall.title.wirelessKey"),
    "media-keys": t("rollcall.title.mediaKeys"),
    "caps-lock-light": t("rollcall.title.capsLockLight"),
    "external-display": t("rollcall.title.externalDisplay"),
    "usb-port": t("rollcall.title.usbPort"),
    "charger": t("rollcall.title.charger"),
    "bluetooth-device": t("rollcall.title.bluetoothDevice"),
    "suspend": t("rollcall.title.suspend"),
    "lid": t("rollcall.title.lid"),
    "fingerprint": t("rollcall.title.fingerprint"),
    "keyboard": t("rollcall.title.keyboard"),
    "touchpad": t("rollcall.title.touchpad"),
    "touchscreen": t("rollcall.title.touchscreen")
  }
  return table[id] || fallback || id
}

function stepsText(tr, id) {
  var t = translator(tr)
  var table = {
    "speakers": t("rollcall.steps.speakers"),
    "microphone": t("rollcall.steps.microphone"),
    "headphones": t("rollcall.steps.headphones"),
    "camera": t("rollcall.steps.camera"),
    "volume-keys": t("rollcall.steps.volumeKeys"),
    "mic-mute-key": t("rollcall.steps.micMuteKey"),
    "brightness-keys": t("rollcall.steps.brightnessKeys"),
    "keyboard-backlight-key": t("rollcall.steps.keyboardBacklightKey"),
    "wireless-key": t("rollcall.steps.wirelessKey"),
    "media-keys": t("rollcall.steps.mediaKeys"),
    "caps-lock-light": t("rollcall.steps.capsLockLight"),
    "external-display": t("rollcall.steps.externalDisplay"),
    "usb-port": t("rollcall.steps.usbPort"),
    "charger": t("rollcall.steps.charger"),
    "bluetooth-device": t("rollcall.steps.bluetoothDevice"),
    "suspend": t("rollcall.steps.suspend"),
    "lid": t("rollcall.steps.lid"),
    "fingerprint": t("rollcall.steps.fingerprint"),
    "keyboard": t("rollcall.steps.keyboard"),
    "touchpad": t("rollcall.steps.touchpad"),
    "touchscreen": t("rollcall.steps.touchscreen")
  }
  return table[id] || ""
}

function needsText(tr, needs) {
  var t = translator(tr)
  var table = {
    "headphones": t("rollcall.needs.headphones"),
    "usb-device": t("rollcall.needs.usbDevice"),
    "external-display": t("rollcall.needs.externalDisplay"),
    "bluetooth-device": t("rollcall.needs.bluetoothDevice"),
    "charger": t("rollcall.needs.charger"),
    "enrolled-finger": t("rollcall.needs.enrolledFinger")
  }
  return table[needs] || ""
}

// What the test said, in the current language when the catalog has it.
// PROMPTS is filled from omarchy-rollcall-test's keys; an unknown key shows
// the English the test printed.
function promptText(tr, key, english) {
  var table = prompts(tr)
  return table.hasOwnProperty(key) && table[key] ? table[key] : english
}

function prompts(tr) {
  var t = translator(tr)
  return {
    "speakers.volume": t("rollcall.prompt.speakers.volume"),
    "speakers.left": t("rollcall.prompt.speakers.left"),
    "speakers.right": t("rollcall.prompt.speakers.right"),
    "speakers.question": t("rollcall.prompt.speakers.question"),
    "microphone.speak": t("rollcall.prompt.microphone.speak"),
    "microphone.playback": t("rollcall.prompt.microphone.playback"),
    "microphone.question": t("rollcall.prompt.microphone.question"),
    "headphones.unplug": t("rollcall.prompt.headphones.unplug"),
    "headphones.plug": t("rollcall.prompt.headphones.plug"),
    "headphones.listen": t("rollcall.prompt.headphones.listen"),
    "headphones.question": t("rollcall.prompt.headphones.question"),
    "camera.look": t("rollcall.prompt.camera.look"),
    "camera.question": t("rollcall.prompt.camera.question"),
    "volume-keys.up": t("rollcall.prompt.volumeKeys.up"),
    "volume-keys.down": t("rollcall.prompt.volumeKeys.down"),
    "volume-keys.mute": t("rollcall.prompt.volumeKeys.mute"),
    "volume-keys.unmute": t("rollcall.prompt.volumeKeys.unmute"),
    "mic-mute-key.press": t("rollcall.prompt.micMuteKey.press"),
    "mic-mute-key.again": t("rollcall.prompt.micMuteKey.again"),
    "brightness-keys.up": t("rollcall.prompt.brightnessKeys.up"),
    "brightness-keys.down": t("rollcall.prompt.brightnessKeys.down"),
    "brightness-keys.question": t("rollcall.prompt.brightnessKeys.question"),
    "keyboard-backlight-key.press": t("rollcall.prompt.keyboardBacklightKey.press"),
    "wireless-key.press": t("rollcall.prompt.wirelessKey.press"),
    "wireless-key.again": t("rollcall.prompt.wirelessKey.again"),
    "media-keys.start": t("rollcall.prompt.mediaKeys.start"),
    "media-keys.pause": t("rollcall.prompt.mediaKeys.pause"),
    "media-keys.resume": t("rollcall.prompt.mediaKeys.resume"),
    "media-keys.question": t("rollcall.prompt.mediaKeys.question"),
    "caps-lock-light.press": t("rollcall.prompt.capsLockLight.press"),
    "caps-lock-light.again": t("rollcall.prompt.capsLockLight.again"),
    "caps-lock-light.question": t("rollcall.prompt.capsLockLight.question"),
    "external-display.unplug-first": t("rollcall.prompt.externalDisplay.unplugFirst"),
    "external-display.plug": t("rollcall.prompt.externalDisplay.plug"),
    "external-display.check-unplug": t("rollcall.prompt.externalDisplay.checkUnplug"),
    "external-display.question": t("rollcall.prompt.externalDisplay.question"),
    "usb-port.plug": t("rollcall.prompt.usbPort.plug"),
    "charger.plug": t("rollcall.prompt.charger.plug"),
    "charger.unplug": t("rollcall.prompt.charger.unplug"),
    "bluetooth-device.connect": t("rollcall.prompt.bluetoothDevice.connect"),
    "bluetooth-device.listen": t("rollcall.prompt.bluetoothDevice.listen"),
    "bluetooth-device.question": t("rollcall.prompt.bluetoothDevice.question"),
    "suspend.countdown": t("rollcall.prompt.suspend.countdown"),
    "lid.close": t("rollcall.prompt.lid.close"),
    "fingerprint.touch": t("rollcall.prompt.fingerprint.touch")
  }
}

if (typeof module !== "undefined") {
  module.exports = {
    resultForExit: resultForExit,
    parseLine: parseLine,
    imageAllowed: imageAllowed,
    parseList: parseList,
    parseReport: parseReport,
    titleText: titleText,
    stepsText: stepsText,
    needsText: needsText,
    promptText: promptText
  }
}
