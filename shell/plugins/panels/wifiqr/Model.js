// Parses omarchy-network-qr output: a "meta\t<iface>\t<security>\t<ssid>"
// header, then a square 0/1 module matrix. The SSID sits last so it may
// contain tabs. A malformed matrix returns empty rather than rendering a
// code that cannot scan.
function parseQrOutput(raw) {
  var lines = String(raw || "").trim().split(/\r?\n/).filter(function(line) { return line !== "" })
  var meta = { iface: "", security: "", ssid: "" }

  if (lines.length > 0 && lines[0].indexOf("meta\t") === 0) {
    var fields = lines.shift().split("\t")
    meta.iface = fields[1] || ""
    meta.security = fields[2] || ""
    meta.ssid = fields.slice(3).join("\t")
  }

  return { meta: meta, matrix: parseQrMatrix(lines) }
}

function parseQrMatrix(lines) {
  if (lines.length === 0) return { rows: [], size: 0 }

  var size = lines[0].length
  if (size !== lines.length) return { rows: [], size: 0 }

  for (var i = 0; i < lines.length; i++) {
    if (lines[i].length !== size || !/^[01]+$/.test(lines[i])) return { rows: [], size: 0 }
  }

  return { rows: lines, size: size }
}

function decodeBase64Utf8(b64) {
  var clean = String(b64 || "").replace(/[^A-Za-z0-9+/=]/g, "")
  if (clean.length === 0) return ""

  var alphabet = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/"
  var bytes = []
  var buffer = 0
  var bits = 0

  for (var i = 0; i < clean.length; i++) {
    var ch = clean.charAt(i)
    if (ch === "=") break
    var val = alphabet.indexOf(ch)
    if (val === -1) continue
    buffer = (buffer << 6) | val
    bits += 6
    if (bits >= 8) {
      bits -= 8
      bytes.push((buffer >> bits) & 0xff)
    }
  }

  var pct = ""
  for (var j = 0; j < bytes.length; j++) {
    var hex = bytes[j].toString(16)
    pct += "%" + (hex.length < 2 ? "0" + hex : hex)
  }

  try {
    return decodeURIComponent(pct)
  } catch (e) {
    var fallback = ""
    for (var k = 0; k < bytes.length; k++) fallback += String.fromCharCode(bytes[k])
    return fallback
  }
}

// Removes control characters (\0, \r, \n) and caps string length so malformed
// or hostile QR payloads cannot overflow UI bindings or inject lines into
// line-oriented nmcli stdin commands.
function sanitizeField(value, maxLen) {
  var str = String(value || "").replace(/[\u0000-\u001f\u007f]/g, "")
  if (maxLen > 0 && str.length > maxLen) str = str.substring(0, maxLen)
  return str
}

// Parses a standard WIFI: QR payload:
//   WIFI:T:WPA;S:MyNetwork;P:MyPassword;H:false;;
// Supports backslash-escaped characters (\\, \;, \:, \,, \") inside values.
function parseWifiQr(raw) {
  var input = String(raw || "").replace(/^[\r\n\s]+|[\r\n\s]+$/g, "")
  if (input.length === 0) return { valid: false, reason: "empty" }
  if (input.length > 1024) return { valid: false, reason: "notWifi" }
  if (!/^wifi:/i.test(input)) return { valid: false, reason: "notWifi" }

  var body = input.substring(5)
  var fields = {}
  var token = ""
  var escaped = false

  for (var i = 0; i < body.length; i++) {
    var c = body.charAt(i)
    if (escaped) {
      token += c
      escaped = false
    } else if (c === "\\") {
      escaped = true
    } else if (c === ";") {
      if (token.length > 0) {
        var colon = token.indexOf(":")
        if (colon > 0) {
          var key = token.substring(0, colon).toUpperCase()
          var val = token.substring(colon + 1)
          fields[key] = val
        }
        token = ""
      }
    } else {
      token += c
    }
  }

  if (token.length > 0) {
    var lastColon = token.indexOf(":")
    if (lastColon > 0) {
      fields[token.substring(0, lastColon).toUpperCase()] = token.substring(lastColon + 1)
    }
  }

  var ssid = sanitizeField(fields.S || "", 64)
  var password = sanitizeField(fields.P || "", 128)
  var rawType = sanitizeField(fields.T || "", 32).toUpperCase()
  var hiddenRaw = sanitizeField(fields.H || "", 16).toLowerCase()
  var hidden = hiddenRaw === "true" || hiddenRaw === "1" || hiddenRaw === "yes"

  if (ssid === "") {
    return { valid: false, reason: "missingSsid" }
  }

  var security = "nopass"
  if (rawType === "" || rawType === "NOPASS" || rawType === "NONE" || rawType === "OPEN" || rawType === "OWE") {
    security = "nopass"
  } else if (rawType === "SAE" || rawType === "WPA3" || rawType === "WPA3-SAE") {
    security = "SAE"
  } else if (rawType === "WPA" || rawType === "WPA2" || rawType === "WPA-PSK" || rawType === "WPA2-PSK" || rawType === "WPA/WPA2") {
    security = "WPA"
  } else if (rawType === "WEP") {
    security = "WEP"
  } else if (rawType.indexOf("EAP") !== -1 || rawType.indexOf("8021X") !== -1) {
    return { valid: false, reason: "enterpriseUnsupported", ssid: ssid }
  } else {
    security = "WPA"
  }

  // Some generators omit T: when a password is present, assuming WPA.
  if (rawType === "" && password !== "") {
    security = "WPA"
  }

  if (security !== "nopass" && password === "") {
    return { valid: false, reason: "missingPassword", ssid: ssid }
  }

  return {
    valid: true,
    ssid: ssid,
    password: security === "nopass" ? "" : password,
    security: security,
    hidden: hidden
  }
}

function securityLabel(security, openLabel) {
  if (security === "SAE") return "WPA3"
  if (security === "WPA") return "WPA"
  if (security === "WEP") return "WEP"
  return openLabel || "Open"
}

function parseScannerLine(line) {
  var text = String(line || "").replace(/\r?\n$/, "")
  if (text === "") return null

  var parts = text.split("\t")
  var kind = parts[0]

  if (kind === "camera") {
    return {
      type: "camera",
      device: sanitizeField(parts[1] || "", 64),
      label: sanitizeField(parts.slice(2).join("\t") || parts[1] || "", 80)
    }
  }
  if (kind === "active") {
    return {
      type: "active",
      device: sanitizeField(parts[1] || "", 64),
      label: sanitizeField(parts[2] || parts[1] || "", 80),
      framePath: sanitizeField(parts[3] || "", 256)
    }
  }
  if (kind === "ready") {
    return {
      type: "ready",
      framePath: sanitizeField(parts[1] || "", 256)
    }
  }
  if (kind === "qr") {
    return {
      type: "qr",
      raw: decodeBase64Utf8(parts[1] || "")
    }
  }
  if (kind === "error") {
    return {
      type: "error",
      code: sanitizeField(parts[1] || "cameraFailed", 64)
    }
  }

  return null
}

if (typeof module !== "undefined") {
  module.exports = {
    parseQrOutput: parseQrOutput,
    parseQrMatrix: parseQrMatrix,
    decodeBase64Utf8: decodeBase64Utf8,
    sanitizeField: sanitizeField,
    parseWifiQr: parseWifiQr,
    securityLabel: securityLabel,
    parseScannerLine: parseScannerLine
  }
}
