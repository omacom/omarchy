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

// A 2.4G receiver exposes a mouse and its companion HID endpoints, and a vendor
// hotkey block arrives as a radio control or extra buttons. Each holds the
// seat's starting layout, so a mouse scroll while Russian is active must not
// drag the label back to English (US).
assertEqual(model.isTypedKeyboard('2.4g-mouse'), false, 'a mouse endpoint is not typed on')
assertEqual(model.isTypedKeyboard('2.4g-mouse-1'), false, 'a numbered mouse endpoint is not typed on')
assertEqual(model.isTypedKeyboard('2.4g-mouse-consumer-control'), false, 'a mouse consumer control is not typed on')
assertEqual(model.isTypedKeyboard('2.4g-mouse-system-control'), false, 'a mouse system control is not typed on')
assertEqual(model.isTypedKeyboard('pixart-usb-optical-mouse'), false, 'a wired mouse is not typed on')
assertEqual(model.isTypedKeyboard('ite-tech.-inc.-ite-device(8910)-wireless-radio-control'), false, 'a wireless radio control is not typed on')
assertEqual(model.isTypedKeyboard('ideapad-extra-buttons'), false, 'a vendor hotkey block is not typed on')
assertEqual(model.isTypedKeyboard('2.4g-mouse-consumer-control-1'), false, 'a numbered consumer control is not typed on')
assertEqual(model.isTypedKeyboard('usb-keyboard'), true, 'a real keyboard sharing the receiver seat is still typed on')
assertEqual(model.isTypedKeyboard('2.4g-mouse-keyboard'), true, 'the keyboard a combo receiver names after its mouse is still typed on')
assertEqual(model.isTypedKeyboard('mosart-semi.-2.4g-keyboard-mouse-keyboard'), true, 'a keyboard whose product name mentions a mouse is still typed on')

// The activelayout event names the keyboard ahead of the layout it moved to,
// and a description with a comma in it has to survive the split.
const rawEvent = data => ({ data })
const parsedEvent = data => ({ data, parse: count => data.split(',', count - 1).concat(data.split(',').slice(count - 1).join(',')) })

assertEqual(model.eventKeyboardName(rawEvent('at-translated-set-2-keyboard,French')), 'at-translated-set-2-keyboard', 'the event names its keyboard')
assertEqual(model.eventKeyboardName(parsedEvent('at-translated-set-2-keyboard,English (US, intl.)')), 'at-translated-set-2-keyboard', 'a description carrying a comma leaves the name alone')
assertEqual(model.eventKeyboardName(rawEvent('hl-virtual-keyboard,English (US)')), '', 'the keyboard an input method injects through is not typed on')
assertEqual(model.eventKeyboardName(rawEvent('2.4g-mouse-consumer-control,English (US)')), '', 'a mouse endpoint raising the event is not typed on')
assertEqual(model.eventKeyboardName({ parse: () => { throw new Error('unsupported') }, data: 'kb,French' }), 'kb', 'a binding without parse falls back to the raw data')
assertEqual(model.eventKeyboardName({}), '', 'an event with nothing in it names no keyboard')

// The reporter's repro: the keyboard sits on Russian while the mouse endpoints
// stay on English (US); a mouse event must leave the reading on the keyboard.
// Run it the way the widget does: keep the last name an event gave, and read
// from the devices isTypedKeyboard lets through.
const mixedSeat = [
  { name: '2.4g-mouse', active_layout_index: 0, active_keymap: 'English (US)' },
  { name: '2.4g-mouse-consumer-control', active_layout_index: 0, active_keymap: 'English (US)' },
  { name: 'at-translated-set-2-keyboard', active_layout_index: 1, active_keymap: 'Russian' },
]
let typedName = 'at-translated-set-2-keyboard'
for (const device of ['2.4g-mouse', '2.4g-mouse-system-control', '2.4g-mouse-consumer-control']) {
  const named = model.eventKeyboardName(rawEvent(device + ',English (US)'))
  if (named) typedName = named
}
assertEqual(typedName, 'at-translated-set-2-keyboard', 'the mouse events leave the typed keyboard named')
assertEqual(model.selectKeyboard(mixedSeat.filter(k => model.isTypedKeyboard(k.name)), typedName).active_keymap, 'Russian', 'the reading stays on the keyboard that moved')
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
  const needs = new Function('layoutsRead', 'multipleLayouts', 'multipleInputs',
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
}
JS
