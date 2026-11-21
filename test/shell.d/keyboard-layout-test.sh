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
assertEqual(model.inputTooltip(japanese, 'English (US)', false, 'Super + I'), 'Mozc · Super + I', 'input tooltip shows only its name and shortcut')
assertEqual(model.inputTooltip(japanese, 'English (US)', true, 'Super + I'), 'Mozc · Super + I', 'multiple layouts keep the input tooltip compact')
assertEqual(model.inputTooltip({ ...japanese, current: 'keyboard-us', name: 'Keyboard - English (US)' }, 'English (US)', false, 'Super + I'), 'English (US) · Super + I', 'Latin input omits the redundant keyboard prefix')
assertEqual(model.inputTooltip({ ...japanese, current: 'keyboard-us', name: 'Keyboard - English (US)' }, 'Danish', true, 'Super + Alt + I'), 'Danish · Super + Alt + I', 'direct input tooltip follows the active compositor layout')
assertEqual(model.inputTooltip({ methods: ['keyboard-fr'] }, 'French', false), 'French', 'a single layout tooltip stays compact')
assertEqual(model.showIndicator('EN', false, false), false, 'English alone stays hidden')
assertEqual(model.showIndicator('ENG', false, false), false, 'English before the brief table loads stays hidden')
assertEqual(model.showIndicator('FR', false, false), false, 'French alone stays hidden')
assertEqual(model.showIndicator('EN', false, true), true, 'Latin with another input mode stays available')
assertEqual(model.showIndicator('EN', true, false), true, 'multiple keyboard layouts stay available')
assertEqual(model.showIndicator('FR', true, false), true, 'French and English layouts stay available')
assertEqual(model.inputTooltip({ methods: ['keyboard-fr'] }, 'French', true, 'Super + I'), 'French · Super + I', 'multiple layouts advertise their switching shortcut')

// Native Lua bindings keep a description even when their dispatcher is opaque.
const binding = (mask, key, description = 'Switch input language', submap = '') =>
  `bindd
\tmodmask: ${mask}
\tsubmap: ${submap}
\tkey: ${key}
\tkeycode: 0
\tdescription: ${description}
\tdispatcher: HL.Dispatcher(exec_cmd)
\targ: 265

`
const rebound = model.switchShortcut(binding(72, 'I'))
assertEqual(rebound, 'Super + Alt + I', 'the tooltip resolves a rebound shortcut from live bindings')
assertEqual(model.inputTooltip({}, 'Danish', true, rebound), 'Danish · Super + Alt + I', 'the layout tooltip advertises the actual shortcut')
assertEqual(model.switchShortcut(binding(64, 'SUPER + I')), 'Super + I', 'legacy Lua display keys do not duplicate modifiers')
assertEqual(model.switchShortcut(binding(5, 'space')), 'Ctrl + Shift + space', 'modifier combinations and keysyms survive')
assertEqual(model.switchShortcut(binding(64, 'I') + binding(72, 'I') + binding(64, 'I')), 'Super + I / Super + Alt + I', 'multiple shortcuts are deduplicated')
assertEqual(model.switchShortcut(binding(64, 'I', 'Switch input language back')), '', 'the backwards action is not advertised as the forward action')
assertEqual(model.switchShortcut(binding(64, 'I', 'Switch input language', 'resize')), '', 'a submap-only binding is not advertised globally')
assertEqual(model.switchShortcut(binding(128, 'I') + binding('', 'I')), '', 'unknown or missing modifier masks do not invent a shortcut')
assertEqual(model.switchShortcut(binding(64, '').replace('keycode: 0', 'keycode: 31')), 'Super + code:31', 'a physical-key binding retains its explicit code')
assertEqual(model.switchShortcut(''), '', 'an empty or failed query resolves no shortcut')
assertEqual(model.inputTooltip({}, 'Danish', true, ''), 'Danish', 'an unbound action leaves only the layout name')
assertEqual(model.inputTooltip(japanese, 'English (US)', false, ''), 'Mozc', 'an unresolved input-method shortcut leaves only the engine name')

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
assertEqual(model.isTypedKeyboard('acer-wmi-hotkeys'), false, 'vendor WMI hotkeys are not a keyboard')
assertEqual(model.isTypedKeyboard('acer-wireless-radio-control'), false, 'vendor radio controls are not a keyboard')
assertEqual(model.isTypedKeyboard('asus-wmi-hotkeys-1'), false, 'a duplicate vendor hotkey device is not a keyboard')
assertEqual(model.isTypedKeyboard('dell-wmi'), true, 'an unrecognized device stays available')
assertEqual(model.isTypedKeyboard('logitech-k380'), true, 'an external keyboard stays available')
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
assertEqual(model.eventKeyboardName(rawEvent('asus-wmi-hotkeys,French')), '', 'vendor hotkeys cannot replace the last typed keyboard')
assertEqual(model.eventKeyboardName(rawEvent('asus-wireless-radio-control,English (US)')), '', 'radio events are excluded from keyboard selection')
{
  const widget = require('fs').readFileSync(path.join(root, 'shell/plugins/bar/widgets/KeyboardLayout.qml'), 'utf8')
  assert(!/Component\.onCompleted: \{[\s\S]*?briefsProc\.running = true/.test(widget), 'the xkb layout table is not read at startup')
  const load = new Function('state', 'briefsProc', 'InputMethodState', widget.match(/function loadBriefs\(\) \{([\s\S]*?)\n  \}/)[1].replace(/\b(needsBriefs|briefsRequested)\b/g, 'state.$1'))
  let shortcutRequests = 0
  const inputState = { requestKeybindings: () => shortcutRequests++ }
  const proc = { running: false }
  const state = { needsBriefs: false, briefsRequested: false }
  load(state, proc, inputState)
  assert(!proc.running, 'a seat with one layout and one input method never reads the table')
  assertEqual(shortcutRequests, 0, 'a hidden indicator never requests keybindings')
  state.needsBriefs = true
  load(state, proc, inputState)
  assert(proc.running, 'the table is read once a label needs it')
  proc.running = false
  load(state, proc, inputState)
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

{
  const source = require('fs').readFileSync(path.join(root, 'shell/Commons/InputMethodState.qml'), 'utf8')
  const query = { running: false }
  const output = { text: '' }
  const shared = { keybindings: '', bindingsRequested: false, bindingsPending: false }
  for (const name of ['requestKeybindings', 'refreshKeybindings']) {
    const body = source.match(new RegExp('function ' + name + '\\(\\) \\{([\\s\\S]*?)\\n  \\}'))[1]
    shared[name] = new Function('bindingsQuery', 'with (this) {' + body + '}').bind(shared, query)
  }
  const exited = new Function('root', 'bindingsOutput', 'exitCode', 'exitStatus',
    source.match(/id: bindingsQuery[\s\S]*?onExited: function\(exitCode, exitStatus\) \{([\s\S]*?)\n    \}/)[1])
  shared.requestKeybindings()
  assert(query.running, 'the first visible indicator starts the shared binding query')
  query.running = false
  shared.requestKeybindings()
  assert(!query.running, 'another monitor does not repeat the initial binding query')
  shared.keybindings = 'old bindings'
  shared.refreshKeybindings()
  shared.refreshKeybindings()
  assertEqual(shared.keybindings, '', 'a reload immediately invalidates the old shortcut')
  query.running = false
  output.text = 'superseded bindings'
  exited(shared, output, 0, 0)
  assert(query.running && shared.keybindings === '', 'an in-flight reload discards the superseded result and re-queries')
  query.running = false
  output.text = 'new bindings'
  exited(shared, output, 0, 0)
  assertEqual(shared.keybindings, 'new bindings', 'the latest completed query supplies the shortcut')
  shared.refreshKeybindings()
  query.running = false
  exited(shared, output, 1, 0)
  assertEqual(shared.keybindings, '', 'a failed query leaves no stale shortcut')
}
JS
