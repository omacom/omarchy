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

// The same table, keyed by the layout/variant pair hyprctl reports ("us" for a
// bare layout, "us:intl" once a variant is set): the seat's configured list is
// positional, and this is what turns it into descriptions. A block without a
// layout line is a model or a group, not a layout, and never enters the table.
function layoutDescriptionsByPair(text) {
  // Null prototype: a description like "constructor" reaches an inherited
  // member rather than the table, the way shortLabel guards its own.
  var byPair = Object.create(null)
  var layout = ""
  var variant = ""
  var description = ""

  var commit = function () {
    if (layout && description) byPair[variant ? layout + ":" + variant : layout] = description
    layout = ""
    variant = ""
    description = ""
  }

  String(text || "").split("\n").forEach(function (line) {
    if (/^\s*- /.test(line)) commit()

    // The layout opens its own block ("- layout: 'us'"), so it is the one field
    // the dash prefix can carry; variant and description sit under it.
    var field = line.match(/^\s*(?:- )?(layout|variant|description): (.*)$/)
    if (!field) return

    if (field[1] === "layout") layout = field[2].replace(/^'|'$/g, "")
    else if (field[1] === "variant") variant = field[2].replace(/^'|'$/g, "")
    else description = field[2]
  })
  commit()

  return byPair
}

// The configured list hyprctl reports per keyboard — layout "us,us" with variant
// ",intl" — as the pair keys the table above answers to. The lists are paired
// positionally; a variant list that is missing or shorter leaves the rest bare,
// the way xkb itself treats an absent variant.
function configuredLayoutPairs(layouts, variants) {
  var layoutList = String(layouts || "").split(",")
  var variantList = String(variants || "").split(",")
  var pairs = []

  layoutList.forEach(function (entry, index) {
    if (entry === "") return
    // xkb also reads the inline spelling "us(intl)", which carries its variant
    // on the layout and never consults the variant list.
    var inline = entry.match(/^([^()]+)\(([^()]+)\)$/)
    if (inline) {
      pairs.push(inline[1] + ":" + inline[2])
      return
    }
    var variant = index < variantList.length ? variantList[index] : ""
    pairs.push(variant ? entry + ":" + variant : entry)
  })

  return pairs
}

// The descriptions of the configured layouts, in list order; a pair the table
// does not know reads as "" and gets the plain fallback label later. The table
// can be a plain QML object, so the lookup is a typeof check, the way shortLabel
// guards its own ("constructor" reaches an inherited member, not a description).
function configuredDescriptions(layouts, variants, descriptionsByPair) {
  var byPair = descriptionsByPair || {}
  return configuredLayoutPairs(layouts, variants).map(function (pair) {
    var description = byPair[pair]
    return typeof description === "string" ? description : ""
  })
}

// The bar label per configured layout description, with a subscript where two
// configured layouts share one: us and us:intl both read EN, and a label that
// cannot tell them apart describes the wrong keyboard half the time. GNOME
// marks the same collision the same way (en₁, en₂); one narrow character, so
// the widget keeps the slot it sits in. Every member of a colliding group is
// subscripted by its order in the list; a layout alone on its label is left
// alone. Descriptions the briefs table could not resolve fall back to
// shortLabel and are subscripted like any other collision; a pair missing from
// the layout table reads as empty and gets no label here at all.
function subscriptedLabels(descriptions, briefs) {
  var labels = Object.create(null)
  var groups = Object.create(null)
  var seen = Object.create(null)
  var order = []
  var list = descriptions || []

  list.forEach(function (description) {
    // The same description can sit in the list twice (us,de,us types on one
    // layout twice); it gets one label, not a collision with itself.
    if (!description || seen[description]) return
    seen[description] = true
    var label = shortLabel(description, briefs)
    if (!label) return
    if (groups[label] === undefined) {
      groups[label] = []
      order.push(label)
    }
    groups[label].push(description)
  })

  order.forEach(function (label) {
    var group = groups[label]
    group.forEach(function (description, index) {
      labels[description] = group.length > 1 && index < 9
        ? label + String.fromCharCode(0x2081 + index)
        : label
    })
  })

  return labels
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
    layoutDescriptionsByPair: layoutDescriptionsByPair,
    configuredLayoutPairs: configuredLayoutPairs,
    configuredDescriptions: configuredDescriptions,
    subscriptedLabels: subscriptedLabels,
    selectKeyboard: selectKeyboard,
    shortLabel: shortLabel,
    inputLabel: inputLabel,
    inputTooltip: inputTooltip,
    showIndicator: showIndicator
  }
}
