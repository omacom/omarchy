#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

run_node_test <<'JS'
const model = requireFromRoot('shell/plugins/bar/widgets/KeyboardLayoutModel.js')

const japanese = { methods: ['keyboard-us', 'mozc'], current: 'mozc', name: 'Mozc', language: 'ja' }
assertEqual(model.inputLabel(japanese, 'EN'), 'あ', 'Japanese input has a distinct active label')
assertEqual(model.inputLabel({ ...japanese, label: 'ア' }, 'EN'), 'ア', 'the live engine mode takes precedence over its default glyph')
assertEqual(model.inputLabel({ ...japanese, current: 'keyboard-us' }, 'EN'), 'EN', 'Latin input retains the keyboard label')
assertEqual(model.inputLabel({}, 'EN'), 'EN', 'a stopped input service retains the keyboard label')
assertEqual(model.inputLabel({ current: 'hangul' }, 'EN'), '한', 'Korean input has a distinct label')
assertEqual(model.inputLabel({ current: 'custom', language: 'vi' }, 'EN'), 'VI', 'other engines use their reported language')
assertEqual(model.inputTooltip(japanese, 'English (US)', false), 'Mozc · Super + I', 'input tooltip shows only its name and shortcut')
assertEqual(model.inputTooltip(japanese, 'English (US)', true), 'Mozc · Super + I', 'multiple layouts keep the input tooltip compact')
assertEqual(model.inputTooltip({ ...japanese, current: 'keyboard-us', name: 'Keyboard - English (US)' }, 'English (US)', false), 'English (US) · Super + I', 'Latin input omits the redundant keyboard prefix')
assertEqual(model.inputTooltip({ ...japanese, current: 'keyboard-us', name: 'Keyboard - English (US)' }, 'Danish', true), 'Danish · Super + I', 'direct input tooltip follows the active compositor layout')
assertEqual(model.inputTooltip({ methods: ['keyboard-fr'] }, 'French', false), 'French', 'a single layout tooltip stays compact')

// Caps Lock is spelled out in the tooltip, between the name and the shortcut,
// in every input mode the badge shows on.
assertEqual(model.inputTooltip({ ...japanese, current: 'keyboard-us', name: 'Keyboard - English (US)' }, 'English (US)', false, true), 'English (US) · Caps Lock on · Super + I', 'Caps Lock sits between the layout and the shortcut')
assertEqual(model.inputTooltip(japanese, 'English (US)', false, true), 'Mozc · Caps Lock on · Super + I', 'Caps Lock shows beside an input method too')
assertEqual(model.inputTooltip({ methods: ['keyboard-us', 'hangul'], current: 'hangul', name: 'Hangul' }, 'Korean', false, true), 'Hangul · Caps Lock on · Super + I', 'Caps Lock shows in Hangul mode')
assertEqual(model.inputTooltip({ methods: ['keyboard-fr'] }, 'French', true, true), 'French · Caps Lock on · Super + I', 'Caps Lock shows on a seat with several layouts')
assertEqual(model.inputTooltip({ methods: ['keyboard-fr'] }, 'French', false, true), 'French · Caps Lock on', 'a single layout names Caps Lock without a shortcut')
assertEqual(model.inputTooltip(japanese, 'English (US)', false, false), 'Mozc · Super + I', 'Caps Lock off leaves the tooltip as it was')
assertEqual(model.inputTooltip(japanese, 'English (US)', false, true, (key, english) => key === 'bar.capsLockOn' ? 'Verr. Maj.' : english), 'Mozc · Verr. Maj. · Super + I', 'the Caps Lock words come from the catalog')
assertEqual(model.capsLockOn([{ name: 'kb', capsLock: true }]), true, 'a keyboard reporting Caps Lock has it on')
assertEqual(model.capsLockOn([{ name: 'kb', capsLock: false }]), false, 'a keyboard reporting no Caps Lock has it off')
assertEqual(model.capsLockOn([{ name: 'kb' }]), false, 'an older Hyprland that reports no lock reads as off')
assertEqual(model.capsLockOn([{ name: 'laptop', capsLock: false }, { name: 'usb', capsLock: true }]), true, 'Caps Lock on a second keyboard lights the badge')
assertEqual(model.capsLockOn([]), false, 'no keyboard means no Caps Lock')
assertEqual(model.capsLockOn(undefined), false, 'no reading means no Caps Lock')
assertEqual(model.showIndicator('EN', false, false, true), true, 'one layout shows the widget while Caps Lock is on')
assertEqual(model.showIndicator('EN', false, false, false), false, 'one layout hides the widget again once Caps Lock is off')
assertEqual(model.showIndicator('', false, false, true), false, 'Caps Lock with no keymap still shows nothing')
assertEqual(model.showIndicator('EN', false, false), false, 'English alone stays hidden')
assertEqual(model.showIndicator('ENG', false, false), false, 'English before the brief table loads stays hidden')
assertEqual(model.showIndicator('FR', false, false), false, 'French alone stays hidden')
assertEqual(model.showIndicator('EN', false, true), true, 'Latin with another input mode stays available')
assertEqual(model.showIndicator('EN', true, false), true, 'multiple keyboard layouts stay available')
assertEqual(model.showIndicator('FR', true, false), true, 'French and English layouts stay available')
assertEqual(model.inputTooltip({ methods: ['keyboard-fr'] }, 'French', true), 'French · Super + I', 'multiple layouts advertise their switching shortcut')

// Trimmed from xkbcli list, keeping the format of every section it prints,
// including the options nested under an option group: those quote their
// description and print an empty brief, one indent deeper than a layout's.
const listing = [
  'models:',
  '- name: pc105',
  '  vendor: Generic',
  '  description: Generic 105-key PC',
  'layouts:',
  "- layout: 'us'",
  "  variant: ''",
  "  brief: 'en'",
  '  description: English (US)',
  "  iso639: ['eng']",
  "  iso3166: ['USA']",
  "- layout: 'us'",
  "  variant: 'intl'",
  "  brief: 'en'",
  '  description: English (US, intl., with dead keys)',
  "- layout: 'br'",
  "  variant: ''",
  "  brief: 'pt'",
  '  description: Portuguese (Brazil)',
  "- layout: 'epo'",
  "  variant: ''",
  "  brief: 'eo'",
  '  description: Esperanto',
  "- layout: 'latam'",
  "  variant: ''",
  "  brief: 'es'",
  '  description: Spanish (Latin American)',
  "- layout: 'mm'",
  "  variant: 'zawgyi'",
  "  brief: 'my-zwg'",
  '  description: Burmese (Zawgyi)',
  'option_groups:',
  "- name: 'grp'",
  '  description: Switching to another layout',
  '  allows_multiple: true',
  '  options:',
  "  - name: 'grp:switch'",
  "    brief: ''",
  "    description: 'Right Alt (while pressed)'",
  '    layout-specific: false',
].join('\n')

const briefs = model.layoutBriefs(listing)

assertEqual(briefs['English (US)'], 'en', 'the table reads a layout brief')
assertEqual(briefs['English (US, intl., with dead keys)'], 'en', 'the table reads a variant brief')
assertEqual(briefs['Generic 105-key PC'], undefined, 'the table skips keyboard models')
assertEqual(briefs['Switching to another layout'], undefined, 'the table skips option groups')
assertEqual(briefs["'Right Alt (while pressed)'"], undefined, 'the table skips the options under a group')
assertEqual(Object.keys(briefs).length, 6, 'the table holds nothing but the layouts')

assertEqual(model.shortLabel('English (US)', briefs), 'EN', 'the label is the language, not the country')
assertEqual(model.shortLabel('Portuguese (Brazil)', briefs), 'PT', 'a country variant keeps its language')
assertEqual(model.shortLabel('Esperanto', briefs), 'EO', 'a layout without a country still gets a code')
assertEqual(model.shortLabel('Spanish (Latin American)', briefs), 'ES', 'a layout spanning countries still gets a code')
assertEqual(model.shortLabel('Burmese (Zawgyi)', briefs), 'MY', 'a brief carrying a script drops it')
assertEqual(model.shortLabel('A user-defined custom Layout', { 'A user-defined custom Layout': 'custom' }), 'CUS', 'a brief that is a word is cut to size')

// A brief pairs with the description printed under it, so a block that prints
// one without the other must not hand its code to the block that follows.
const orphaned = model.layoutBriefs([
  'layouts:',
  "- layout: 'us'",
  "  brief: 'en'",
  "- layout: 'gr'",
  '  description: Greek',
].join('\n'))

assertEqual(orphaned['Greek'], undefined, 'a brief stops at the end of its block')

assertEqual(model.shortLabel('Elvish (Tengwar)', briefs), 'ELV', 'an unlisted layout falls back to its description')
assertEqual(model.shortLabel('English (US)', {}), 'ENG', 'the label survives an empty table')
assertEqual(model.shortLabel('constructor', {}), 'CON', 'a description naming a built-in still falls back')
assertEqual(model.shortLabel('', briefs), '', 'no keymap means no label')

// The seat as hyprctl reports it, virtual keyboards already filtered out: the
// buttons libinput calls keyboards sit beside the one being typed on, and the
// main flag lands on either, or on the virtual keyboard that isn't here.
const seat = (activeIndex, main) => [
  { name: 'power-button', active_layout_index: 0, active_keymap: 'English (US)', main: main === 'power-button' },
  { name: 'at-translated-set-2-keyboard', active_layout_index: activeIndex, active_keymap: activeIndex ? 'French' : 'English (US)', main: main === 'keyboard' },
]

assertEqual(model.selectKeyboard(seat(1)).active_keymap, 'French', 'the keyboard that switched is read when nothing holds main')
assertEqual(model.selectKeyboard(seat(1, 'power-button')).active_keymap, 'French', 'the keyboard that switched outranks a button holding main')
assertEqual(model.selectKeyboard(seat(0)).active_keymap, 'English (US)', 'before a switch every keyboard reads the same layout')
assertEqual(model.selectKeyboard(seat(0), 'at-translated-set-2-keyboard').name, 'at-translated-set-2-keyboard', 'the keyboard activelayout named is kept once it switches back')
assertEqual(model.selectKeyboard([{ name: 'a' }, { name: 'b' }]).name, 'a', 'a keyboard reporting no index still gets picked')
assertEqual(model.selectKeyboard([]), undefined, 'a seat with no typed keyboard picks none')

// Two real keyboards on the layout the seat started on, so nothing but the name
// says which one is being typed on. The one that wrapped from the last layout
// back to the first sits behind the other and is still the one that switched.
const pair = (activeIndex, otherIndex) => [
  { name: 'at-translated-set-2-keyboard', active_layout_index: otherIndex, active_keymap: otherIndex ? 'German' : 'English (US)' },
  { name: 'usb-keyboard', active_layout_index: activeIndex, active_keymap: activeIndex ? 'German' : 'English (US)' },
]

assertEqual(model.selectKeyboard(pair(0, 0), 'usb-keyboard').name, 'usb-keyboard', 'the keyboard that switched is read once it is named')
assertEqual(model.selectKeyboard(pair(0, 2), 'usb-keyboard').name, 'usb-keyboard', 'a keyboard that wrapped back to the first layout is still the one that switched')
assertEqual(model.selectKeyboard(pair(0, 2), 'gone-keyboard').name, 'at-translated-set-2-keyboard', 'a name no keyboard answers to falls back to layout progress')

// Hyprland calls the ACPI buttons keyboards too, and hands them the seat's
// layout list. Reading one would describe a layout nobody typed, and switching
// one would leave the keyboard where it was.
assertEqual(model.isTypedKeyboard('at-translated-set-2-keyboard'), true, 'a real keyboard is typed on')
assertEqual(model.isTypedKeyboard('power-button'), false, 'a power button is not')
assertEqual(model.isTypedKeyboard('lid-switch'), false, 'a lid switch is not')
assertEqual(model.isTypedKeyboard('sleep-button'), false, 'a sleep button is not')
assertEqual(model.isTypedKeyboard('hl-virtual-keyboard-1'), false, 'the keyboard an input method injects through is not')
assertEqual(model.isTypedKeyboard(''), true, 'a keyboard reporting no name is left where it was found')

// The activelayout event names the keyboard ahead of the layout it moved to,
// and a description with a comma in it has to survive the split.
const rawEvent = data => ({ data })
const parsedEvent = data => ({ data, parse: count => data.split(',', count - 1).concat(data.split(',').slice(count - 1).join(',')) })

assertEqual(model.eventKeyboardName(rawEvent('at-translated-set-2-keyboard,French')), 'at-translated-set-2-keyboard', 'the event names its keyboard')
assertEqual(model.eventKeyboardName(parsedEvent('at-translated-set-2-keyboard,English (US, intl.)')), 'at-translated-set-2-keyboard', 'a description carrying a comma leaves the name alone')
assertEqual(model.eventKeyboardName(rawEvent('hl-virtual-keyboard,English (US)')), '', 'the keyboard an input method injects through is not typed on')
assertEqual(model.eventKeyboardName({ parse: () => { throw new Error('unsupported') }, data: 'kb,French' }), 'kb', 'a binding without parse falls back to the raw data')
assertEqual(model.eventKeyboardName({}), '', 'an event with nothing in it names no keyboard')
{
  const widget = require('fs').readFileSync(path.join(root, 'shell/plugins/bar/widgets/KeyboardLayout.qml'), 'utf8')
  assert(!/Component\.onCompleted: \{[\s\S]*?briefsProc\.running = true/.test(widget), 'the xkb layout table is not read at startup')
  const load = new Function('state', 'briefsProc', widget.match(/function loadBriefs\(\) \{([\s\S]*?)\n  \}/)[1].replace(/\b(needsBriefs|briefsRequested)\b/g, 'state.$1'))
  const proc = { running: false }
  const state = { needsBriefs: false, briefsRequested: false }
  load(state, proc)
  assert(!proc.running, 'a seat with one layout and one input method never reads the table')
  state.needsBriefs = true
  load(state, proc)
  assert(proc.running, 'the table is read once a label needs it')
  proc.running = false
  load(state, proc)
  assert(!proc.running, 'the table is read only once')
  assert(widget.includes('onNeedsBriefsChanged: loadBriefs()'), 'the table loads as soon as a label is needed')

  // Drive the real keyboard reading, then the needsBriefs binding, as QML would.
  const reading = new Function('root', 'KeyboardLayoutModel', 'text',
    widget.match(/id: queryProc[\s\S]*?onStreamFinished: \{([\s\S]*?)\n      \}/)[1])
  const needs = new Function('layoutsRead', 'multipleLayouts', 'multipleInputs', 'capsLock',
    'return ' + widget.match(/readonly property bool needsBriefs: ([^\n]+)/)[1])
  const widgetState = layout => {
    const w = { typedKeyboardName: '', multipleLayouts: true, layoutsRead: false }
    w.typedKeyboards = keyboards => keyboards.filter(k => model.isTypedKeyboard(k.name))
    w.selectKeyboard = typed => model.selectKeyboard(typed, w.typedKeyboardName)
    reading(w, model, JSON.stringify({ keyboards: [{ name: 'at-translated-set-2-keyboard', main: true, layout, active_keymap: 'English (US)', active_layout_index: 0 }] }))
    return w
  }
  const single = widgetState('us')
  assert(single.layoutsRead && !needs(single.layoutsRead, single.multipleLayouts, false), 'a first reading of one layout needs no table')
  assert(needs(single.layoutsRead, single.multipleLayouts, true), 'several input methods on one layout need the table')
  const several = widgetState('us,dk')
  assert(needs(several.layoutsRead, several.multipleLayouts, false), 'a first reading of several layouts needs the table')
  assert(!needs(false, true, true), 'nothing is needed before the first reading')

  // The reading takes Caps Lock off any keyboard someone types on, never off a
  // button, and drops it once the last keyboard is gone.
  const capsReading = (keyboards, named = 'usb-keyboard') => {
    const w = { typedKeyboardName: named, multipleLayouts: true, layoutsRead: false, capsLock: true }
    w.typedKeyboards = list => list.filter(k => model.isTypedKeyboard(k.name))
    w.selectKeyboard = typed => model.selectKeyboard(typed, w.typedKeyboardName)
    reading(w, model, JSON.stringify({ keyboards }))
    return w
  }
  const keyboard = (name, capsLock) => ({ name, layout: 'us,kr', active_keymap: 'English (US)', active_layout_index: 0, capsLock })
  assert(capsReading([keyboard('power-button', false), keyboard('usb-keyboard', true)]).capsLock, 'Caps Lock is read off the keyboard being typed on')
  assert(!capsReading([keyboard('power-button', true), keyboard('usb-keyboard', false)]).capsLock, 'a button reporting Caps Lock does not light the badge')
  assert(!capsReading([keyboard('power-button', true)]).capsLock, 'Caps Lock clears once the last keyboard is unplugged')
  {
    const second = capsReading([keyboard('at-translated-set-2-keyboard', false), keyboard('usb-keyboard', true)], 'at-translated-set-2-keyboard')
    assert(second.capsLock && second.keyboardName === 'at-translated-set-2-keyboard', 'Caps Lock on a second keyboard lights the badge while the label keeps its keyboard')
  }
  {
    const single = l => ({ name: 'at-translated-set-2-keyboard', layout: 'us', active_keymap: 'English (US)', active_layout_index: 0, capsLock: l })
    const on = capsReading([single(true)], '')
    const off = capsReading([single(false)], '')
    assert(on.capsLock && !on.multipleLayouts && needs(on.layoutsRead, on.multipleLayouts, false, on.capsLock), 'Caps Lock on a single layout reads the label table')
    assert(model.showIndicator('EN', on.multipleLayouts, false, on.capsLock), 'Caps Lock on a single layout shows the widget')
    assert(!off.capsLock && !needs(off.layoutsRead, off.multipleLayouts, false, off.capsLock), 'a single layout with Caps Lock off needs no table')
    assert(!model.showIndicator('EN', off.multipleLayouts, false, off.capsLock), 'a single layout with Caps Lock off stays hidden')
  }
  assert(widget.includes('KeyboardLayoutModel.showIndicator(layoutLabel, multipleLayouts, multipleInputs, capsLock)'), 'the widget shows while Caps Lock is on')

  // Caps Lock raises no Hyprland event, so the widget reads the seat again on
  // the shortcut Hyprland sends when the key is let go, without a timer.
  assert(/Connections \{\s*target: CapsLock\s*function onToggled\(\) \{ root\.refresh\(\) \}/.test(widget), 'the widget reads the seat again when Caps Lock is let go')
  const capsLock = require('fs').readFileSync(path.join(root, 'shell/Commons/CapsLock.qml'), 'utf8')
  assert(/^pragma Singleton/.test(capsLock) && !/Timer|Process/.test(capsLock), 'one Caps Lock shortcut serves every bar and starts nothing')
  assert(capsLock.includes('name: "caps-lock"') && capsLock.includes('appid: "omarchy"'), 'the shell registers the shortcut Hyprland sends')
  assert(require('fs').readFileSync(path.join(root, 'shell/Commons/qmldir'), 'utf8').includes('singleton CapsLock 1.0 CapsLock.qml'), 'the Caps Lock singleton is registered')
}
JS

# Load input.lua against a stub hl and print its keybindings, to check that
# Caps Lock reaches the shell without being taken from apps.
require_command lua
caps_home=$(mktemp -d)
trap 'rm -rf "$caps_home"' EXIT
caps_binds=$(HOME="$caps_home" OMARCHY_PATH="$ROOT" lua <<'LUA'
package.path = os.getenv("OMARCHY_PATH") .. "/?.lua;" .. package.path
local function proxy()
  return setmetatable({}, {
    __index = function(self, key) local value = proxy(); rawset(self, key, value); return value end,
    __call = function() return {} end,
  })
end
local dsp = proxy()
rawset(dsp, "global", function(name) return { global = name } end)
hl = setmetatable({
  dsp = dsp,
  bind = function(keys, dispatcher, opts)
    opts = opts or {}
    if type(dispatcher) == "table" and dispatcher.global then
      local flags = {}
      for _, flag in ipairs({ "release", "transparent", "ignore_mods", "non_consuming", "locked", "dont_inhibit", "submap_universal" }) do
        if opts[flag] then flags[#flags + 1] = flag end
      end
      print(keys .. "\t" .. dispatcher.global .. "\t" .. table.concat(flags, ",") .. "\t" .. (opts.description or ""))
    end
  end,
}, { __index = function() return function() return {} end end })
require("default.hypr.helpers")
require("default.hypr.input")
LUA
)
[[ $caps_binds == $'Caps_Lock\tomarchy:caps-lock\trelease,transparent,ignore_mods,non_consuming,locked,dont_inhibit,submap_universal\t' ]] ||
  fail "Caps Lock release reaches the shell without taking the key, locked, inhibited or in a submap: $caps_binds"
pass "Caps Lock release reaches the shell without taking the key, locked, inhibited or in a submap"

