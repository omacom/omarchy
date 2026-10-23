#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

run_node_test <<'JS'
const fs = require('fs')
const menu = requireFromRoot('shell/plugins/menu/MenuModel.js')
const menuQml = fs.readFileSync(path.join(root, 'shell/plugins/menu/Menu.qml'), 'utf8')
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
assert(
  /var summon = MenuModel\.summonAction\(command\)\s*if \(summon && root\.shell && root\.shell\.summon\(summon\.id, summon\.payload\)\) return\s*Util\.execDetached\(command\)/.test(menuQml),
  'menu falls back to bash when an in-process summon is refused'
)

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
assert(
  /function matchesQuery\(entry, query\) \{\s*\n\s*return MenuModel\.matchesQuery\(entry, query, root\.isVisible\(entry\) && !root\.isDisabled\(entry\)\)/.test(menuQml),
  'menu search skips disabled rows, which belong to the submenu they sit in rather than a list of what you can do'
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
assert(
  /function resolveRoute\(input\) \{\s*\n\s*return MenuModel\.resolveRoute\(root\.items, root\.itemOrder, input\)\s*\n\s*\}/.test(menuQml),
  'menu delegates route resolution to the shared model'
)
const triggerItems = defaultItems.filter(item => item.parent === 'trigger')
const rootIds = defaultItems.filter(item => item.parent === 'root').map(item => item.id)
assertEqual(rootIds.indexOf('appearance'), rootIds.indexOf('trigger') - 1, 'menu lists Appearance right before Trigger')
assert(!defaultById.style && !defaultById['trigger.appearance'], 'menu folds Style into Appearance and takes Appearance out of Trigger')
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
assertEqual(
  defaultById['trigger.emoji'].action,
  'omarchy-menu-emoji',
  'menu opens the emoji picker from Trigger'
)
assert(
  defaultById['update.omarchy'].icon === '\ue900',
  'menu update Omarchy entry uses the Omarchy glyph'
)
assert(
  defaultById['update.omarchy'].iconFont === 'omarchy',
  'menu update Omarchy entry renders the private glyph with the Omarchy font'
)
assertEqual(
  defaultById['update.themes'].when,
  'omarchy-theme-extras',
  'menu hides Extra Themes until a theme cloned from git is there to update'
)
assert(
  defaultById['setup.input'].action.includes('input.lua'),
  'menu keeps Input as a direct config action'
)
assert(
  defaultById['setup.direct-boot'].action.includes('omarchy-setup-direct-boot'),
  'menu places Direct Boot directly under Setup'
)
assert(
  defaultById['setup.reset'].action.includes('omarchy-system-factory-reset'),
  'menu exposes Reset Computer under Setup'
)
const setupEntries = defaultItems.filter(item => item.parent === 'setup')
assertEqual(
  setupEntries[setupEntries.length - 1].id,
  'setup.reset',
  'menu lists Reset Computer last under Setup'
)
const expectedAgents = {
  agy: { icon: '󰫢', label: 'Antigravity' },
  pi: { icon: '\ue901', iconFont: 'omarchy', label: 'Pi' },
  omp: { icon: '\ue903', iconFont: 'omarchy', label: 'omp' },
  opencode: { icon: '\ue902', iconFont: 'omarchy', label: 'OpenCode' },
  ori: { icon: '\ue909', iconFont: 'omarchy', label: 'Ori' },
  claude: { icon: '󰛄', label: 'Claude' },
  codex: { icon: '\ue905', iconFont: 'omarchy', label: 'Codex' },
  grok: { icon: '\ue904', iconFont: 'omarchy', label: 'Grok' },
  kimi: { icon: '\u{f06a9}', label: 'Kimi' },
  hermes: { icon: '\ue90a', iconFont: 'omarchy', label: 'Hermes' },
  openclaw: { icon: '\ue90c', iconFont: 'omarchy', label: 'OpenClaw' },
  copilot: { icon: '', label: 'Copilot' },
  crush: { icon: '󰋑', label: 'Crush' },
  muse: { icon: '󰛤', label: 'Muse Code' },
  'cursor-agent': { icon: '\ue90d', iconFont: 'omarchy', label: 'Cursor CLI' },

}
assert(
  Object.entries(expectedAgents).every(([agent, expected]) => {
    const entry = defaultById[`setup.default.agent.${agent}`]
    return entry
      && entry.icon === expected.icon
      && entry.iconFont === (expected.iconFont || '')
      && entry.label === expected.label
      && entry.action === `omarchy-default-agent ${agent}`
      && !entry.when
      && entry.checked.includes(`== \"${agent}\"`)
  }),
  'menu exposes every supported coding agent with its own glyph under Defaults > Agent'
)
assertDeepEqual(
  defaultItems
    .filter(item => item.parent === 'setup.default.agent')
    .map(item => item.label),
  ['Antigravity', 'Claude', 'Codex', 'Copilot', 'Crush', 'Cursor CLI', 'Grok', 'Hermes', 'Kimi', 'Muse Code', 'omp', 'OpenClaw', 'OpenCode', 'Ori', 'Pi'],
  'menu sorts coding agents alphabetically'
)
const expectedDefaults = {
  browser: ['Chromium', 'Chrome', 'Brave', 'Brave Origin', 'Edge', 'Firefox', 'Zen'],
  terminal: ['Alacritty', 'Foot', 'Ghostty', 'Kitty'],
  editor: ['Neovim', 'VSCode', 'Cursor', 'Zed', 'Sublime Text', 'Helix', 'Vim', 'Emacs'],
  dictation: ['Superwhisper', 'Voxtype']
}
assert(
  Object.entries(expectedDefaults).every(([type, labels]) => {
    const entries = defaultItems.filter(item => item.parent === `setup.default.${type}`)
    return entries.map(item => item.label).join('\0') === labels.join('\0')
      && entries.every(item => !item.when)
  }),
  'menu always exposes every supported browser, terminal, editor, and dictation backend under Defaults'
)
assert(!defaultById['install.ai.crush'], 'menu removes Crush from Install > AI')
// Software you already have keeps its place in Install, dimmed rather than
// dropped, so the list reads as a catalog of what Omarchy can install.
// Chromium Account is the sole Install row with anything left to hide for. The
// Windows VM, whose guest can't run elsewhere, and the installers that need
// x86_64 binaries (vendor builds for x86_64 alone, Windows games under Wine)
// hide only off x86_64. Dropbox's x86_64 client runs under box64 on ARM, which
// needs 4K pages, so it hides only where pages are larger. Spotify installs its
// web player where its client can't run, so it never hides. Any other `when:`
// here is a row that went back to vanishing once installed.
const windowsGuard = 'omarchy-hw-x86'
const x86OnlyInstalls = ['install.windows', 'install.browser.edge', 'install.gaming.minecraft', 'install.gaming.heroic', 'install.gaming.geforce-now', 'install.gaming.battlenet', 'install.gaming.lutris']
const fourKPageGuard = '[[ $(getconf PAGESIZE) == 4096 ]]'
assertDeepEqual(
  defaultItems
    .filter(item => item.id.startsWith('install.') && item.action && item.when)
    .map(item => item.id)
    .sort(),
  [...x86OnlyInstalls, 'install.service.dropbox', 'install.service.chromium-account'].sort(),
  'menu never hides an Install row because the software is already there'
)
assert(
  x86OnlyInstalls.every(id => defaultById[id].when === windowsGuard),
  'menu hides the Windows VM and the x86_64-only installers only off x86_64'
)
assertEqual(
  defaultById['install.service.dropbox'].when,
  fourKPageGuard,
  'menu offers Dropbox wherever box64 can run it, on x86_64 and on ARM with 4K pages'
)
assert(
  !defaultById['install.service.spotify'].when
    && defaultById['install.service.spotify'].disabled.includes('applications/Spotify.desktop'),
  'menu offers Spotify on every platform and dims it once its client or web player is installed'
)
assert(
  ['install.browser.zen', 'install.editor.vscode', 'install.gaming.steam', 'install.development.rust', 'install.windows'].every(
    id => defaultById[id].disabled && (!defaultById[id].when || defaultById[id].when === windowsGuard)
  ),
  'menu dims the Install rows for software that is already installed'
)
assertEqual(
  defaultById['install.browser.zen'].disabled,
  'omarchy-pkg-present zen-browser-bin',
  'menu asks the same presence question it used to hide the row with'
)
// A guard can still be about something other than having the software: no
// Chromium at all means no account to wire up, and that row stays hidden.
assert(
  defaultById['install.service.chromium-account'].when === '[[ -f ~/.config/chromium-flags.conf ]]'
    && defaultById['install.service.chromium-account'].disabled.includes('oauth2-client-id'),
  'menu keeps hiding Chromium Account without Chromium, and dims it once the account is set up'
)
assert(
  defaultItems.filter(item => item.id.startsWith('remove.')).every(item => !item.disabled)
    && defaultById['remove.browser.zen'].when === 'omarchy-pkg-present zen-browser-bin',
  'menu still hides Remove rows for software that is not installed'
)
assertDeepEqual(
  defaultItems
    .filter(item => item.parent === 'remove')
    .map(item => item.id),
  [
    'remove.package',
    'remove.ai',
    'remove.dictation',
    'remove.service',
    'remove.development',
    'remove.theme',
    'remove.gaming',
    'remove.browser',
    'remove.webapp',
    'remove.tui',
    'remove.windows',
    'remove.preinstalls',
    'remove.security'
  ],
  'menu keeps the Remove category order'
)
assert(
  defaultById['setup.security.passwordless-sudo'].action.includes('omarchy-sudo-passwordless'),
  'menu places Passwordless Sudo under Setup > Security'
)
assert(
  !defaultById['trigger.toggle.direct-boot'] && !defaultById['trigger.toggle.passwordless-sudo'],
  'menu removes the relocated toggles from Trigger > Toggle'
)
assertDeepEqual(
  defaultItems.filter(item => item.parent === 'appearance.top-bar').map(item => item.label),
  ['Hide Bar', 'Show Bar', 'Position Bar', 'Bar Background', 'Bar Indicators'],
  'menu gathers the Menu Bar under Appearance'
)
assert(
  defaultById['appearance.top-bar.hide'].when === '! omarchy-toggle-enabled bar-off'
    && defaultById['appearance.top-bar.show'].when === 'omarchy-toggle-enabled bar-off'
    && defaultById['appearance.top-bar.hide'].action === 'omarchy-toggle-bar'
    && defaultById['appearance.top-bar.show'].action === 'omarchy-toggle-bar',
  'menu offers Hide while the Menu Bar shows and Show while it is hidden'
)
assert(
  defaultById['appearance.top-bar.position'].kind === 'menu',
  'menu groups Menu Bar positions in a submenu'
)
assert(
  ['top', 'bottom', 'left', 'right'].every(position => defaultById[`appearance.top-bar.position.${position}`].action === `omarchy-bar position ${position}`),
  'menu lists all Menu Bar positions under Position'
)
assertDeepEqual(
  defaultItems.filter(item => item.parent === 'appearance.top-bar.background').map(item => [item.label, item.action]),
  [
    ['Opaque Bar', 'omarchy-bar background opaque'],
    ['Glassy Bar', 'omarchy-bar background glassy'],
    ['Clear Bar', 'omarchy-bar background none']
  ],
  'menu picks the bar background from Menu Bar > Bar Background'
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
assertDeepEqual(
  defaultItems.filter(item => item.parent === 'appearance.dock').map(item => item.label),
  ['Auto-hide Dock', 'Always-on Dock', 'Dock Position'],
  'menu gathers the dock under Appearance > Dock'
)
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
  assert(
    defaultById['appearance.dock.autohide'].action === 'omarchy-dock autohide on'
      && defaultById['appearance.dock.always-on'].action === 'omarchy-dock autohide off',
    'menu turns dock auto-hide on and off'
  )
  fs.rmSync(home, { recursive: true, force: true })
}
assertDeepEqual(
  defaultItems.filter(item => item.parent === 'appearance.dock.position').map(item => [item.label, item.action]),
  [
    ['Top Dock', 'omarchy-dock position top'],
    ['Bottom Dock', 'omarchy-dock position bottom'],
    ['Left Dock', 'omarchy-dock position left'],
    ['Right Dock', 'omarchy-dock position right']
  ],
  'menu picks the dock position from Appearance > Dock > Dock Position'
)
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
assertDeepEqual(
  defaultItems.filter(item => item.parent === 'appearance.top-bar.indicators').map(item => item.label),
  ['Show Battery %', 'Hide Battery %', 'Clock'],
  'menu gathers bar indicator options under Menu Bar > Bar Indicators'
)
const clockModel = requireFromRoot('shell/plugins/panels/clock/Model.js')
const clockRows = defaultItems.filter(item => item.parent === 'appearance.top-bar.indicators.clock')
// Each row hands bash its format, so ask bash what it hands over.
const clockRowFormats = key => clockRows
  .filter(item => item.action.startsWith(`omarchy-bar set omarchy.clock ${key} `))
  .map(item => require('child_process').execFileSync('bash', ['-c', item.action.replace(`omarchy-bar set omarchy.clock ${key} `, 'printf %s ')], { encoding: 'utf8' }))
assertDeepEqual(clockRowFormats('format'), clockModel.clockFormats(false), 'menu spells out every horizontal clock format')
assertDeepEqual(clockRowFormats('verticalFormat'), clockModel.clockFormats(true), 'menu spells out every vertical clock format')
assert(
  clockRows.every(item => item.checked && item.checked.includes('$(omarchy-bar get omarchy.clock ') && item.when.includes('$(omarchy-bar position)')),
  'menu checks the current clock format and offers only the formats for the bar orientation'
)
assertDeepEqual(
  ['top', 'bottom', 'left', 'right'].map(position => defaultById[`appearance.top-bar.position.${position}`].label),
  ['Top Bar', 'Bottom Bar', 'Left Bar', 'Right Bar'],
  'menu names each position after the bar'
)
assertDeepEqual(
  defaultItems.filter(item => item.parent === 'appearance.windows.corners').map(item => [item.label, item.action]),
  [['Theme Corners', 'omarchy-hyprland-corners theme'], ['Sharp Corners', 'omarchy-hyprland-corners sharp'], ['Rounded Corners', 'omarchy-hyprland-corners rounded']],
  'menu picks window corners from Appearance > Windows > Window Corners'
)
assertDeepEqual(
  defaultItems.filter(item => item.parent === 'appearance.windows.transparency').map(item => [item.label, item.action]),
  [
    ['Opaque Windows', 'omarchy-hyprland-window-transparency opaque'],
    ['Transparent Windows', 'omarchy-hyprland-window-transparency transparent'],
    ['Glassy Windows', 'omarchy-hyprland-window-transparency glassy']
  ],
  'menu picks window transparency from Appearance > Windows > Window Opacity'
)
const triggerIds = triggerItems.map(item => item.id)
const windowLabels = ['Window Gaps On', 'Window Gaps Off', 'Window Corners', 'Window Opacity', '1-Window Ratio On', '1-Window Ratio Off']
const appearanceLabels = ['Animations On', 'Animations Off', 'Menu Bar', 'Dock', 'Windows', 'Workspace Layout', ...windowLabels]
assertEqual(triggerIds[0], 'trigger.toggle', 'menu lists Toggle first under Trigger')
assertDeepEqual(
  defaultItems.filter(item => item.parent === 'appearance').map(item => item.label),
  ['Theme', 'Background', 'Font', 'Menu Bar', 'Windows', 'Branding', 'Dock', 'Workspace Layout', 'Animations On', 'Animations Off', 'Unlock'],
  'menu gathers the style and look of the desktop under Appearance'
)
assertDeepEqual(
  defaultItems.filter(item => item.parent === 'appearance.windows').map(item => item.label),
  windowLabels,
  'menu gathers the window looks under Appearance > Windows'
)
assertDeepEqual(
  defaultItems.filter(item => item.parent === 'appearance.branding').map(item => item.label),
  ['Screensaver', 'About'],
  'menu gathers the screensaver and About logos under Appearance > Branding'
)
assert(
  !defaultItems.some(item => item.parent === 'trigger.toggle' && appearanceLabels.includes(item.label)),
  'menu leaves the appearance entries out of Trigger > Toggle'
)
assertEqual(triggerIds.indexOf('trigger.clipboard-history'), triggerIds.indexOf('trigger.emoji') + 1, 'menu places Clipboard History right after Emoji')
assert(
  !defaultItems.some(item => item.id.startsWith('appearance.background-intro'))
    && defaultById['appearance.animations-on'].action === 'omarchy-toggle-animations',
  'menu uses the existing animations toggle without separate background intro controls'
)
assertDeepEqual(
  defaultItems.filter(item => item.parent === 'setup.plugin').map(item => item.label),
  ['Enable Plugin', 'Disable Plugin', 'Add Plugin', 'Clone Plugin', 'Remove Plugin'],
  'menu manages plugins from Setup > Plugins'
)
assert(
  ['enable', 'disable', 'clone', 'remove'].every(
    verb => defaultById[`setup.plugin.${verb}`].action === `omarchy-menu-plugin ${verb}`
  ),
  'menu picks a plugin the way it already picks a theme or a timezone'
)
assert(
  !defaultById['setup.plugin.enable'].when && !defaultById['setup.plugin.disable'].when,
  'menu always offers Enable and Disable, which cover the built-in plugins too'
)
assert(
  defaultById['setup.plugin.remove'].when.includes('.config/omarchy/plugins'),
  'menu hides Remove until a plugin the user installed exists to delete'
)
assert(
  defaultById['setup.plugin.add'].action.includes('omarchy-plugin-add'),
  'menu adds a plugin through the CLI, where the trust warning and clone output are visible'
)

const pluginPicker = fs.readFileSync(path.join(root, 'bin/omarchy-menu-plugin'), 'utf8')
assert(
  /enable\).*\(\.enabled \| not\)/.test(pluginPicker) && /disable\).*\.canDisable and \.enabled/.test(pluginPicker),
  'plugin picker offers what each verb can act on'
)
assert(
  /remove\).*\(\.firstParty \| not\)/.test(pluginPicker)
    && /clone\).*\.firstParty/.test(pluginPicker)
    && !/kinds|bar-widget|A_BAR_OPTION|NOT_A_BAR_OPTION|BAR_ICON/.test(pluginPicker),
  'plugin picker leaves plugin-kind decisions to its data and the plugin command'
)

const pluginAdd = fs.readFileSync(path.join(root, 'bin/omarchy-plugin-add'), 'utf8')
const pluginEnable = fs.readFileSync(path.join(root, 'bin/omarchy-plugin-enable'), 'utf8')
assert(
  /Now using \$id as the bar/.test(pluginEnable)
    && /omarchy-plugin-enable "\$id" "\$\{ENABLE_PLACEMENT\[@\]\}"/.test(pluginAdd),
  'plugin enable reports a bar as replacing the one in use, whether enabled or freshly added'
)
assert(
  /\.barWidget\.defaultSection \/\/ "centerEnd" \| if \. == "center" then "centerEnd" end/.test(pluginAdd)
    && /printf '%s\\n' left centerBegin center centerEnd tray right \|/.test(pluginAdd)
    && /gum choose[\s\S]*?--selected "\$default_section"/.test(pluginAdd),
  'interactive plugin add offers every bar section and selects the manifest placement or centerEnd fallback by default'
)
assert(
  /"omarchy-plugin-\$1" "\$id"/.test(pluginPicker),
  'plugin picker delegates enable and disable without interpreting plugin kinds'
)
// Icons ride along as "<glyph>\tlabel\tsubtext"; the menu shows the glyph,
// renders the subtext under the label, and hands back "label\tsubtext" so the
// picker can act on the id without resolving a display name. What the picker
// then does with the row it gets back is checked in menu-plugin-test.sh.
assert(
  /\.name \+ \\"\\\\t\\" \+ \.id/.test(pluginPicker)
    && /id=\$\(cut -f2 <<<"\$selection"\)/.test(pluginPicker),
  'plugin picker shows the id as row subtext and acts on the id the selection hands back'
)
assert(
  /var icon = parts\.length > 1 \? parts\.shift\(\) : ""\s*\n\s*var label = parts\.shift\(\) \|\| ""\s*\n\s*var detail = parts\.join\("\\t"\)/.test(menuQml),
  'menu select mode reads a leading icon and a trailing subtext off an option'
)
assert(
  /omarchy-launch-floating-terminal-with-presentation "omarchy-plugin-remove/.test(pluginPicker),
  'plugin picker removes where the confirmation and backup path are visible'
)

// A font installed since the shell started should show up without a restart.
const providerBlock = menuQml.match(/readonly property var providers: \(\{[\s\S]*?\n  \}\)/)[0]
assert(
  /"fonts": \{[\s\S]*?volatile: true/.test(providerBlock),
  'menu re-enumerates the font list every time it is opened'
)
assert(
  /function setActiveMenu\([\s\S]*?root\.invalidateVolatileProvider\(id\)\s*\n\s*root\.loadProviderForMenu\(id\)/.test(menuQml)
    && /function openExistingMenu\([\s\S]*?invalidateVolatileProvider\(activeMenu\)\s*\n\s*loadProviderForMenu\(activeMenu\)/.test(menuQml),
  'menu invalidates volatile providers when entering a menu, not on every keystroke'
)
assert(
  ['loadProviderForMenu', 'loadProvidersForSearch'].every(
    name => !menuQml.match(new RegExp(`function ${name}\\([^)]*\\) \\{([\\s\\S]*?)\\n  \\}`))[1].includes('invalidateVolatileProvider')
  ),
  'menu search never restarts a volatile provider'
)
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
assertEqual(
  defaultById['trigger.hardware.laptop-display-on'].when,
  'omarchy-hw-laptop && omarchy-hyprland-toggle-enabled internal-monitor-disable',
  'menu only shows Laptop Display on laptops'
)
assertEqual(
  defaultById['trigger.hardware.mirror-display-on'].when,
  'omarchy-hw-laptop && ! omarchy-hyprland-toggle-enabled internal-monitor-mirror',
  'menu only shows Mirror Display on laptops'
)
assertEqual(
  defaultById['trigger.capture.screenrecord.webcam'].when,
  'omarchy-hw-webcam',
  'menu only shows webcam screen recording when a webcam is available'
)
assertEqual(
  defaultById['trigger.capture.screenrecord.stop'].when,
  'omarchy-capture-screenrecording --status',
  'menu shows Stop Screenrecording only when its stop has a recording to end'
)
assert(
  /font\.family: row\.iconFont\.length > 0 \? row\.iconFont : root\.fontFamily/.test(menuQml),
  'menu rows support per-icon font families'
)

assert(
  /function select\(delta\)[\s\S]*root\.disarmPointer\(\)[\s\S]*selectedIndex =/.test(menuQml),
  'menu keyboard navigation disarms pointer selection'
)
// A dimmed row is not a target: the cursor steps over it, the pointer refuses
// to land on it, and neither Enter nor a click can reach it.
assert(
  /function select\(delta\)[\s\S]*?var target = root\.nextSelectable\(from, delta\)\s*\n\s*if \(target < 0\) return/.test(menuQml),
  'menu keyboard navigation skips disabled rows in the direction of travel'
)
assert(
  /function rowSelectable\(index\)[\s\S]*?return !displayModel\.get\(index\)\.disabled/.test(menuQml),
  'menu reads selectability off the row'
)
assert(
  /function activateIndex\(index, fromPointer\)[\s\S]*?if \(!root\.rowSelectable\(index\)\) return/.test(menuQml),
  'menu refuses to activate a disabled row'
)
assert(
  /function selectFromPointer\(index, item, mouse\)[\s\S]*?if \(!root\.rowSelectable\(index\)\) return/.test(menuQml)
    && /onClicked: \{\s*\n\s*if \(row\.disabled\) return/.test(menuQml),
  'menu leaves the cursor put when the pointer crosses a disabled row'
)
assert(
  /opacity: row\.disabled \? 0\.4 : 1/.test(menuQml) && !/font\.italic/.test(menuQml),
  'menu renders a disabled row faded, and leaves it at that'
)
assert(
  /function rebuildDisplay\(\)[\s\S]*?root\.settleCursor\(\)/.test(menuQml),
  'menu parks the cursor on a selectable row after the rows change'
)
// A menu with nothing selectable in it has no cursor, and Return must not
// conjure one onto a disabled row just because rows exist.
assert(
  /function settleCursor\(\)[\s\S]*?root\.cursorActive = target >= 0/.test(menuQml)
    && /else if \(root\.cursorActive\) root\.activateIndex\(root\.selectedIndex\)\s*\n\s*else root\.settleCursor\(\)/.test(menuQml),
  'menu ties the cursor to a selectable row existing, both ways'
)
assert(
  /function setFilter\(nextFilter\)[\s\S]*root\.disarmPointer\(\)/.test(menuQml),
  'menu filter changes disarm pointer selection'
)
assert(
  /function setActiveMenu\(id, pushHistory, fromPointer\)[\s\S]*if \(fromPointer\) pointerGate\.allowInitialSample\(\)\s*else root\.disarmPointer\(\)/.test(menuQml),
  'menu route changes only accept an initial pointer sample for mouse activation'
)
assert(
  /\(event\.key === Qt\.Key_Backspace \|\| Util\.readingKey\(event\) === Qt\.Key_Left\) && !root\.filterText[\s\S]*root\.goBack\(\)/.test(menuQml),
  'menu Left key (Right in a right-to-left language) follows empty-filter Backspace navigation'
)
// Input methods commit text only to a text-input item, so the search line must be one.
const filterInputBlock = (menuQml.match(/FilterInput \{[\s\S]*?\n          \}/) || [''])[0]
assert(
  /keyHandler: keyCatcher/.test(filterInputBlock)
    && /readOnly: root\.deleteConfirmOpen/.test(filterInputBlock)
    && /onTextChanged: if \(text !== root\.filterText\) root\.setFilter\(text\)/.test(filterInputBlock)
    && /onFilterTextChanged: if \(filterInput\.text !== filterText\) filterInput\.text = filterText/.test(menuQml)
    && !/event\.text/.test(menuQml.match(/id: keyCatcher[\s\S]*?ConfirmDialog \{/)[0])
    && (menuQml.match(/keyCatcher\.forceActiveFocus/g) || []).length === 0,
  'menu search line takes input-method text, refuses it behind the delete confirmation, and stays in step with the filter'
)
assert(
  /PointerMoveGate\s*\{[\s\S]*id: pointerGate[\s\S]*referenceItem: card[\s\S]*\}/.test(menuQml),
  'menu uses shared pointer movement gate in card coordinates'
)
assert(
  /function disarmPointer\(\)[\s\S]*pointerGate\.reset\(\)/.test(menuQml),
  'menu resets pointer movement gate when pointer selection is disarmed'
)
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
// Rows are keyed by id, so a provider handing over two rows with the same id
// would lose one. Distinct plugin ids can slugify alike, which is why the
// menu makes each row id its own before merging.
assertEqual(
  ['acme.foo', 'acme_foo', 'acme-foo'].map(menu.slugify).join(','),
  'acme-foo,acme-foo,acme-foo',
  'menu slugs collide across plugin ids that differ only in separator'
)
assert(
  /var rowId = menuId \+ "\." \+ root\.slugify\(value\)\s*\n\s*while \(takenIds\[rowId\]\) rowId \+= "-"/.test(menuQml),
  'menu keeps colliding provider rows apart so none is dropped'
)

// The maps live in QML `var` properties, where an in-place write is
// occasionally dropped by the engine, so both merges must hand back fresh
// objects for the caller to assign in one shot.
assert(
  /var merged = MenuModel\.mergeAppRows\(root\.items, root\.itemOrder, appRows\)\s*\n\s*root\.items = merged\.items\s*\n\s*root\.itemOrder = merged\.itemOrder/.test(menuQml),
  'menu assigns the rebuilt app item map instead of mutating it in place'
)
assert(
  /var merged = MenuModel\.swapProviderRows\(root\.items, root\.itemOrder, menuId, providerRows\)\s*\n[\s\S]*?root\.items = merged\.items\s*\n\s*root\.itemOrder = merged\.itemOrder/.test(menuQml),
  'menu assigns the rebuilt provider item map instead of mutating it in place'
)
assert(
  !/root\.items\[[^\]]+\] =/.test(menuQml) && !/delete root\.items\[/.test(menuQml),
  'menu never writes into the item map held by the var property'
)

for (const functionName of ['openExistingMenu', 'openDmenu']) {
  const openMatch = menuQml.match(new RegExp(`function ${functionName}\\([^)]*\\) \\{([\\s\\S]*?)\\n  \\}`))
  assert(openMatch, `menu ${functionName} function exists`)
  assert(
    openMatch[1].indexOf('root.disarmPointer()') < openMatch[1].indexOf('opened = true')
      && !openMatch[1].includes('pointerGate.allowInitialSample()'),
    `menu ${functionName} ignores a stale hidden-pointer position when becoming visible`
  )
}
assert(
  /function selectFromPointer\(index, item, mouse\)[\s\S]*pointerGate\.moved\(item, mouse\)[\s\S]*root\.selectedIndex = index/.test(menuQml),
  'menu only selects from pointer after real movement'
)
assert(
  /onPositionChanged: function\(mouse\) \{\s*root\.selectFromPointer\(row\.index, row, mouse\)\s*\}/.test(menuQml),
  'menu row hover routes through pointer movement gate'
)
assert(
  /dmenuSaved = dmenuSelected\s*\n\s*if \(dmenuOnChange\.length > 0\)/.test(menuQml)
    && /root\.dmenuSaved = root\.dmenuSelected\s*\n\s*\} else \{\s*root\.dmenuSelected = root\.dmenuSaved/.test(menuQml),
  'a failed immediate change restores the confirmed checks, even after reopening onto queued ones'
)
assert(
  /onEntered: root\.selectFromPointer\(row\.index, row, \{\s*x: mouseArea\.mouseX,\s*y: mouseArea\.mouseY\s*\}\)/.test(menuQml),
  'menu samples pointer movement immediately when entering a row'
)
assert(
  /function activateIndex\(index, fromPointer\)[\s\S]*root\.setActiveMenu\(row\.target \|\| row\.itemId, true, fromPointer\)/.test(menuQml)
    && /onClicked:[\s\S]*root\.activateIndex\(row\.index, true\)/.test(menuQml),
  'mouse activation carries pointer intent into subordinate menus'
)
// Both menu files load separately at startup; evaluating after the first
// alone ran the whole guard batch twice.
assert(
  /function rebuildItemsFromSources\(skipGuards\)[\s\S]*?if \(!skipGuards && root\.defaultMenuSettled && root\.userMenuSettled\) root\.evaluateGuards\(\)/.test(menuQml)
    && /onLoaded: \{ root\.defaultMenuItems = [^}]*root\.defaultMenuSettled = true; root\.rebuildItemsFromSources\(\) \}/.test(menuQml)
    && /onLoadFailed: \{ root\.defaultMenuSettled = true; if \(root\.userMenuSettled\) root\.evaluateGuards\(\) \}/.test(menuQml)
    && /onLoaded: \{ root\.userMenuItems = [^}]*root\.userMenuSettled = true; root\.rebuildItemsFromSources\(\) \}/.test(menuQml)
    && /onLoadFailed: \{ root\.userMenuItems = \[\]; root\.userMenuSettled = true; root\.rebuildItemsFromSources\(\) \}/.test(menuQml),
  'menu evaluates guards once both menu files have answered, not once per file at startup'
)
assert(
  /function openExistingMenu\([\s\S]*?root\.evaluateGuards\(\)/.test(menuQml),
  'menu still evaluates guards on every open, settled or not'
)
JS

font_charset=$(fc-query --format='%{charset}' "$ROOT/default/fonts/omarchy/omarchy.ttf")
[[ $font_charset == *"e900-e90f"* ]] || fail "Omarchy icon font includes every custom menu glyph"
pass "Omarchy icon font includes the official agent marks"
