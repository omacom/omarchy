#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

run_node_test <<'JS'
const fs = require('fs')
const panelSource = fs.readFileSync(root + '/shell/plugins/agents/Panel.qml', 'utf8')

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
assert(/opacity: stale \? 0\.5 : 1\.0/.test(panelSource) && /"As of " \+ root\.formatDuration/.test(panelSource), 'limits kept from an earlier check dim and say how old they are on hover')
assert(/onPickingChanged: resetKeys\(\)/.test(panelSource), 'the cursor starts over when the agent list comes or goes')
assert(!/t === "a" \|\| t === "A"/.test(panelSource), 'adding an account has no hotkey; the + is the way in')
assert(/if \(!accounts\[a\]\.active\) \{/.test(panelSource) && /if \(row\.length > 0\) rows\.push\(row\)/.test(panelSource), 'the active account with nothing to fix is not a keyboard stop')
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
