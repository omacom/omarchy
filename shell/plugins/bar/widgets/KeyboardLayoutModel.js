// Label math for the keyboard layout widget, kept Qt-free so it can be unit
// tested under node (test/shell.d/keyboard-layout-test.sh).

// xkbcli list prints YAML, and every layout and variant block pairs a brief with
// the description hyprctl reports as the active keymap:
//
//   - layout: 'us'
//     variant: ''
//     brief: 'en'
//     description: English (US)
//
// The models and option groups it also prints carry no brief of their own, and
// a brief never carries past the block it was printed in, so neither reaches
// the table.
function layoutBriefs(text) {
  var briefs = {}
  var brief = ""

  String(text || "").split("\n").forEach(function (line) {
    if (/^\s*- /.test(line)) brief = ""

    var field = line.match(/^  (brief|description): (.*)$/)
    if (!field) return

    if (field[1] === "brief") {
      brief = field[2].replace(/^'|'$/g, "")
    } else if (brief) {
      briefs[field[2]] = brief
      brief = ""
    }
  })

  return briefs
}

// The same walk, keeping the variant each description belongs to instead of
// its brief. A block always prints its variant line, even when the variant is
// empty, so a description recorded against null means the walk never saw the
// variant line rather than a variantless base layout.
function layoutVariants(text) {
  var variants = {}
  var variant = null

  String(text || "").split("\n").forEach(function (line) {
    if (/^\s*- /.test(line)) variant = null

    var field = line.match(/^  (variant|description): (.*)$/)
    if (!field) return

    if (field[1] === "variant") {
      variant = field[2].replace(/^'|'$/g, "")
    } else if (variant !== null) {
      variants[field[2]] = variant
    }
  })

  return variants
}

// The brief is a short language code rather than a country one, which keeps the
// label sensible for the layouts named after a language: Esperanto reads EO and
// Arabic reads AR. It is the same code GNOME shows in its own indicator.
//
// Layouts missing from the table fall back to the first word of the description,
// which reads as ENG/POR but at least says something.
//
// Nearly every brief is a bare two-letter code, but a few tack a script onto it
// (Burmese (Zawgyi) is my-zwg) and the custom layout's is a word, so drop the
// script and cap the result at the same three characters the fallback gets.
// The widget sits between fixed neighbours on the bar and has no room to grow.
function shortLabel(description, briefs) {
  if (!description) return ""

  // A description like "constructor" reaches an inherited member rather than a
  // brief, so take the lookup only when it hands back the string it promises.
  var brief = (briefs || {})[description]
  var label = typeof brief === "string" && brief ? brief.split("-")[0] : description.split(/\s+/)[0]
  return label.substring(0, 3).toUpperCase()
}

// The label a seat holding variants of one layout reads. Every one of them
// shares the brief, so the label names the variant instead: Dvorak reads DVO
// where the language reads EN. The variant comes from the table rather than
// the description, which parses "English (US, intl., with dead keys)" into a
// country. A base variant carries no variant name and keeps the brief, as does
// anything the table does not know.
function variantLabel(description, variants) {
  var variant = (variants || {})[description]
  return typeof variant === "string" && variant ? variant.substring(0, 3).toUpperCase() : ""
}

// The label the widget shows: the variant when the seat holds variants of one
// layout, the language brief otherwise.
function displayLabel(description, briefs, variants, variantMode) {
  if (variantMode) {
    var label = variantLabel(description, variants)
    if (label) return label
  }

  return shortLabel(description, briefs)
}

// Variants of one layout share its code, so a code the layout list holds twice
// means two of its variants are enabled and the brief alone can no longer tell
// them apart.
function hasVariantDuplicates(layouts) {
  var codes = String(layouts || "").split(",").map(function (code) { return code.trim() })
  return codes.some(function (code, index) { return codes.indexOf(code) !== index })
}

// Hyprland's activelayout event pairs the keyboard that switched with the layout
// it moved to. Quickshell cuts the event into that many fields, so a description
// carrying a comma of its own stays in one piece; a binding old enough to hand
// back only the raw string gets split by hand. The virtual keyboard fcitx5 binds
// to inject announces switches too, and names a keyboard nobody types on.
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

// Hyprland reports more than keyboards as keyboards. fcitx5 binds a virtual one
// to inject through, which keeps the us layout the input method gave it, and the
// ACPI power button, lid switch and sleep key each arrive carrying the seat's
// layout list without anyone ever typing on them. Both answer to switchxkblayout
// and both can hold the main flag, so a widget that reads or switches whatever
// the seat hands it ends up describing a button. Leave them out and what remains
// is keyboards, which is what the rest of this file can then assume.
//
// Missing a name here costs the accuracy the seat had before, never a keyboard:
// anything unrecognised stays in the list.
var UNTYPED_KEYBOARDS = /^(hl-virtual-keyboard|power-button|sleep-button|lid-switch|video-bus)|(-wmi-hotkeys|-wireless-radio-control)(-\d+)?$/

function isTypedKeyboard(name) {
  return !UNTYPED_KEYBOARDS.test(String(name || ""))
}

// Every keyboard on the seat carries the same layout list unless one was given
// its own, but only the one being typed on advances through it. So the
// furthest-advanced is the one worth reading, and a switch names the keyboard it
// moved, which settles a seat holding two real keyboards outright.
//
// The name is taken whenever a keyboard still answers to it, wherever that
// keyboard sits in the list. Comparing positions instead would read the wrong
// keyboard the moment one wrapped from the last layout back to the first, which
// is the ordinary way round a pair of them. Applying a layout to the whole seat
// names a keyboard too, but leaves every one of them on the same layout, so the
// label reads the same whichever of them the name settles on.
function selectKeyboard(typed, namedByEvent) {
  var keyboards = typed || []

  return keyboards.find(function (keyboard) {
    return keyboard.name === namedByEvent
  }) || keyboards.reduce(function (furthest, keyboard) {
    return layoutIndex(keyboard) > layoutIndex(furthest) ? keyboard : furthest
  }, keyboards[0])
}

function inputLabel(state, fallback) {
  if (!state || !state.current || state.current.indexOf("keyboard-") === 0) return fallback
  if (state.label) return String(state.label).substring(0, 3)
  var labels = { mozc: "あ", hangul: "한", pinyin: "拼", chewing: "注", cangjie5: "倉" }
  return labels[state.current] || shortLabel(state.language || state.name, {})
}

function inputTooltip(state, layout, multipleLayouts) {
  if (!state || !state.methods || state.methods.length < 2)
    return layout + (multipleLayouts ? " · Super + I" : "")
  var name = state.current && state.current.indexOf("keyboard-") === 0 ? layout : (state.name || layout)
  return name.replace(/^Keyboard - /, "") + " · Super + I"
}

function showIndicator(layoutLabel, multipleLayouts, multipleInputs) {
  return multipleInputs || (layoutLabel !== "" && multipleLayouts)
}

function layoutIndex(keyboard) {
  return (keyboard && keyboard.active_layout_index) || 0
}

if (typeof module !== "undefined") {
  module.exports = {
    eventKeyboardName: eventKeyboardName,
    isTypedKeyboard: isTypedKeyboard,
    layoutBriefs: layoutBriefs,
    layoutVariants: layoutVariants,
    selectKeyboard: selectKeyboard,
    shortLabel: shortLabel,
    variantLabel: variantLabel,
    displayLabel: displayLabel,
    hasVariantDuplicates: hasVariantDuplicates,
    inputLabel: inputLabel,
    inputTooltip: inputTooltip,
    showIndicator: showIndicator
  }
}
