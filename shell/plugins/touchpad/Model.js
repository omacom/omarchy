// Settings model for the touchpad window. The window keeps the user's choices
// as a sparse document: only the keys they changed are written to
// ~/.config/omarchy/touchpad.json, and default/hypr/touchpad.lua validates and
// applies it. Everything else here derives what to display from that document,
// the running Hyprland options, and the user's own ~/.config/hypr/input.lua.

var SETTINGS = {
  natural_scroll: {
    type: "bool",
    label: "Natural scrolling",
    description: "Content follows your fingers, like on a phone",
    fallback: false
  },
  scroll_factor: {
    type: "number",
    label: "Scroll speed",
    description: "How far content moves for each swipe",
    min: 0.1,
    max: 2,
    step: 0.05,
    decimals: 2,
    suffix: "×",
    fallback: 0.4
  },
  scroll_method: {
    type: "choice",
    pointer: true,
    label: "Scroll with",
    options: [
      { value: "2fg", label: "Two fingers" },
      { value: "edge", label: "Right edge" },
      { value: "no_scroll", label: "Off" }
    ],
    fallback: "2fg"
  },
  tap_to_click: {
    type: "bool",
    label: "Tap to click",
    description: "A light tap clicks without pressing the pad down",
    fallback: true
  },
  tap_button_map: {
    type: "choice",
    label: "Two-finger tap",
    description: "Three fingers then do the other one",
    options: [
      { value: "lrm", label: "Right click" },
      { value: "lmr", label: "Middle click" }
    ],
    fallback: "lrm"
  },
  clickfinger_behavior: {
    type: "bool",
    label: "Two-finger click to right-click",
    description: "Off uses the bottom-right corner of the pad instead",
    fallback: true
  },
  middle_button_emulation: {
    type: "bool",
    label: "Middle click emulation",
    description: "Press left and right together for a middle click",
    fallback: false
  },
  tap_and_drag: {
    type: "bool",
    label: "Tap and drag",
    description: "Tap, then touch again and move to drag",
    fallback: true
  },
  drag_lock: {
    type: "choice",
    integer: true,
    label: "Drag lock",
    description: "Keep a tap-drag going after you lift your finger",
    options: [
      { value: "0", label: "Off" },
      { value: "1", label: "Brief pause" },
      { value: "2", label: "Until tapped" }
    ],
    fallback: 0
  },
  drag_3fg: {
    type: "choice",
    integer: true,
    label: "Multi-finger drag",
    description: "Drag windows and selections without pressing",
    options: [
      { value: "0", label: "Off" },
      { value: "1", label: "Three fingers" },
      { value: "2", label: "Four fingers" }
    ],
    fallback: 0
  },
  disable_while_typing: {
    type: "bool",
    label: "Disable while typing",
    description: "Ignore palm touches while you type",
    fallback: true
  },
  sensitivity: {
    type: "number",
    pointer: true,
    label: "Pointer speed",
    description: "Only touchpads change; mice keep their own speed",
    min: -1,
    max: 1,
    step: 0.05,
    decimals: 2,
    signed: true,
    fallback: 0
  },
  accel_profile: {
    type: "choice",
    pointer: true,
    label: "Acceleration",
    description: "Adaptive moves further on quick swipes; flat is constant",
    options: [
      { value: "adaptive", label: "Adaptive" },
      { value: "flat", label: "Flat" }
    ],
    fallback: "adaptive"
  },
  left_handed: {
    type: "bool",
    pointer: true,
    label: "Left-handed",
    description: "Swap the left and right buttons",
    fallback: false
  }
}

var GESTURE_SETTINGS = {
  workspace_swipe_invert: {
    type: "bool",
    label: "Invert workspace swipe",
    description: "Swipe toward the workspace you want instead of pushing the current one away",
    fallback: true
  },
  workspace_swipe_distance: {
    type: "number",
    integer: true,
    label: "Swipe distance",
    description: "How far a swipe travels before the workspace fully changes",
    min: 100,
    max: 1000,
    step: 25,
    decimals: 0,
    suffix: " px",
    fallback: 300
  },
  workspace_swipe_create_new: {
    type: "bool",
    label: "Create workspaces at the end",
    description: "Swiping past the last workspace opens a new one",
    fallback: true
  },
  workspace_swipe_forever: {
    type: "bool",
    label: "Swipe across many workspaces",
    description: "Keep moving through workspaces in one long swipe",
    fallback: false
  },
  workspace_swipe_direction_lock: {
    type: "bool",
    label: "Lock swipe direction",
    description: "A swipe that starts sideways stays sideways",
    fallback: true
  }
}

var PAGES = [
  { id: "scrolling", label: "Scrolling", icon: "󰡏" },
  { id: "clicking", label: "Tap & Click", icon: "󰍽" },
  { id: "pointer", label: "Pointer", icon: "󰇀" },
  { id: "gestures", label: "Gestures", icon: "󰆾" },
  { id: "apps", label: "App Scrolling", icon: "󰀻" },
  { id: "devices", label: "Devices", icon: "󰟸" }
]

var PAGE_SETTINGS = {
  scrolling: ["natural_scroll", "scroll_factor", "scroll_method"],
  clicking: ["tap_to_click", "tap_button_map", "clickfinger_behavior", "middle_button_emulation", "tap_and_drag", "drag_lock", "drag_3fg"],
  pointer: ["sensitivity", "accel_profile", "disable_while_typing", "left_handed"]
}

// What a device can override on its own, in display order.
var DEVICE_SETTINGS = ["natural_scroll", "scroll_factor", "sensitivity", "accel_profile", "tap_to_click", "left_handed"]

var FINGERS = [
  { value: "2", label: "Two" },
  { value: "3", label: "Three" },
  { value: "4", label: "Four" },
  { value: "5", label: "Five" }
]

var DIRECTIONS = [
  { value: "horizontal", label: "Sideways" },
  { value: "vertical", label: "Vertical" },
  { value: "swipe", label: "Any way" },
  { value: "left", label: "Left" },
  { value: "right", label: "Right" },
  { value: "up", label: "Up" },
  { value: "down", label: "Down" },
  { value: "pinch", label: "Pinch" },
  { value: "pinchin", label: "Pinch in" },
  { value: "pinchout", label: "Pinch out" }
]

var MODIFIERS = [
  { value: "", label: "No key" },
  { value: "SUPER", label: "Super" },
  { value: "ALT", label: "Alt" },
  { value: "CTRL", label: "Ctrl" },
  { value: "SHIFT", label: "Shift" }
]

// Keep the names in sync with M.actions in default/hypr/touchpad.lua.
var ACTIONS = [
  { value: "workspace", label: "Workspaces" },
  { value: "workspace_next", label: "Next workspace" },
  { value: "workspace_previous", label: "Previous workspace" },
  { value: "focus_left", label: "Focus left" },
  { value: "focus_right", label: "Focus right" },
  { value: "focus_up", label: "Focus up" },
  { value: "focus_down", label: "Focus down" },
  { value: "move", label: "Move window" },
  { value: "resize", label: "Resize window" },
  { value: "float", label: "Toggle floating" },
  { value: "fullscreen", label: "Fullscreen" },
  { value: "maximize", label: "Maximize" },
  { value: "close", label: "Close window" },
  { value: "special", label: "Scratchpad" },
  { value: "zoom", label: "Zoom screen" },
  { value: "scroll_move", label: "Scroll layout" },
  { value: "menu", label: "Omarchy menu" },
  { value: "notifications", label: "Notification history" }
]

var GESTURE_PRESETS = [
  { label: "Swipe between workspaces", binding: { fingers: 3, direction: "horizontal", action: "workspace" } },
  { label: "Swipe up for the menu", binding: { fingers: 4, direction: "up", action: "menu" } },
  { label: "Swipe down to close", binding: { fingers: 4, direction: "down", action: "close" } },
  { label: "Pinch to zoom the screen", binding: { fingers: 3, direction: "pinch", action: "zoom" } },
  { label: "Swipe up for scratchpad", binding: { fingers: 3, direction: "up", action: "special" } }
]

// Keep in sync with M.default_apps in default/hypr/touchpad.lua.
var DEFAULT_APPS = [
  { match: "(Alacritty|kitty)", scroll: 1.5 },
  { match: "foot", scroll: 2.0 },
  { match: "com.mitchellh.ghostty", scroll: 0.2 }
]

function loaderBool() {
  return { type: "bool" }
}

function loaderNumber(min, max, integer) {
  return { type: "number", min: min, max: max, integer: integer === true }
}

function loaderChoice() {
  return { type: "choice", options: Array.prototype.map.call(arguments, function(value) { return { value: value } }) }
}

// Everything default/hypr/touchpad.lua accepts, which is wider than what the
// window offers: hand-edited keys it does not show and values beyond its
// sliders still apply, so saving an unrelated edit must keep them. Keep in
// sync with M.touchpad_schema, M.pointer_schema, and
// M.gesture_settings_schema there.
var LOADER_SETTINGS = {
  natural_scroll: loaderBool(),
  scroll_factor: loaderNumber(0.05, 5),
  tap_to_click: loaderBool(),
  tap_button_map: loaderChoice("lrm", "lmr"),
  clickfinger_behavior: loaderBool(),
  middle_button_emulation: loaderBool(),
  disable_while_typing: loaderBool(),
  tap_and_drag: loaderBool(),
  drag_lock: loaderNumber(0, 2, true),
  drag_3fg: loaderNumber(0, 2, true),
  flip_x: loaderBool(),
  flip_y: loaderBool(),
  sensitivity: loaderNumber(-1, 1),
  accel_profile: loaderChoice("adaptive", "flat"),
  left_handed: loaderBool(),
  scroll_method: loaderChoice("2fg", "edge", "on_button_down", "no_scroll")
}

var LOADER_GESTURE_SETTINGS = {
  workspace_swipe_distance: loaderNumber(50, 2000, true),
  workspace_swipe_invert: loaderBool(),
  workspace_swipe_create_new: loaderBool(),
  workspace_swipe_forever: loaderBool(),
  workspace_swipe_cancel_ratio: loaderNumber(0, 1),
  workspace_swipe_min_speed_to_force: loaderNumber(0, 200, true),
  workspace_swipe_direction_lock: loaderBool()
}

function isObject(value) {
  return value !== null && typeof value === "object" && !Array.isArray(value)
}

function copy(value) {
  return value === undefined ? undefined : JSON.parse(JSON.stringify(value))
}

function labelFor(options, value) {
  var wanted = String(value)
  for (var i = 0; i < options.length; i++) {
    if (options[i].value === wanted) return options[i].label
  }
  return wanted
}

function validValue(spec, value) {
  if (!spec) return false
  if (spec.type === "bool") return typeof value === "boolean"
  if (spec.type === "number") {
    if (typeof value !== "number" || !isFinite(value)) return false
    if (spec.integer && Math.floor(value) !== value) return false
    return value >= spec.min && value <= spec.max
  }
  if (spec.type === "choice") {
    for (var i = 0; i < spec.options.length; i++) {
      var option = spec.options[i].value
      if (spec.integer ? Number(option) === value : option === value) return true
    }
  }
  return false
}

function pickValid(source, specs) {
  var result = {}
  if (!isObject(source)) return result
  for (var key in specs) {
    if (source[key] !== undefined && validValue(specs[key], source[key])) result[key] = source[key]
  }
  return result
}

function validText(value, limit) {
  return typeof value === "string" && value !== "" && value.length <= limit && !/[\u0000-\u001f\u007f]/.test(value)
}

function validBinding(binding) {
  if (!isObject(binding)) return false
  if ([2, 3, 4, 5].indexOf(binding.fingers) < 0) return false
  if (!DIRECTIONS.some(function(d) { return d.value === binding.direction })) return false
  if (!ACTIONS.some(function(a) { return a.value === binding.action })) return false
  if (binding.mods !== undefined && !MODIFIERS.some(function(m) { return m.value === binding.mods })) return false
  return true
}

// Scale and a scratchpad name are not offered here but the loader honours
// them, so a binding keeps them as long as they are valid there.
function cleanBinding(binding) {
  var result = { fingers: binding.fingers, direction: binding.direction, action: binding.action }
  if (binding.mods) result.mods = binding.mods
  if (typeof binding.scale === "number" && binding.scale >= 0.1 && binding.scale <= 10) result.scale = binding.scale
  if (binding.action === "special" && validText(binding.workspace_name, 64) && /^[A-Za-z0-9_-]+$/.test(binding.workspace_name)) {
    result.workspace_name = binding.workspace_name
  }
  return result
}

// The saved document, reduced to what the Lua side will accept. Anything the
// loader would drop is dropped here too, so the window never shows a setting
// as saved when Hyprland is ignoring it, and anything it keeps is kept here.
function normalize(data) {
  var source = isObject(data) ? data : {}
  var state = {
    touchpad: pickValid(source.touchpad, LOADER_SETTINGS),
    devices: {},
    gestures: { settings: {}, bindings: [] },
    apps: null
  }

  if (isObject(source.devices)) {
    for (var name in source.devices) {
      if (validText(name, 256)) state.devices[name] = pickValid(source.devices[name], LOADER_SETTINGS)
    }
  }

  if (isObject(source.gestures)) {
    state.gestures.settings = pickValid(source.gestures.settings, LOADER_GESTURE_SETTINGS)
    if (Array.isArray(source.gestures.bindings)) {
      state.gestures.bindings = source.gestures.bindings.filter(validBinding).map(cleanBinding)
    }
  }

  if (Array.isArray(source.apps)) {
    state.apps = source.apps.filter(function(app) {
      return isObject(app) && validText(app.match, 200) && typeof app.scroll === "number" && app.scroll >= 0.05 && app.scroll <= 10
    }).map(function(app) { return { match: app.match, scroll: app.scroll } })
  }

  return state
}

function parse(text) {
  if (!text || !String(text).trim()) return normalize({})
  try {
    return normalize(JSON.parse(String(text)))
  } catch (e) {
    return normalize({})
  }
}

function serialize(state) {
  var data = { version: 1 }
  if (Object.keys(state.touchpad).length > 0) data.touchpad = state.touchpad
  if (Object.keys(state.devices).length > 0) data.devices = state.devices
  var gestures = {}
  if (Object.keys(state.gestures.settings).length > 0) gestures.settings = state.gestures.settings
  if (state.gestures.bindings.length > 0) gestures.bindings = state.gestures.bindings
  if (Object.keys(gestures).length > 0) data.gestures = gestures
  if (state.apps !== null) data.apps = state.apps
  return JSON.stringify(data, null, 2) + "\n"
}

// Hyprland reports unset strings as "" and unset enums by their raw default,
// so map those back to the choice the pad is actually using.
function liveValue(key, live, specs) {
  var spec = (specs || SETTINGS)[key]
  if (!spec || !isObject(live) || live[key] === undefined || live[key] === null) return undefined
  var value = live[key]
  if (spec.type === "bool") return typeof value === "boolean" ? value : Boolean(value)
  if (spec.type === "choice" && spec.integer) return Number(value)
  if (spec.type === "choice") return value === "" ? undefined : String(value)
  if (spec.type === "number") return Number(value)
  return value
}

function effective(key, saved, live, specs) {
  var spec = (specs || SETTINGS)[key]
  if (isObject(saved) && saved[key] !== undefined) return saved[key]
  var running = liveValue(key, live, specs)
  if (running !== undefined && validValue(spec, running)) return running
  return spec ? spec.fallback : undefined
}

function deviceEffective(key, state, name, live) {
  var overrides = state.devices[name] || {}
  if (overrides[key] !== undefined) return overrides[key]
  return effective(key, state.touchpad, live)
}

function formatNumber(spec, value) {
  var number = Number(value)
  var text = number.toFixed(spec.decimals !== undefined ? spec.decimals : 2)
  if (spec.signed && number > 0) text = "+" + text
  return text + (spec.suffix || "")
}

// Lua comments can hold example settings, as Omarchy's own input.lua template
// does, so drop them before looking for anything the user really set.
function stripLuaComments(text) {
  return String(text || "")
    .replace(/--\[(=*)\[[\s\S]*?\]\1\]/g, "")
    .replace(/--[^\n]*/g, "")
}

function blockAfter(text, pattern) {
  var match = pattern.exec(text)
  if (!match) return ""
  var start = match.index + match[0].length
  var depth = 1
  for (var i = start; i < text.length; i++) {
    var char = text[i]
    if (char === "{") depth++
    else if (char === "}") {
      depth--
      if (depth === 0) return text.slice(start, i)
    }
  }
  return text.slice(start)
}

function topLevelKeys(block) {
  var keys = {}
  var depth = 0
  var pattern = /([{}])|\b([a-z_0-9]+)\s*=(?!=)/g
  var match
  while ((match = pattern.exec(block)) !== null) {
    if (match[1] === "{") depth++
    else if (match[1] === "}") depth--
    else if (depth === 0) keys[match[2]] = true
  }
  return keys
}

// Which of this window's settings ~/.config/hypr/input.lua also sets. The
// touchpad module applies after that file, so a value saved here wins; the
// window marks these so it is clear that an untouched one shows input.lua's
// value and that resetting one hands the option back to the file.
function userOverrides(text) {
  var code = stripLuaComments(text)
  var touchpad = topLevelKeys(blockAfter(code, /\btouchpad\s*=\s*\{/))
  var gestureSettings = topLevelKeys(blockAfter(code, /\bgestures\s*=\s*\{/))
  var result = { touchpad: {}, gestureSettings: {}, gestures: 0, appScroll: false }

  for (var key in touchpad) {
    if (SETTINGS[key] && !SETTINGS[key].pointer) result.touchpad[key] = true
  }
  for (var setting in gestureSettings) {
    if (GESTURE_SETTINGS[setting]) result.gestureSettings[setting] = true
  }
  result.gestures = (code.match(/\bhl\.gesture\s*\(/g) || []).length
  result.appScroll = /\bscroll_touchpad\b/.test(code)
  return result
}

var DIRECTION_COVERS = {
  swipe: ["swipe", "horizontal", "vertical", "left", "right", "up", "down"],
  horizontal: ["horizontal", "left", "right"],
  vertical: ["vertical", "up", "down"],
  pinch: ["pinch", "pinchin", "pinchout"]
}

function directionsOverlap(a, b) {
  if (a === b) return true
  var coversA = DIRECTION_COVERS[a] || [a]
  var coversB = DIRECTION_COVERS[b] || [b]
  return coversA.indexOf(b) >= 0 || coversB.indexOf(a) >= 0
}

// Hyprland refuses a gesture that an earlier one already covers, so flag the
// later binding of each overlapping pair, plus swipes that scrolling owns.
function gestureProblems(bindings) {
  var problems = []
  for (var i = 0; i < bindings.length; i++) {
    var binding = bindings[i]
    var problem = ""
    var pinch = DIRECTION_COVERS.pinch.indexOf(binding.direction) >= 0
    if (binding.fingers === 2 && !pinch) problem = "Two-finger swipes are used for scrolling"
    for (var j = 0; j < i && problem === ""; j++) {
      var earlier = bindings[j]
      if (earlier.fingers === binding.fingers && (earlier.mods || "") === (binding.mods || "")
          && directionsOverlap(earlier.direction, binding.direction)) {
        problem = "Gesture " + (j + 1) + " already uses this swipe"
      }
    }
    problems.push(problem)
  }
  return problems
}

function presetActive(bindings, preset) {
  return bindings.some(function(binding) {
    return binding.fingers === preset.binding.fingers
      && binding.direction === preset.binding.direction
      && binding.action === preset.binding.action
      && !binding.mods
  })
}

// A new gesture starts on the first finger count and direction that nothing
// else covers yet, so adding one never produces a conflict by default.
function nextBinding(bindings) {
  var candidates = [
    [3, "horizontal"], [3, "up"], [3, "down"], [4, "horizontal"], [4, "up"], [4, "down"],
    [3, "pinch"], [4, "pinch"], [5, "horizontal"], [5, "up"], [5, "down"]
  ]
  for (var i = 0; i < candidates.length; i++) {
    var fingers = candidates[i][0]
    var direction = candidates[i][1]
    var taken = bindings.some(function(b) {
      return b.fingers === fingers && !b.mods && directionsOverlap(b.direction, direction)
    })
    if (!taken) {
      var action = direction === "horizontal" ? "workspace" : direction === "pinch" ? "zoom" : direction === "up" ? "menu" : "close"
      return { fingers: fingers, direction: direction, action: action }
    }
  }
  return { fingers: 5, direction: "pinch", action: "zoom", mods: "SUPER" }
}

function appsOrDefault(apps) {
  return copy(apps === null || apps === undefined ? DEFAULT_APPS : apps)
}

function sameApps(a, b) {
  return JSON.stringify(a) === JSON.stringify(b)
}

// A short, friendly device name: drop the bus prefix and hex ids Hyprland uses.
function deviceLabel(name) {
  var text = String(name || "")
  var cleaned = text
    .replace(/^[a-z0-9]+:[0-9a-f]{2}-[0-9a-f]{4}:[0-9a-f]{4}-/i, "")
    .replace(/-/g, " ")
    .trim()
  var vendor = text.match(/^([a-z]+)[0-9]*:/i)
  var label = cleaned || text
  if (vendor && cleaned.toLowerCase().indexOf(vendor[1].toLowerCase()) < 0) label = vendor[1].toUpperCase() + " " + label
  return label.replace(/\b\w/g, function(c) { return c.toUpperCase() })
}

if (typeof module !== "undefined") {
  module.exports = {
    SETTINGS: SETTINGS,
    GESTURE_SETTINGS: GESTURE_SETTINGS,
    LOADER_SETTINGS: LOADER_SETTINGS,
    LOADER_GESTURE_SETTINGS: LOADER_GESTURE_SETTINGS,
    PAGES: PAGES,
    PAGE_SETTINGS: PAGE_SETTINGS,
    DEVICE_SETTINGS: DEVICE_SETTINGS,
    ACTIONS: ACTIONS,
    DIRECTIONS: DIRECTIONS,
    FINGERS: FINGERS,
    MODIFIERS: MODIFIERS,
    GESTURE_PRESETS: GESTURE_PRESETS,
    DEFAULT_APPS: DEFAULT_APPS,
    normalize: normalize,
    parse: parse,
    serialize: serialize,
    effective: effective,
    deviceEffective: deviceEffective,
    liveValue: liveValue,
    formatNumber: formatNumber,
    labelFor: labelFor,
    userOverrides: userOverrides,
    gestureProblems: gestureProblems,
    presetActive: presetActive,
    nextBinding: nextBinding,
    appsOrDefault: appsOrDefault,
    sameApps: sameApps,
    deviceLabel: deviceLabel,
    copy: copy
  }
}
