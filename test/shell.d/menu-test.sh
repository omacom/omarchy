#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

run_node_test <<'JS'
const fs = require('fs')
const menu = requireFromRoot('shell/plugins/menu/MenuModel.js')
const defaultMenuJsonc = fs.readFileSync(path.join(root, 'default/omarchy/omarchy-menu.jsonc'), 'utf8')

assertDeepEqual(
  menu.summonAction("omarchy-shell shell summon omarchy.speedtest"),
  { id: 'omarchy.speedtest', payload: '{}' },
  'menu runs a bare summon action in-process'
)
assertDeepEqual(
  menu.summonAction(`omarchy-shell shell summon omarchy.image-picker '{"source":"themes"}'`),
  { id: 'omarchy.image-picker', payload: '{"source":"themes"}' },
  'menu keeps a single-quoted summon payload'
)
assertEqual(menu.summonAction("omarchy-shell shell summon omarchy.speedtest && echo done"), null, 'menu leaves compound summon commands to bash')
assertEqual(menu.summonAction(`omarchy-shell shell summon omarchy.x "$(id)"`), null, 'menu leaves shell-expanded payloads to bash')
assertEqual(menu.summonAction("omarchy-theme-set nord"), null, 'menu leaves ordinary actions to bash')

const parsed = menu.parseMenuJsonc(`
{
  // comment
  "items": {
    "root": { "label": "Go" },
    "style": { "label": "Style" },
    "style.theme": {
      "label": "Themes",
      "aliases": "theme",
      "description": "appearance colors",
      "action": "omarchy-theme-set"
    },
  },
}
`)

assertEqual(parsed.length, 3, 'menu parses JSONC with comments and trailing commas')
assertDeepEqual(
  parsed.find(item => item.id === 'style.theme'),
  {
    id: 'style.theme',
    parent: 'style',
    kind: 'action',
    icon: '',
    iconFont: '',
    label: 'Themes',
    title: '',
    target: '',
    description: 'appearance colors',
    action: 'omarchy-theme-set',
    provider: '',
    aliases: ['theme'],
    searchTerms: [],
    when: '',
    checked: '',
    disabled: '',
    alt: ''
  },
  'menu normalizes parsed items'
)

// A watched file read mid-write must keep the rows already there, never
// replace them with nothing, or the menu opens empty until the shell restarts.
const shippedMenu = fs.readFileSync(path.join(root, 'default/omarchy/omarchy-menu.jsonc'), 'utf8')
const goodRows = menu.parseMenuJsonc(shippedMenu)
assert(goodRows.length > 0, 'menu reads the shipped file')
assertEqual(menu.keepMenuRows(goodRows, shippedMenu.slice(0, Math.floor(shippedMenu.length / 2)), true), goodRows, 'menu keeps its rows when the shipped file is read half-written')
assertEqual(menu.keepMenuRows(goodRows, '', true), goodRows, 'menu keeps its rows when the shipped file is read empty')
assertEqual(menu.keepMenuRows(goodRows, '[]', true), goodRows, 'menu keeps its rows when the shipped file reads as something other than a menu')
assertDeepEqual(menu.keepMenuRows(goodRows, '{"items": {"root": {"label": "Go"}}}', true).map(item => item.id), ['root'], 'menu takes the finished file once it reads whole')
assertDeepEqual(menu.keepMenuRows([], shippedMenu, true), goodRows, 'menu takes the shipped file on its first whole read')
const userRows = menu.parseMenuJsonc('{"tools": {"label": "Tools"}}')
assertEqual(menu.keepMenuRows(userRows, '{"tools": {', false), userRows, 'menu keeps the user extension while it is read half-saved')
assertDeepEqual(menu.keepMenuRows(userRows, '// all commented out\n', false), [], 'menu drops the user extension once it is emptied')

const user = [
  menu.normalizeItem('style.theme', { label: 'Theme picker', aliases: ['theme', 'colors'], action: 'custom-theme' }),
  menu.normalizeItem('tools', { label: 'Tools' })
]
const merged = menu.mergeMenuSources(parsed, user)
assertEqual(merged.items['style.theme'].label, 'Theme picker', 'menu user entries override default entries')
assertEqual(merged.items['style.theme'].order, 2, 'menu preserves original order on override')
assert(merged.items.root, 'menu injects root when merging sources')

assertEqual(menu.slugify('Power Saver!'), 'power-saver', 'menu slugifies provider rows')
assertEqual(menu.pathFor(merged.items, 'style.theme'), 'Style › Theme picker', 'menu builds item paths')
assertEqual(menu.parentPathFor(merged.items, 'style.theme'), 'Style', 'menu builds parent paths')
assert(menu.isDescendantOf(merged.items, 'style.theme', 'style'), 'menu detects descendants')
assertEqual(menu.childCount(merged.items, merged.itemOrder, 'style'), 1, 'menu counts children')
assertEqual(menu.labelFor({ id: 'style.theme', label: 'Theme', checked: 'cmd' }, { 'style.theme': true }), 'Theme ✓', 'menu appends checked marker')
assertEqual(menu.labelFor({ id: 'install.browser.zen', label: 'Zen', disabled: 'cmd' }, {}, { 'install.browser.zen': true }), 'Zen ✓', 'menu marks a disabled row as something you already have')
assertEqual(menu.labelFor({ id: 'install.browser.zen', label: 'Zen', disabled: 'cmd' }, {}, { 'install.browser.zen': false }), 'Zen', 'menu leaves an uninstalled row unmarked')

const visibilityItems = {
  hardware: menu.normalizeItem('hardware', { label: 'Hardware' }),
  laptop: menu.normalizeItem('hardware.laptop', { label: 'Laptop', when: 'is-laptop', action: 'toggle-laptop' }),
  nested: menu.normalizeItem('nested', { label: 'Nested' }),
  branch: menu.normalizeItem('nested.branch', { label: 'Branch' }),
  leaf: menu.normalizeItem('nested.branch.leaf', { label: 'Leaf', when: 'has-leaf', action: 'run-leaf' }),
  dynamic: menu.normalizeItem('dynamic', { label: 'Dynamic', provider: 'items' })
}
const visibilityOrder = Object.keys(visibilityItems)
assert(!menu.isVisible(visibilityItems, visibilityOrder, { 'hardware.laptop': false }, visibilityItems.hardware), 'menu hides a submenu with no visible children')
assert(menu.isVisible(visibilityItems, visibilityOrder, { 'hardware.laptop': true }, visibilityItems.hardware), 'menu shows a submenu with a visible child')
assert(!menu.isVisible(visibilityItems, visibilityOrder, { 'nested.branch.leaf': false }, visibilityItems.nested), 'menu hides recursively empty submenus')
assert(menu.isVisible(visibilityItems, visibilityOrder, {}, visibilityItems.dynamic), 'menu keeps provider-backed submenus visible')

// `disabled:` is the softer guard: the row stays listed and only loses the
// cursor, which is how an already-installed app keeps its place in Install.
const installed = menu.normalizeItem('install.browser.zen', { label: 'Zen', disabled: 'omarchy-pkg-present zen-browser-bin', action: 'install-zen' })
assert(menu.isVisible({ 'install.browser.zen': installed }, ['install.browser.zen'], { 'install.browser.zen': false }, installed), 'menu keeps a disabled row visible')
assert(menu.isDisabled({ 'install.browser.zen': true }, installed), 'menu disables a row whose disabled: succeeded')
assert(!menu.isDisabled({ 'install.browser.zen': false }, installed), 'menu leaves a row selectable when its disabled: failed')
assert(!menu.isDisabled({ 'install.browser.zen': true }, visibilityItems.laptop), 'menu never disables a row that declares no disabled:')

// `alt:` swaps a row for another entry while Alt is held, unless that
// entry's own guards rule it out on this machine.
const altItems = {
  'system.reboot': menu.normalizeItem('system.reboot', { label: 'Reboot', alt: 'system.firmware', action: 'reboot' }),
  'system.firmware': menu.normalizeItem('system.firmware', { label: 'Reboot to BIOS', when: 'uefi', disabled: 'busy', action: 'firmware' }),
  'system.lock': menu.normalizeItem('system.lock', { label: 'Lock', alt: 'system', action: 'lock' }),
  system: menu.normalizeItem('system', { label: 'System' })
}
assertEqual(menu.altVariant(altItems, { 'system.firmware': true }, {}, altItems['system.reboot']).id, 'system.firmware', 'menu swaps a row for its alt stand-in')
assertEqual(menu.altVariant(altItems, { 'system.firmware': false }, {}, altItems['system.reboot']), null, 'menu keeps the row when the stand-in is guarded out')
assertEqual(menu.altVariant(altItems, { 'system.firmware': true }, { 'system.firmware': true }, altItems['system.reboot']), null, 'menu keeps the row when the stand-in is disabled')
assertEqual(menu.altVariant(altItems, {}, {}, altItems['system.lock']), null, 'menu only swaps a row for an action')
assertDeepEqual(menu.altVariantIds(altItems, Object.keys(altItems)), { 'system.firmware': true }, 'menu hides only entries that can stand in for another row')
assert(
  menu.displayRow({ 'install.browser.zen': installed }, ['install.browser.zen'], {}, { 'install.browser.zen': true }, installed, '', 0).disabled,
  'menu display rows carry their disabled state'
)

const entry = merged.items['style.theme']
assert(menu.matchesQuery(entry, 'theme', true), 'menu matches labels and aliases')
assert(menu.matchesQuery(entry, 'colors', true), 'menu matches aliases')
assert(!menu.matchesQuery(entry, 'missing', true), 'menu rejects missing terms')
assert(!menu.matchesQuery(entry, 'theme', false), 'menu hides invisible matches')
assert(menu.searchScore(merged.items, entry, 'theme') < menu.searchScore(merged.items, entry, 'appearance'), 'menu scores name matches above description matches')

assertDeepEqual(
  menu.displayRow(merged.items, merged.itemOrder, {}, {}, entry, 'Style', 12, 'search'),
  {
    itemId: 'style.theme',
    disabled: false,
    kind: 'action',
    icon: '',
    iconFont: '',
    appIcon: '',
    appId: '',
    label: 'Theme picker',
    target: 'style.theme',
    detail: 'Style',
    path: 'Style › Theme picker',
    childCount: 0,
    action: 'custom-theme',
    provider: '',
    score: 12,
    section: 'search'
  },
  'menu builds display rows'
)

const defaultItems = menu.parseMenuJsonc(defaultMenuJsonc)
const defaultById = Object.fromEntries(defaultItems.map(item => [item.id, item]))

// Needs the real menu: app rows sort after all menu items, and only at that
// item count does the order tiebreak alone bury an installed app.
const rankBase = menu.mergeMenuSources(defaultItems, [])
const ranked = menu.mergeAppRows(rankBase.items, rankBase.itemOrder, [
  { id: 'apps.brave', parent: 'apps', kind: 'app', label: 'Brave', description: '', aliases: [] },
  { id: 'apps.fontforge', parent: 'apps', kind: 'app', label: 'FontForge', description: '', aliases: [] },
  { id: 'apps.zen', parent: 'apps', kind: 'app', label: 'Zen Browser', description: '', aliases: [] }
])
const rankScore = (id, query) => menu.searchScore(ranked.items, ranked.items[id], query)
assert(
  ['install.browser.brave', 'remove.browser.brave', 'setup.default.browser.brave'].every(
    id => rankScore('apps.brave', 'brave') < rankScore(id, 'brave')
  ),
  'menu ranks an installed app above menu entries matching the query equally well'
)
assert(
  ['install.browser.zen', 'remove.browser.zen', 'setup.default.browser.zen'].every(
    id => rankScore('apps.zen', 'zen') < rankScore(id, 'zen')
  ),
  'menu ranks an app matching the query as a whole word above exact-labeled menu entries'
)
assert(
  rankScore('appearance.font', 'font') < rankScore('apps.fontforge', 'font'),
  'menu keeps a better-matching menu entry above a weaker app match'
)
assert(
  rankScore('system.about', 'abou') < rankScore('appearance.branding.about', 'abou'),
  'menu ranks a shallower equal match above a deeper submenu'
)

// Routing: htop ships `Keywords=system;...`, which app rows carry as aliases.
// An installed app must never capture a menu route (SUPER+ESCAPE opens the
// `system` menu), while its keywords keep working for search.
const routed = menu.mergeAppRows(rankBase.items, rankBase.itemOrder, [
  { id: 'apps.htop', parent: 'apps', kind: 'app', label: 'Htop', description: 'Process Viewer', aliases: ['Process Viewer', 'system', 'process'] }
])
assertEqual(menu.resolveRoute(routed.items, routed.itemOrder, 'system'), 'system', 'menu routes an exact id even when an app keyword matches it')
assertEqual(menu.resolveRoute(routed.items, routed.itemOrder, 'process'), 'process', 'menu never routes to an app row through its keywords')
assertEqual(menu.resolveRoute(routed.items, routed.itemOrder, 'power-menu'), 'system', 'menu routes declared aliases to their item')
assertEqual(menu.resolveRoute(routed.items, routed.itemOrder, 'power_menu'), 'system', 'menu normalizes underscores in routes')
assertEqual(menu.resolveRoute(routed.items, routed.itemOrder, ''), 'root', 'menu routes empty input to root')
assertEqual(menu.resolveRoute(routed.items, routed.itemOrder, 'no-such-route'), 'no-such-route', 'menu falls through to the literal input')
assert(menu.matchesQuery(routed.items['apps.htop'], 'system', true), 'menu still finds an app by its keywords in search')

// Style folded into Appearance; the old route still lands there.
assertEqual(menu.resolveRoute(routed.items, routed.itemOrder, 'style'), 'appearance', 'menu still routes style to Appearance')

// Super+Ctrl+O routes through the `toggle` alias (#15168): dropping it
// silently broke the shortcut, so pin the aliases and both routes.
assertDeepEqual(
  defaultById['trigger.toggle'].aliases,
  ['toggle', 'toggles'],
  'menu keeps the toggle aliases the shortcut routes through'
)
assertEqual(menu.resolveRoute(rankBase.items, rankBase.itemOrder, 'toggle'), 'trigger.toggle', 'menu routes toggle to the Toggle menu')
assertEqual(menu.resolveRoute(rankBase.items, rankBase.itemOrder, 'toggles'), 'trigger.toggle', 'menu routes toggles to the Toggle menu')

// Install rows dim what is already there through `disabled:` (docs/menu.md);
// hiding one on a presence check makes installed software vanish from the
// catalog it was installed from. Remove rows are the opposite.
const presenceCheck = /omarchy-(pkg|cmd)-(present|missing)|\.desktop\b/
assertDeepEqual(
  defaultItems.filter(item => item.id.startsWith('install.') && item.action && presenceCheck.test(item.when)).map(item => item.id),
  [],
  'menu never hides an Install row because the software is already there'
)
assert(
  defaultItems.filter(item => item.id.startsWith('remove.')).every(item => !item.disabled),
  'menu hides Remove rows rather than dimming them'
)

// Exactly the bar's current background is checked. Ask bash, against a
// shell.json in each state, which rows it checks.
{
  const os = require('os')
  const { execFileSync } = require('child_process')
  const home = fs.mkdtempSync(path.join(os.tmpdir(), 'menu-bar-background-'))
  fs.mkdirSync(path.join(home, '.config/omarchy'), { recursive: true })
  const checked = bar => {
    fs.writeFileSync(path.join(home, '.config/omarchy/shell.json'), JSON.stringify({ bar }))
    return ['opaque', 'glassy', 'clear'].filter(look => {
      try {
        execFileSync('bash', ['-c', defaultById[`appearance.top-bar.background.${look}`].checked], { env: { ...process.env, HOME: home, OMARCHY_PATH: root, PATH: `${root}/bin:${process.env.PATH}` } })
        return true
      } catch (e) {
        return false
      }
    })
  }
  assertDeepEqual(checked({}), ['opaque'], 'menu checks Opaque Bar while the bar is opaque')
  assertDeepEqual(checked({ background: 'glassy' }), ['glassy'], 'menu checks Glassy Bar while the bar is glassy')
  assertDeepEqual(checked({ background: 'none' }), ['clear'], 'menu checks Clear Bar while the bar has no background')
  assertDeepEqual(checked({ transparent: true }), ['clear'], 'menu checks Clear Bar for a bar made transparent before backgrounds')
  fs.rmSync(home, { recursive: true, force: true })
}

// The dock only appears on floating workspaces, so its settings only show
// there. Ask bash, against a stubbed layout for the active workspace.
{
  const os = require('os')
  const { execFileSync } = require('child_process')
  const stub = fs.mkdtempSync(path.join(os.tmpdir(), 'menu-dock-layout-'))
  const shown = layout => {
    fs.writeFileSync(path.join(stub, 'omarchy-hyprland-workspace-layout-current'), `#!/bin/bash\necho ${layout}\n`, { mode: 0o755 })
    try {
      execFileSync('bash', ['-c', defaultById['appearance.dock'].when], { env: { ...process.env, PATH: `${stub}:${process.env.PATH}` } })
      return true
    } catch (e) {
      return false
    }
  }
  assert(shown('floating'), 'menu shows Appearance > Dock on a floating workspace')
  assert(!shown('dwindle') && !shown('scrolling'), 'menu hides Appearance > Dock on a tiled workspace')
  fs.rmSync(stub, { recursive: true, force: true })
}

// Auto-hide Dock shows while the dock stays up, and Always-on Dock while it
// hides. Ask bash, against a shell.json in each state, which rows it shows.
{
  const os = require('os')
  const { execFileSync } = require('child_process')
  const home = fs.mkdtempSync(path.join(os.tmpdir(), 'menu-dock-autohide-'))
  fs.mkdirSync(path.join(home, '.config/omarchy'), { recursive: true })
  const shown = dock => {
    fs.writeFileSync(path.join(home, '.config/omarchy/shell.json'), JSON.stringify({ version: 1, dock }))
    return ['autohide', 'always-on'].filter(row => {
      try {
        execFileSync('bash', ['-c', defaultById[`appearance.dock.${row}`].when], { env: { ...process.env, HOME: home, OMARCHY_PATH: root, PATH: `${root}/bin:${process.env.PATH}` } })
        return true
      } catch (e) {
        return false
      }
    })
  }
  assertDeepEqual(shown({}), ['autohide'], 'menu offers Auto-hide Dock while the dock stays up')
  assertDeepEqual(shown({ autohide: true }), ['always-on'], 'menu offers Always-on Dock while the dock hides')
  fs.rmSync(home, { recursive: true, force: true })
}

// Exactly the dock's current position is checked, and a shell.json without
// one has the dock at the bottom.
{
  const os = require('os')
  const { execFileSync } = require('child_process')
  const home = fs.mkdtempSync(path.join(os.tmpdir(), 'menu-dock-position-'))
  fs.mkdirSync(path.join(home, '.config/omarchy'), { recursive: true })
  const checked = dock => {
    fs.writeFileSync(path.join(home, '.config/omarchy/shell.json'), JSON.stringify({ version: 1, dock }))
    return ['top', 'bottom', 'left', 'right'].filter(position => {
      try {
        execFileSync('bash', ['-c', defaultById[`appearance.dock.position.${position}`].checked], { env: { ...process.env, HOME: home, OMARCHY_PATH: root, PATH: `${root}/bin:${process.env.PATH}` } })
        return true
      } catch (e) {
        return false
      }
    })
  }
  assertDeepEqual(checked(undefined), ['bottom'], 'menu checks Bottom Dock while no position is set')
  assertDeepEqual(checked({ position: 'left' }), ['left'], 'menu checks Left Dock while the dock is on the left')
  fs.rmSync(home, { recursive: true, force: true })
}

const clockModel = requireFromRoot('shell/plugins/panels/clock/Model.js')
const clockRows = defaultItems.filter(item => item.parent === 'appearance.top-bar.indicators.clock')
// Each row hands bash its format, so ask bash what it hands over.
const clockRowFormats = key => clockRows
  .filter(item => item.action.startsWith(`omarchy-bar set omarchy.clock ${key} `))
  .map(item => require('child_process').execFileSync('bash', ['-c', item.action.replace(`omarchy-bar set omarchy.clock ${key} `, 'printf %s ')], { encoding: 'utf8' }))
assertDeepEqual(clockRowFormats('format'), clockModel.clockFormats(false), 'menu spells out every horizontal clock format')
assertDeepEqual(clockRowFormats('verticalFormat'), clockModel.clockFormats(true), 'menu spells out every vertical clock format')

// A toggle is a pair of rows named for what picking them does: the -on row
// shows while the feature is off and turns it on, the -off row the reverse.
{
  const pairs = defaultItems.filter(item => item.id.endsWith('-on') && defaultById[item.id.replace(/-on$/, '-off')])
  assert(pairs.length >= 14, 'menu names every toggle by what picking it does', String(pairs.length))
  for (const on of pairs) {
    const off = defaultById[on.id.replace(/-on$/, '-off')]
    assertEqual(off.action, on.action, `${on.id} and its -off row flip the same toggle`)
    assert(on.when && off.when && on.when !== off.when, `${on.id} and its -off row show in opposite states`)
  }
}

// App rows are rebuilt from scratch on every desktop-entry rescan. The merge
// must be idempotent and must never carry an orphan id forward, or a single
// lost write turns into an app listed twice (and thrice, and so on).
const nonAppItems = {
  root: { id: 'root', kind: 'menu', label: 'Go' },
  apps: { id: 'apps', kind: 'menu', label: 'Apps', provider: 'apps' }
}
const nonAppOrder = ['root', 'apps']
const appRowsFor = ids => ids.map(id => ({ id: `apps.${id}`, kind: 'app', parent: 'apps', label: id, appId: id }))

const firstMerge = menu.mergeAppRows(nonAppItems, nonAppOrder, appRowsFor(['alacritty', 'youtube']))
assert(
  firstMerge.itemOrder.join(',') === 'root,apps,apps.alacritty,apps.youtube',
  'app merge appends app rows after the static menu items'
)

const secondMerge = menu.mergeAppRows(firstMerge.items, firstMerge.itemOrder, appRowsFor(['alacritty', 'youtube']))
assert(
  secondMerge.itemOrder.join(',') === 'root,apps,apps.alacritty,apps.youtube',
  'repeating the app merge with the same entries does not duplicate rows'
)

assert(
  menu.mergeAppRows(secondMerge.items, secondMerge.itemOrder, appRowsFor(['alacritty'])).itemOrder.join(',')
    === 'root,apps,apps.alacritty',
  'app merge drops rows for entries that went away'
)

assert(
  menu.mergeAppRows(nonAppItems, nonAppOrder, appRowsFor(['youtube', 'youtube'])).itemOrder.join(',')
    === 'root,apps,apps.youtube',
  'app merge lists an app once even when two desktop entries share an id'
)

const orphanedItems = {}
for (const key in firstMerge.items) orphanedItems[key] = firstMerge.items[key]
delete orphanedItems['apps.youtube']
const healed = menu.mergeAppRows(orphanedItems, firstMerge.itemOrder, appRowsFor(['alacritty', 'youtube']))
assert(
  healed.itemOrder.join(',') === 'root,apps,apps.alacritty,apps.youtube'
    && !!healed.items['apps.youtube'],
  'app merge heals an order entry whose item went missing instead of duplicating it'
)

assert(
  !firstMerge.items['apps.youtube'].hasOwnProperty('__probe')
    && (() => {
      const before = Object.keys(nonAppItems).length
      menu.mergeAppRows(nonAppItems, nonAppOrder, appRowsFor(['gimp']))
      return Object.keys(nonAppItems).length === before
    })(),
  'app merge leaves the map it was handed untouched'
)

const providerRowsFor = values => values.map(value => ({ id: `style.font.${value}`, kind: 'action', parent: 'style.font', label: value }))
const firstProviderMerge = menu.swapProviderRows(nonAppItems, nonAppOrder, 'style.font', providerRowsFor(['mono', 'serif']))
assert(
  firstProviderMerge.itemOrder.join(',') === 'root,apps,style.font.mono,style.font.serif',
  'provider merge appends its rows'
)
assert(
  menu.swapProviderRows(firstProviderMerge.items, firstProviderMerge.itemOrder, 'style.font', providerRowsFor(['mono', 'serif']))
    .itemOrder.join(',') === 'root,apps,style.font.mono,style.font.serif',
  'repeating a provider merge does not duplicate rows'
)
// A plugin drops out of the Enable list the moment it is enabled, so a
// provider that runs again has to lose the rows it contributed last time.
const rerunProviderMerge = menu.swapProviderRows(firstProviderMerge.items, firstProviderMerge.itemOrder, 'style.font', providerRowsFor(['serif']))
assert(
  rerunProviderMerge.itemOrder.join(',') === 'root,apps,style.font.serif',
  'provider merge drops rows the provider no longer lists'
)
assert(
  menu.swapProviderRows(firstProviderMerge.items, firstProviderMerge.itemOrder, 'style.other', providerRowsFor([]))
    .itemOrder.join(',') === 'root,apps,style.font.mono,style.font.serif',
  'provider merge leaves rows belonging to another provider alone'
)

assertDeepEqual(
  menu.parseKeybindingsRecords(
    'SUPER + K                           → Keybindings\tlua\thl.dsp.global("omarchy:menu.learn.keybindings")\n'
    + 'SUPER + RETURN                      → Terminal\texec\tprintf "a\tb"\n'
    + 'SUPER + Z                           → Zoom in\t\t\n'
    + '\n'
  ),
  {
    entries: [
      { label: 'SUPER + K                           → Keybindings', dispatcher: 'lua', arg: 'hl.dsp.global("omarchy:menu.learn.keybindings")' },
      { label: 'SUPER + RETURN                      → Terminal', dispatcher: 'exec', arg: 'printf "a\tb"' },
      { label: 'SUPER + Z                           → Zoom in', dispatcher: '', arg: '' }
    ],
    options: [
      'SUPER + K                           → Keybindings',
      'SUPER + RETURN                      → Terminal',
      'SUPER + Z                           → Zoom in'
    ]
  },
  'keybindings record parser keeps tabs inside command arguments and skips blank lines'
)

// Every glyph the menu draws in the Omarchy font is one the font carries. The
// ranges come from the font itself, so a new glyph needs no edit here.
const fontRanges = require('child_process')
  .execFileSync('fc-query', ['--format=%{charset}', path.join(root, 'default/fonts/omarchy/omarchy.ttf')], { encoding: 'utf8' })
  .trim().split(/\s+/).map(range => range.split('-').map(hex => parseInt(hex, 16)))
const fontGlyphRows = defaultItems.filter(item => item.iconFont === 'omarchy')
assert(fontGlyphRows.length > 0, 'the menu draws some glyphs in the Omarchy font')
const missingGlyphs = fontGlyphRows
  .flatMap(item => [...item.icon].map(glyph => ({ id: item.id, code: glyph.codePointAt(0) })))
  .filter(({ code }) => !fontRanges.some(([start, end = start]) => code >= start && code <= end))
  .map(({ id, code }) => `${id} U+${code.toString(16)}`)
assertDeepEqual(missingGlyphs, [], 'every menu glyph drawn in the Omarchy font is one the font carries')
JS

# Verify omarchy-menu-select and omarchy-menu-input serialize payloads faithfully
# (including UTF-8, tabs, dash-prefixed options, multi-select, and dimensions).
select_tmp=$(mktemp -d)
trap 'rm -rf "$select_tmp"' EXIT
mkdir -p "$select_tmp/bin"

cat >"$select_tmp/bin/omarchy-shell" <<'SH'
#!/bin/bash
payload="$4"
printf '%s\n' "$payload" >"$PAYLOAD_OUT"
options_file=$(jq -r '.optionsFile // empty' <<<"$payload")
if [[ -n $options_file ]]; then
  cp "$options_file" "$PAYLOAD_OUT.options"
fi
sel_file=$(jq -r '.selectionFile' <<<"$payload")
done_file=$(jq -r '.doneFile' <<<"$payload")
printf '%s\n' "$FAKE_ANSWER" >"$sel_file"
: >"$done_file"
SH
chmod +x "$select_tmp/bin/omarchy-shell"

select_answer=$(PATH="$select_tmp/bin:$PATH" PAYLOAD_OUT="$select_tmp/select.json" FAKE_ANSWER="-dash" \
  "$ROOT/bin/omarchy-menu-select" "Pick (æøå)" "-dash" $'✓\tSecond\tsub' -- \
  --multiple --selected "-dash" --selected $'Second\tsub' \
  --on-change '["apply","--set"]' --change-key "k1" --width 640 --maxheight 480)
[[ $select_answer == "-dash" ]] || fail "omarchy-menu-select returns the selected value" "$select_answer"
jq -e --slurpfile options "$select_tmp/select.json.options" '
  .mode == "select"
  and .prompt == "Pick (æøå)"
  and $options == [["-dash", "✓\tSecond\tsub"]]
  and .multiple == true
  and .selected == ["-dash", "Second\tsub"]
  and .onChange == ["apply", "--set"]
  and .changeKey == "k1"
  and .width == 640
  and .maxHeight == 480
' "$select_tmp/select.json" >/dev/null || fail "omarchy-menu-select builds the expected JSON payload" "$(cat "$select_tmp/select.json")"
pass "omarchy-menu-select builds the expected JSON payload"

# Empty selected list and omitted dimensions stay clean (empty array, no null width/maxHeight).
PATH="$select_tmp/bin:$PATH" PAYLOAD_OUT="$select_tmp/select-min.json" FAKE_ANSWER="One" \
  "$ROOT/bin/omarchy-menu-select" "Simple" "One" >/dev/null
jq -e '
  .mode == "select"
  and .multiple == false
  and .selected == []
  and (has("width") | not)
  and (has("maxHeight") | not)
' "$select_tmp/select-min.json" >/dev/null || fail "omarchy-menu-select omits unset dimensions and keeps selected empty" "$(cat "$select_tmp/select-min.json")"
pass "omarchy-menu-select omits unset dimensions and keeps selected empty"

input_answer=$(PATH="$select_tmp/bin:$PATH" PAYLOAD_OUT="$select_tmp/input.json" FAKE_ANSWER="15" \
  "$ROOT/bin/omarchy-menu-input" "Reminder (æøå)" --width 400)
[[ $input_answer == "15" ]] || fail "omarchy-menu-input returns the entered value" "$input_answer"
jq -e '
  .mode == "input"
  and .prompt == "Reminder (æøå)"
  and .width == 400
' "$select_tmp/input.json" >/dev/null || fail "omarchy-menu-input builds the expected JSON payload" "$(cat "$select_tmp/input.json")"
pass "omarchy-menu-input builds the expected JSON payload"

# The select and input menus trade their data with omarchy-menu-select and
# omarchy-menu-input through the caller's private files. None of it may travel
# on a command line: every user on the machine can read /proc/<pid>/cmdline,
# and Linux refuses a single argument of 128 KiB or more.
transport_tmp="$select_tmp/transport"
mkdir -p "$transport_tmp"

# omarchy-menu-select against a stand-in shell that answers the way the real
# one does: it reads the options file, writes the pick and creates the done
# file. The stand-in and jq log every argument they get, so an option that
# reaches either command line is caught.
stub_bin="$transport_tmp/bin"
mkdir -p "$stub_bin"
cat >"$stub_bin/jq" <<STUB
#!/bin/bash
printf '%s\n' "\$@" >>"\$MENU_TEST_DIR/argv"
exec $(command -v jq) "\$@"
STUB
cat >"$stub_bin/omarchy-shell" <<'STUB'
#!/bin/bash
printf '%s\n' "$@" >>"$MENU_TEST_DIR/argv"
payload=$4
printf '%s' "$payload" >"$MENU_TEST_DIR/payload.json"
options_file=$(jq -r '.optionsFile // empty' <<<"$payload")
if [[ -n $options_file ]]; then
  cp "$options_file" "$MENU_TEST_DIR/options.json"
  stat -c %a "$(dirname "$options_file")" >"$MENU_TEST_DIR/options.mode"
fi
if [[ -n ${MENU_TEST_PICK:-} ]]; then
  printf '%s\n' "$MENU_TEST_PICK" >"$(jq -r .selectionFile <<<"$payload")"
fi
: >"$(jq -r .doneFile <<<"$payload")"
STUB
chmod +x "$stub_bin/jq" "$stub_bin/omarchy-shell"

menu_select() {
  local case_dir=$1
  shift
  MENU_TEST_DIR="$case_dir" PATH="$stub_bin:$PATH" "$ROOT/bin/omarchy-menu-select" "$@"
}

large="$transport_tmp/large"
mkdir -p "$large"
seq -f 'menu-transport-row-%06g-padding-padding' 4000 >"$large/rows"
pick=$(MENU_TEST_PICK=menu-transport-row-004000-padding-padding menu_select "$large" "Pick a row" <"$large/rows") \
  || fail "a list over 128 KiB opens the menu"
[[ $pick == "menu-transport-row-004000-padding-padding" ]] || fail "a pick from a large list comes back" "Got: $pick"
jq -e '.prompt == "Pick a row" and has("optionsFile") and (has("options") | not)' "$large/payload.json" >/dev/null \
  || fail "the payload names the options file instead of carrying the options" "$(<"$large/payload.json")"
cmp -s <(jq -r '.[]' "$large/options.json") "$large/rows" || fail "the options file holds every row in order"
(( $(stat -c %s "$large/options.json") > 131072 )) || fail "the large list is past Linux's single-argument limit"
[[ $(<"$large/options.mode") == "700" ]] || fail "the options file is in a private directory while the menu is open" "Mode: $(<"$large/options.mode")"
jq -e '.selectionFileCreated == true' "$large/payload.json" >/dev/null || fail "omarchy-menu-select says it created its selection file" "$(<"$large/payload.json")"
[[ -s $large/argv ]] || fail "jq and the shell stand-in log their arguments"
if grep -qF menu-transport-row "$large/argv"; then
  fail "no option reaches a command line" "$(grep -F menu-transport-row "$large/argv" | head -3)"
fi
[[ ! -e $(jq -r .optionsFile "$large/payload.json") ]] || fail "the options file is removed after the pick"
pass "a 4,000-row list on stdin reaches the menu in a private file and stays off every command line"

arguments="$transport_tmp/arguments"
mkdir -p "$arguments"
glyph=$(printf '\xef\x82\xac')
options=("$glyph"$'\tFirefox\tWeb browser' 'Ünïcode café' $'two\nlines')
MENU_TEST_PICK='Ünïcode café' menu_select "$arguments" Browser "${options[@]}" -- --width 400 >"$arguments/out" \
  || fail "options given as arguments open the menu"
[[ $(<"$arguments/out") == 'Ünïcode café' ]] || fail "a pick from argument options comes back" "Got: $(<"$arguments/out")"
[[ $(jq -c . "$arguments/options.json") == "$(jq -cn '$ARGS.positional' --args "${options[@]}")" ]] \
  || fail "options keep their glyphs, tabs, newlines and Unicode" "$(<"$arguments/options.json")"
jq -e '.width == 400 and .prompt == "Browser"' "$arguments/payload.json" >/dev/null || fail "menu arguments still reach the payload"
if grep -qF 'café' "$arguments/argv"; then
  fail "options given as arguments go no further than omarchy-menu-select's own command line"
fi
pass "options given as arguments keep their glyphs, tabs, newlines and Unicode and go no further"

cancelled="$transport_tmp/cancelled"
mkdir -p "$cancelled"
status=0
menu_select "$cancelled" Pick one two >"$cancelled/out" || status=$?
(( status == 1 )) && [[ ! -s $cancelled/out ]] || fail "a cancelled menu exits 1 with no output" "Status: $status"
[[ ! -e $(jq -r .optionsFile "$cancelled/payload.json") ]] || fail "a cancelled menu removes its options file"
pass "a cancelled menu exits 1 and removes its options file"

input="$transport_tmp/input"
mkdir -p "$input"
typed=$(MENU_TEST_DIR="$input" MENU_TEST_PICK='typed café' PATH="$stub_bin:$PATH" "$ROOT/bin/omarchy-menu-input" Name) \
  || fail "an input prompt returns what was typed"
[[ $typed == 'typed café' ]] || fail "an input prompt returns what was typed" "Got: $typed"
jq -e '.mode == "input" and .selectionFileCreated == true' "$input/payload.json" >/dev/null \
  || fail "omarchy-menu-input says it created its selection file" "$(<"$input/payload.json")"
pass "omarchy-menu-input says it created its selection file and returns what was typed"

# Run the shipped read and write paths against real files with Quickshell's
# FileView, offscreen and on a private runtime directory.
mkdir -p "$transport_tmp/qml" "$transport_tmp/run" "$transport_tmp/files"
chmod 700 "$transport_tmp/run"
(
  umask 077
  for name in pick pick-again cancelled; do
    : >"$transport_tmp/files/$name"
  done
)
ROOT="$ROOT" FIXTURE="$transport_tmp" node <<'JS'
const fs = require('fs')
const path = require('path')
const source = fs.readFileSync(path.join(process.env.ROOT, 'shell/plugins/menu/Menu.qml'), 'utf8')
const extract = (pattern, name) => {
  const match = source.match(pattern)
  if (!match) {
    console.error(`Menu.qml has no ${name}`)
    process.exit(1)
  }
  return match[0]
}
const parts = [
  extract(/  Component \{\n    id: requestFileWriter[\s\S]*?\n  \}/, 'requestFileWriter'),
  extract(/  Component \{\n    id: requestFileReader[\s\S]*?\n  \}/, 'requestFileReader'),
  extract(/  function finishRequest\([\s\S]*?\n  \}/, 'finishRequest'),
  extract(/  function writeRequestFile\([\s\S]*?\n  \}/, 'writeRequestFile'),
  extract(/  function requestFileExists\([\s\S]*?\n  \}/, 'requestFileExists'),
  extract(/  function readOptionsFile\([\s\S]*?\n  \}/, 'readOptionsFile'),
].join('\n')
const files = path.join(process.env.FIXTURE, 'files')
const rows = Array.from({ length: 10000 }, (_, i) => `\uf0ac\tRow ${i} ünïcode\tsubtext ${i}`)
fs.writeFileSync(path.join(files, 'rows.json'), JSON.stringify(rows))
fs.writeFileSync(path.join(files, 'broken.json'), '["unterminated')
fs.writeFileSync(path.join(files, 'object.json'), '{"options":["a"]}')
fs.writeFileSync(path.join(files, 'empty.json'), '')
fs.writeFileSync(path.join(process.env.FIXTURE, 'qml', 'shell.qml'), `
import QtQuick
import Quickshell
import Quickshell.Io
ShellRoot {
  id: root
  property bool requestActive: false
  property string selectionFile: ""
  property bool selectionFileCreated: false
  property string doneFile: ""
  property bool opened: true
  property string dir: ${JSON.stringify(files)}
  property string expectedRows: ${JSON.stringify(JSON.stringify(rows))}
${parts}
  Component { id: reader; FileView { blockLoading: true; printErrors: false } }
  function read(name) {
    var file = reader.createObject(root, { path: dir + "/" + name })
    file.waitForJob()
    var text = file.loaded ? file.text() : null
    file.destroy()
    return text
  }
  // Opens a request the way openDmenu does, from a caller that created its
  // selection file unless told otherwise.
  function request(selectionName, created) {
    requestActive = true
    selectionFile = dir + "/" + selectionName
    selectionFileCreated = created !== false
    doneFile = dir + "/" + selectionName + ".done"
  }
  function check(condition, message) {
    if (!condition) throw new Error(message)
  }
  Component.onCompleted: {
    for (var i = 0; i < 20; i++)
      check(JSON.stringify(readOptionsFile(dir + "/rows.json")) === expectedRows, "10,000 rows read back whole")
    writeRequestFile(dir + "/rows.json", JSON.stringify(["replaced"]) + "\\n")
    check(JSON.stringify(readOptionsFile(dir + "/rows.json")) === '["replaced"]', "a rewritten file reads fresh")
    check(readOptionsFile(dir + "/missing.json") === null, "a missing file reads as unreadable")
    check(readOptionsFile(dir + "/broken.json") === null, "malformed JSON reads as unreadable")
    check(readOptionsFile(dir + "/object.json") === null, "JSON that is not a list reads as unreadable")
    check(readOptionsFile(dir + "/empty.json") === null, "an empty file reads as unreadable")

    var pick = "Firefox\\tünïcode subtext"
    request("pick")
    finishRequest(pick)
    check(read("pick") === pick + "\\n", "a pick reaches the selection file")
    check(read("pick.done") !== null, "a pick creates the done file")
    check(!requestActive && selectionFile === "" && doneFile === "", "a finished request lets go of its files")

    request("pick-again")
    finishRequest(pick)
    check(read("pick-again") === pick + "\\n", "the same pick reaches the next request's file")

    request("cancelled")
    finishRequest(null)
    check(read("cancelled") === "", "a cancel leaves the selection empty")
    check(read("cancelled.done") !== null, "a cancel creates the done file")

    check(requestFileExists(dir + "/cancelled") && !requestFileExists(dir + "/gone"), "an empty selection file counts as there, and a missing one as gone")

    // These callers created their selection files, then gave up and removed them.
    request("gone")
    finishRequest(pick)
    check(read("gone") === null && read("gone.done") === null, "a pick for a caller that gave up writes neither file")
    check(!requestActive && selectionFile === "" && !selectionFileCreated && doneFile === "", "a request whose caller gave up lets go of its files")
    request("gone-cancelled")
    finishRequest(null)
    check(read("gone-cancelled.done") === null, "a cancel for a caller that gave up creates no done file")

    // This caller leaves creating its selection file to the shell.
    request("uncreated", false)
    finishRequest(pick)
    check(read("uncreated") === pick + "\\n" && read("uncreated.done") !== null, "a caller that never created its selection file still gets its pick")

    requestActive = true
    selectionFile = ""
    doneFile = dir + "/bare.done"
    finishRequest(null)
    check(read("bare.done") !== null, "a request without a selection file still gets its done file")

    finishRequest("late")
    check(!opened, "a finish without a request only closes the menu")
    console.log("MENU_TRANSPORT_FILEVIEW_PASS")
    Qt.callLater(function() { Qt.quit() })
  }
}
`)
JS
if command -v quickshell >/dev/null 2>&1; then
  if ! QT_QPA_PLATFORM=offscreen QT_QUICK_BACKEND=software QT_QPA_PLATFORMTHEME= QT_STYLE_OVERRIDE= \
    XDG_RUNTIME_DIR="$transport_tmp/run" timeout 15 quickshell -p "$transport_tmp/qml" --no-color >"$transport_tmp/qml.log" 2>&1; then
    cat "$transport_tmp/qml.log" >&2
    fail "menu transport FileView fixture exits cleanly"
  fi
  grep -q 'MENU_TRANSPORT_FILEVIEW_PASS' "$transport_tmp/qml.log" || { cat "$transport_tmp/qml.log" >&2; fail "real FileView reads menu rows and writes menu results"; }
  [[ $(stat -c %a "$transport_tmp/files/pick") == "600" ]] || fail "a pick keeps the selection file private" "Mode: $(stat -c %a "$transport_tmp/files/pick")"
  for name in gone gone.done gone-cancelled gone-cancelled.done; do
    [[ ! -e $transport_tmp/files/$name ]] || fail "nothing is written for a caller that gave up" "Found: $name"
  done
  pass "real FileView reads rows fresh, refuses unreadable ones, writes picks and cancels into the caller's private files, writes nothing for a caller that gave up, and still answers one that never created its selection file"
else
  skip "quickshell unavailable; skipping the real FileView reads and writes"
fi
