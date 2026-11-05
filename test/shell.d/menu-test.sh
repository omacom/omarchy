#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

run_node_test <<'JS'
const fs = require('fs')
const vm = require('vm')
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
const terminalFont = requireFromRoot('shell/plugins/menu/TerminalFont.js')
const menuQml = fs.readFileSync(path.join(root, 'shell/plugins/menu/Menu.qml'), 'utf8')

assertEqual(terminalFont.pointSize('ghostty', '# font-size = 99\nfont-size = 10\n'), 10, 'preview reads Ghostty point size, not comments')
assertEqual(terminalFont.pointSize('ghostty', 'font-size = 10\nfont-size = 12.5 # override'), 12.5, 'preview uses the last configured fractional size')
assertEqual(terminalFont.pointSize('kitty', 'font_size   11.5'), 11.5, 'preview reads Kitty point size')
assertEqual(terminalFont.pointSize('alacritty', '[window]\nsize = 99\n[font]\nsize = 10.5\n[other]\nsize = 42'), 10.5, 'preview reads only the Alacritty font section')
assertEqual(terminalFont.pointSize('foot', '[main]\nfont=Example:size=12,Other:size=20\n[other]\nfont=Example:size=99'), 12, 'preview reads the primary Foot font size')
assertEqual(terminalFont.pointSize('ghostty', 'font-size = 0\nfont-size = invalid'), 9, 'invalid or missing sizes fall back to the Omarchy default')
assertEqual(terminalFont.configPath('ghostty'), 'ghostty/config', 'preview locates the default terminal configuration')
assertEqual(terminalFont.configPath('unknown'), '', 'unsupported terminals have no guessed config path')
assert(menuQml.includes('pointSize: root.terminalFontPointSize, weight: Font.Normal'), 'font names use their own family at terminal point size')
assert(menuQml.includes('pointSize: root.terminalFontPointSize'), 'sample text uses terminal point size instead of shell caption pixels')

const previewSamples = vm.runInNewContext(menuQml.match(/readonly property var fontPreviewSamples: (\[[\s\S]*?\n  \])/)[1])
assertEqual(previewSamples.length, 8, 'preview cycles the original sample and seven language snippets')
assertEqual(previewSamples[0], 'Aa Bb 0123456789 {} [] -> !=', 'preview starts with the original sample')
for (const [index, marker] of ['puts ', 'Vec<_>', 'name: string', 'fmt.Println', '$name', 'std::cout', 'System.out.println'].entries()) {
  assert(previewSamples[index + 1].includes(marker), 'preview language order: ' + marker)
}
assert(previewSamples.every(sample => !sample.includes('\n')), 'all preview samples fit on one line')
assert(menuQml.includes('interval: 3000'), 'preview advances every three seconds')
for (const route of ['appearance.font', 'style.font', 'install.style.font']) {
  assert(menuQml.includes('root.activeMenu === "' + route + '"'), 'preview timer supports font route ' + route)
}
assert(/onRunningChanged: \{\s*fontPreviewTransition.stop\(\)\s*root.fontPreviewIndex = 0\s*root.fontPreviewPreviousIndex = 0\s*root.fontPreviewProgress = 1/.test(menuQml), 'preview resets without animating when opening the font menu')
assert(menuQml.includes('(root.fontPreviewIndex + 1) % root.fontPreviewSamples.length'), 'preview wraps back to the original sample')
assert(menuQml.includes('text: row.previewReady ? root.fontPreviewSamples[root.fontPreviewIndex] : "Preview unavailable"'), 'font rows share the current sample and preserve the unavailable fallback')
const previewQml = fs.readFileSync(path.join(root, 'shell/plugins/menu/FontPreview.qml'), 'utf8')
assert(menuQml.includes('duration: Style.duration(220)'), 'sample transitions respect the animation setting')
assert(menuQml.includes('easing.bezierCurve: Style.easeOut'), 'sample transitions use the shared smooth easing')
assert(menuQml.includes('root.fontPreviewPreviousIndex = root.fontPreviewIndex'), 'transition retains the outgoing sample')
assert(previewQml.includes('opacity: 1 - root.progress') && previewQml.includes('x: -Style.space(16) * root.progress'), 'outgoing sample fades and moves left')
assert(previewQml.includes('opacity: root.progress') && previewQml.includes('x: Style.space(16) * (1 - root.progress)'), 'incoming sample fades and moves in from the right')
assert(previewQml.includes('clip: true') && previewQml.includes('implicitHeight: incoming.implicitHeight'), 'sample transitions stay clipped in a stable line height')

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
    previewFont: '',
    previewFontFile: '',
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
    previewFont: '',
    previewFontFile: '',
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

const preview = menu.normalizeItem('font.example', {
  label: 'Example', action: 'install-example', previewFont: 'Example Mono',
  previewFontFile: 'default/fonts/previews/example.ttf'
})
const previewRow = menu.displayRow({ [preview.id]: preview }, [preview.id], {}, {}, preview, 'Fonts')
assertEqual(previewRow.previewFont, 'Example Mono', 'menu carries preview font families')
assertEqual(previewRow.previewFontFile, preview.previewFontFile, 'menu carries preview font files')
assertEqual(previewRow.action, 'install-example', 'font previews do not change actions')
assertEqual(previewRow.detail, 'Fonts', 'font previews preserve search paths')
const specimens = JSON.parse(fs.readFileSync(path.join(root, 'default/fonts/previews/sources.json'), 'utf8'))
const installFonts = defaultItems.filter(item => item.parent === 'install.style.font' || /\bomarchy-install-font\b/.test(item.action))
for (const font of installFonts) {
  assert(font.previewFontFile, `${font.id} includes an offline preview (see agents/skills/font-previews.md)`)
  assert(font.previewFont && font.action.startsWith('omarchy-install-font ') && font.action.endsWith(` '${font.previewFont}'`), `${font.id} previews its install family`)
  const key = font.id.split('.').pop()
  assert(specimens[key], `${font.id} records specimen provenance`)
  assertEqual(font.previewFontFile, `default/fonts/previews/${key}.ttf`, `${font.id} points to its own specimen`)
  assertEqual(specimens[key].sourceFamily, font.previewFont, `${font.id} specimen matches its actual font family`)
  assert(/^https:\/\//.test(specimens[key].url) && /^[0-9a-f]{64}$/.test(specimens[key].sourceSha256), `${font.id} records a source URL and hash`)
  assert(specimens[key].licenseUrl || (specimens[key].archiveMember && specimens[key].licenseMember), `${font.id} records a rebuildable license source`)
  const asset = fs.readFileSync(path.join(root, font.previewFontFile))
  assertEqual(asset.readUInt32BE(0), 0x00010000, `${font.id} has a TrueType specimen`)
  assert(asset.length < 100000, `${font.id} specimen is small`)
  const tableCount = asset.readUInt16BE(4)
  let nameOffset = 0
  for (let i = 0; i < tableCount; i++) {
    const offset = 12 + i * 16
    if (asset.toString('ascii', offset, offset + 4) === 'name') nameOffset = asset.readUInt32BE(offset + 8)
  }
  assert(nameOffset > 0, `${font.id} has a font name table`)
  const names = []
  for (let i = 0; i < asset.readUInt16BE(nameOffset + 2); i++) {
    const offset = nameOffset + 6 + i * 12
    const platform = asset.readUInt16BE(offset)
    const nameId = asset.readUInt16BE(offset + 6)
    if ((platform === 0 || platform === 3) && (nameId === 1 || nameId === 16)) {
      const start = nameOffset + asset.readUInt16BE(nameOffset + 4) + asset.readUInt16BE(offset + 10)
      names.push(Buffer.from(asset.subarray(start, start + asset.readUInt16BE(offset + 8))).swap16().toString('utf16le'))
    }
  }
  assert(names.length > 0 && names.every(name => name === specimens[key].previewFamily && name.startsWith('Omarchy Preview ')), `${font.id} uses its private preview family, not the full installed family`)
  assert(fs.readFileSync(path.join(root, `default/fonts/previews/${key}.LICENSE`), 'utf8').trim(), `${font.id} includes its license`)
}
assert(menuQml.includes('previewFontFor: function(value) { return value }'), 'installed fonts preview their provider value')
assert(menuQml.includes('height: root.rowHeightForDetail(row.detail, row.previewFont)'), 'delegate sizing accounts for previews')
assert(menuQml.includes('total += root.rowHeightForDetail(row.detail, row.previewFont)'), 'list sizing accounts for previews')

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
JS
