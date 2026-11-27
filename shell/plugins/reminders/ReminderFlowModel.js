function validMinutes(value) {
  var minutes = String(value || "").trim()
  return /^[0-9]+$/.test(minutes) && Number(minutes) > 0 ? minutes : ""
}

// A clock time: "14:30", "2:30pm", "2pm", "at 9". Bare digits stay minutes,
// so "15" never lands here; parseFirstStep tries validMinutes first.
function parseClockTime(value) {
  var text = String(value || "").trim()
  var explicitAt = /^(?:at|@)\s+/i.test(text)
  text = text.replace(/^(?:at|@)\s+/i, "")

  var hours = -1
  var minutes = 0
  var meridiem = null
  var match = text.match(/^(\d{1,2}):(\d{2})(?:\s*([aApP])\.?\s?[mM]\.?)?$/)
  if (match) {
    hours = Number(match[1])
    minutes = Number(match[2])
    meridiem = match[3] ? match[3].toLowerCase() : null
  } else {
    match = text.match(/^(\d{1,2})\s*([aApP])\.?\s?[mM]\.?$/)
    if (match) {
      hours = Number(match[1])
      meridiem = match[2].toLowerCase()
    } else if (explicitAt) {
      match = text.match(/^(\d{1,2})$/)
      if (match) hours = Number(match[1])
    }
  }
  if (hours < 0 || minutes > 59) return null
  if (meridiem) {
    if (hours < 1 || hours > 12) return null
    hours = meridiem === "a" ? hours % 12 : hours % 12 + 12
  } else if (hours > 23) {
    return null
  }
  var label = ("0" + hours).slice(-2) + ":" + ("0" + minutes).slice(-2)
  return { hours: hours, minutes: minutes, label: label }
}

function parseFirstStep(value) {
  var text = String(value || "").trim()
  if (!text) return null
  var minutes = validMinutes(text)
  if (minutes) return { kind: "minutes", arg: minutes }
  var at = parseClockTime(text)
  if (at) return { kind: "at", arg: at.label }
  return null
}

function reminderArgs(firstStep, message) {
  var parsed = firstStep && typeof firstStep === "object" ? firstStep : parseFirstStep(firstStep)
  if (!parsed || (parsed.kind !== "minutes" && parsed.kind !== "at") || typeof parsed.arg !== "string") return []
  var args = [parsed.arg]
  var text = String(message || "")
  if (text.length > 0) args.push(text)
  return args
}

if (typeof module !== "undefined") {
  module.exports = {
    validMinutes: validMinutes,
    parseClockTime: parseClockTime,
    parseFirstStep: parseFirstStep,
    reminderArgs: reminderArgs
  }
}
