// The keyboard layout the lock screen names under the password field. Someone
// who switches between layouts (English and Czech, say) cannot see what a
// masked password is being typed in, and the layouts disagree on the digits and
// letters a password is likely to hold, so a wrong guess reads as a wrong
// password. A seat with a single layout gets nothing: there is no other layout
// to have typed in by mistake.
//
// Mirrors the keyboard selection in plugins/bar/widgets/KeyboardLayoutModel.js.
// The lock keeps its own copy because a cloned lock is copied without the bar.

// Hyprland reports more than keyboards as keyboards: the virtual keyboard fcitx5
// injects through keeps a layout of its own, and power buttons, lid switches,
// and vendor hotkey blocks carry the seat's list without anyone typing on them.
var UNTYPED_KEYBOARDS = /^(hl-virtual-keyboard|power-button|sleep-button|lid-switch|video-bus)|(-wmi-hotkeys|-wireless-radio-control)(-\d+)?$/

function isTypedKeyboard(name) {
  return !UNTYPED_KEYBOARDS.test(String(name || ""))
}

// The keyboard an activelayout event names, or "" for one nobody types on.
function eventKeyboardName(event) {
  var parts

  try {
    if (event && event.parse) parts = event.parse(2)
  } catch (error) {
  }

  if (!parts) parts = String(event && event.data ? event.data : "").split(",")

  var name = String(parts[0] || "")
  return isTypedKeyboard(name) ? name : ""
}

function layoutIndex(keyboard) {
  return (keyboard && keyboard.active_layout_index) || 0
}

// Reads `hyprctl -j devices` keyboards. Only the keyboard being typed on
// advances through the list, so the one a switch named wins, then the
// furthest-advanced. `multiple` is false for a single layout, which hides it.
function activeLayout(keyboards, namedByEvent) {
  var typed = (Array.isArray(keyboards) ? keyboards : []).filter(function (keyboard) {
    return keyboard && isTypedKeyboard(keyboard.name)
  })

  var keyboard = typed.find(function (candidate) {
    return namedByEvent && candidate.name === namedByEvent
  }) || typed.reduce(function (furthest, candidate) {
    return layoutIndex(candidate) > layoutIndex(furthest) ? candidate : furthest
  }, typed[0])

  if (!keyboard || !keyboard.active_keymap) return { name: "", multiple: false }

  return {
    name: String(keyboard.active_keymap),
    multiple: String(keyboard.layout || "").indexOf(",") !== -1
  }
}

if (typeof module !== "undefined") {
  module.exports = {
    activeLayout: activeLayout,
    eventKeyboardName: eventKeyboardName,
    isTypedKeyboard: isTypedKeyboard
  }
}
