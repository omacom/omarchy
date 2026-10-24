#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

run_node_test <<'JS'
const fs = require('fs')
const panelSource = fs.readFileSync(root + '/shell/plugins/agents/Panel.qml', 'utf8')

const signInFunctions = ['supportsSignIn', 'needsSignIn', 'otherTrouble'].map(name => {
  const match = panelSource.match(new RegExp('function ' + name + '\\([^]*?\\n  \\}'))
  return match ? match[0] : ''
}).join('\n')
const signIn = new Function('addProviders', signInFunctions + '\nreturn {needsSignIn, otherTrouble}')(
  [{providerId: 'claude'}, {providerId: 'codex'}, {providerId: 'grok'}]
)
for (const id of ['claude', 'codex', 'grok'])
  assert(signIn.needsSignIn({providerId: id, usageStatusText: 'Sign-in expired'}), id + ' keeps its sign-in link')
assert(signIn.needsSignIn({usageStatusText: 'Sign-in expired'}), 'account rows keep their sign-in link')
for (const status of ['Sign-in expired', 'Waiting for auth']) {
  assert(!signIn.needsSignIn({providerId: 'agy', usageStatusText: status}), 'an agent the panel cannot sign in gets no link for ' + status)
  assert(signIn.otherTrouble({providerId: 'agy', usageStatusText: status}) === status, 'an agent the panel cannot sign in still shows ' + status)
}
assert(/function launchAgent\(\)/.test(panelSource), 'agents panel launches the default agent')
assert(/root\.bar\.run\("omarchy-agent --pick"\)/.test(panelSource), 'agents panel uses the desktop agent launcher')
assert(/if \(buttonCode === Qt\.RightButton\) root\.launchAgent\(\)/.test(panelSource), 'agents right click launches the agent')
assert(/else if \(buttonCode === Qt\.MiddleButton\) root\.refreshNow\(\)/.test(panelSource), 'agents middle click refreshes the limits')
assert(/else root\.toggle\(\)/.test(panelSource), 'agents left click still toggles the panel')
assert(!/if \(buttonCode === Qt\.RightButton\) root\.refreshNow\(\)/.test(panelSource), 'agents right click no longer refreshes')
assert(/if \(root\.addStage === "" \|\| root\.picking\) root\.moveKey\(dx, dy\)/.test(panelSource), 'arrows move the agents panel cursor on the page and while picking an agent to add')
assert(/target\.kind === "choice"\) chooseAddProvider\(/.test(panelSource), 'Enter on an agent to add chooses it')
assert(!/text: root\.addStage === "running" \? "Cancel" : "Back"/.test(panelSource), 'the hero X is the only way back from adding')
assert(/hasCursor: root\.hasKey\("add"\)/.test(panelSource) && /hasCursor: root\.hasKey\("launch"\)/.test(panelSource), 'the hero buttons take the keyboard cursor')
assert(/hasCursor: root\.hasKey\("starter", index\)/.test(panelSource), 'the starter tiles take the keyboard cursor')
assert(/root\.pointAt\("account", Number\(t\) - 1\)/.test(panelSource), 'number keys move the cursor to an account')
assert(/target\.kind === "launch"\) launchAgent\(\)/.test(panelSource), 'Enter on the launcher starts the default agent')
assert(/row\.push\(\{ kind: "autoswitch", index: entry \}\)/.test(panelSource), 'an inactive account offers Autoswitch and Use as separate stops')
assert(/kind: "signin", index: entry/.test(panelSource) && /kind: "providerSignin", index: p/.test(panelSource), 'Sign-in required links are keyboard stops')
assert(/target\.kind === "signin"\) signInAgain\(/.test(panelSource) && /target\.kind === "providerSignin"\) signInAgain\(/.test(panelSource), 'Enter on Sign-in required signs in again')
assert(/target\.kind === "autoswitch"\) setSwitchMode\(/.test(panelSource), 'Enter on Autoswitch flips the switch mode')
assert(/keyColumn = use >= 0 \? use : /.test(panelSource), 'moving up or down onto an account lands on Use')
assert(/Qt\.callLater\(function\(\) \{ if \(picking\) pointAt\("choice", 0\) \}\)/.test(panelSource), 'picking an agent to add starts with the first one focused')
assert(!/opacity: stale \?/.test(panelSource) && /I18n\.t\("agents\.lastUpdatedAgo"\)\.arg\(root\.formatDuration/.test(panelSource), 'stale limits say how old they are only on hover')
assert(/onPickingChanged: resetKeys\(\)/.test(panelSource), 'the cursor starts over when the agent list comes or goes')
assert(!/t === "a" \|\| t === "A"/.test(panelSource), 'adding an account has no hotkey; the + is the way in')
assert(/if \(!accounts\[a\]\.active\) \{/.test(panelSource) && /if \(row\.length > 0\) rows\.push\(row\)/.test(panelSource), 'the active account with nothing to fix is not a keyboard stop')
assert(/text: section\.provider \? \(root\.helpDisplayText\(section\.provider\.authHelpText\) \|\| root\.statusDisplayText\(section\.provider\.usageStatusText\) \|\| ""\) : ""/.test(panelSource), 'the trouble line falls back to the usage status when a record has no auth help')
assert(/case "Run `codex login` to authenticate\.":\s*return Commons\.I18n\.t\("agents\.helpRunToAuthenticate"\)\.arg\("`codex login`"\)/.test(panelSource), 'known collector help lines are translated at display, commands kept verbatim')
// A reworded collector line would silently fall back to English, so every
// fixed help line the collectors cache must still be one the panel maps.
for (const name of ['claude', 'codex', 'grok', 'fireworks']) {
  const collector = fs.readFileSync(root + '/bin/omarchy-agent-usage-' + name, 'utf8')
  const help = collector.match(/^AUTH_HELP = "([^"]+)"$/m)
  assert(help && panelSource.includes('case ' + JSON.stringify(help[1]) + ':'), name + ' auth help is translated in the panel')
}
const mainSource = fs.readFileSync(root + '/shell/plugins/agents/Main.qml', 'utf8')
assert(/var from = Math\.min\(0\.8, \(threshold - 15\) \/ 100\)/.test(mainSource), 'faster checks start 15 points below the switch threshold')
assert(/rows\.push\(\[\{ kind: "provider", index: p \}\]\)/.test(panelSource), "every agent's header is a keyboard stop")
assert(/reorderable: root\.addStage === "" && !root\.renaming/.test(panelSource) && /onEditingChanged: root\.renaming = editing/.test(panelSource) && /onReorderRequested: function\(dy\) \{ root\.reorderProvider\(dy\) \}/.test(panelSource), 'Ctrl+Up/Down moves the agent the cursor is in')
assert(/onReleased: root\.dropProvider\(\)/.test(panelSource), 'an agent can be dragged by its mark')
assert(/function moveProvider\(id, to\)/.test(mainSource) && /return orderedProviders\(result\)/.test(mainSource), 'the agents keep the order they were moved into')
const catcherSource = fs.readFileSync(root + '/shell/Ui/PanelKeyCatcher.qml', 'utf8')
assert(/if \(reorderable && \(event\.modifiers & Qt\.ControlModifier\)\)/.test(catcherSource), 'only panels that ask for it turn Ctrl+Up/Down into a reorder')
assert(/if \(\["account", "autoswitch", "signin"\]\.indexOf\(target\.kind\) < 0\) return -1/.test(panelSource), 'Ctrl+Up/Down does nothing outside an agent')
JS

# The panel reads a window out of a label, and that guess cannot survive a
# model name — "Opus 5 (1M context)" parses as a one-minute window. A collector
# that states the title outright is taken at its word.
run_node_test <<'JS'
const fs = require('fs')
const source = fs.readFileSync(root + '/shell/plugins/agents/Panel.qml', 'utf8')
const panelRoot = { nowMs: Date.now() }
const start = source.indexOf('function windowIsLong')
const end = source.indexOf('// The window that decides')
assert(start > 0 && end > start, 'agents panel exposes its limit-window helpers')
eval(source.slice(start, end).replaceAll('root.nowMs', 'panelRoot.nowMs'))
eval(source.slice(source.indexOf('function needsSignIn'), source.indexOf('// Sign an account')))

const paused = { usageStatusText: 'Limits paused', limits: [] }
assertEqual(pausedWithoutLimits(paused), true, 'paused usage without a cache shows a recovery placeholder')
assertEqual(otherTrouble(paused), '', 'paused usage never puts the confusing status in the header')
assertEqual(pausedWithoutLimits({ ...paused, limits: [{ label: 'Session (5-hour)', percent: 0, resetsAt: '' }] }), false, 'cached usage replaces the recovery placeholder')
assertEqual(pausedWithoutLimits({ usageStatusText: 'Sign-in expired', limits: [] }), false, 'expired sign-ins retain their sign-in action')
assertEqual(pausedWithoutLimits(null), false, 'missing records do not show a paused-usage placeholder')

assertDeepEqual(
  limitWindows({ limits: [
    { label: 'Session (5-hour)', percent: 0.78, resetsAt: '' },
    { label: 'Opus 5 (1M context) Weekly', title: 'Opus 5 (1M context) Weekly', percent: 0.42, resetsAt: '' }
  ] }),
  [
    { title: 'Session', percent: 0.78, resetAt: '' },
    { title: 'Opus 5 (1M context) Weekly', percent: 0.42, resetAt: '' }
  ],
  'agents panel titles a limit off the collector when it states one'
)

assertDeepEqual(
  limitWindows({ limits: [{ label: 'Weekly (7-day)', percent: 0.12, resetsAt: '' }] }),
  [{ title: 'Weekly', percent: 0.12, resetAt: '' }],
  'agents panel still reads a window out of a label that carries no title'
)

const resetAt = new Date(panelRoot.nowMs + 1000).toISOString()
const measured = { limits: [{ label: 'Session (5-hour)', percent: 0.78, resetsAt: resetAt }] }
assertEqual(limitWindows(measured)[0].percent, 0.78, 'usage remains until the reset time')
panelRoot.nowMs += 1000
assertDeepEqual(limitWindows(measured), [{ title: 'Session', percent: 0, resetAt: '' }], 'usage resets at the deadline while the panel stays open')
assertEqual(measured.limits[0].percent, 0.78, 'display reset leaves the measured record intact')

// A model's weekly allowance rides under the Weekly row; one whose window has
// no row of its own keeps a row.
assertDeepEqual(
  displayWindows({ limits: [
    { label: 'Session (5-hour)', percent: 0.94, resetsAt: '' },
    { label: 'Weekly (7-day)', percent: 0.25, resetsAt: 'w' },
    { label: 'Fable Weekly', title: 'Fable Weekly', percent: 0.09, resetsAt: 'w' },
    { label: 'Opus Monthly', title: 'Opus Monthly', percent: 0.5, resetsAt: '' }
  ] }),
  [
    { title: 'Session', percent: 0.94, resetAt: '', scoped: [] },
    { title: 'Weekly', percent: 0.25, resetAt: 'w', scoped: [{ title: 'Fable', percent: 0.09, resetAt: 'w' }] },
    { title: 'Opus Monthly', percent: 0.5, resetAt: '', scoped: [] }
  ],
  'agents panel shows a model-scoped window under the window it runs on'
)
JS

# The bar follows the fullest limit that can stop a prompt. Cursor's auto and
# named model meters are a breakdown of the included total, including on a
# record that has no supplementary flag yet. A Claude session, a model
# allowance such as Fable, and an on-demand dollar cap still count.
run_node_test <<'JS'
const fs = require('fs')
const source = fs.readFileSync(root + '/shell/plugins/agents/Panel.qml', 'utf8')
const panelRoot = { nowMs: Date.now() }
const start = source.indexOf('function windowIsLong')
const end = source.indexOf('function resetMsFor')
assert(start > 0 && end > start && source.slice(start, end).includes('function bindingWindow'), 'agents panel exposes the window that lights the bar')
eval(source.slice(start, end).replaceAll('root.nowMs', 'panelRoot.nowMs'))

function binding(limits) {
  const window = bindingWindow({ limits })
  return window ? { title: window.title, percent: window.percent } : null
}

// The same 90% comparison the bar icon uses.
function alarms(providers) {
  return providers.some(provider => {
    const window = bindingWindow(provider)
    return !!(window && window.percent >= 0.9)
  })
}

const cursorLive = { limits: [
  { label: 'Included total', title: 'Monthly', percent: 0.2685709677419355, resetsAt: '2099-01-01T00:00:00Z' },
  { label: 'Auto models', title: 'Auto models Monthly', percent: 0.24416666666666667, resetsAt: '2099-01-01T00:00:00Z' },
  { label: 'Named models', title: 'Named models Monthly', percent: 1, resetsAt: '2099-01-01T00:00:00Z' }
]}
const claudeOut = { limits: [{ label: 'Session (5-hour)', percent: 1, resetsAt: '2099-01-01T00:00:00Z' }] }

assertDeepEqual(binding(cursorLive.limits), { title: 'Monthly', percent: 0.2685709677419355 }, 'Cursor named models at 100% leave the included total binding')
assertEqual(alarms([cursorLive]), false, 'Cursor named models at 100% do not light the bar')
assertEqual(limitWindows(cursorLive).some(window => Object.prototype.hasOwnProperty.call(window, 'supplementary')), false, 'a record without the flag does not grow a supplementary field')

assertDeepEqual(binding(claudeOut.limits), { title: 'Session', percent: 1 }, 'a full Claude session is the window that binds')
assertEqual(alarms([claudeOut, cursorLive]), true, 'a full Claude session still lights the bar')
assertEqual(alarms([{ limits: [{ label: 'Session (5-hour)', percent: 0.9, resetsAt: '' }] }]), true, 'a session at 90% still lights the bar')
assertEqual(alarms([{ limits: [{ label: 'Session (5-hour)', percent: 0.899, resetsAt: '' }] }]), false, 'a session under 90% leaves the bar alone')
assertDeepEqual(
  binding([{ label: 'Session (5-hour)', percent: 1, resetsAt: '2000-01-01T00:00:00Z' }]),
  { title: 'Session', percent: 0 },
  'an elapsed session reads as reset'
)
assertEqual(alarms([{ limits: [{ label: 'Session (5-hour)', percent: 1, resetsAt: '2000-01-01T00:00:00Z' }] }]), false, 'an elapsed session does not keep the bar lit')

assertDeepEqual(binding([
  { label: 'Named models', title: 'Named models Monthly', percent: 1, resetsAt: '' },
  { label: 'Session (5-hour)', percent: 1, resetsAt: '2099-01-01T00:00:00Z' }
]), { title: 'Session', percent: 1 }, 'a full session still binds when a named-model breakdown is listed first')

const flagged = [
  { label: 'Included total', title: 'Monthly', percent: 0.2686, resetsAt: '' },
  { label: 'Auto models', title: 'Composer', percent: 1, resetsAt: '', supplementary: true },
  { label: 'Named models', title: 'API models', percent: 1, resetsAt: '', supplementary: true }
]
assertDeepEqual(binding(flagged), { title: 'Monthly', percent: 0.2686 }, 'a flagged breakdown stays off the bar under any title')
assertEqual(limitWindows({ limits: flagged })[0].supplementary, undefined, 'the included total does not pick up the flag')
assertEqual(limitWindows({ limits: flagged })[1].supplementary, true, 'a breakdown keeps its flag')

assertDeepEqual(binding([
  { label: 'Included total', title: 'Monthly', percent: 0.1876, resetsAt: '' },
  { label: 'Auto models', title: 'Auto models Monthly', percent: 0.1181, resetsAt: '' },
  { label: 'Named models', title: 'Named models Monthly', percent: 1, resetsAt: '' },
  { label: 'On-demand $9.51 / $10.00', title: 'On-demand $9.51 / $10.00 Monthly', percent: 0.951, resetsAt: '' }
]), { title: 'On-demand $9.51 / $10.00 Monthly', percent: 0.951 }, 'an on-demand dollar cap still binds when named models are full')

assertDeepEqual(binding([
  { label: 'Weekly (7-day)', percent: 0.25, resetsAt: '' },
  { label: 'Fable Weekly', title: 'Fable Weekly', percent: 0.95, resetsAt: '' }
]), { title: 'Fable Weekly', percent: 0.95 }, 'a model allowance of its own still binds')

assertDeepEqual(binding([
  { label: 'Weekly', title: 'Weekly', percent: 0.1, resetsAt: '' },
  { label: 'Claude/GPT Weekly', title: 'Claude/GPT Weekly', percent: 0.95, resetsAt: '' }
]), { title: 'Claude/GPT Weekly', percent: 0.95 }, 'an Antigravity model bucket still binds')

assertDeepEqual(binding([
  { label: 'Spend limit', title: 'Spend limit', percent: 0.95, resetsAt: '' }
]), { title: 'Spend limit', percent: 0.95 }, 'a Codex spend limit still binds')

assertDeepEqual(binding([
  { label: 'Weekly', title: 'Weekly', percent: 0.2, resetsAt: '' },
  { label: 'Bonus', title: 'Bonus pool', percent: 1, resetsAt: '', supplementary: true }
]), { title: 'Weekly', percent: 0.2 }, 'a supplementary flag keeps a breakdown off the bar')
assertEqual(alarms([{ limits: [
  { label: 'Weekly', title: 'Weekly', percent: 0.2, resetsAt: '' },
  { label: 'Bonus', title: 'Bonus pool', percent: 1, resetsAt: '', supplementary: true }
] }]), false, 'a supplementary breakdown at 100% does not light the bar')

assertDeepEqual(
  displayWindows({ limits: [
    { label: 'Included total', title: 'Monthly', percent: 0.27, resetsAt: '' },
    { label: 'Named models', title: 'Named models Monthly', percent: 1, resetsAt: '', supplementary: true }
  ] }),
  [{ title: 'Monthly', percent: 0.27, resetAt: '', scoped: [{ title: 'Named models', percent: 1, resetAt: '' }] }],
  'a named-model breakdown still draws as a tick on the included row'
)
JS
