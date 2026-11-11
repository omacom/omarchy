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
    disabled: ''
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

const numbers = requireFromRoot('shell/Commons/Numbers.js')
for (const [value, written] of [
  [0, '0'], [-0, '0'], [14, '14'], [1.5, '1.5'], [0.000001, '0.000001'], [1e-7, '0.0000001'], [1.1e-7, '0.00000011'], [-2.5e-8, '-0.000000025'],
  ['1.1e-7', '0.00000011'], [999999999999999900000, '999999999999999900000'], [1e21, '1000000000000000000000'], [1.5e21, '1500000000000000000000'], [-1e21, '-1000000000000000000000']
]) {
  assertEqual(numbers.plain(value), written, `${value} is written in plain digits`)
}
assertEqual(numbers.format(1.1e-7, undefined, ',', '0'), '0,00000011', 'a small number keeps its digits in a comma-decimal language')
assertEqual(numbers.format(1.1e-7, undefined, '.', '٠'), '٠.٠٠٠٠٠٠١١', 'a small number keeps its digits in a language with its own numerals')
assertEqual(numbers.format(1.5, 2, '.', '0'), '1.50', 'asking for decimals still pads them')

const calc = requireFromRoot('shell/plugins/menu/Calc.js')
for (const [text, answer] of [
  // Precedence and grouping
  ['2 + 3 * 4', '14'], ['(2+3)*4', '20'], ['2+3+4', '9'], ['10-2-3', '5'], ['2*3/4', '1.5'], ['100/10/5', '2'], ['((1+2))*3', '9'], ['-(2+3)*2', '-10'],
  // Every spelling of multiply and divide
  ['3x4', '12'], ['3X4', '12'], ['3×4', '12'], ['3*4', '12'], ['6÷2', '3'], ['6/4', '1.5'], ['3 x 4', '12'],
  // Signs
  ['2*-3', '-6'], ['-2+5', '3'], ['+2+5', '7'], ['--2+1', '3'], ['2--3', '5'], ['2+-+-3', '5'], ['7-8', '-1'],
  // Zero, and never a negative one
  ['0*5', '0'], ['0*-1', '0'], ['5-5', '0'], ['0/5', '0'],
  // Decimals, and float noise that must not show
  ['.5+.5', '1'], ['5.+1', '6'], ['0.1+0.2', '0.3'], ['0.1*3', '0.3'], ['0.1+0.7', '0.8'], ['1.1*1.1', '1.21'], ['1.005*1000', '1005'], ['1/3', '0.333333333333333'], ['2/3', '0.666666666666667'],
  // Digits that were typed are kept
  ['1000000000000+1', '1000000000001'], ['9007199254740990+1', '9007199254740991'], ['123456789012.5+1', '123456789013.5'],
  // Whitespace
  ['  2 + 2  ', '4'], ['2\t+\t2', '4'],
  // Reads as a sum even though it might be a date
  ['2024-11-05', '2008']
]) {
  assertEqual(calc.evaluate(text), answer, `the calculator answers "${text}"`)
}
for (const [text, written] of [['0.000001/10', '0.0000001'], ['0.0000001*0.0000001', '0.00000000000001'], ['-0.000001/10', '-0.0000001']]) {
  assertEqual(numbers.plain(calc.evaluate(text)), written, `a tiny answer to "${text}" is written out`)
}
for (const text of [
  // Nothing to calculate
  '', ' ', null, undefined, '5', '-5', '+5', '(5)', '5.5',
  // Unfinished or malformed
  '2+', '+', '*', '*2', '2*', '2+*3', '(2+3', '2+3)', '()', '()+1', '2(3)', '(2)(3)', '2 3+1', 'x', '2x', 'x2', '1.2.3', '1.2.3+1', '..+1',
  // No answer
  '1/0', '0/0', '-1/0', '5+1/0',
  // Past what a double can hold exactly
  '9007199254740992+1', '12345678901234567+1', '12345678901234567-12345678901234566', '99999999*99999999', '9007199254740991+1',
  // Syntax that isn't supported
  '1,000+1', '1e5+1', '2^3', '5%', '٣+٤',
  // Ordinary searches and anything that could be a command
  '7-zip', 'firefox 2+2', '2+2 firefox', '$(id)+1', '1+1;id', '1+`id`', '1+1|id',
  // Too long to be typed by hand, and deep enough to overflow the stack
  '('.repeat(5000) + '1+1' + ')'.repeat(5000), '1' + '+1'.repeat(200)
]) {
  assertEqual(calc.evaluate(text), '', `the calculator leaves ${JSON.stringify(String(text).slice(0, 30))} to search`)
}

const currency = requireFromRoot('shell/plugins/menu/Currency.js')
for (const [text, amount, from, to] of [
  // Amount and currency, in either order
  ['INR 100 to USD', 100, 'inr', 'usd'], ['100 INR to USD', 100, 'inr', 'usd'], ['inr100 to usd', 100, 'inr', 'usd'], ['100inr to usd', 100, 'inr', 'usd'], ['$5 to INR', 5, 'usd', 'inr'], ['5$ to inr', 5, 'usd', 'inr'],
  // Symbols
  ['₹100 in $', 100, 'inr', 'usd'], ['€5 to £', 5, 'eur', 'gbp'], ['£5 to €', 5, 'gbp', 'eur'], ['¥500 to usd', 500, 'jpy', 'usd'], ['₩1000 to usd', 1000, 'krw', 'usd'], ['₽100 to usd', 100, 'rub', 'usd'], ['₺100 to usd', 100, 'try', 'usd'], ['₫1000 to usd', 1000, 'vnd', 'usd'], ['₱100 to usd', 100, 'php', 'usd'], ['฿100 to usd', 100, 'thb', 'usd'],
  // The other dollars
  ['a$5 to usd', 5, 'aud', 'usd'], ['c$5 to usd', 5, 'cad', 'usd'], ['s$5 to usd', 5, 'sgd', 'usd'], ['hk$5 to usd', 5, 'hkd', 'usd'], ['nz$5 to usd', 5, 'nzd', 'usd'], ['us$5 to inr', 5, 'usd', 'inr'], ['usd$5 to inr', 5, 'usd', 'inr'],
  // Names
  ['100 rupees to dollars', 100, 'inr', 'usd'], ['100 rupee in dollar', 100, 'inr', 'usd'], ['rs 100 to usd', 100, 'inr', 'usd'], ['rs.100 to usd', 100, 'inr', 'usd'], ['100 rs. to usd', 100, 'inr', 'usd'], ['5 usd to rs.', 5, 'usd', 'inr'], ['5 quid to euros', 5, 'gbp', 'eur'], ['5 bucks to rupees', 5, 'usd', 'inr'], ['10 yuan to usd', 10, 'cny', 'usd'], ['10 rmb to usd', 10, 'cny', 'usd'], ['500 yen to usd', 500, 'jpy', 'usd'], ['500 won to usd', 500, 'krw', 'usd'], ['5 rubles to usd', 5, 'rub', 'usd'],
  // Connectors, spaced and not
  ['5 usd in inr', 5, 'usd', 'inr'], ['5 usd into inr', 5, 'usd', 'inr'], ['5 usd as inr', 5, 'usd', 'inr'], ['5 usd = inr', 5, 'usd', 'inr'], ['5usd=inr', 5, 'usd', 'inr'], ['5 usd => inr', 5, 'usd', 'inr'], ['5 usd->inr', 5, 'usd', 'inr'], ['5 usd → inr', 5, 'usd', 'inr'], ['5 usd inr', 5, 'usd', 'inr'],
  // Questions
  ['how much is $5 in inr?', 5, 'usd', 'inr'], ['what is 5 usd in inr', 5, 'usd', 'inr'], ["what's 5 usd in inr", 5, 'usd', 'inr'], ['whats 5 usd in inr?', 5, 'usd', 'inr'], ['convert 1,000 jpy into gbp', 1000, 'jpy', 'gbp'], ['please convert 5 usd to inr', 5, 'usd', 'inr'], ['change 5 usd to inr', 5, 'usd', 'inr'], ['exchange 5 usd to inr', 5, 'usd', 'inr'], ['please exchange 5 usd to inr', 5, 'usd', 'inr'],
  // Punctuation, case and spacing
  ['5 usd to inr.', 5, 'usd', 'inr'], ['5 usd to inr!', 5, 'usd', 'inr'], ['5 usd to inr?!', 5, 'usd', 'inr'], ['5 USD TO INR', 5, 'usd', 'inr'], ['  5   usd   to   inr  ', 5, 'usd', 'inr'],
  // Amounts
  ['1,000 usd to inr', 1000, 'usd', 'inr'], ['1,000,000 usd to inr', 1000000, 'usd', 'inr'], ['1,000.50 JPY into GBP', 1000.5, 'jpy', 'gbp'], ['1,00,000 inr to usd', 100000, 'inr', 'usd'], ['10,00,000 inr to usd', 1000000, 'inr', 'usd'], ['.5 usd to inr', 0.5, 'usd', 'inr'], ['0.5 usd to inr', 0.5, 'usd', 'inr'], ['0 usd to inr', 0, 'usd', 'inr'], ['0.00 usd to inr', 0, 'usd', 'inr'], ['007 usd to inr', 7, 'usd', 'inr'],
  // No amount means one, when both sides are certainly currencies
  ['usd to inr', 1, 'usd', 'inr'], ['USD in EUR', 1, 'usd', 'eur'], ['dollars to rupees', 1, 'usd', 'inr'], ['$ to inr', 1, 'usd', 'inr'], ['₹ in $', 1, 'inr', 'usd'], ['₺ to usd', 1, 'try', 'usd'], ['btc to usd', 1, 'btc', 'usd'], ['usd to btc', 1, 'usd', 'btc'], ['doge to usdt', 1, 'doge', 'usdt'], ['usd to usd', 1, 'usd', 'usd']
]) {
  const { known, ...read } = currency.parse(text) || {}
  assertDeepEqual(read, { amount, from, to }, `the menu reads the conversion "${text}"`)
  assertEqual(known, 2, `"${text}" names two known currencies`)
}
for (const [text, known] of [
  // An amount is enough to ask the API, whose list has what ours doesn't
  ['5 ada to usd', 1], ['5 usd to ada', 1], ['5 try to usd', 1], ['5 usd to dogs', 1], ['2 try to sleep', 0], ['5 ada to sol', 0], ['5 cats to dogs', 0], ['5 all in one', 0], ['10 go home', 0], ['5 valueof to usd', 1]
]) {
  assertEqual((currency.parse(text) || {}).known, known, `"${text}" names ${known} known currencies`)
}
for (const text of [
  // Not a conversion at all
  '', ' ', null, undefined, 'zen', 'usd', '5', '100 inr', '$5', 'convert usd', 'please convert', 'how much is ram', 'what is omarchy',
  // Unfinished, as it is on the way to being typed
  '100 inr to', '100 inr in', '$5 to', 'to usd', 'in usd', '5 to usd', 'usd to',
  // Ordinary menu searches that look like "x to y"
  'go to settings', 'save as pdf', 'back to main', 'log in vpn', 'add to bar', 'set to dnd', 'move to trash', 'time to sleep',
  // Pairs of real API codes that are really words
  'all in one', 'link to one', 'top to one', 'try in one', 'pen to top', 'sol in dash', 'try to top',
  // One side is a currency, but with no amount that doesn't make it a conversion
  'usd to dogs', 'dogs to usd', 'try to usd', 'usd to top',
  // Decimal commas stay searches, as guessing would be off by a hundred times
  '1,25 USD to EUR', '1,00 usd to eur', '1,000,00 usd to inr', '1,0000 usd to inr', '1,5,000 usd to inr',
  // Other malformed amounts
  '5. usd to inr', '1.2.3 usd to inr', '-5 usd to inr', '5e3 usd to inr', '٥ usd to inr',
  // Malformed currencies
  'zz$5 to usd', '5 usd to x', '5 usd to 1inch', '5 usd to ₿', '5 verylongcurrencyname to usd', '__proto__ to usd', '5 usd to __proto__',
  // More than one conversion
  '5 usd to inr to eur', '5 usd 6 eur to inr',
  // Anything that could be a command
  '$(id) to usd', '5 usd to $(id)', '5 usd to `id`', '5 usd; rm to inr', "5 usd to 'inr",
  // Too long to be typed by hand
  '9'.repeat(100) + ' usd to inr', '9'.repeat(400) + ' usd to inr'
]) {
  assertEqual(currency.parse(text), null, `the menu leaves ${JSON.stringify(String(text).slice(0, 30))} to search`)
}
for (const [value, rounded] of [[1.0578803, 1.06], [1, 1], [0, 0], [1234567.891, 1234567.89], [473.9, 473.9], [0.0105788, 0.01058], [0.999999, 1], [1.1e-7, 1.1e-7], [1e21, 1e21]]) {
  assertEqual(currency.round(value), rounded, `a conversion rounds ${value} to ${rounded}`)
}

// Expected values are worked out from each unit's definition (an inch is 0.0254 m,
// a pound 0.45359237 kg, a US gallon 231 cubic inches), not from Units.js, and
// rounded to the ten significant digits an answer keeps.
const units = requireFromRoot('shell/plugins/menu/Units.js')
for (const [text, amount, from, value, to] of [
  // Length
  ['5 km to mi', 5, 'km', 3.106855961, 'mi'], ['1 mi to km', 1, 'mi', 1.609344, 'km'], ['6 ft to m', 6, 'ft', 1.8288, 'm'], ['12 in to cm', 12, 'in', 30.48, 'cm'],
  ['1 yd to ft', 1, 'yd', 3, 'ft'], ['100 cm to m', 100, 'cm', 1, 'm'], ['1 m to mm', 1, 'm', 1000, 'mm'], ['1 m to ft', 1, 'm', 3.280839895, 'ft'],
  ['1 nmi to km', 1, 'nmi', 1.852, 'km'], ['1 µm to nm', 1, 'µm', 1000, 'nm'], ['1 um to nm', 1, 'µm', 1000, 'nm'], ['1 micron to nm', 1, 'µm', 1000, 'nm'], ['1 Å to nm', 1, 'Å', 0.1, 'nm'],
  ['1 ly to km', 1, 'ly', 9460730473000, 'km'], ['1 au to km', 1, 'au', 149597870.7, 'km'], ['1 pc to ly', 1, 'pc', 3.261563777, 'ly'], ['1 furlong to m', 1, 'fur', 201.168, 'm'], ['1000 thou to in', 1000, 'thou', 1, 'in'],
  // Every spelling of a length
  ['1 meter to cm', 1, 'm', 100, 'cm'], ['1 metre to cm', 1, 'm', 100, 'cm'], ['2 metres to cm', 2, 'm', 200, 'cm'], ['10 kilometers to miles', 10, 'km', 6.213711922, 'mi'], ['10 kilometres to mile', 10, 'km', 6.213711922, 'mi'],
  ['1 foot to inches', 1, 'ft', 12, 'in'], ['3 feet to inch', 3, 'ft', 36, 'in'], ['1 yard to feet', 1, 'yd', 3, 'ft'], ['2 miles to yards', 2, 'mi', 3520, 'yd'], ['1 nautical mile to m', 1, 'nmi', 1852, 'm'], ['1 light year to km', 1, 'ly', 9460730473000, 'km'], ['1 lightyear to km', 1, 'ly', 9460730473000, 'km'],
  // Feet and inches as marks, and lengths made of parts
  ["5'11\" to cm", 5.9166666667, 'ft', 180.34, 'cm'], ["6' to cm", 6, 'ft', 182.88, 'cm'], ['10" to cm', 10, 'in', 25.4, 'cm'], ['5 ft 11 in to cm', 5.9166666667, 'ft', 180.34, 'cm'], ['5 feet 11 inches in cm', 5.9166666667, 'ft', 180.34, 'cm'], ['1 m 50 cm to ft', 1.5, 'm', 4.921259843, 'ft'],
  // Mass
  ['1 kg to lb', 1, 'kg', 2.204622622, 'lb'], ['1 lb to g', 1, 'lb', 453.59237, 'g'], ['16 oz to lb', 16, 'oz', 1, 'lb'], ['1 st to lb', 1, 'st', 14, 'lb'], ['1 stone to pounds', 1, 'st', 14, 'lb'],
  ['1 t to kg', 1, 't', 1000, 'kg'], ['1 tonne to lb', 1, 't', 2204.622622, 'lb'], ['1 metric ton to kg', 1, 't', 1000, 'kg'], ['1 ton to kg', 1, 'ton', 907.18474, 'kg'], ['1 short ton to lb', 1, 'ton', 2000, 'lb'], ['1 long ton to kg', 1, 'long ton', 1016.046909, 'kg'],
  ['1 ct to g', 1, 'ct', 0.2, 'g'], ['7000 gr to lb', 7000, 'gr', 1, 'lb'], ['1 g to mg', 1, 'g', 1000, 'mg'], ['1 mg to µg', 1, 'mg', 1000, 'µg'], ['1 mcg to mg', 1, 'µg', 0.001, 'mg'], ['5 pounds to kg', 5, 'lb', 2.26796185, 'kg'], ['5 lbs to kg', 5, 'lb', 2.26796185, 'kg'],
  ['2 lb 3 oz to kg', 2.1875, 'lb', 0.9922333094, 'kg'], ['1 kg 200 g to lb', 1.2, 'kg', 2.645547146, 'lb'], ['1 kilo to grams', 1, 'kg', 1000, 'g'],
  // Temperature, which has an offset and a floor
  ['100 c to f', 100, '°C', 212, '°F'], ['32 f to c', 32, '°F', 0, '°C'], ['-40 c to f', -40, '°C', -40, '°F'], ['-40 f to c', -40, '°F', -40, '°C'], ['−40 c to f', -40, '°C', -40, '°F'],
  ['0 k to c', 0, 'K', -273.15, '°C'], ['0 c to k', 0, '°C', 273.15, 'K'], ['300 K to C', 300, 'K', 26.85, '°C'], ['98.6 f to c', 98.6, '°F', 37, '°C'], ['491.67 °R to °C', 491.67, '°R', 0, '°C'], ['0 rankine to kelvin', 0, '°R', 0, 'K'],
  ['20 °C to °F', 20, '°C', 68, '°F'], ['20°c to f', 20, '°C', 68, '°F'], ['20 ° C to ° F', 20, '°C', 68, '°F'], ['20 celsius to fahrenheit', 20, '°C', 68, '°F'], ['20 centigrade to fahrenheit', 20, '°C', 68, '°F'],
  ['20 degrees celsius to fahrenheit', 20, '°C', 68, '°F'], ['68 deg f to c', 68, '°F', 20, '°C'], ['68 degf to degc', 68, '°F', 20, '°C'], ['-273.15 c to k', -273.15, '°C', 0, 'K'], ['-459.67 f to k', -459.67, '°F', 0, 'K'], ['1 c to c', 1, '°C', 1, '°C'],
  // Volume, US unless it says otherwise
  ['1 gal to l', 1, 'gal', 3.785411784, 'L'], ['1 l to ml', 1, 'L', 1000, 'mL'], ['1 L to mL', 1, 'L', 1000, 'mL'], ['1 cup to ml', 1, 'cup', 236.5882365, 'mL'], ['1 tbsp to tsp', 1, 'tbsp', 3, 'tsp'],
  ['1 fl oz to ml', 1, 'fl oz', 29.57352956, 'mL'], ['8 fl oz to ml', 8, 'fl oz', 236.5882365, 'mL'], ['8 oz to g', 8, 'oz', 226.796185, 'g'], ['1 cup to fl oz', 1, 'cup', 8, 'fl oz'], ['1 qt to pt', 1, 'qt', 2, 'pt'], ['1 gal to qt', 1, 'gal', 4, 'qt'], ['1 gallon to cups', 1, 'gal', 16, 'cup'],
  ['2 liters to gallons', 2, 'L', 0.5283441047, 'gal'], ['2 litres to gallons', 2, 'L', 0.5283441047, 'gal'], ['1 imp gal to l', 1, 'imp gal', 4.54609, 'L'], ['1 imperial gallon to l', 1, 'imp gal', 4.54609, 'L'], ['1 uk pint to ml', 1, 'imp pt', 568.26125, 'mL'],
  ['1 m3 to l', 1, 'm³', 1000, 'L'], ['1 m³ to l', 1, 'm³', 1000, 'L'], ['1 cubic meter to liters', 1, 'm³', 1000, 'L'], ['1 cc to ml', 1, 'cm³', 1, 'mL'], ['1 cm³ to ml', 1, 'cm³', 1, 'mL'], ['1 ft3 to l', 1, 'ft³', 28.31684659, 'L'], ['1 cu ft to l', 1, 'ft³', 28.31684659, 'L'],
  ['1 cl to ml', 1, 'cL', 10, 'mL'], ['1 dl to ml', 1, 'dL', 100, 'mL'], ['1 tablespoon to teaspoons', 1, 'tbsp', 3, 'tsp'],
  // Fractions and mixed numbers, as recipes write them
  ['3/4 cup to tbsp', 0.75, 'cup', 12, 'tbsp'], ['1/2 gal to qt', 0.5, 'gal', 2, 'qt'], ['1 1/2 cups to tbsp', 1.5, 'cup', 24, 'tbsp'], ['2 1/4 tsp to ml', 2.25, 'tsp', 11.09007359, 'mL'],
  // Area
  ['1 acre to m2', 1, 'ac', 4046.856422, 'm²'], ['1 ha to acres', 1, 'ha', 2.471053815, 'ac'], ['1 km2 to ha', 1, 'km²', 100, 'ha'], ['1 m² to ft²', 1, 'm²', 10.76391042, 'ft²'], ['1 sq ft to sq in', 1, 'ft²', 144, 'in²'],
  ['1 square mile to acres', 1, 'mi²', 640, 'ac'], ['1 m^2 to cm^2', 1, 'm²', 10000, 'cm²'], ['100 square feet to square meters', 100, 'ft²', 9.290304, 'm²'], ['1 hectare to m2', 1, 'ha', 10000, 'm²'], ['1 sq yd to sq ft', 1, 'yd²', 9, 'ft²'],
  // Speed
  ['100 km/h to mph', 100, 'km/h', 62.13711922, 'mph'], ['60 mph to km/h', 60, 'mph', 96.56064, 'km/h'], ['1 m/s to km/h', 1, 'm/s', 3.6, 'km/h'], ['10 knots to km/h', 10, 'kn', 18.52, 'km/h'], ['1 kn to m/s', 1, 'kn', 0.5144444444, 'm/s'],
  ['100 kph to mph', 100, 'km/h', 62.13711922, 'mph'], ['100 kmh to mph', 100, 'km/h', 62.13711922, 'mph'], ['60 miles per hour to kilometers per hour', 60, 'mph', 96.56064, 'km/h'], ['1 ft/s to m/s', 1, 'ft/s', 0.3048, 'm/s'], ['1 meter per second to km/h', 1, 'm/s', 3.6, 'km/h'],
  // Time
  ['1 h to min', 1, 'h', 60, 'min'], ['1 day to h', 1, 'd', 24, 'h'], ['1 week to days', 1, 'wk', 7, 'd'], ['90 min to h', 90, 'min', 1.5, 'h'], ['1 yr to days', 1, 'yr', 365.25, 'd'], ['1 month to days', 1, 'mo', 30.4375, 'd'], ['1 fortnight to days', 1, 'fortnight', 14, 'd'],
  ['1 s to ms', 1, 's', 1000, 'ms'], ['1 ms to µs', 1, 'ms', 1000, 'µs'], ['1 us to ns', 1, 'µs', 1000, 'ns'], ['1 decade to yr', 1, 'decade', 10, 'yr'], ['1 century to years', 1, 'century', 100, 'yr'], ['3600 s to h', 3600, 's', 1, 'h'], ['2 hours to seconds', 2, 'h', 7200, 's'], ['1 h 30 min to min', 1.5, 'h', 90, 'min'],
  // Data: SI prefixes are powers of ten, IEC ones powers of two; a capital-first "Mb" is bits, and all-lowercase means bytes
  ['1 GB to MB', 1, 'GB', 1000, 'MB'], ['1 GiB to MiB', 1, 'GiB', 1024, 'MiB'], ['1 GiB to GB', 1, 'GiB', 1.073741824, 'GB'], ['1 TB to GiB', 1, 'TB', 931.3225746, 'GiB'], ['1 MB to Mb', 1, 'MB', 8, 'Mbit'], ['100 Mb to MB', 100, 'Mbit', 12.5, 'MB'],
  ['1 byte to bits', 1, 'B', 8, 'bit'], ['8 bits to bytes', 8, 'bit', 1, 'B'], ['1 kB to B', 1, 'kB', 1000, 'B'], ['1 KB to B', 1, 'kB', 1000, 'B'], ['1 kib to bit', 1, 'KiB', 8192, 'bit'], ['1 gb to mb', 1, 'GB', 1000, 'MB'], ['1 Gb to Mb', 1, 'Gbit', 1000, 'Mbit'],
  ['1 gigabit to megabytes', 1, 'Gbit', 125, 'MB'], ['1 PB to TB', 1, 'PB', 1000, 'TB'], ['1 PiB to TiB', 1, 'PiB', 1024, 'TiB'], ['1 gigabyte to megabytes', 1, 'GB', 1000, 'MB'], ['1 gibibyte to mebibytes', 1, 'GiB', 1024, 'MiB'],
  // Data rates
  ['100 Mbps to MB/s', 100, 'Mbit/s', 12.5, 'MB/s'], ['1 Gbps to Mbps', 1, 'Gbit/s', 1000, 'Mbit/s'], ['1 MB/s to kbps', 1, 'MB/s', 8000, 'kbit/s'], ['100 mbps to mb/s', 100, 'Mbit/s', 12.5, 'MB/s'],
  // Pressure
  ['1 atm to kPa', 1, 'atm', 101.325, 'kPa'], ['1 bar to psi', 1, 'bar', 14.50377377, 'psi'], ['1 atm to mmHg', 1, 'atm', 759.9998917, 'mmHg'], ['1 atm to torr', 1, 'atm', 760, 'Torr'], ['1 psi to kPa', 1, 'psi', 6.894757293, 'kPa'],
  ['1013.25 hPa to atm', 1013.25, 'hPa', 1, 'atm'], ['1 bar to mbar', 1, 'bar', 1000, 'mbar'], ['1 MPa to bar', 1, 'MPa', 10, 'bar'], ['1 inHg to hPa', 1, 'inHg', 33.86389, 'hPa'], ['1 pascal to Pa', 1, 'Pa', 1, 'Pa'],
  // Energy, where a capital "Cal" is a food calorie
  ['1 kWh to MJ', 1, 'kWh', 3.6, 'MJ'], ['1 kcal to kJ', 1, 'kcal', 4.184, 'kJ'], ['1 Cal to kJ', 1, 'kcal', 4.184, 'kJ'], ['1 kcal to cal', 1, 'kcal', 1000, 'cal'], ['1 btu to J', 1, 'BTU', 1055.055853, 'J'], ['1 Wh to J', 1, 'Wh', 3600, 'J'],
  ['1 eV to J', 1, 'eV', 1.602176634e-19, 'J'], ['1 therm to MJ', 1, 'therm', 105.4804, 'MJ'], ['1 GJ to kWh', 1, 'GJ', 277.7777778, 'kWh'], ['1 calorie to joules', 1, 'cal', 4.184, 'J'], ['1 MWh to kWh', 1, 'MWh', 1000, 'kWh'],
  // Power, where milli and mega differ only by case
  ['1 hp to W', 1, 'hp', 745.6998716, 'W'], ['1 kW to hp', 1, 'kW', 1.34102209, 'hp'], ['1 MW to kW', 1, 'MW', 1000, 'kW'], ['1000 mW to W', 1000, 'mW', 1, 'W'], ['1 GW to MW', 1, 'GW', 1000, 'MW'], ['1 PS to W', 1, 'PS', 735.49875, 'W'], ['1 W to btu/h', 1, 'W', 3.412141633, 'BTU/h'], ['1 horsepower to watts', 1, 'hp', 745.6998716, 'W'],
  // Angle
  ['180 deg to rad', 180, '°', 3.141592654, 'rad'], ['1 rad to °', 1, 'rad', 57.29577951, '°'], ['1 turn to deg', 1, 'turn', 360, '°'], ['90° to rad', 90, '°', 1.570796327, 'rad'], ['100 grad to deg', 100, 'grad', 90, '°'],
  ['1 deg to arcmin', 1, '°', 60, 'arcmin'], ['1 arcmin to arcsec', 1, 'arcmin', 60, 'arcsec'], ['2 revolutions to degrees', 2, 'turn', 720, '°'], ['1 radian to degrees', 1, 'rad', 57.29577951, '°'],
  // Frequency
  ['1 GHz to MHz', 1, 'GHz', 1000, 'MHz'], ['1 kHz to Hz', 1, 'kHz', 1000, 'Hz'], ['60 rpm to Hz', 60, 'rpm', 1, 'Hz'], ['1 Hz to rpm', 1, 'Hz', 60, 'rpm'], ['1 mhz to khz', 1, 'MHz', 1000, 'kHz'], ['1 hertz to hz', 1, 'Hz', 1, 'Hz'],
  // Force, where a capital "kN" is a kilonewton and "kn" a knot
  ['1 kgf to N', 1, 'kgf', 9.80665, 'N'], ['1 lbf to N', 1, 'lbf', 4.448221615, 'N'], ['1 kN to N', 1, 'kN', 1000, 'N'], ['1 N to dyn', 1, 'N', 100000, 'dyn'], ['1 newton to dynes', 1, 'N', 100000, 'dyn'],
  // Fuel economy, which is the other way up in litres per 100 km
  ['10 l/100km to mpg', 10, 'L/100 km', 23.52145833, 'mpg'], ['30 mpg to l/100km', 30, 'mpg', 7.840486111, 'L/100 km'], ['10 km/l to l/100km', 10, 'km/L', 10, 'L/100 km'], ['30 mpg to km/l', 30, 'mpg', 12.75431122, 'km/L'],
  ['1 mpg uk to mpg', 1, 'mpg (imp)', 0.8326741846, 'mpg'], ['5 L/100 km to km/L', 5, 'L/100 km', 20, 'km/L'], ['20 kmpl to l/100km', 20, 'km/L', 5, 'L/100 km'], ['0 mpg to km/l', 0, 'mpg', 0, 'km/L'],
  // Amounts
  ['1,000 m to km', 1000, 'm', 1, 'km'], ['1,00,000 cm to km', 100000, 'cm', 1, 'km'], ['1,000.5 m to km', 1000.5, 'm', 1.0005, 'km'], ['.5 km to m', 0.5, 'km', 500, 'm'], ['0 m to ft', 0, 'm', 0, 'ft'], ['-1 m to cm', -1, 'm', -100, 'cm'], ['5 m to m', 5, 'm', 5, 'm'],
  // Spacing, case, punctuation and the ways of asking
  ['5km to mi', 5, 'km', 3.106855961, 'mi'], ['5 KM TO MI', 5, 'km', 3.106855961, 'mi'], ['  5   km   to   mi  ', 5, 'km', 3.106855961, 'mi'], ['5 km to mi.', 5, 'km', 3.106855961, 'mi'], ['5 km to mi?', 5, 'km', 3.106855961, 'mi'],
  ['5 km in mi', 5, 'km', 3.106855961, 'mi'], ['5 km into mi', 5, 'km', 3.106855961, 'mi'], ['5 km as mi', 5, 'km', 3.106855961, 'mi'], ['5 km = mi', 5, 'km', 3.106855961, 'mi'], ['5 km -> mi', 5, 'km', 3.106855961, 'mi'], ['5 km => mi', 5, 'km', 3.106855961, 'mi'], ['5 km → mi', 5, 'km', 3.106855961, 'mi'], ['5 km mi', 5, 'km', 3.106855961, 'mi'],
  ['convert 5 km to mi', 5, 'km', 3.106855961, 'mi'], ['please convert 5 km to mi', 5, 'km', 3.106855961, 'mi'], ['what is 5 km in mi?', 5, 'km', 3.106855961, 'mi'], ["what's 5 km in mi", 5, 'km', 3.106855961, 'mi'], ['how much is 5 km in mi', 5, 'km', 3.106855961, 'mi'],
  ['a mile in km', 1, 'mi', 1.609344, 'km'], ['an inch in mm', 1, 'in', 25.4, 'mm'], ['how many feet in a mile', 1, 'mi', 5280, 'ft'], ['how many feet in a mile?', 1, 'mi', 5280, 'ft'], ['how many cm in 2 inches', 2, 'in', 5.08, 'cm'], ['how many inches are in 3 ft', 3, 'ft', 36, 'in'], ['how many ml in one cup', 1, 'cup', 236.5882365, 'mL'], ['how many grams in a pound', 1, 'lb', 453.59237, 'g'],
  // "in" as a unit as well as a connector
  ['5 in to cm', 5, 'in', 12.7, 'cm'], ['5 ft in in', 5, 'ft', 60, 'in'], ['2 m in in', 2, 'm', 78.74015748, 'in'], ['5 in in cm', 5, 'in', 12.7, 'cm']
]) {
  const answer = units.convert(text)
  const read = answer && { amount: Number(answer.amount.toFixed(10)), from: answer.from, value: answer.value, to: answer.to }
  assertDeepEqual(read, { amount, from, value, to }, `the menu converts "${text}"`)
}

for (const [text, written] of [['1 nm to ly', '0.0000000000000000000000001057000834'], ['1 ly to nm', '9460730473000000000000000'], ['1 eV to J', '0.0000000000000000001602176634']]) {
  assertEqual(numbers.plain(units.convert(text).value), written, `a conversion of "${text}" is written out in plain digits`)
}
assert(Object.is(units.convert('-0 m to ft').value, 0), 'a conversion never answers a negative zero')
assert(Object.is(units.convert('-273.15 c to k').value, 0) && Object.is(units.convert('-459.67 f to r').value, 0), 'a temperature that lands on zero is a plain zero')

// The symbol an answer shows can be typed back, and any unit converts to itself
// and back again from every other unit it shares a kind with.
for (const [kind, symbols] of Object.entries(units.kinds())) {
  assert(symbols.length > 1, `${kind} has units to convert between`)
  for (const a of symbols) {
    const self = units.convert(`7 ${a} to ${a}`)
    assertDeepEqual(self && [self.from, self.value, self.to], [a, 7, a], `"${a}" can be typed back as it is shown`)
    for (const b of symbols) {
      const there = units.convert(`7 ${a} to ${b}`)
      const back = there && units.convert(`${numbers.plain(there.value)} ${b} to ${a}`)
      assert(back && Math.abs(back.value - 7) < 7e-8, `7 ${a} survives a trip through ${b}`, JSON.stringify([there, back]))
    }
  }
}

for (const text of [
  // Not a conversion at all
  '', ' ', null, undefined, 'km', '5', '5 km', '5 km to', '5 km in', 'km to mi', 'to mi', '5 to mi', 'convert', 'how many feet', 'how many feet in', 'how many feet in a', 'a mile', 'a mile in',
  // Two kinds of thing
  '5 kg to m', '5 c to kg', '1 l/100km to km/h', '1 gb to gbit/s', '1 h to hz', '5 oz to ml', '5 m 5 kg to g', '1 km 3 l to m',
  // Parts that can't be added up: temperatures, fuel economy, a negative part, a target with an amount
  '5 c 3 f to k', '5 c 3 c to f', '10 mpg 5 km/l to l/100km', '5 ft -3 in to cm', '5 km to 3 mi', '5 m to ft 2 in',
  // Units nobody can tell apart, or that don't exist
  '5 mw to w', '5 zorks to m', '5 km to zorks', '5 m to ft to in', '5 m to', '5 b to kb', '5 kb to b',
  // Below absolute zero
  '-274 c to f', '-1 k to c', '-1 °R to K', '-460 f to c', '-273.16 c to k',
  // No answer, or one the other way up from nothing
  '0 mpg to l/100km', '0 l/100km to mpg', '-5 mpg to km/l', '-5 l/100km to mpg', '1/0 cup to ml', '0/0 cup to ml',
  // Malformed amounts: a decimal comma could be off by a hundred times
  '1,25 m to cm', '1,0000 m to cm', '1e3 m to km', '5. m to cm', '1.2.3 m to cm', '١ m to cm', '--5 m to cm', '+-5 m to cm', '1/2/3 cup to ml', '1 1/0 cup to ml', '1 / 2 cup to ml',
  // Currencies and money words belong to the currency row
  '5 usd to inr', '5 pounds to dollars', '100 rupees to kg', '$5 to m',
  // Ordinary menu searches
  'go to settings', 'save as pdf', 'back to main', 'log in vpn', 'move to trash', 'time to sleep', '7-zip', '2+2', '5 cats to dogs', '10 go home',
  // Names on Object's prototype are not units
  '5 constructor to m', '5 m to constructor', '5 __proto__ to m', '5 m to tostring', '5 hasownproperty to m', '5 valueof to m',
  // Anything that could be a command
  '$(id) m to ft', '5 m to $(id)', '5 m to `id`', '5 m; rm to ft', "5 m to 'ft",
  // Too long to be typed by hand
  '9'.repeat(100) + ' m to ft', '1' + ' 1 m'.repeat(40) + ' to ft'
]) {
  assertEqual(units.convert(text), null, `the menu leaves ${JSON.stringify(String(text).slice(0, 30))} to search`)
}
assertEqual(calc.evaluate('3/4 cup to tbsp'), '', 'a fraction of a unit is not a sum')
JS
