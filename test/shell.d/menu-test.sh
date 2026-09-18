#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

run_node_test <<'JS'
const fs = require('fs')
const menu = requireFromRoot('shell/plugins/menu/MenuModel.js')
const menuModelJs = fs.readFileSync(path.join(root, 'shell/plugins/menu/MenuModel.js'), 'utf8')
const menuQml = fs.readFileSync(path.join(root, 'shell/plugins/menu/Menu.qml'), 'utf8')
const actionPanelQml = fs.readFileSync(path.join(root, 'shell/plugins/menu/ActionPanel.qml'), 'utf8')
const previewPaneQml = fs.readFileSync(path.join(root, 'shell/plugins/menu/PreviewPane.qml'), 'utf8')
const scopeSearchQml = fs.readFileSync(path.join(root, 'shell/plugins/menu/ScopeSearchController.qml'), 'utf8')
const defaultMenuJsonc = fs.readFileSync(path.join(root, 'default/omarchy/omarchy-menu.jsonc'), 'utf8')
const shellQml = fs.readFileSync(path.join(root, 'shell/shell.qml'), 'utf8')
const utilitiesLua = fs.readFileSync(path.join(root, 'default/hypr/bindings/utilities.lua'), 'utf8')

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
    when: '',
    checked: '',
    disabled: ''
  },
  'menu normalizes parsed items'
)

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
    appSubtitle: '',
    summary: '',
    categories: [],
    desktopActions: [],
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

assert(shellQml.includes('delegate: GlobalShortcut {'), 'shell registers menu hotkeys in the persistent process')
assert(shellQml.includes('shell.toggle("omarchy.menu", JSON.stringify({ menu: modelData.route }))'), 'global menu hotkeys still resolve plugin replacements centrally')
assert(utilitiesLua.includes('hl.dsp.global("omarchy:menu-root")'), 'Super+Space bypasses per-invocation shell IPC startup')
assertEqual(menu.parentDirectory('/home/user/file.txt'), '/home/user', 'menu finds a file containing folder')
assertEqual(menu.parentDirectory('/home/user/project/'), '/home/user', 'menu finds a project containing folder')
assertEqual(menu.parentDirectory('/file.txt'), '/', 'menu keeps a root-level file in root')
assertDeepEqual(
  menu.actionsForRow({ kind: 'file', target: '/tmp/readme', label: 'readme', disabled: false }).map(action => action.id),
  ['primary', 'open-parent', 'copy-path', 'forget-recent'],
  'file action panel offers open, reveal, copy, and forget'
)
assertDeepEqual(
  menu.actionsForRow({ kind: 'agent-session', target: 'session-1', label: 'Session', disabled: false }).map(action => action.id),
  ['primary', 'copy-session-id', 'forget-conversation'],
  'conversation action panel offers resume, copy id, and forget'
)
assertDeepEqual(
  menu.actionsForRow({ kind: 'app', appId: 'firefox', label: 'Firefox', disabled: false }).map(action => action.id),
  ['primary', 'uninstall-app'],
  'application action panel offers open and uninstall'
)
assertEqual(menu.actionsForRow({ kind: 'hint', disabled: true }).length, 0, 'action panel skips inert rows')
assert(menuQml.includes('event.key === Qt.Key_K && (event.modifiers & Qt.ControlModifier)'), 'menu opens actions with Ctrl+K')
assert(menuQml.includes('mouse.button === Qt.RightButton'), 'menu opens actions from a row context click')
assertEqual(menu.actionsForRow({ kind: 'file' })[2].operation, 'copy-target', 'result actions separate stable operations from type-specific presentation')
assert(actionPanelQml.includes('signal triggered(var action)'), 'action panel returns declarative action descriptors to the menu')
assert(actionPanelQml.includes('ListView {') && actionPanelQml.includes('ListView.Contain'), 'action panel caps long app action lists and keeps keyboard selection visible')

const nativeAppActions = menu.actionsForRow({
  kind: 'app', appId: 'firefox', label: 'Firefox', disabled: false,
  desktopActions: [
    { id: 'new-window', name: 'New Window', icon: 'window-new' },
    { id: 'private-window', name: 'New Private Window', icon: '' }
  ]
})
assertDeepEqual(nativeAppActions.map(action => action.id), ['primary', 'desktop.new-window', 'desktop.private-window', 'uninstall-app'], 'application action panel expands every declared desktop action in order')
assertEqual(nativeAppActions[2].operation, 'desktop-action', 'native application actions use a stable declarative operation')
assertEqual(nativeAppActions[2].target, 'private-window', 'native application action descriptors retain only their action id')

assertEqual(menu.previewForRow({ kind: 'file', target: '/tmp/manual.pdf', label: 'Manual' }).kind, 'image', 'menu previews PDF and image files visually')
assertEqual(menu.previewForRow({ kind: 'file', target: '/tmp/readme.md', label: 'Readme' }).kind, 'text', 'menu previews known text files as text')
assertEqual(menu.previewForRow({ kind: 'file', target: '/tmp/archive.zip', label: 'Archive' }).kind, 'metadata', 'menu falls back to metadata for opaque files')
const appPreview = menu.previewForRow({
  kind: 'app', label: 'Firefox', appIcon: 'firefox', appId: 'firefox',
  appSubtitle: 'Web Browser', summary: 'Browse the Web', categories: ['Network', 'WebBrowser'],
  lastUsed: 1000, useCount: 3
}, 121000)
assertEqual(appPreview.kind, 'app', 'menu previews applications through their icon')
assertEqual(appPreview.subtitle, 'Web Browser', 'application previews retain the desktop entry generic name')
assertEqual(appPreview.summary, 'Browse the Web', 'application previews retain the desktop entry comment')
assertDeepEqual(appPreview.metadata, [
  { label: 'Category', value: 'Internet' },
  { label: 'Last opened', value: '2m ago' },
  { label: 'Launches', value: '3 times' },
  { label: 'Application ID', value: 'firefox' }
], 'application previews expose useful structured metadata')
assertEqual(menu.previewForRow({ kind: 'menu', label: 'Setup' }).kind, '', 'menu does not expand for non-previewable command rows')
assert(menuQml.includes('MenuModel.previewForRow(displayModel.get(index), Date.now())'), 'menu derives previews from the selected result descriptor')
assert(menuQml.includes('PreviewPane {'), 'menu delegates preview rendering to the preview pane')
assert(menuQml.includes('width: root.previewSpaceReserved'), 'result views reserve a stable detail column as selection changes')
assert(
  /function hasPreviewableRows\(serial\) \{[\s\S]*?MenuModel\.previewForRow\(displayModel\.get\(i\)\)\.kind !== ""/.test(menuQml)
    && menuQml.includes('root.hasPreviewableRows(layoutSerial)'),
  'fallback and loading states use the full card unless the displayed result set can show a preview'
)
assert(
  menuQml.includes('label: "Ask Agent"')
    && menuQml.includes('label: "Search the Web"'),
  'fallback commands use concise full-width actions without a redundant heading'
)
assert(!menuQml.includes('Use “" + root.filterText'), 'fallback commands do not add a decorative query heading')
assert(
  /property int cardWidth: Math\.min\(root\.dmenuActive \? Style\.space\(root\.dmenuWidth\)\s*\n\s*: root\.standardCardWidth/.test(menuQml),
  'every normal launcher route uses one fixed outer width while dmenu keeps its requested width'
)
assert(menuQml.includes('anchors.horizontalCenter: parent.horizontalCenter'), 'the fixed-width launcher card remains horizontally centered')
assert(menuQml.includes('interval: 32'), 'menu coalesces sustained key-repeat bursts while text updates immediately')
assert(
  !/visibleRowsHeight:[^\n]*filterText/.test(menuQml),
  'filter text changes do not synchronously walk row layout before results change'
)
assert(
  /var previousWasEmpty = !root\.filterText\.trim\(\)[\s\S]*?if \(previousWasEmpty\) root\.loadProvidersForSearch\(\)/.test(menuQml),
  'menu scans unloaded providers once when search begins rather than on every key'
)
assert(
  menuModelJs.includes('if (Math.abs(al - bl) > 2) return 99'),
  'typo matching rejects impossible length differences before allocating UI-thread work'
)
assert(previewPaneQml.includes('["head", "-c", "12288", "--", root.descriptor.target]'), 'text previews read a bounded amount without a shell')
assert(previewPaneQml.includes('model: root.descriptor.metadata || []'), 'preview pane renders structured application metadata declaratively')

const defaultItems = menu.parseMenuJsonc(defaultMenuJsonc)
const defaultById = Object.fromEntries(defaultItems.map(item => [item.id, item]))

assertEqual(defaultById.search.kind, 'menu', 'menu groups web searches in a Search submenu')
assertDeepEqual(
  defaultItems.filter(item => item.parent === 'search').map(item => item.id),
  ['search.web', 'search.github', 'search.aur'],
  'menu keeps Web, GitHub, and AUR under Search'
)
assert(!defaultById.github && !defaultById.aur && !defaultById.archwiki, 'menu keeps search services and Arch Wiki out of the root')
assert(defaultById['search.github'].aliases.includes('github'), 'menu preserves the GitHub route as an alias')
assert(defaultById['search.aur'].aliases.includes('aur'), 'menu preserves the AUR route as an alias')
assert(defaultById['learn.arch'].aliases.includes('archwiki'), 'menu preserves the Arch Wiki route on Learn > Arch')

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
  rankScore('style.font', 'font') < rankScore('apps.fontforge', 'font'),
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
assertEqual(menu.resolveRoute(routed.items, routed.itemOrder, 'github'), 'search.github', 'menu preserves the former GitHub route below Search')
assertEqual(menu.resolveRoute(routed.items, routed.itemOrder, 'aur'), 'search.aur', 'menu preserves the former AUR route below Search')
assertEqual(menu.resolveRoute(routed.items, routed.itemOrder, 'archwiki'), 'learn.arch', 'menu preserves the former Arch Wiki route below Learn')
assertEqual(menu.resolveRoute(routed.items, routed.itemOrder, 'power_menu'), 'system', 'menu normalizes underscores in routes')
assertEqual(menu.resolveRoute(routed.items, routed.itemOrder, ''), 'root', 'menu routes empty input to root')
assertEqual(menu.resolveRoute(routed.items, routed.itemOrder, 'no-such-route'), 'no-such-route', 'menu falls through to the literal input')
assert(menu.matchesQuery(routed.items['apps.htop'], 'system', true), 'menu still finds an app by its keywords in search')
assert(
  /function resolveRoute\(input\) \{\s*\n\s*return MenuModel\.resolveRoute\(root\.items, root\.itemOrder, input\)\s*\n\s*\}/.test(menuQml),
  'menu delegates route resolution to the shared model'
)
const triggerItems = defaultItems.filter(item => item.parent === 'trigger')
assertEqual(
  triggerItems[0].id,
  'trigger.emoji',
  'menu lists Emoji first under Trigger'
)
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
  ['Antigravity', 'Claude', 'Codex', 'Copilot', 'Crush', 'Cursor CLI', 'Grok', 'Hermes', 'Muse Code', 'omp', 'OpenClaw', 'OpenCode', 'Ori', 'Pi'],
  'menu sorts coding agents alphabetically'
)
const expectedDefaults = {
  browser: ['Chromium', 'Chrome', 'Brave', 'Brave Origin', 'Edge', 'Firefox', 'Zen'],
  terminal: ['Alacritty', 'Foot', 'Ghostty', 'Kitty'],
  editor: ['Neovim', 'VSCode', 'Cursor', 'Zed', 'Sublime Text', 'Helix', 'Vim', 'Emacs']
}
assert(
  Object.entries(expectedDefaults).every(([type, labels]) => {
    const entries = defaultItems.filter(item => item.parent === `setup.default.${type}`)
    return entries.map(item => item.label).join('\0') === labels.join('\0')
      && entries.every(item => !item.when)
  }),
  'menu always exposes every supported browser, terminal, and editor under Defaults'
)
assert(!defaultById['install.ai.crush'], 'menu removes Crush from Install > AI')
// Software you already have keeps its place in Install, dimmed rather than
// dropped, so the list reads as a catalog of what Omarchy can install.
// Chromium Account is the sole Install row with anything left to hide for, so
// any other `when:` here is a row that went back to vanishing once installed.
assertDeepEqual(
  defaultItems
    .filter(item => item.id.startsWith('install.') && item.action && item.when)
    .map(item => item.id),
  ['install.service.chromium-account'],
  'menu never hides an Install row because the software is already there'
)
assert(
  ['install.browser.zen', 'install.editor.vscode', 'install.gaming.steam', 'install.development.rust', 'install.windows'].every(
    id => defaultById[id].disabled && !defaultById[id].when
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
  'menu orders Remove categories like their Install counterparts, followed by Remove-only categories'
)
assert(
  defaultById['setup.security.passwordless-sudo'].action.includes('omarchy-sudo-passwordless'),
  'menu places Passwordless Sudo under Setup > Security'
)
assert(
  !defaultById['trigger.toggle.direct-boot'] && !defaultById['trigger.toggle.passwordless-sudo'],
  'menu removes the relocated toggles from Trigger > Toggle'
)
assert(
  defaultById['style.bar.position'].kind === 'menu',
  'menu groups Menu Bar positions in a submenu'
)
assert(
  ['top', 'bottom', 'left', 'right'].every(position => defaultById[`style.bar.position.${position}`].action === `omarchy-bar position ${position}`),
  'menu lists all Menu Bar positions under Position'
)
assertEqual(
  defaultById['style.bar.transparency'].action,
  'omarchy-bar transparent toggle',
  'menu exposes Menu Bar transparency as a toggle'
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
  /\.barWidget\.defaultSection \/\/ "center"/.test(pluginAdd)
    && /gum choose[\s\S]*?--selected "\$default_section"/.test(pluginAdd),
  'interactive plugin add selects the manifest placement or center fallback by default'
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
assertEqual(
  defaultById['trigger.hardware.laptop-display'].when,
  'omarchy-hw-laptop',
  'menu only shows Laptop Display on laptops'
)
assertEqual(
  defaultById['trigger.hardware.mirror-display'].when,
  'omarchy-hw-laptop',
  'menu only shows Mirror Display on laptops'
)
assertEqual(
  defaultById['trigger.capture.screenrecord.webcam'].when,
  'omarchy-hw-webcam',
  'menu only shows webcam screen recording when a webcam is available'
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
    && /onClicked: function\(mouse\) \{\s*\n\s*if \(row\.disabled\) return/.test(menuQml),
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
  /\(event\.key === Qt\.Key_Backspace \|\| event\.key === Qt\.Key_Left\) && !root\.filterText[\s\S]*root\.goBack\(\)/.test(menuQml),
  'menu Left key follows empty-filter Backspace navigation'
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
  /onEntered: root\.selectFromPointer\(row\.index, row, \{\s*x: mouseArea\.mouseX,\s*y: mouseArea\.mouseY\s*\}\)/.test(menuQml),
  'menu samples pointer movement immediately when entering a row'
)
assert(
  /function activateIndex\(index, fromPointer\)[\s\S]*root\.setActiveMenu\(row\.target \|\| row\.itemId, true, fromPointer\)/.test(menuQml)
    && /onClicked:[\s\S]*root\.activateIndex\(row\.index, true\)/.test(menuQml),
  'mouse activation carries pointer intent into subordinate menus'
)

// Fuzzy matching and typo tolerance
assertEqual(menu.fuzzyMatch('zen', 'zen').score, 100, 'fuzzyMatch scores exact matches 100')
assertEqual(menu.fuzzyMatch('zen', 'zen-browser').score, 85, 'fuzzyMatch scores prefix matches 85')
assert(menu.fuzzyMatch('zb', 'zen-browser').matched, 'fuzzyMatch matches subsequence across word boundaries')
assert(!menu.fuzzyMatch('xyz', 'zen').matched, 'fuzzyMatch rejects non-subsequence')
assert(menu.fuzzyMatchWords('term', 'alacritty terminal emulator').matched, 'fuzzyMatchWords finds matches across words')

assert(menu.typoMatch('brav', 'brave').matched, 'typoMatch tolerates single-character omission')
assert(menu.typoMatch('chrmoe', 'chrome').matched, 'typoMatch tolerates transposition via Damerau-Levenshtein')
assert(!menu.typoMatch('zen', 'zen').matched, 'typoMatch skips short patterns of 3 or fewer characters')
assert(!menu.typoMatch('firefox', 'brave').matched, 'typoMatch rejects large edit distances')

// Quicklink and prompt-first input helpers
assertEqual(menu.quicklinkFirstTerm('g search query'), 'g', 'quicklinkFirstTerm extracts trigger word')
assertEqual(menu.quicklinkRemainder('g search query'), 'search query', 'quicklinkRemainder extracts query after trigger')
assertEqual(menu.quicklinkRemainder('singleword'), '', 'quicklinkRemainder returns empty string for single word')
assert(menu.hasParam('omarchy-websearch {}'), 'hasParam detects {} placeholder')
assert(!menu.hasParam('omarchy-theme-set'), 'hasParam returns false when {} is absent')
assertEqual(menu.substituteParam('echo {}', 'hello world'), 'echo hello world', 'substituteParam replaces {} with argument')

assertDeepEqual(
  menu.normalizeInput({ prompt: 'Ask...', action: 'omarchy-agent-ask {}' }),
  { prompt: 'Ask...', action: 'omarchy-agent-ask {}' },
  'normalizeInput returns normalized prompt and action'
)
assertEqual(
  menu.normalizeInput({ action: 'run {}' }).prompt,
  'Input',
  'normalizeInput defaults missing prompt to Input'
)
assertEqual(menu.normalizeInput(null), null, 'normalizeInput rejects null')
assertEqual(menu.normalizeInput({ prompt: 'No action' }), null, 'normalizeInput rejects missing action')

// Recent files search and icons
assertEqual(menu.iconForFile('main.rs'), '\ue7a8', 'iconForFile identifies Rust files')
assertEqual(menu.iconForFile('app.ts'), '\ue628', 'iconForFile identifies TypeScript files')
assertEqual(menu.iconForFile('config.json'), '\ue60b', 'iconForFile identifies JSON files')
assertEqual(menu.iconForFile('Dockerfile'), '\ue7b0', 'iconForFile identifies Dockerfile')
assertEqual(menu.iconForFile('unknown.xyz123'), '\uf016', 'iconForFile falls back to default document icon')

const sampleFrecency = {
  '/home/user/project/main.rs': { score: 100 },
  '/home/user/docs/notes.txt': { score: 50 },
  'relative/path/ignored.txt': { score: 200 }
}
const fileRows = menu.fileSearchRows(sampleFrecency, 'main', 5)
assertEqual(fileRows.length, 1, 'fileSearchRows filters entries by query terms')
assertEqual(fileRows[0].target, '/home/user/project/main.rs', 'fileSearchRows targets matching absolute path')
assertEqual(fileRows[0].kind, 'file', 'fileSearchRows creates file kind rows')
assertEqual(fileRows[0].label, 'main.rs', 'fileSearchRows extracts basename for label')
assertEqual(fileRows[0].detail, '/home/user/project', 'fileSearchRows extracts dirname for detail')
assertEqual(menu.fileSearchRows(sampleFrecency, '', 5).length, 0, 'fileSearchRows returns empty list for empty query')

// Unflattened submenus (flat: false) hide children from root flat search
const itemsMap = {
  'root': { id: 'root', parent: '' },
  'trigger': { id: 'trigger', parent: 'root' },
  'trigger.window': { id: 'trigger.window', parent: 'trigger' },
  'trigger.window.workspace': { id: 'trigger.window.workspace', parent: 'trigger.window', flat: false },
  'trigger.window.workspace.1': { id: 'trigger.window.workspace.1', parent: 'trigger.window.workspace' },
  'trigger.window.left': { id: 'trigger.window.left', parent: 'trigger.window' }
}
assert(menu.isSearchableDescendant(itemsMap, 'trigger.window.workspace', 'root'), 'unflattened submenu is searchable from root')
assert(!menu.isSearchableDescendant(itemsMap, 'trigger.window.workspace.1', 'root'), 'unflattened submenu child is hidden from root flat search')
assert(menu.isSearchableDescendant(itemsMap, 'trigger.window.left', 'root'), 'normal child is searchable from root')
assert(menu.isSearchableDescendant(itemsMap, 'trigger.window.workspace.1', 'trigger.window.workspace'), 'unflattened submenu child is searchable when submenu is active')

// Project and agent-session frecency rows
const richFrecency = {
  '/home/user/Work/kiln': { score: 120, kind: 'project', title: 'kiln' },
  '01a079e9-sess': { score: 80, kind: 'agent-session', title: 'Fix schema bug' }
}
const projRows = menu.fileSearchRows(richFrecency, 'kiln', 5)
assertEqual(projRows.length, 1, 'fileSearchRows matches project directory')
assertEqual(projRows[0].kind, 'project', 'project row has project kind')
assertEqual(projRows[0].icon, '\uf07c', 'project row uses folder icon')
assertEqual(projRows[0].label, 'kiln', 'project row uses project title')

const sessRows = menu.fileSearchRows(richFrecency, 'schema', 5)
assertEqual(sessRows.length, 0, 'fileSearchRows omits agent sessions from root search')
const resumeRows = menu.fileSearchRows(richFrecency, 'resume', 5)
assertEqual(resumeRows.length, 0, 'fileSearchRows does not match agent sessions on resume keyword')

// Lazy session search in resume subsection
const emptySess = menu.sessionSearchRows(richFrecency, '', 5)
assertEqual(emptySess.length, 1, 'sessionSearchRows returns recent sessions on empty query')
const matchSess = menu.sessionSearchRows(richFrecency, 'schema', 5)
assertEqual(matchSess.length, 1, 'sessionSearchRows lazily matches session by keyword')
assertEqual(matchSess[0].label, 'Fix schema bug', 'sessionSearchRows uses session title')
assertEqual(matchSess[0].action, "omarchy agent resume '01a079e9-sess'", 'sessionSearchRows configures resume command')

// Generic scoped search and normalization
const normScoped = menu.normalizeItem('resume', {
  label: 'Resume agent…',
  scope: 'agent-session',
  placeholder: 'Search previous conversations…',
  action: 'omarchy agent resume {}'
})
assertEqual(normScoped.kind, 'menu', 'scoped item normalizes to menu kind')
assertEqual(normScoped.scope, 'agent-session', 'scope attribute preserved')
assertEqual(normScoped.placeholder, 'Search previous conversations…', 'placeholder attribute preserved')
assertEqual(normScoped.action, 'omarchy agent resume {}', 'action template preserved')
assert(menu.isVisible({ resume: normScoped }, ['resume'], {}, normScoped), 'scoped menu is visible')

const emptyScoped = menu.scopedSearchRows(richFrecency, 'agent-session', '', 5)
assertEqual(emptyScoped.length, 1, 'scopedSearchRows returns recent items on empty query')
const matchScoped = menu.scopedSearchRows(richFrecency, 'agent-session', 'schema', 5, 'omarchy agent resume {}')
assertEqual(matchScoped.length, 1, 'scopedSearchRows lazily matches session by keyword')
assertEqual(matchScoped[0].label, 'Fix schema bug', 'scopedSearchRows uses item title')
assertEqual(matchScoped[0].action, "omarchy agent resume '01a079e9-sess'", 'scopedSearchRows configures templated action')

const normalizedScoped = menu.normalizeScopedResults([
  { target: "session'one", label: 'Session one', score: 7, lastUsed: 1000, useCount: 3, pinned: true }
], 'agent-session', 'omarchy agent resume {}', '')
assertEqual(normalizedScoped[0].kind, 'agent-session', 'streamed scope results inherit their declared kind')
assertEqual(normalizedScoped[0].icon, '', 'streamed scope results inherit their fallback icon')
assertEqual(normalizedScoped[0].action, "omarchy agent resume 'session'\\''one'", 'streamed scope results safely receive the menu action template')
assert(normalizedScoped[0].pinned && normalizedScoped[0].useCount === 3, 'streamed scope results retain rich activity metadata')

assertEqual(menu.relativeAge(1000, 31000), 'now', 'result recency rounds sub-minute ages to now')
assertEqual(menu.relativeAge(1000, 3 * 60 * 60000 + 1000), '3h', 'result recency formats compact hours')
const richRows = menu.decorateResultRows([
  { kind: 'file', target: '/tmp/report.pdf' },
  { kind: 'app', appId: 'org.example.App' }
], {
  '/tmp/report.pdf': { lastUsed: 1000, count: 4, pinned: true },
  'org.example.App': { lastUsed: 61000, count: 2 }
}, 121000)
assertDeepEqual(richRows[0].accessories.map(a => a.id), ['pinned', 'recency'], 'file results declare multiple ordered accessories')
assertEqual(richRows[0].accessories[1].text, '2m', 'result rows expose compact recency')
assertDeepEqual(menu.actionsForRow(richRows[0]).map(a => a.id), ['primary', 'open-parent', 'copy-path', 'unpin', 'forget-recent'], 'pinned files declaratively replace Pin with Unpin')
assertDeepEqual(menu.actionsForRow(richRows[1]).map(a => a.id), ['primary', 'pin', 'reset-ranking', 'uninstall-app'], 'used apps declaratively offer Pin and Reset Ranking')
const declaredAccessory = menu.decorateResultRows([
  { kind: 'fallback', accessories: [{ id: 'context', text: 'Default agent' }] }
], {}, 121000)
assertDeepEqual(declaredAccessory[0].accessories, [{ id: 'context', text: 'Default agent' }], 'result decoration preserves explicitly declared contextual accessories')

const firstBatch = menu.reduceScopeSearchEvent([], false, {
  version: 1, source: 'activity', queryId: '7', type: 'rows', rows: [{ target: 'one' }]
}, '7')
assert(firstBatch.accepted && firstBatch.started && firstBatch.changed, 'scope search reducer accepts a correlated row batch')
assertEqual(firstBatch.rows.length, 1, 'scope search reducer appends streamed rows')
const staleBatch = menu.reduceScopeSearchEvent(firstBatch.rows, true, {
  version: 1, source: 'activity', queryId: '6', type: 'rows', rows: [{ target: 'stale' }]
}, '7')
assert(!staleBatch.accepted && staleBatch.rows.length === 1, 'scope search reducer rejects stale query ids')
const populatedDone = menu.reduceScopeSearchEvent(firstBatch.rows, true, {
  version: 1, source: 'activity', queryId: '7', type: 'done'
}, '7')
assert(populatedDone.terminal && !populatedDone.changed, 'scope search reducer avoids a redundant populated done update')
const emptyDone = menu.reduceScopeSearchEvent([], false, {
  version: 1, source: 'activity', queryId: '7', type: 'done'
}, '7')
assert(emptyDone.terminal && emptyDone.changed, 'scope search reducer publishes a terminal empty result')
const failedSearch = menu.reduceScopeSearchEvent(firstBatch.rows, true, {
  version: 1, source: 'activity', queryId: '7', type: 'error', message: 'database unavailable'
}, '7')
assert(failedSearch.terminal && failedSearch.failed && !failedSearch.changed && failedSearch.rows.length === 1, 'scope search reducer preserves rows on backend errors')

assert(menuQml.includes('ScopeSearchController {'), 'menu delegates lazy-search lifecycle to one controller')
assert(menuQml.includes('scopeSearch.search(activeEntry.scope, query)'), 'menu schedules scoped queries through the controller contract')
assert(scopeSearchQml.includes('stdout: SplitParser {'), 'scope search consumes asynchronous results as a delimited stream')
assert(scopeSearchQml.includes('stdinEnabled: true'), 'scope search keeps a persistent worker')
assert(scopeSearchQml.includes('command: ["omarchy-activity", "search", "--worker"]'), 'scope search bypasses an intermediary shell for reliable worker lifecycle')
assert(scopeSearchQml.includes('worker.generation !== controller.generation'), 'scope search rejects results from stale generations')
assert(scopeSearchQml.includes('queryId: String(worker.generation)'), 'scope search correlates worker requests with generations')
JS

font_charset=$(fc-query --format='%{charset}' "$ROOT/default/fonts/omarchy/omarchy.ttf")
[[ $font_charset == *"e900-e90e"* ]] || fail "Omarchy icon font includes every custom menu glyph"
pass "Omarchy icon font includes the official agent marks"
