#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

run_node_test <<'JS'
const fs = require('fs')

const systemRules = fs.readFileSync(path.join(root, 'default/hypr/apps/system.lua'), 'utf8')

// Verify presence of RapidRAW in app class list and folder selection titles
assert(systemRules.includes('RapidRAW'), 'system window rules include RapidRAW')
assert(/Select \[Ff\]older/.test(systemRules), 'system window rules include Select Folder matcher')

// Extract the matcher regexes and floating action tags from system.lua
const classRuleMatch = /o\.window\(\s*\{\s*class = "([^"]+)",\s*title = "([^"]+)",?\s*\},?\s*\{\s*tag = "([^"]+)"\s*\}\s*\)/.exec(systemRules)
assert(classRuleMatch, 'found class + title window rule in system.lua')
assertEqual(classRuleMatch[3], '+floating-window', 'class + title picker rule assigns +floating-window tag')
const appClassRegex = new RegExp(classRuleMatch[1])
const appTitleRegex = new RegExp(classRuleMatch[2])

const genericTitleMatch = /o\.window\(\s*\{\s*title = "([^"]+)",?\s*\},?\s*\{\s*tag = "([^"]+)"\s*\}\s*\)/.exec(systemRules)
assert(genericTitleMatch, 'found generic title window rule in system.lua')
assertEqual(genericTitleMatch[2], '+floating-window', 'generic title picker rule assigns +floating-window tag')
const genericTitleRegex = new RegExp(genericTitleMatch[1])

// Verify floating-window tag configures floating geometry
assert(/o\.window\(\{\s*tag = "floating-window"\s*\},\s*\{\s*float = true\s*\}\)/.test(systemRules), 'floating-window tag enables float')
assert(/o\.window\(\{\s*tag = "floating-window"\s*\},\s*\{\s*center = true\s*\}\)/.test(systemRules), 'floating-window tag centers windows')

function appliedTags(appClass, windowTitle) {
  const tags = []
  if (appClass === 'xdg-desktop-portal-gtk') tags.push('+floating-window')
  if (appClassRegex.test(appClass) && appTitleRegex.test(windowTitle)) tags.push(classRuleMatch[3])
  if (genericTitleRegex.test(windowTitle)) tags.push(genericTitleMatch[2])
  return tags
}

function matchesFloatingPicker(appClass, windowTitle) {
  return appliedTags(appClass, windowTitle).includes('+floating-window')
}

// RapidRAW portal dialogs
assert(matchesFloatingPicker('RapidRAW', 'Select Folder'), 'RapidRAW Select Folder floats')
assert(matchesFloatingPicker('RapidRAW', 'Select folder'), 'RapidRAW lowercase select folder floats')
assert(matchesFloatingPicker('RapidRAW', 'Open Folder'), 'RapidRAW Open Folder floats')
assert(matchesFloatingPicker('RapidRAW', 'Open File'), 'RapidRAW Open File floats')
assert(matchesFloatingPicker('RapidRAW', 'Save As'), 'RapidRAW Save As floats')

// Main RapidRAW window should NOT float
assert(!matchesFloatingPicker('RapidRAW', 'RapidRAW'), 'RapidRAW main editor window does not match picker rule')
assert(!matchesFloatingPicker('RapidRAW', 'IMG_0001.CR3 - RapidRAW'), 'RapidRAW image editor window does not match picker rule')

// Sublime Text, DesktopEditors, Nautilus dialogs
assert(matchesFloatingPicker('sublime_text', 'Open File'), 'Sublime Text Open File floats')
assert(matchesFloatingPicker('sublime_text', 'Open Folder'), 'Sublime Text Open Folder floats')
assert(matchesFloatingPicker('DesktopEditors', 'Save As'), 'DesktopEditors Save As floats')
assert(matchesFloatingPicker('org.gnome.Nautilus', 'Open Folder'), 'Nautilus Open Folder floats')

// Generic folder pickers from unknown apps inheriting class
assert(matchesFloatingPicker('unknown_app', 'Select Folder'), 'Generic Select Folder floats')
assert(matchesFloatingPicker('some_editor', 'Select a Folder'), 'Generic Select a Folder floats')
assert(matchesFloatingPicker('another_tool', 'Open Folder'), 'Generic Open Folder floats')

// Unrelated windows from other apps should NOT float
assert(!matchesFloatingPicker('google-chrome', 'Select Folder in VSCode - Google Chrome'), 'Browser tab does not float')
assert(!matchesFloatingPicker('sublime_text', 'system.lua — Omarchy'), 'Sublime Text editor window does not float')
JS
